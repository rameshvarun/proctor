Robot = class('Robot')
Robot:include(Stateful)

-- Walk and run speeds.
local WALK_SPEED = 20
local RUN_SPEED = 40

local footsteps = {
  love.audio.newSource("assets/sound/footstep-1.wav", "static"),
  love.audio.newSource("assets/sound/footstep-2.wav", "static"),
  love.audio.newSource("assets/sound/footstep-1.wav", "static"),
  love.audio.newSource("assets/sound/footstep-2.wav", "static"),
  love.audio.newSource("assets/sound/footstep-1.wav", "static"),
  love.audio.newSource("assets/sound/footstep-2.wav", "static"),
}

for _, source in ipairs(footsteps) do
  source:setAttenuationDistances(20, math.huge)
end

function Robot:initialize(walkGraph)
  self.graph = walkGraph

  -- We start at node 3 on the graph.
  self.node = 3
  self.pos = self.graph:getNodeData(self.node)

  -- Footstep counter.
  self.footstep = 1

  -- Keep track of a set of visited nodes so that the robot doesn't go back and
  -- forth between two nodes.
  self.visited = {}
  self.visited[self.node] = true

  self.footstepTimer = 0

  self:gotoState('Idle')
end

function Robot:update(dt)
  for _, source in ipairs(footsteps) do
    source:setPosition(self.pos.x, self.pos.y, 0)
  end
  self.footstepTimer = self.footstepTimer - dt
end

function Robot:alert(node)
  self:gotoState('Alerted', node)
end

local IdleState = Robot:addState('Idle')

function IdleState:enteredState()
  self.visited = {}
  self.idle_time = lume.random(2, 4)
  log.debug("Idle for:", self.idle_time)
end

function IdleState:update(dt)
  Robot.update(self, dt)
  self.idle_time = self.idle_time - dt

  if self.idle_time < 0 then
    if lume.random() < 0.3 then
      self:gotoState('Alerted', lume.randomchoice({self.graph.rightScare, self.graph.leftScare}))
    else
      self:gotoState('RandomWalk')
    end
  end
end

local RandomWalkState = Robot:addState('RandomWalk')

function RandomWalkState:enteredState()
  self.startPos = self.pos

  local neighbors = self.graph:getNeighbors(self.node)
  log.debug(inspect(neighbors))

  local choices = lume.filter(neighbors, function(n)
    return self.visited[n] == nil
  end)

  if #choices == 0 then
    log.debug("Resetting visited set.")
    self.visited = {}
    choices = neighbors
  end

  self.nextNode = lume.randomchoice(choices)
  self.nextPos = self.graph:getNodeData(self.nextNode)

  log.debug("Walking to node:", self.nextNode)

  self.moveDir = (self.nextPos - self.startPos):normalized()
  self.walkTime = (self.nextPos - self.startPos):len() / WALK_SPEED
  self.walkTimer = 0
end


function RandomWalkState:update(dt)
  Robot.update(self, dt)

  if self.footstepTimer < 0 then
    self.footstepTimer = 0.84
    footsteps[self.footstep]:play()
    self.footstep = self.footstep + 1
    if self.footstep > #footsteps then
      self.footstep = 1
    end
  end

  self.walkTimer = self.walkTimer + dt
  self.pos = self.startPos + self.walkTimer * WALK_SPEED * self.moveDir

  if self.walkTimer > self.walkTime then
    self.node = self.nextNode
    self.visited[self.node] = true

    if self.alerted == true then
      self.alerted = false
      self:gotoState('Alerted', self.alertNode)
    elseif lume.random() < 0.2 then
      self:gotoState('Idle')
    else
      self:gotoState('RandomWalk')
    end
  end
end

function RandomWalkState:alert(node)
  if not self.alerted then
    log.debug("Alerted while walking. Waiting for a movement to finish.")
    self.alerted = true
  end
  self.alertNode = node
end

local DeathState = Robot:addState('Death')
function DeathState:enteredState() end

local AlertedState = Robot:addState('Alerted')

function AlertedState:alert()
  -- No-op if we are already alerted.
end

function AlertedState:enteredState(target)
  -- Find the path to the target node.
  self.target = target
  self.path = self.graph:getPath(self.node, self.target, function(from, to)
    return (self.graph:getNodeData(to) - self.graph:getNodeData(from)):len()
  end)

  self.footstepTimer = 0.0

  -- Determine the first node to walk to.
  self.pathIndex = 1
  self:setupWalk()
end

function AlertedState:setupWalk()
  self.nextNode = self.path[self.pathIndex]
  self.nextPos = self.graph:getNodeData(self.nextNode)

  log.debug("Running to node:", self.nextNode)

  self.startPos = self.pos
  self.moveDir = (self.nextPos - self.pos):normalized()
  self.walkTime = (self.nextPos - self.startPos):len() / RUN_SPEED
  self.walkTimer = 0
end

function AlertedState:update(dt)
  Robot.update(self, dt)

  if self.footstepTimer < 0 then
    self.footstepTimer = 0.4
    footsteps[self.footstep]:play()
    self.footstep = self.footstep + 1
    if self.footstep > #footsteps then
      self.footstep = 1
    end
  end

  self.walkTimer = self.walkTimer + dt
  self.pos = self.startPos + self.walkTimer * RUN_SPEED * self.moveDir

  if self.walkTimer > self.walkTime then
    self.node = self.nextNode
    self.pathIndex = self.pathIndex + 1
    if self.pathIndex <= #self.path then
      self:setupWalk()
    else
      self.path = nil
      self:gotoState('Idle')
    end
  end
end

return Robot
