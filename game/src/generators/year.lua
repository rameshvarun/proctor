return function()
  if lume.random() > 0.5 then
    return math.floor(lume.random(3001)) .. " AK"
  else
    return math.floor(lume.random(1, 1001)) .. " BK"
  end
end
