local MainMenu = class('MainMenu', Scene)

local Intro = require 'src.scenes.intro'
local Credits = require 'src.scenes.credits'

local STATIC_SHADER = love.graphics.newShader('src/shader/static.frag', 'src/shader/static.vert')

local background = love.graphics.newImage("assets/graphics/mainmenu.png")

local MAXIMUM_SIZE = vector(1920, 1080)

local startGameAction = { name = 'Start Game', action = function()
  Scene.switchTo(Intro())
end}
local toggleFullscreenAction = { name = 'Toggle Fullscreen', action = function()
  if love.window.getFullscreen() then
    _, _, flags = love.window.getMode()
    flags.fullscreen = false
    love.window.setMode(1280, 720, flags)
  else
    _, _, flags = love.window.getMode()
    flags.fullscreen = true

    modes = love.window.getFullscreenModes()
    table.sort(modes, function(a, b) return a.width*a.height < b.width*b.height end)

    local best_mode = modes[1]
    for i, mode in ipairs(modes) do
      if mode.width <= MAXIMUM_SIZE.x and mode.height <= MAXIMUM_SIZE.y then
        best_mode = mode
      end
    end

    log.debug("Best Mode", inspect(best_mode))
    love.window.setMode(best_mode.width, best_mode.height, flags)
  end
end}

local creditsAction = { name = 'Credits', action = function()
  Scene.switchTo(Credits())
end}

local quitAction = { name = 'Quit', action = function()
  love.event.quit()
end}

local options = {
  startGameAction,
  toggleFullscreenAction,
  creditsAction,
  quitAction
}

if WEB then
  options = {
    startGameAction,
    creditsAction
  }
end

local MENU_AMBIENCE = love.audio.newSource('assets/sound/ambience.mp3', 'static')

function MainMenu:initialize()
  Scene.initialize(self)

  self.ambience = MENU_AMBIENCE
  self.ambience:setLooping(true)

  self.current = 1

  self:resize()
end

function MainMenu:resize()
  local uiScale = self:calculateUIScale()
  self.titleFont = love.graphics.newFont("assets/ui/future-not-found.ttf", 100 * uiScale)
  self.optionFont = love.graphics.newFont("assets/ui/future-not-found.ttf", 40 * uiScale)
  self.versionFont = love.graphics.newFont("assets/ui/future-not-found.ttf", 30 * uiScale)
end

function MainMenu:enter()
  self.ambience:play()
end

function MainMenu:exit()
  self.ambience:stop()
end

function MainMenu:keypressed(key, scancode, isrepeat)
  local click = love.audio.newSource('assets/sound/click.wav', 'static')
  if key == 'down' then
    self.current = self.current + 1
    click:play()
  elseif key == 'up' then
    self.current = self.current - 1
    click:play()
  elseif key == 'return' then
    options[self.current].action()
    click:play()
  end

  if self.current > #options then self.current = 1 end
  if self.current < 1 then self.current = #options end
end

function MainMenu:draw()
  love.graphics.push()
  GameScene.scaling(self)
  love.graphics.setColor(1, 1, 1, 0.2)
  love.graphics.draw(background)
  love.graphics.pop()

  STATIC_SHADER:send('time', self.time % 5)
  love.graphics.setShader(STATIC_SHADER)
  love.graphics.setColor(1, 1, 1, 0.4)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setShader()

  Color.WHITE:use()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local mw, mh = sw / 2, sh / 2
  local uiScale = self:calculateUIScale()

  love.graphics.setFont(self.titleFont)
  love.graphics.printf("Proctor", 100, sh * 0.2, sw - 200, "center")

  for i, option in ipairs(options) do
      love.graphics.setFont(self.optionFont)

      local text = option.name
      if self.current == i then
        text = '> ' .. text .. ' <'
      end
      love.graphics.printf(text, 100, sh * 0.45 + 60 * (i- 1) * uiScale, sw - 200, "center")
  end

  love.graphics.setFont(self.versionFont)
  love.graphics.printf("v" .. VERSION, 30, love.graphics.getHeight() - 50, 200, "left")
end

return MainMenu
