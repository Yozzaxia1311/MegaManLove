function rectOverlaps(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function pointRectOverlaps(x1,y1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1 and
         y1 < y2+h2 and
         y2 < y1
end

function imageRectOverlaps(x, y, w, h, data, x2, y2, w2, h2)
  local neww, newh = w-1, h-1
  if rectOverlaps(x2, y2, w2, h2, x, y, w, h) then
    local clmx = math.clamp(math.round(x2-x), 0, neww)
    local clmw = math.clamp(math.round(x2-x)+w2, 0, neww)
    local clmy = math.clamp(math.round(y2-y), 0, newh)
    local clmh = math.clamp(math.round(y2-y)+h2, 0, newh)
    for xi=clmx, clmw do
      for yi=clmy, clmh do
        if data[yi+1] and data[yi+1][xi+1] ~= 0 and pointRectOverlaps(x + xi, y + yi, x2, y2, w2, h2) then
          return true
        end
      end
    end
  end
  return false
end