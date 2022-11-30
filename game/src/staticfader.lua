local StaticFader = class('StaticFader')
StaticFader:include(Stateful)

local STATIC_SHADER = love.graphics.newShader('src/shader/static.frag', 'src/shader/static.vert')

function StaticFader:initialize() end
function StaticFader:draw() end
function StaticFader:update(dt) end

function StaticFader:fadeIn(duration)
  self:gotoState('FadeIn', duration)
end

local FadeInState = StaticFader:addState('FadeIn')
function FadeInState:enteredState(duration)
  log.debug('Fading in static. Duration: ', duration)
  self.duration = duration
  self.time = 0
end
function FadeInState:update(dt)
  self.time = self.time + dt
end
function FadeInState:draw()
  STATIC_SHADER:send('time', self.time % 5)
  love.graphics.setShader(STATIC_SHADER)
  love.graphics.setColor(1, 1, 1, lume.clamp(self.time, 0, self.duration) / self.duration)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setShader()
end

return StaticFader
