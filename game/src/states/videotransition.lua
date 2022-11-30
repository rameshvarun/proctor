function VideoTransitionState(stateName, nextState, videoFile, cameraOrientations)
  local TransitionState = GameScene:addState(stateName)
  local transitionVideo = love.graphics.newVideo('assets/graphics/' .. videoFile, {audio = false})

  function TransitionState:enteredState()
    transitionVideo:play()
  end

  function TransitionState:videoDraw()
    GameScene.videoDraw(self)
    love.graphics.draw(transitionVideo)
  end

  function TransitionState:update(dt)
    GameScene.update(self, dt)

    if cameraOrientations then
      local frame = math.floor(transitionVideo:tell() * 60) + 1
      frame = lume.clamp(frame, 1, #cameraOrientations)
      local orientation = cameraOrientations[frame]
      local f, up = orientation.forward, orientation.up
      love.audio.setOrientation(f[1], f[2], f[3], up[1], up[2], up[3])
    end

    if not transitionVideo:isPlaying() then
      self:gotoState(nextState)
      transitionVideo:release()
      transitionVideo = love.graphics.newVideo('assets/graphics/' .. videoFile, {audio = false})
    end
  end
end

local function reverse(orientations)
  local result = {}
  for _, elem in ipairs(orientations) do
    table.insert(result, 1, elem)
  end
  return result
end

VideoTransitionState('CenterToRight', "Right", 'center-right.ogv', require ("assets.graphics.centerrightorientations"))
VideoTransitionState('RightToCenter', "Center", 'right-center.ogv', reverse(require ("assets.graphics.centerrightorientations")))

VideoTransitionState('CenterToLeft', "Left", 'center-left.ogv', require ("assets.graphics.centerleftorientations"))
VideoTransitionState('LeftToCenter', "Center", 'left-center.ogv', reverse(require ("assets.graphics.centerleftorientations")))
