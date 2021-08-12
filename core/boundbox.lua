local _floor = math.floor
local _ceil = math.ceil
local _clamp = math.clamp
local _min = math.min
local _max = math.max
local _dist2d = math.dist2d

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
  return _dist2d(x1, y1, x2, y2) <= r1 + r2
end

function floorCircleOverlapsCircle(x1, y1, r1, x2, y2, r2)
  return _floor(_dist2d(x1, y1, x2, y2)) <= r1 + r2
end

function pointOverlapsCircle(x1, y1, x2, y2, r2)
  return _dist2d(x1, y1, x2, y2) <= r2
end

function circleOverlapsRect(x1, y1, r1, x2, y2, w2, h2)
  return ((x1 - _max(x2, _min(x1, x2 + w2))) ^ 2) + ((y1 - _max(y2, _min(y1, y2 + h2))) ^ 2) < r1 ^ 2
end

local _pointOverlapsRect = pointOverlapsRect
local _pointOverlapsCircle = pointOverlapsCircle
local _floorCircleOverlapsCircle = floorCircleOverlapsCircle
local _rectOverlapsRect = rectOverlapsRect
local _circleOverlapsRect = circleOverlapsRect

function imageOverlapsRect(x, y, data, x2, y2, w2, h2)
  if _rectOverlapsRect(x, y, data:getWidth(), data:getHeight(), x2, y2, w2, h2) then
    local neww, newh = data:getWidth()-1, data:getHeight()-1
    
    for xi=_clamp(_floor(x2-x), 0, neww), _clamp(_ceil(x2-x)+w2, 0, neww) do
      for yi=_clamp(_floor(y2-y), 0, newh), _clamp(_ceil(y2-y)+h2, 0, newh) do
        local _, _, _, a = data:getPixel(xi, yi)
        if a > 0 and _rectOverlapsRect(x + xi, y + yi, 1, 1, x2, y2, w2, h2) then
          return true
        end
      end
    end
  end
  return false
end

function imageOverlapsCircle(x, y, data, x2, y2, r2)
  if _circleOverlapsRect(x2, y2, r2, x, y, data:getWidth(), data:getHeight()) then
    local neww, newh = data:getWidth()-1, data:getHeight()-1
    
    for xi=_clamp(_floor(x2-x)-r2, 0, neww), _clamp(_ceil(x2-x)+r2, 0, neww) do
      for yi=_clamp(_floor(y2-y)-r2, 0, newh), _clamp(_ceil(y2-y)+r2, 0, newh) do
        local _, _, _, a = data:getPixel(xi, yi)
        if a > 0 and _circleOverlapsRect(x2, y2, r2, x + xi, y + yi, 1, 1) then
          return true
        end
      end
    end
  end
  return false
end

function floorImageOverlapsCircle(x, y, data, x2, y2, r2)
  if _circleOverlapsRect(x2, y2, r2, x, y, data:getWidth(), data:getHeight()) then
    local neww, newh = data:getWidth()-1, data:getHeight()-1
    
    for xi=_clamp(_floor(x2-x)-r2, 0, neww), _clamp(_ceil(x2-x)+r2, 0, neww) do
      for yi=_clamp(_floor(y2-y)-r2, 0, newh), _clamp(_ceil(y2-y)+r2, 0, newh) do
        local _, _, _, a = data:getPixel(xi, yi)
        if a > 0 and _circleOverlapsRect(x2, y2, r2, x + xi, y + yi, 1, 1) then
          return true
        end
      end
    end
  end
  return false
end

function imageOverlapsImage(x, y, data, x2, y2, data2)
  if _rectOverlapsRect(x, y, data:getWidth(), data:getHeight(), x2, y2, data2:getWidth(), data2:getHeight()) then
    local neww, newh = data:getWidth()-1, data:getHeight()-1
    local neww2, newh2 = data2:getWidth()-1, data2:getHeight()-1
    
    for xi=_clamp(_floor(x2-x), 0, neww), _clamp(_ceil(x2-x)+w2, 0, neww) do
      for yi=_clamp(_floor(y2-y), 0, newh), _clamp(_ceil(y2-y)+h2, 0, newh) do
        for xi2=_clamp(_floor(x-x2), 0, neww2), _clamp(_ceil(x-x2)+w, 0, neww2) do
          for yi2=_clamp(_floor(y-y2), 0, newh2), _clamp(_ceil(y-y2)+h, 0, newh2) do
            local _, _, _, a = data:getPixel(xi, yi)
            local _, _, _, a2 = data2:getPixel(xi2, yi2)
            if a > 0 and a2 > 0 and _rectOverlapsRect(x + xi, y + yi, 1, 1, x2 + xi2, y2 + yi2, 1, 1) then
              return true
            end
          end
        end
      end
    end
  end
  return false
end