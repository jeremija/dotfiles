hs.alert.defaultStyle.radius = 2
hs.alert.defaultStyle.textSize = 12
hs.alert.defaultStyle.textFont = 'Monaco'
hs.alert.defaultStyle.strokeColor = { black = 0, alpha = 0 }
hs.alert.defaultStyle.strokeWidth = 0
hs.alert.defaultStyle.textStyle = { paragraphStyle = { alignment = 'center' } }

hs.loadSpoon('capslock')
spoon.capslock.start()

hs.loadSpoon('cmus')
spoon.cmus.bindHotKeys({
  prev = {{"shift", "alt"}, "z"},
  play = {{"shift", "alt"}, "x"},
  pause = {{"shift", "alt"}, "c"},
  stop = {{"shift", "alt"}, "v"},
  next = {{"shift", "alt"}, "b"},
  seekBackward = {{"shift", "alt"}, "3"},
  seekForward = {{"shift", "alt"}, "4"}
})
