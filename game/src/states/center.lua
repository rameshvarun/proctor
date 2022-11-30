local Center = GameScene:addState('Center')


function Center:draw()
  self.playerPage:draw()
  GameScene.draw(self)
end

local rightArrow = love.graphics.newImage('assets/ui/keyboard-arrow-right.png')
local leftArrow = love.graphics.newImage('assets/ui/keyboard-arrow-left.png')
local enter = love.graphics.newImage('assets/ui/keyboard-enter.png')
local space = love.graphics.newImage('assets/ui/keyboard-space.png')

local orientations = require ("assets.graphics.centerrightorientations")
function Center:enteredState()
  local orientation = orientations[1]
  local f, up = orientation.forward, orientation.up
  love.audio.setOrientation(f[1], f[2], f[3], up[1], up[2], up[3])
end

function Center:uiDraw()
  GameScene.uiDraw(self)

  if self.testEnded then return end

  Color(1, 1, 1, 0.3):use()
  love.graphics.setFont(self.uiFont)

  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()

  local mw = love.graphics.getWidth() / 2
  local mh = love.graphics.getHeight() / 2

  love.graphics.printf("HOLD", sw - rightArrow:getWidth() - 40, 10, rightArrow:getWidth() + 40, "center")
  love.graphics.draw(rightArrow, sw - rightArrow:getWidth() - 20, 30)
  love.graphics.printf("LOOK RIGHT", sw - rightArrow:getWidth() - 40, rightArrow:getHeight() + 30, rightArrow:getWidth() + 40, "center")

  love.graphics.printf("HOLD", 0, 10, leftArrow:getWidth() + 40, "center")
  love.graphics.draw(leftArrow, 20, 30)
  love.graphics.printf("LOOK LEFT", 0, leftArrow:getHeight() + 30, leftArrow:getWidth() + 40, "center")

  love.graphics.draw(enter, sw - enter:getWidth() - 30, sh - enter:getHeight() - 45 - 30)
  love.graphics.printf("SUBMIT TEST", sw - enter:getWidth() - 30, sh - 40 - 30, enter:getWidth(), "center")

  love.graphics.draw(space, mw - space:getWidth()/2, sh * 0.9 - space:getHeight())
  love.graphics.printf("CHANGE ANSWER", mw - space:getWidth()/2 - 30, sh * 0.9 - 10, space:getWidth() + 60, "center")

  self:pageTurnUI(self.playerPage)
end

function Center:videoDraw()
  GameScene.videoDraw(self)
  love.graphics.draw(self.center)
  self.playerPage:videoDraw()
end

function Center:update(dt)
  GameScene.update(self, dt)
  if self.controls.lookRight:isDown() then
    if (WALK_GRAPH:getNodeData(WALK_GRAPH.rightScare) - self.robot.pos):len() < SCARE_DISTANCE then
      self:gotoState('CenterToRightDeath')
    else
      self:gotoState('CenterToRight')
    end
  elseif self.controls.lookLeft:isDown() then
    if (WALK_GRAPH:getNodeData(WALK_GRAPH.leftScare) - self.robot.pos):len() < SCARE_DISTANCE then
      self:gotoState('CenterToLeftDeath')
    else
      self:gotoState('CenterToLeft')
    end
  end

  if self.controls.cycleAnswer:pressed() then
    self.playerPage:cycleAnswer()
  end

  if self.controls.submit:pressed() then
    self:endTest()
  end

  if self.playerPage.page_index < self.playerPage:numPages() and self.controls.nextPage:pressed() then
    self.playerPage:nextPage()
  end

  if self.playerPage.page_index > 1 and self.controls.prevPage:pressed() then
    self.playerPage:prevPage()
  end
end
