local Page = class('Page')

local PAGE_SHADER = love.graphics.newShader('src/shader/page.frag', 'src/shader/page.vert')
local PAGE_FONT = love.graphics.newFont(40)
local GRADE_FONT = love.graphics.newFont('assets/ui/roboto.ttf', 60)

local CANVAS_SIZE = vector(500, 600)
local CHOICE_LETTERS = {'A', 'B', 'C', 'D', 'E', 'F', 'G'}

local FLIP_SFX = love.audio.newSource('assets/sound/page_flip.wav','static')
local PENCIL_SFX = love.audio.newSource('assets/sound/pencil.wav','static')


function Page:initialize(questions, vertices)
  self.questions = questions
  self.page_index = 1

  self.mesh = love.graphics.newMesh({
      {"VertexPosition", "float", 2},
      {"ZPositionAttribute", "float", 1},
      {"VertexTexCoord", "float", 2},
  }, vertices, "strip")

  self.canvas = love.graphics.newCanvas(CANVAS_SIZE:unpack())
  self.canvas:setWrap('clampzero', 'clampzero')
  self.mesh:setTexture(self.canvas)
end

function Page:numPages() return #self.questions end
function Page:nextPage()
  FLIP_SFX:clone():play()
  self.page_index = self.page_index + 1
end
function Page:prevPage()
  FLIP_SFX:clone():play()
  self.page_index = self.page_index - 1
end

function Page:cycleAnswer()
  PENCIL_SFX:clone():play()
  local page = self.questions[self.page_index]
  page.selection = page.selection + 1
  if page.selection > #page.choices then page.selection = 1 end
end

function Page:addGrade(grade)
  self.grade = grade
end

-- Draw to the canvas.
function Page:draw()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()

  Color.BLACK:use()
  love.graphics.setFont(PAGE_FONT)

  local page = self.questions[self.page_index]

  love.graphics.printf(page.question , 10, 20, 500 - 20, "center")

  for i, choice in ipairs(page.choices) do
    love.graphics.printf(CHOICE_LETTERS[i] .. ') ' .. choice , 20, 150 + 60 * i, 500 - 40, "left")
  end

  love.graphics.setLineWidth(1)
  love.graphics.ellipse('line', self.canvas:getWidth() / 3, 170 + 60*page.selection, (self.canvas:getWidth() - 50) / 3, 30)

  love.graphics.printf(self.page_index .. '/' .. self:numPages(), self.canvas:getWidth() - 100, self.canvas:getHeight() - 60, 80, "right")

  if DEBUG then
    Color.GREEN:use()
    love.graphics.setLineWidth(5)
    love.graphics.rectangle('line', 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
  end

  if self.grade then
    Color.RED:use()
    love.graphics.setFont(GRADE_FONT)
    love.graphics.setLineWidth(5)
    love.graphics.circle('line', self.canvas:getWidth() - 75, 115, 60, 32)
    love.graphics.printf(self.grade, self.canvas:getWidth() - 150, 80, 150, "center")
  end

  love.graphics.setCanvas()
end

-- Invoke when you want to draw the page to the actual game screen.
function Page:videoDraw()
  love.graphics.setShader(PAGE_SHADER)
  love.graphics.draw(self.mesh)
  love.graphics.setShader()
end

return Page
