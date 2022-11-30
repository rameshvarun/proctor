local Graph = require "src.graph"

local NUM_DESKS_ROWS = 3
local DESK_SIZE = vector(40, 50)

WALK_GRAPH = Graph()

assert(NUM_DESKS_ROWS % 2 == 1)

local middle_desk = (NUM_DESKS_ROWS + 1) / 2
log.debug("Middle Desk: ", middle_desk)
local prev_i, prev_k = nil, nil
for i=1, NUM_DESKS_ROWS do
  local bottom = i - NUM_DESKS_ROWS/2

  local left = WALK_GRAPH:addNode(vector(-0.5*DESK_SIZE.x, (bottom - 0.5)*DESK_SIZE.y))
  local right = WALK_GRAPH:addNode(vector(0.5*DESK_SIZE.x, (bottom - 0.5)*DESK_SIZE.y))

  if i == 1 then
    local i = WALK_GRAPH:addNode(vector(-0.5*DESK_SIZE.x, (bottom - 1)*DESK_SIZE.y))
    local j = WALK_GRAPH:addNode(vector(0*DESK_SIZE.x, (bottom - 1)*DESK_SIZE.y))
    local k = WALK_GRAPH:addNode(vector(0.5*DESK_SIZE.x, (bottom - 1)*DESK_SIZE.y))

    WALK_GRAPH:addEdge(i, j)
    WALK_GRAPH:addEdge(j, k)

    WALK_GRAPH:addEdge(i, left)
    WALK_GRAPH:addEdge(k, right)
  else
    WALK_GRAPH:addEdge(prev_i, left)
    WALK_GRAPH:addEdge(prev_k, right)
  end

  if i == middle_desk then
    WALK_GRAPH.rightScare = right
    WALK_GRAPH.leftScare = left
  end

  local i = WALK_GRAPH:addNode(vector(-0.5*DESK_SIZE.x, bottom*DESK_SIZE.y))
  local j = WALK_GRAPH:addNode(vector(0*DESK_SIZE.x, bottom*DESK_SIZE.y))
  local k = WALK_GRAPH:addNode(vector(0.5*DESK_SIZE.x, bottom*DESK_SIZE.y))

  WALK_GRAPH:addEdge(i, left)
  WALK_GRAPH:addEdge(k, right)

  WALK_GRAPH:addEdge(i, j)
  WALK_GRAPH:addEdge(j, k)

  prev_i, prev_k = i, k
end

return WALK_GRAPH
