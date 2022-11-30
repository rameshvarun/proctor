local Intro = class('Intro', Scene)

local intro = love.audio.newSource('assets/sound/robot-intro.ogg', 'static')

function doOnce(thunk)
  local executed = false
  return function()
    if not executed then
      executed = true
      thunk()
    end
  end
end

local sawIntro = false

function Intro:initialize()
  Scene.initialize(self)

  self.started = false
  self.afterAudio = doOnce(function()
    self.timer:after(1, function()
      Scene.switchTo(GameScene())
    end)
  end)
end

function Intro:enter()
  if not sawIntro then
    sawIntro = true
    self.timer:after(1, function()
      intro:play()
      self.started = true
    end)
  else
    self.afterAudio()
  end
end

function Intro:exit()
  intro:stop()
end

function Intro:keypressed(key, scancode, isrepeat)
  if self.loadedTime ~= nil and self.time > self.loadedTime then
    intro:stop()
  end
end

local font = love.graphics.newFont("assets/ui/roboto.ttf", 20)

function Intro:draw()
  Scene.draw(self)
  if self.loadedTime ~= nil and self.time > self.loadedTime and intro:isPlaying() then
    love.graphics.setFont(font)
    love.graphics.printf("Press any key to skip...", 0, 0.8 * love.graphics.getHeight(), love.graphics.getWidth(), "center")
  end
end

function Intro:update(dt)
  Scene.update(self, dt)
  if self.started then
    SLIDE_FROM_LEFT()
    SLIDE_FROM_RIGHT()

    if self.loadedTime == nil then
      self.loadedTime = self.time
    end

    if not intro:isPlaying() then
      self.afterAudio()
    end
  end
end

return Intro
