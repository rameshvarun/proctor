local HeadphoneRecomentation = class('HeadphoneRecomentation', Scene)
local MainMenu = require 'src.scenes.mainmenu'

local headphones = love.graphics.newImage('assets/ui/headphones.png')
local warningFont = love.graphics.newFont("assets/ui/roboto.ttf", 30)

local BlackFader = require "src.blackfader"

function HeadphoneRecomentation:initialize()
  Scene.initialize(self)

  self.blackFader = BlackFader()
  self.blackFader:fadeOut(1)
  self.fadingOut = false

  self.timer:after(3, function()
      self:next()
    end)
end

function HeadphoneRecomentation:update(dt)
  Scene.update(self, dt)
  self.blackFader:update(dt)
end

function HeadphoneRecomentation:next()
  if not self.fadingOut then
    self.fadingOut = true

    self.blackFader:fadeIn(1)
    self.timer:after(1, function()
      Scene.switchTo(MainMenu())
    end)
  end
end

function HeadphoneRecomentation:keypressed() self:next() end
function HeadphoneRecomentation:mousepressed() self:next() end

function HeadphoneRecomentation:draw()
  Color.WHITE:use()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local mw, mh = sw / 2, sh / 2
  love.graphics.draw(headphones, mw - headphones:getWidth() / 2, mh - headphones:getHeight())

  love.graphics.setFont(warningFont)
  love.graphics.printf("THIS GAME USES 3D SOUND\nHEADPHONES ARE RECOMMENDED", 100, mh + 25, sw - 200, "center")

  self.blackFader:draw()
end

return HeadphoneRecomentation
