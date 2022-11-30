local Right = GameScene:addState('Right')

local orientations = require ("assets.graphics.centerrightorientations")
function Right:enteredState()
  local orientation = orientations[#orientations]
  local f, up = orientation.forward, orientation.up
  love.audio.setOrientation(f[1], f[2], f[3], up[1], up[2], up[3])

  self.alertTimer = lume.random(1, 3)
end

function Right:draw()
  self.rightPage:draw()
  GameScene.draw(self)
end

function Right:videoDraw()
  GameScene.videoDraw(self)
  love.graphics.draw(self.right)
  self.rightPage:videoDraw()
end

function Right:update(dt)
  GameScene.update(self, dt)

  self.alertTimer = self.alertTimer - dt
  if self.alertTimer < 0 then
    self.robot:alert(WALK_GRAPH.rightScare)
  end

  local scare_pos = WALK_GRAPH:getNodeData(WALK_GRAPH.rightScare)
  if (scare_pos - self.robot.pos):len() < SCARE_DISTANCE then
    if self.robot.pos.y > scare_pos.y then
      self:gotoState('DeathSlide', self.right, self.slideFromRight)
    else
      self:gotoState('DeathSlide', self.right, self.slideFromLeft)
    end
  else
    if not self.controls.lookRight:isDown() then
      self:gotoState('RightToCenter')
    end
  end

  local scare_pos = WALK_GRAPH:getNodeData(WALK_GRAPH.leftScare)
  if (scare_pos - self.robot.pos):len() < SCARE_DISTANCE then
    self:gotoState('RightToLeftDeath')
  end

  if self.rightPage.page_index < self.rightPage:numPages() and self.controls.nextPage:pressed() then
    self.rightPage:nextPage()
  end

  if self.rightPage.page_index > 1 and self.controls.prevPage:pressed() then
    self.rightPage:prevPage()
  end
end

function Right:uiDraw()
  GameScene.uiDraw(self)

  Color(1, 1, 1, 0.5):use()
  love.graphics.setFont(self.uiFont)
  self:pageTurnUI(self.rightPage)
end

local q = love.graphics.newImage('assets/ui/keyboard-q.png')
local e = love.graphics.newImage('assets/ui/keyboard-e.png')
function Right:pageTurnUI(page)
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()

  if page.page_index > 1 then
    love.graphics.draw(q, sw * 0.25 - q:getWidth()/2, sh * 0.4 - q:getHeight() / 2)
    love.graphics.printf("PREV PAGE", sw * 0.25 - 30, sh * 0.4 + 50, 60, "center")
  end

  if page.page_index < page:numPages() then
    love.graphics.draw(e, sw * 0.55 - e:getWidth()/2, sh * 0.4 - e:getHeight() / 2)
    love.graphics.printf("NEXT PAGE", sw * 0.55 - 30, sh * 0.4 + 50, 60, "center")
  end
end
