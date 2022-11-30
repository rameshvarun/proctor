local Left = GameScene:addState('Left')

local orientations = require ("assets.graphics.centerleftorientations")
function Left:enteredState()
  local orientation = orientations[#orientations]
  local f, up = orientation.forward, orientation.up
  love.audio.setOrientation(f[1], f[2], f[3], up[1], up[2], up[3])

  self.alertTimer = lume.random(1, 3)
end

function Left:draw()
  self.leftPage:draw()
  GameScene.draw(self)
end

function Left:videoDraw()
  GameScene.videoDraw(self)
  love.graphics.draw(self.left)
  self.leftPage:videoDraw()
end

function Left:update(dt)
  GameScene.update(self, dt)

  self.alertTimer = self.alertTimer - dt
  if self.alertTimer < 0 then
    self.robot:alert(WALK_GRAPH.leftScare)
  end

  local scare_pos = WALK_GRAPH:getNodeData(WALK_GRAPH.leftScare)
  if (scare_pos - self.robot.pos):len() < SCARE_DISTANCE then
    if self.robot.pos.y > scare_pos.y then
      self:gotoState('DeathSlide', self.left, self.slideFromLeft)
    else
      self:gotoState('DeathSlide', self.left, self.slideFromRight)
    end
  else
    if not self.controls.lookLeft:isDown() then
      self:gotoState('LeftToCenter')
    end
  end

  local scare_pos = WALK_GRAPH:getNodeData(WALK_GRAPH.rightScare)
  if (scare_pos - self.robot.pos):len() < SCARE_DISTANCE then
    self:gotoState('LeftToRightDeath')
  end

  if self.leftPage.page_index < self.leftPage:numPages() and self.controls.nextPage:pressed() then
    self.leftPage:nextPage()
  end

  if self.leftPage.page_index > 1 and self.controls.prevPage:pressed() then
    self.leftPage:prevPage()
  end
end

function Left:uiDraw()
  GameScene.uiDraw(self)

  Color(1, 1, 1, 0.5):use()
  love.graphics.setFont(self.uiFont)
  self:pageTurnUI(self.leftPage)
end


local q = love.graphics.newImage('assets/ui/keyboard-q.png')
local e = love.graphics.newImage('assets/ui/keyboard-e.png')
function Left:pageTurnUI(page)
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()

  if page.page_index > 1 then
    love.graphics.draw(q, sw * 0.4 - q:getWidth()/2, sh * 0.5 - q:getHeight() / 2)
    love.graphics.printf("PREV PAGE", sw * 0.4 - 30, sh * 0.5 + 50, 60, "center")
  end

  if page.page_index < page:numPages() then
    love.graphics.draw(e, sw * 0.7 - e:getWidth()/2, sh * 0.5 - e:getHeight() / 2)
    love.graphics.printf("NEXT PAGE", sw * 0.7 - 30, sh * 0.5 + 50, 60, "center")
  end
end
