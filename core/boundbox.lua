function rectOverlapsRect(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function pointOverlapsRect(x1,y1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1 and
         y1 < y2+h2 and
         y2 < y1
end

function pointOverlapsPoint(x1,y1, x2,y2)
  return x1 == x2 and y1 == y2
end

function imageOverlapsRect(x, y, w, h, data, x2, y2, w2, h2)
  if rectOverlapsRect(x2, y2, w2, h2, x, y, w, h) then
    local neww, newh = w-1, h-1
    
    local clmx = math.clamp(math.round(x2-x), 0, neww)
    local clmw = math.clamp(math.round(x2-x)+w2, 0, neww)
    local clmy = math.clamp(math.round(y2-y), 0, newh)
    local clmh = math.clamp(math.round(y2-y)+h2, 0, newh)
    
    for xi=clmx, clmw do
      for yi=clmy, clmh do
        if data[yi+1] and data[yi+1][xi+1] ~= 0 and pointOverlapsRect(x + xi, y + yi, x2, y2, w2, h2) then
          return true
        end
      end
    end
  end
  return false
end

function imageOverlapsImage(x, y, w, h, data, x2, y2, w2, h2, data2)
  if rectOverlapsRect(x2, y2, w2, h2, x, y, w, h) then
    local neww, newh = w-1, h-1
    local neww2, newh2 = w2-1, h2-1
    
    local clmx = math.clamp(math.round(x2-x), 0, neww)
    local clmw = math.clamp(math.round(x2-x)+w2, 0, neww)
    local clmy = math.clamp(math.round(y2-y), 0, newh)
    local clmh = math.clamp(math.round(y2-y)+h2, 0, newh)
    
    local clmx2 = math.clamp(math.round(x-x2), 0, neww2)
    local clmw2 = math.clamp(math.round(x-x2)+w, 0, neww2)
    local clmy2 = math.clamp(math.round(y-y2), 0, newh2)
    local clmh2 = math.clamp(math.round(y-y2)+h, 0, newh2)
    
    for xi=clmx, clmw do
      for yi=clmy, clmh do
        for xi2=clmx2, clmw2 do
          for yi2=clmy2, clmh2 do
            if data[yi+1] and data[yi+1][xi+1] ~= 0 and data2[yi2+1] and data2[yi2+1][xi2+1] ~= 0 and
              pointOverlapsPoint(x + xi, y + yi, x2 + xi2, y2 + yi2) then
              return true
            end
          end
        end
      end
    end
  end
  return false
end