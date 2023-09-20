local thr = require'thread'
local utils = require'nvimgdb.utils'
local nvimgdb = require'nvimgdb'

local E = {}

E.common_timeout = (vim.env.GITHUB_WORKFLOW ~= nil or utils.is_windows) and 10000 or 5000

---Feed keys to Neovim
---@param keys string @keystrokes
---@param timeout? number @delay in milliseconds after the input
function E.feed(keys, timeout)
  vim.api.nvim_input(keys)
  thr.y(timeout == nil and 200 or timeout)
end

---Execute a command
---@param cmd string neovim command
function E.exe(cmd)
  thr.y(0, vim.cmd(cmd))
end

function E.get_time_ms()
  return vim.loop.hrtime() * 1e-6
end

---Wait until the query passes the check
---@param query function
---@param check function
---@param timeout_ms? number timeout in milliseconds (E.common_timeout if omitted)
---@return boolean|any true if the check function returned true, or the result of the query function otherwise
function E.wait_for(query, check, timeout_ms)
  if timeout_ms == nil then
    timeout_ms = E.common_timeout
  end
  local deadline = E.get_time_ms() + timeout_ms
  local value = nil
  while E.get_time_ms() < deadline do
    value = query()
    if check(value) then
      return true
    end
    thr.y(100)
  end
  return value
end

---Wait until the debugger gets into the desired state
---@param state boolean true for paused, false for running
---@param timeout_ms? number Timeout in milliseconds
---@return boolean
function E.wait_state(state, timeout_ms)
  if timeout_ms == nil then
    timeout_ms = 5000
  end
  local query = function()
    local parser = nvimgdb.here.parser
    return type(parser) == 'table' and parser:is_paused()
  end
  return E.wait_for(query, function(is_paused) return is_paused == state end, timeout_ms)
end

---Wait until the debugger doesn't have new output
---@param timeout_ms? number Timeout in milliseconds
---@return boolean
function E.wait_is_still(timeout_ms)
  local query = function()
    local parser = nvimgdb.here.parser
    return type(parser) == 'table' and parser:is_still()
  end
  return E.wait_for(query, function(is_still) return is_still end, timeout_ms)
end

---Wait until the debugger gets into the paused state
---@param timeout_ms? number Timeout in milliseconds
---@return boolean
function E.wait_paused(timeout_ms)
  return E.wait_is_still(timeout_ms) and E.wait_state(true, timeout_ms)
end

---Wait until the debugger gets into the running state
---@param timeout_ms? number Timeout in milliseconds
---@return boolean
function E.wait_running(timeout_ms)
  return E.wait_state(false, timeout_ms)
end

---Get buffers satisfying the predicate
---@param pred function(buf: integer): boolean condition for a buffer to be reported
---@return table<integer, string> map of buffer number to name
function E.get_buffers_impl(pred)
  local buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if pred(buf) then
      buffers[buf] = vim.api.nvim_buf_get_name(buf)
    end
  end
  return buffers
end

---Get all the loaded buffers
---@return table<integer, string> map of buffer number to name
function E.get_buffers()
  -- Determine how many terminal buffers are there.
  return E.get_buffers_impl(function(buf)
    return vim.api.nvim_buf_is_loaded(buf)
  end)
end

---Get all the terminal buffers
---@return table<integer, string> map of buffer number to name
function E.get_termbuffers()
  -- Determine how many terminal buffers are there.
  return E.get_buffers_impl(function(buf)
    return vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal'
  end)
end

---@alias BreakpointInfo table<integer, integer[]>  # breakpoint ID -> list of lines
---@alias SignInfo {cur: string, brk: BreakpointInfo}  # information about signs

---Get current signs: current line and breakpoints
---@return SignInfo
function E.get_signs()
  -- Get pointer position and list of breakpoints.
  local ret = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
      local breaks = {}
      for _, bsigns in ipairs(vim.fn.sign_getplaced(buf, {group = "NvimGdb"})) do
        for _, signs in ipairs(bsigns.signs) do
          local sname = signs.name
          if sname == 'GdbCurrentLine' then
            local bname = vim.api.nvim_buf_get_name(buf):match("[^/\\]+$")
            if bname == nil then
              bname = vim.api.nvim_buf_get_name(buf)
            end
            if ret.cur == nil then
              ret.cur = bname .. ':' .. signs.lnum
            else
              if ret.curs == nil then
                ret.curs = {}
              end
              table.insert(ret.curs, bname .. ':' .. signs.lnum)
            end
          end
          if sname:match('^GdbBreakpoint') then
            local num = assert(tonumber(sname:sub(1 + string.len('GdbBreakpoint'))))
            if breaks[num] == nil then
              breaks[num] = {}
            end
            table.insert(breaks[num], signs.lnum)
          end
        end
      end
      if next(breaks) ~= nil then
        ret.brk = breaks
      end
    end
  end
  return ret
end

---Wait until the sign configuration is as expected
---@param expected_signs SignInfo
---@param timeout_ms number?
---@return boolean|SignInfo true if expected_signs realized, actual signs otherwise
function E.wait_signs(expected_signs, timeout_ms)
  local function query()
    return E.get_signs()
  end
  local function is_expected(signs)
    return vim.deep_equal(expected_signs, signs)
  end
  return E.wait_is_still(timeout_ms) and E.wait_for(query, is_expected, timeout_ms)
end

---Wait until cursor in the current window gets to the given line
---@param line integer 1-based line number
---@param timeout_ms? number timeout in milliseconds
---@return true|integer true if successful, the actual line number otherwise
function E.wait_cursor(line, timeout_ms)
  return E.wait_for(
    function() return vim.api.nvim_win_get_cursor(0)[1] end,
    function(row) return row == line end,
    timeout_ms
  )
end

return E
