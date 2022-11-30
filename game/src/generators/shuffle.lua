return function (t)
  if #t < 2 then
    return t
  end

  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end
