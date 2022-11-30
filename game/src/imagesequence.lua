ImageSequence = class('ImageSequence')

function ImageSequence:initialize(folder, extension, fps)
  assert(love.filesystem.getInfo(folder, "directory"))

  self.length = #(love.filesystem.getDirectoryItems(folder))
  log.debug(folder .. " has " .. self.length .. " frames.")

  self.folder = folder
  self.extension = extension
  self.fps = fps

  -- Preload image sequence.
  self.images = {}
  for i=1, self.length do
    table.insert(self.images, self:imageForFrame(i))
  end

  self:restart()
end

function ImageSequence:restart()
  self.start_time = love.timer.getTime()
end

function ImageSequence:update(dt) end

function ImageSequence:imageForFrame(frame)
  local file = string.format("%04d", frame)
  return love.graphics.newImage(self.folder .. "/" .. file .. self.extension)
end

function ImageSequence:draw()
  local frame = math.ceil((love.timer.getTime() - self.start_time) * self.fps)
  frame = lume.clamp(frame, 1, self.length)
  love.graphics.draw(self.images[frame])
end

return ImageSequence
