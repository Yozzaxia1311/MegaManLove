function rectOverlapsRect(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
    x2 < x1 + w1 and
    y1 < y2 + h2 and
    y2 < y1 + h1
end

function pointOverlapsRect(x1, y1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
  x2 < x1 and
  y1 < y2 + h2 and
  y2 < y1
end

function pointOverlapsPoint(x1, y1, x2, y2)
  return x1 == x2 and y1 == y2
end

function circleOverlapsCircle(x1, y1, r1, x2, y2, r2)
  return math.dist2d(x1, y1, x2, y2) <= r1 + r2
end

function pointOverlapsCircle(x1, y1, x2, y2, r2)
  return math.dist2d(x1, y1, x2, y2) <= r2
end

function circleOverlapsRect(x1, y1, r1, x2, y2, w2, h2)
  return pointOverlapsRect(x1, y1, x2, y2, w2, h2) or
    pointOverlapsCircle(x2, y2, x1, y1, r1) or
    pointOverlapsCircle(x2 + w2, y2, x1, y1, r1) or
    pointOverlapsCircle(x2 + w2, y2 + h2, x1, y1, r1) or
    pointOverlapsCircle(x2, y2 + h2, x1, y1, r1)
end

function imageOverlapsRect(x, y, w, h, data, x2, y2, w2, h2)
  if rectOverlapsRect(x, y, w, h, x2, y2, w2, h2) then
    local neww, newh = w-1, h-1
    for xi=math.clamp(math.floor(x2-x), 0, neww), math.clamp(math.ceil(x2-x)+w2, 0, neww) do
      for yi=math.clamp(math.floor(y2-y), 0, newh), math.clamp(math.ceil(y2-y)+h2, 0, newh) do
        local _, _, _, a = data:getPixel(xi, yi)
        if a > 0 and rectOverlapsRect(x + xi, y + yi, 1, 1, x2, y2, w2, h2) then
          return true
        end
      end
    end
  end
  return false
end

function imageOverlapsCircle(x, y, w, h, data, x2, y2, r2)
  if circleOverlapsRect(x2, y2, r2, x, y, w, h) then
    local neww, newh = w-1, h-1
    
    for xi=math.clamp(math.floor(x2-x)-r2, 0, neww), math.clamp(math.ceil(x2-x)+r2, 0, neww) do
      for yi=math.clamp(math.floor(y2-y)-r2, 0, newh), math.clamp(math.ceil(y2-y)+r2, 0, newh) do
        local _, _, _, a = data:getPixel(xi, yi)
        if a > 0 and circleOverlapsRect(x2, y2, r2, x + xi, y + yi, 1, 1) then
          return true
        end
      end
    end
  end
  return false
end

function imageOverlapsImage(x, y, w, h, data, x2, y2, w2, h2, data2)
  if rectOverlapsRect(x, y, w, h, x2, y2, w2, h2) then
    local neww, newh = w-1, h-1
    local neww2, newh2 = w2-1, h2-1
    
    for xi=math.clamp(math.floor(x2-x), 0, neww), math.clamp(math.ceil(x2-x)+w2, 0, neww) do
      for yi=math.clamp(math.floor(y2-y), 0, newh), math.clamp(math.ceil(y2-y)+h2, 0, newh) do
        for xi2=math.clamp(math.floor(x-x2), 0, neww2), math.clamp(math.ceil(x-x2)+w, 0, neww2) do
          for yi2=math.clamp(math.floor(y-y2), 0, newh2), math.clamp(math.ceil(y-y2)+h, 0, newh2) do
            local _, _, _, a = data:getPixel(xi, yi)
            local _, _, _, a2 = data2:getPixel(xi2, yi2)
            if a > 0 and a2 > 0 and rectOverlapsRect(x + xi, y + yi, 1, 1, x2 + xi2, y2 + yi2, 1, 1) then
              return true
            end
          end
        end
      end
    end
  end
  return false
end