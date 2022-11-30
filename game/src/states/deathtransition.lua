local Retry = require 'src.scenes.retry'
STATIC_DURATION = 4

function DeathTransitionState(stateName, videoFile)
  local TransitionState = GameScene:addState(stateName)
  local transitionVideo = love.graphics.newVideo('assets/graphics/' .. videoFile, {audio = false})

  function TransitionState:enteredState()
    self.dead = true
    self.robot:gotoState('Death')
    transitionVideo:play()
    self.scare:play()
    self.timer:after(1, function()
      self.staticFader:fadeIn(1)
    end)

    self.timer:after(STATIC_DURATION, function()
      self.scare:stop()
      GameScene.switchTo(Retry())

      transitionVideo:release()
      transitionVideo = love.graphics.newVideo('assets/graphics/' .. videoFile, {audio = false})
    end)
  end

  function TransitionState:uiDraw() end

  function TransitionState:videoDraw()
    GameScene.videoDraw(self)
    love.graphics.draw(transitionVideo)
  end
end

DeathTransitionState("CenterToRightDeath", "center-right-death.ogv")
DeathTransitionState("CenterToLeftDeath", "center-left-death.ogv")

DeathTransitionState("FailDeath", "fail-death.ogv")

DeathTransitionState("RightToLeftDeath", "right-left-death.ogv")
DeathTransitionState("LeftToRightDeath", "left-right-death.ogv")
