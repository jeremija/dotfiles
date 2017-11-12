local module = {}

module.debugging = false -- whether to print status updates

local eventtap = require "hs.eventtap"
local event    = eventtap.event
local inspect  = require "hs.inspect"

local keyHandler = function(e)
    local watchFor = {
            h = "left",
            j = "down",
            k = "up",
            l = "right",
            u = "delete",
            i = "forwarddelete"
        }
    local actualKey = e:getCharacters(true)
    local replacement = watchFor[actualKey:lower()]
    if replacement then
        local isDown = e:getType() == event.types.keyDown
        local flags  = {}
        for k, v in pairs(e:getFlags()) do
            if v and k ~= "fn" then -- fn will be down because that's our "wrapper", so ignore it
                table.insert(flags, k)
            end
        end
        if module.debugging then print("viKeys: " .. replacement, inspect(flags), isDown) end
        local replacementEvent = event.newKeyEvent(flags, replacement, isDown)
        if isDown then
            -- allow for auto-repeat
            replacementEvent:setProperty(event.properties.keyboardEventAutorepeat, e:getProperty(event.properties.keyboardEventAutorepeat))
        end
        return true, { replacementEvent }
    else
        return false -- do nothing to the event, just pass it along
    end
end

local modifierHandler = function(e)
    local flags = e:getFlags()
    local onlyControlPressed = false
    for k, v in pairs(flags) do
        onlyControlPressed = v and k == "fn"
        if not onlyControlPressed then break end
    end
    -- you must tap and hold fn by itself to turn this on
    if onlyControlPressed and not module.keyListener then
        if module.debugging then print("viKeys: keyhandler on") end
        module.keyListener = eventtap.new({ event.types.keyDown, event.types.keyUp }, keyHandler):start()
    -- however, adding additional modifiers afterwards is ok... its only when fn isn't down that we switch back off
    elseif not flags.fn and module.keyListener then
        if module.debugging then print("viKeys: keyhandler off") end
        module.keyListener:stop()
        module.keyListener = nil
    end
    return false
end

module.modifierListener = eventtap.new({ event.types.flagsChanged }, modifierHandler)

module.start = function()
    module.modifierListener:start()
end

module.stop = function()
    if module.keyListener then
        module.keyListener:stop()
        module.keyListener = nil
    end
    module.modifierListener:stop()
end

module.start() -- autostart

function bind (modifiers, char, command)
  hs.hotkey.bind(modifiers, char, function ()
    os.execute(command)
  end)
end

hs.alert.defaultStyle.radius = 2
hs.alert.defaultStyle.textSize = 12
hs.alert.defaultStyle.textFont = 'Monaco'
hs.alert.defaultStyle.strokeColor = { black = 0, alpha = 0 }
hs.alert.defaultStyle.strokeWidth = 0

alertId = nil
function alert (text)
  hs.alert.closeSpecific(alertId)
  alertId = hs.alert.show(text)
end

function displaySong ()
  local f = io.popen("/usr/local/bin/cmus-remote -Q | head -n 4 | sed \"s|file $HOME/||g\"")
  local lines = {}
  local count = 0
  for line in f:lines() do
    count = count + 1
    print(line)
    table.insert(lines, line)
  end

  local status = lines[1] or 'status stopped'
  if status == 'status stopped' then
    alert('status stopped')
    return
  end
  local file = lines[2] or ''
  local duration = string.match(lines[3], '%d+') or 1
  local position = string.match(lines[4], '%d+') or 0
  local blocks = 30
  local percent = math.floor(blocks * position / duration + 0.5)
  local progress = string.rep('=', percent)
  local left = string.rep(' ', blocks - percent)
  alert(status .. '\n' .. file .. '\n' .. '[' .. progress .. '>' .. left .. ']')
end

function cmus (action, callback)
  return function ()
    os.execute("/usr/local/bin/cmus-remote " .. action)
    if callback then
      callback()
    end
  end
end

hs.hotkey.bind({"shift", "alt"}, "z", cmus("--prev", displaySong))
hs.hotkey.bind({"shift", "alt"}, "x", cmus("--play", displaySong))
hs.hotkey.bind({"shift", "alt"}, "c", cmus("--pause", displaySong))
hs.hotkey.bind({"shift", "alt"}, "v", cmus("--stop", displaySong))
hs.hotkey.bind({"shift", "alt"}, "b", cmus("--next", displaySong))
hs.hotkey.bind({"shift", "alt"}, "3", cmus("--seek -5s", displaySong))
hs.hotkey.bind({"shift", "alt"}, "4", cmus("--seek +5s", displaySong))

return module
