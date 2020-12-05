local module = {}

module.name = 'cmus'
module.version = '1.0.0'
module.author = 'Jerko Steiner <jeremija>'
module.license = 'MIT'

module.alertId = nil

function module:alert (text)
  hs.alert.closeSpecific(self.alertId, 0)
  self.alertId = hs.alert.show(text)
end

function module:displaySong ()
  local f = io.popen("/usr/local/bin/cmus-remote -Q | head -n 4 | sed \"s|file $HOME/||g\"")
  local lines = {}
  local count = 0
  for line in f:lines() do
    count = count + 1
    table.insert(lines, line)
  end

  local status = lines[1] or 'status stopped'
  if status == 'status stopped' then
    self:alert('status stopped')
    return
  end
  local status = status:gsub('^status ', ''):gsub('^%l', string.upper)
  local file = lines[2] or ''
  local file = file:gsub('/', '\n')
  local duration = string.match(lines[3], '%d+') or 1
  local position = string.match(lines[4], '%d+') or 0
  local blocks = 30
  local percent = math.floor(blocks * position / duration + 0.5)
  local progress = string.rep('=', percent)
  local left = string.rep(' ', blocks - percent)
  local fDuration = os.date('!%M:%S', duration)
  local fPosition = os.date('!%M:%S', position)
  local alertText = string.format('%s\n%s\n[%s>%s] %s / %s',
    status, file, progress, left, fPosition, fDuration)
  self:alert(alertText)
end

local function cmus (action)
  return function ()
    os.execute("/usr/local/bin/cmus-remote " .. action)
    module:displaySong()
  end
end

local actions = {}
actions.prev = cmus('--prev')
actions.pause = cmus('--pause')
actions.play = cmus('--play')
actions.stop = cmus('--stop')
actions.next = cmus('--next')
actions.seekBackward = cmus('--seek -5s')
actions.seekForward = cmus('--seek +5s')

module.actions = actions

function module.bindHotKeys (mapping)
  for k, v in pairs(mapping) do
    hs.hotkey.bindSpec(v, actions[k])
  end
end

return module
