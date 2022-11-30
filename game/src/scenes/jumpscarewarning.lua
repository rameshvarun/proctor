local JumpScareWarning = class('JumpScareWarning', Scene)

local warning = love.graphics.newImage('assets/ui/exclamation-triangle.png')
local warningFont = love.graphics.newFont("assets/ui/roboto.ttf", 30)

local HeadphoneRecomentation = require "src.scenes.headphonerecommendation"
local BlackFader = require "src.blackfader"

function JumpScareWarning:initialize()
  Scene.initialize(self)
  self.blackFader = BlackFader()
  self.blackFader:fadeOut(1)

  self.fadingOut = false


  self.timer:after(3, function() self:next() end)
end

function JumpScareWarning:update(dt)
  Scene.update(self, dt)
  self.blackFader:update(dt)
end

function JumpScareWarning:next()
  if not self.fadingOut then
    self.fadingOut = true

    self.blackFader:fadeIn(1)
    self.timer:after(1, function()
      Scene.switchTo(HeadphoneRecomentation())
    end)
  end
end

function JumpScareWarning:keypressed() self:next() end
function JumpScareWarning:mousepressed() self:next() end

function JumpScareWarning:draw()
  Scene.draw(self)

  Color.WHITE:use()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local mw, mh = sw / 2, sh / 2
  love.graphics.draw(warning, mw - warning:getWidth() / 2, mh - warning:getHeight())

  love.graphics.setFont(warningFont)
  love.graphics.printf("THIS GAME CONTAINS JUMPSCARES", 100, mh + 25, sw - 200, "center")

  self.blackFader:draw()
end

return JumpScareWarning
