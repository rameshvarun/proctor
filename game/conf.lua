function love.conf(t)
  t.identity = "proctor"
  t.version = "11.0"

  t.window.title = "Proctor"
  t.window.resizable = true
  t.window.highdpi = true
  t.window.fullscreentype = "exclusive"

  t.window.icon = 'assets/ui/icon.png'

  t.window.width = 1280
  t.window.height = 720
  t.window.vsync = true

  t.window.minwidth = 100
  t.window.minheight = 100

  t.modules.joystick = false
end
