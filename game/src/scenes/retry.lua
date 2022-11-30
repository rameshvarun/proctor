local Retry = class('Retry', Scene)

local MainMenu = require "src.scenes.mainmenu"
local gradeFont = love.graphics.newFont("assets/ui/roboto.ttf", 50)

function Retry:initialize()
  Scene.initialize(self)
end

function Retry:enter()
  self.timer:after(3, function()
    GameScene.switchTo(MainMenu())
  end)
end

function Retry:draw()
end

return Retry
