-- Common FSM implementation for the integrated backends.
-- vim: set et ts=2 sw=2:

local log = require'nvimgdb.log'

---@class ParserImpl base parser implementation
---@field protected actions ParserActions parser callbacks
---@field protected running ParserState running state transitions
---@field protected paused ParserState paused state transitions
---@field protected state ParserState current state (either running or paused)
---@field private buffer string debugger output collected so far
---@field private byte_count number monotonously increasing processed byte counter
---@field private parsing_progress number[] ordered byte counters to ensure parsing in the right order
---@field private timers table<userdata, boolean> scheduled timers
---@field private output_is_still boolean true if no new output when parsing is delayed
local ParserImpl = {}
ParserImpl.__index = ParserImpl

---Initialization
---@param actions ParserActions parser callbacks
function ParserImpl:_init(actions)
  log.debug({"ParserImpl:_init"})
  self.actions = actions
  self.running = {}
  self.paused = {}
  -- Current state (either self.running or self.paused)
  self.state = self.paused
  self.buffer = '\n'
  self.byte_count = 1
  self.parsing_progress = {}
  self.timers = {}
  self.output_is_still = false
end

---Destructor
function ParserImpl:cleanup()
  -- Stop the remaining timers
  for timer, _ in pairs(self.timers) do
    timer:stop()
    timer:close()
  end
  self.timers = {}
end

---@alias ParserState ParserTransition[]
---@alias ParserHandler function(m1:string, m2:string): ParserState

---@class ParserTransition
---@field public matcher string pattern to match in the debugger output
---@field public handler ParserHandler

---Add a new transition for a given state.
---@param state ParserState state to add a transition to
---@param matcher string pattern to look for in the buffer
---@param handler ParserHandler handler to invoke when a match is found
function ParserImpl.add_trans(state, matcher, handler)
  log.debug({"ParserImpl.add_trans", state = state, matcher = matcher, handler = handler})
  state[#state + 1] = {matcher = matcher, handler = handler}
end

---Test whether the FSM is in the paused state.
---@return boolean true if parser is in the paused state
function ParserImpl:is_paused()
  log.debug({"ParserImpl:is_paused"})
  return self.state == self.paused
end

---Test whether the FSM is in the running state.
---@return boolean true if parser is in the running state
function ParserImpl:is_running()
  log.debug({"ParserImpl:is_running"})
  return self.state == self.running
end

---@return string current parser state name
function ParserImpl:_get_state_name()
  log.debug({"ParserImpl:_get_state_name"})
  if self.state == self.running then
    return "running"
  end
  if self.state == self.paused then
    return "paused"
  end
  return tostring(self.state)
end

---From paused to running
---@return ParserState new parser state
function ParserImpl:_paused_continue()
  log.info({"ParserImpl:_paused_continue"})
  self.actions:continue_program()
  return self.running
end

---In paused, show the source code
---@param fname string file name
---@param line string line number
---@return ParserState
function ParserImpl:_paused_jump(fname, line)
  log.debug({"ParserImpl:_paused_jump", fname = fname, line = line})
  -- Remove \r in case if path was too long and split by the backend
  local fname1 = fname:gsub("\r", "")
  if fname1 ~= fname then
    log.info({"Removing \\r from the file name", fname1})
    fname = fname1
  end
  log.info("_paused_jump " .. fname .. ":" .. line)
  self.actions:jump_to_source(fname, assert(tonumber(line)))
  return self.paused
end

---To paused
---@return ParserState
function ParserImpl:_paused()
  log.info({"ParserImpl:_paused"})
  return self.paused
end

---Query breakpoints, to paused
---@return ParserState
function ParserImpl:_query_b()
  log.info({"ParserImpl:_query_b"})
  coroutine.resume(coroutine.create(function()
    self.actions:query_breakpoints()
  end))
  return self.paused
end

---Process a line of the debugger output through the FSM.
---It may be hard to guess when the backend started waiting for input,
---therefore parsing should be done asynchronously after a bit of delay.
---@param lines string[] input lines
function ParserImpl:feed(lines)
  log.debug({"ParserImpl:feed", line = lines})
  self.output_is_still = false
  local nl = ''
  for i, line in ipairs(lines) do
    if i == 1 and line == '' then
      nl = '\n'
    end
    -- Filter out control sequences
    line = line:gsub('\x1B[@-_][0-?]*[ -/]*[@-~]', '')

    self.buffer = self.buffer .. nl .. line
    self.byte_count = self.byte_count + #nl + #line
    nl = '\n'
    log.debug({"buffer", self.buffer})
  end
  self.parsing_progress[#self.parsing_progress + 1] = self.byte_count
  self:_delay_parsing(50, self.byte_count)
end

---@param delay_ms number number of milliseconds to wait before parsing
---@param byte_count number byte mark to allow parsing up to when the delay elapses
function ParserImpl:_delay_parsing(delay_ms, byte_count)
  log.debug({"ParserImpl:_delay_parsing", delay_ms = delay_ms, byte_count = byte_count})
  local timer = vim.loop.new_timer()
  self.timers[timer] = true
  timer:start(delay_ms, 0, vim.schedule_wrap(function()
    if self.timers[timer] ~= nil then
      self.timers[timer] = nil
      timer:stop()
      timer:close()
      self:delay_elapsed(byte_count)
    end
  end))
end

---Search through the buffer to find a match for a transition from the current state.
---@param ignore_tail_bytes number number of bytes at the end to ignore (grace period)
---@return boolean true if a match was found, means repeat searching immediately from a new state
function ParserImpl:_search(ignore_tail_bytes)
  log.debug({"ParserImpl:_search", ignore_tail_bytes = ignore_tail_bytes})
  -- If no new lines to parse have been received, mark that the output stabilized
  if ignore_tail_bytes == 0 then
    self.output_is_still = true
  end
  if #self.buffer <= ignore_tail_bytes then
    return false
  end
  -- If there is a matcher matching the line, call its handler.
  for _, mf in ipairs(self.state) do
    local b, e, m1, m2 = self.buffer:find(mf.matcher)
    if b ~= nil then
      if #self.buffer - e < ignore_tail_bytes then
        -- Wait a bit longer, the next timer is pending
        return false
      end
      self.buffer = self.buffer:sub(e + 1)
      log.debug("prev state: " .. self:_get_state_name())
      self.state = mf.handler(self, m1, m2)
      log.info("new state: " .. self:_get_state_name())
      return true
    end
  end
  return false
end

---Grace period elapsed, can search for a transition from the current state.
---@param byte_count number byte mark up to which can search
function ParserImpl:delay_elapsed(byte_count)
  log.debug({"ParserImpl:delay_elapsed", byte_count = byte_count})
  if self.parsing_progress[1] ~= byte_count then
    -- Another parsing is already in progress, return to this mark later
    self:_delay_parsing(1, byte_count)
    return
  end
  -- Detect whether new input has been received before the previous
  -- delay elapsed.
  local ignore_tail_bytes = self.byte_count - byte_count
  while self:_search(ignore_tail_bytes) do
  end
  -- Pop the current mark allowing parsing the next chunk
  table.remove(self.parsing_progress, 1)
end

---Return true if the output has paused for a while
---@return boolean true if no new output to parse during the parser delay
function ParserImpl:is_still()
  return self.output_is_still
end

return ParserImpl
