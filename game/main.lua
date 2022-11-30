VERSION = love.filesystem.read("version.txt")

-- Platform info.
print("Platform:" .. love.system.getOS())
ANDROID = love.system.getOS() == "Android"
IOS = love.system.getOS() == "iOS"
MOBILE = ANDROID or IOS
WEB = love.system.getOS() == "Web"

math.randomseed(os.time()) -- Seed the random number genrator.

log = require 'external.log' -- Logging library.

inspect = require 'external.inspect' -- Pretty printing Lua objects.
class = require 'external.middleclass' -- Middleclass, for following OOP patterns.
Stateful = require 'external.stateful' -- Stateful.lua, for state-based classes.

vector = require 'external.hump.vector' -- HUMP.vector, for the vector primitive.
lume = require 'external.lume' -- Game-related helpers

Timer = require 'external.hump.timer' -- HUMP.timer
Signal = require 'external.hump.signal' -- HUMP.signal

input = require 'src.input' -- Load in input library.
Color = require 'src.color' -- Color utility library.

require 'src.scene'
require 'src.gamescene'

local JumpScareWarning = require 'src.scenes.jumpscarewarning'
local Grade = require 'src.scenes.grade'

function love.load(arg)
  love.mouse.setVisible(false)
  if arg[1] == 'debug' then
    log.debug("Debug mode enabled.")
    DEBUG = true
  end
  Scene.switchTo(JumpScareWarning()) -- Switch to the initial game state.
end

MAX_DELTA_TIME = 1 / 30
function love.update(dt)
  -- Prevent the delta time from getting out of control.
  if dt > MAX_DELTA_TIME then dt = MAX_DELTA_TIME end
  Timer.update(dt) -- Update global timer events.

  -- If there is a current Scene, update it.
  if Scene.currentState ~= nil then Scene.currentState:update(dt) end

  -- Use lurker for live reload in debug mode.
  if DEBUG then require("external.lurker").update() end
end

function love.draw()
  -- If there is a current Scene, draw it.
  if Scene.currentState ~= nil then Scene.currentState:draw() end
end
