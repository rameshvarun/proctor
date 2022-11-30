local Retry = require 'src.scenes.retry'

local DeathSlideState = GameScene:addState('DeathSlide')

function DeathSlideState:enteredState(background, overlay)
  self.dead = true
  self.background = background
  self.robot:gotoState('Death')
  self.scare:play()

  self.timer:after(0.75, function()
    self.staticFader:fadeIn(1)
  end)

  self.timer:after(STATIC_DURATION, function()
    self.scare:stop()
    GameScene.switchTo(Retry())
  end)

  self.overlay = overlay
  self.overlay:restart()
end

function DeathSlideState:uiDraw() end

function DeathSlideState:update(dt)
  GameScene.update(self, dt)
  self.overlay:update(dt)
end

function DeathSlideState:videoDraw()
  GameScene.videoDraw(self)
  love.graphics.draw(self.background)
  self.overlay:draw()
end
