local Grade = class('Grade', Scene)
local tablex = require('pl.tablex')

local gradeFont = love.graphics.newFont("assets/ui/roboto.ttf", 50)
local outro = love.audio.newSource('assets/sound/outro.mp3', 'static')

function Grade:initialize()
  Scene.initialize(self)
  self.afterAudio = doOnce(function()
    local MainMenu = require 'src.scenes.mainmenu'
    self.timer:after(2, function()
      Scene.switchTo(MainMenu())
    end)
  end)
end

function Grade:enter()
  self.timer:after(2, function()
    outro:play()
    self.started = true
  end)
end

function Grade:draw()
  Color.WHITE:use()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local mw, mh = sw / 2, sh / 2

  love.graphics.setFont(gradeFont)
  love.graphics.printf("GRADE: A+", 100, mh - 25, sw - 200, "center")
end

function Grade:update(dt)
  Scene.update(self, dt)
  if self.started and not outro:isPlaying() then
    self.afterAudio()
  end
end

return Grade
