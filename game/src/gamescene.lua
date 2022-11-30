require "src.robot"
require "src.walkgraph"
require "src.imagesequence"

local tablex = require('pl.tablex')

local questions = require "src.generators.questions"
local Page = require "src.page"
local StaticFader = require "src.staticfader"
local BlackFader = require "src.blackfader"

NATIVE_VIDEO_SIZE = vector(1280, 720)
SCARE_DISTANCE = 12
TEST_TIME = 60 * 2

GameScene = class('GameScene', Scene)
GameScene:include(Stateful)

function Lazy(initializer)
  local value = nil
  return function()
    if value == nil then
      value = initializer()
    end
    return value
  end
end

SLIDE_FROM_LEFT = Lazy(function()
  log.debug("Loading DeathFromLeft sequence...")
  return ImageSequence("assets/graphics/death-from-left", ".png", 60)
end)

SLIDE_FROM_RIGHT = Lazy(function()
  log.debug("Loading DeathFromRight sequence...")
  return ImageSequence("assets/graphics/death-from-right", ".png", 60)
end)

function GameScene:initialize()
  Scene.initialize(self)

  -- Input controls
  self.controls = {}

  self.controls.lookRight = input.Button(input.Key('right'))
  self.controls.lookLeft = input.Button(input.Key('left'))

  self.controls.cycleAnswer = input.Button(input.Key('space'))

  self.controls.nextPage = input.Button(input.Key('e'))
  self.controls.prevPage = input.Button(input.Key('q'))

  self.controls.submit = input.Button(input.Key('return'))

  self.center = love.graphics.newImage("assets/graphics/center.png")
  self.right = love.graphics.newImage("assets/graphics/right.png")
  self.left = love.graphics.newImage("assets/graphics/left.png")

  self.robot = Robot(WALK_GRAPH)
  self.scare = love.audio.newSource('assets/sound/scare.ogg', 'static')

  self.slideFromLeft = SLIDE_FROM_LEFT()
  self.slideFromRight = SLIDE_FROM_RIGHT()

  self.uiColor = Color(1, 1, 1, 0.2)

  self.player_questions, self.left_questions, self.right_questions = questions()

  self.playerPage = Page(self.player_questions, require("assets.graphics.centercoords"))
  self.rightPage = Page(self.right_questions, require("assets.graphics.rightcoords"))
  self.leftPage = Page(self.left_questions, require("assets.graphics.leftcoords"))

  self.ambience = love.audio.newSource('assets/sound/ambience.mp3', 'static')

  self.uiFont = love.graphics.newFont("assets/ui/roboto.ttf", 20)

  self.blackFader = BlackFader()
  self.blackFader:fadeOut(1)

  self.staticFader = StaticFader()

  self.testTimer = TEST_TIME
  self.testEnded = false

  log.debug("Player Questions:", inspect(self.player_questions))
  log.debug("Left Questions:", inspect(self.left_questions))
  log.debug("Right Questions:", inspect(self.right_questions))


  love.audio.setPosition(0, 0, 0)
  love.audio.setOrientation(0, -1, 0, 0, 0, -1)

  self:gotoState('Center')
end

function GameScene:enter()
  self.ambience:play()
  self.ambience:setLooping(true)
end

function GameScene:exit()
  self.ambience:stop()
end


function GameScene:scaling()
  local x_scale = love.graphics.getWidth() / NATIVE_VIDEO_SIZE.x
  local y_scale = love.graphics.getHeight() / NATIVE_VIDEO_SIZE.y

  if x_scale > y_scale then
    love.graphics.scale(x_scale, x_scale)
    love.graphics.translate(0, love.graphics.getHeight()/2 - (x_scale* NATIVE_VIDEO_SIZE.y)/2)
  else
    love.graphics.scale(y_scale, y_scale)
    love.graphics.translate(love.graphics.getWidth()/2 - (y_scale* NATIVE_VIDEO_SIZE.x)/2, 0)
  end
end

function GameScene:draw()
  Scene.draw(self)

  love.graphics.push()
  self:scaling()

  Color.WHITE:use()

  self:videoDraw()
  love.graphics.pop()

  self:uiDraw()

  if DEBUG then self:debugDraw() end

  self.blackFader:draw()
  self.staticFader:draw()
end

local q = love.graphics.newImage('assets/ui/keyboard-q.png')
local e = love.graphics.newImage('assets/ui/keyboard-e.png')
function GameScene:pageTurnUI(page)
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()

  if page.page_index > 1 then
    love.graphics.draw(q, sw * 0.25 - q:getWidth()/2, sh * 0.5 - q:getHeight() / 2)
    love.graphics.printf("PREV PAGE", sw * 0.25 - 30, sh * 0.5 + 50, 60, "center")
  end

  if page.page_index < page:numPages() then
    love.graphics.draw(e, sw * 0.7 - e:getWidth()/2, sh * 0.5 - e:getHeight() / 2)
    love.graphics.printf("NEXT PAGE", sw * 0.7 - 30, sh * 0.5 + 50, 60, "center")
  end
end

local timerFont = love.graphics.newFont("assets/ui/roboto.ttf", 40)
function GameScene:uiDraw()
  Color.WHITE:use()
  love.graphics.setFont(timerFont)

  local timerText = ""
  if self.testTimer > 0 then
    local minutes = math.floor(self.testTimer / 60)
    local seconds = math.floor(self.testTimer % 60)
    timerText = minutes .. ":" .. string.format("%02d", seconds)
  else
    timerText = "0:00"
  end

  love.graphics.printf(timerText, love.graphics.getWidth() / 2 - 100, 40, 200, "center")
end

local debugFont = love.graphics.newFont(12)
function GameScene:debugDraw()
  love.graphics.push()
  love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
  Color.GREEN:use()

  love.graphics.setLineWidth(1)
  love.graphics.setFont(debugFont)

  local x, y, z = love.audio.getPosition()
  local fx, fy, fz, ux, uy, uz = love.audio.getOrientation()
  love.graphics.circle('fill', x, y, 5)
  love.graphics.line(x, y, x + fx * 15, y + fy * 15)

  WALK_GRAPH:eachNode(function(_, point)
    love.graphics.circle('fill', point.x, point.y, 2)
  end)

  WALK_GRAPH:eachEdge(function(_, _, start, end_p, _)
    love.graphics.line(start.x, start.y, end_p.x, end_p.y)
  end)

  Color.RED:use()
  love.graphics.circle('fill', self.robot.pos.x, self.robot.pos.y, 5)

  local point = WALK_GRAPH:getNodeData(WALK_GRAPH.rightScare)
  love.graphics.circle('fill', point.x, point.y, 3)
  love.graphics.circle('line', point.x, point.y, SCARE_DISTANCE)

  if (point - self.robot.pos):len() < SCARE_DISTANCE then
    love.graphics.print("Observed")
  end

  local point = WALK_GRAPH:getNodeData(WALK_GRAPH.leftScare)
  love.graphics.circle('fill', point.x, point.y, 3)
  love.graphics.circle('line', point.x, point.y, SCARE_DISTANCE)

  if (point - self.robot.pos):len() < SCARE_DISTANCE then
    love.graphics.print("Observed")
  end

  if self.robot.path and #self.robot.path > 1 then
    local positions = {}
    for _, node in ipairs(self.robot.path) do
      local point = WALK_GRAPH:getNodeData(node)
      table.insert(positions, point.x)
      table.insert(positions, point.y)
    end
    love.graphics.line(unpack(positions))
  end

  love.graphics.pop()
end

function GameScene:videoDraw()
end

local schoolbell = love.audio.newSource('assets/sound/school-bell.mp3', 'static')
local stamp = love.audio.newSource('assets/sound/stamp.wav', 'static')
local Grade = require "src.scenes.grade"

function GameScene:endTest()
  if self.testEnded == false then
    self.testEnded = true
    self.robot:gotoState('Death')

    -- Calculate grade.
    local right = 0
    tablex.foreach(self.player_questions, function(q)
      if q.answer == q.choices[q.selection] then
        right = right + 1
      end
    end)
    log.debug("Correct Answers:", right)

    local score = right / #self.player_questions

    if right < #self.player_questions then
      self.timer:after(1, function()
        stamp:play()
        self.playerPage:addGrade(right .. "/" .. #self.player_questions)
        self.timer:after(2, function()
          self:gotoState('FailDeath')
        end)
      end)
    else
      self.blackFader:fadeIn(1)
      self.timer:after(1, function()
        Scene.switchTo(Grade(self.player_questions))
      end)
    end
  end
end

function GameScene:update(dt)
  Scene.update(self, dt)
  self.blackFader:update(dt)
  self.staticFader:update(dt)


  if self.dead ~= true then
    if self.testTimer < 0 and self.testEnded == false then
      schoolbell:play()
      self:endTest()
    end

    if self.testEnded == false then
      self.testTimer = self.testTimer - dt

      -- Update all of the controls
      for _, control in pairs(self.controls) do control:update() end
      -- Update the robot behavior.
      self.robot:update(dt)
    end
  end
end

require "src.states.center"
require "src.states.left"
require "src.states.right"
require "src.states.videotransition"
require "src.states.deathtransition"
require "src.states.deathslide"




return GameScene
