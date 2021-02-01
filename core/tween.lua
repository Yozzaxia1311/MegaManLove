tween = {
  _VERSION     = 'tween 2.1.1',
  _DESCRIPTION = 'tweening for lua',
  _URL         = 'https://github.com/kikito/tween.lua',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2014 Enrique García Cota, Yuichi Tateno, Emmanuel Oga

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- easing

-- Adapted from https://github.com/EmmanuelOga/easing. See LICENSE.txt for credits.
-- For all easing functions:
-- t = time == how much time has to pass for the tweening to complete
-- b = begin == starting property value
-- c = change == ending - beginning
-- d = duration == running time. How much time has passed *right now*

tween.easing = {}

-- linear
function tween.easing.linear(t, b, c, d) return c * t / d + b end

-- quad
function tween.easing.inQuad(t, b, c, d) return c * ((t / d) ^ 2) + b end
function tween.easing.outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end
function tween.easing.inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * (t ^ 2) + b end
  return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end
function tween.easing.outInQuad(t, b, c, d)
  if t < d / 2 then return tween.easing.outQuad(t * 2, b, c / 2, d) end
  return tween.easing.inQuad((t * 2) - d, b + c / 2, c / 2, d)
end

-- cubic
function tween.easing.inCubic (t, b, c, d) return c * ((t / d) ^ 3) + b end
function tween.easing.outCubic(t, b, c, d) return c * (((t / d - 1) ^ 3) + 1) + b end
function tween.easing.inOutCubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * t * t * t + b end
  t = t - 2
  return c / 2 * (t * t * t + 2) + b
end
function tween.easing.outInCubic(t, b, c, d)
  if t < d / 2 then return tween.easing.outCubic(t * 2, b, c / 2, d) end
  return tween.easing.inCubic((t * 2) - d, b + c / 2, c / 2, d)
end

-- quart
function tween.easing.inQuart(t, b, c, d) return c * ((t / d) ^ 4) + b end
function tween.easing.outQuart(t, b, c, d) return -c * (((t / d - 1) ^ 4) - 1) + b end
function tween.easing.inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * (t ^ 4) + b end
  return -c / 2 * (((t - 2) ^ 4) - 2) + b
end
function tween.easing.outInQuart(t, b, c, d)
  if t < d / 2 then return tween.easing.outQuart(t * 2, b, c / 2, d) end
  return tween.easing.inQuart((t * 2) - d, b + c / 2, c / 2, d)
end

-- quint
function tween.easing.inQuint(t, b, c, d) return c * ((t / d) ^ 5) + b end
function tween.easing.outQuint(t, b, c, d) return c * (((t / d - 1) ^ 5) + 1) + b end
function tween.easing.inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * (t ^ 5) + b end
  return c / 2 * (((t - 2) ^ 5) + 2) + b
end
function tween.easing.outInQuint(t, b, c, d)
  if t < d / 2 then return tween.easing.outQuint(t * 2, b, c / 2, d) end
  return tween.easing.inQuint((t * 2) - d, b + c / 2, c / 2, d)
end

-- sine
function tween.easing.inSine(t, b, c, d) return -c * math.cos(t / d * (math.pi / 2)) + c + b end
function tween.easing.outSine(t, b, c, d) return c * math.sin(t / d * (math.pi / 2)) + b end
function tween.easing.inOutSine(t, b, c, d) return -c / 2 * (math.cos(math.pi * t / d) - 1) + b end
function tween.easing.outInSine(t, b, c, d)
  if t < d / 2 then return tween.easing.outSine(t * 2, b, c / 2, d) end
  return tween.easing.inSine((t * 2) -d, b + c / 2, c / 2, d)
end

-- expo
function tween.easing.inExpo(t, b, c, d)
  if t == 0 then return b end
  return c * (2 ^ (10 * (t / d - 1))) + b - c * 0.001
end
function tween.easing.outExpo(t, b, c, d)
  if t == d then return b + c end
  return c * 1.001 * (-(2 ^ (-10 * t / d) + 1)) + b
end
function tween.easing.inOutExpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then return c / 2 * (2 ^ (10 * (t - 1))) + b - c * 0.0005 end
  return c / 2 * 1.0005 * (-(2 ^ (-10 * (t - 1))) + 2) + b
end
function tween.easing.outInExpo(t, b, c, d)
  if t < d / 2 then return tween.easing.outExpo(t * 2, b, c / 2, d) end
  return tween.easing.inExpo((t * 2) - d, b + c / 2, c / 2, d)
end

-- circ
function tween.easing.inCirc(t, b, c, d) return(-c * (math.sqrt(1 - ((t / d) ^ 2)) - 1) + b) end
function tween.easing.outCirc(t, b, c, d)  return(c * math.sqrt(1 - ((t / d - 1) ^ 2)) + b) end
function tween.easing.inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then return -c / 2 * (math.sqrt(1 - t * t) - 1) + b end
  t = t - 2
  return c / 2 * (math.sqrt(1 - t * t) + 1) + b
end
function tween.easing.outInCirc(t, b, c, d)
  if t < d / 2 then return tween.easing.outCirc(t * 2, b, c / 2, d) end
  return tween.easing.inCirc((t * 2) - d, b + c / 2, c / 2, d)
end

-- elastic
function tween.calculatePAS(p,a,c,d)
  p, a = p or d * 0.3, a or 0
  if a < math.abs(c) then return p, c, p / 4 end -- p, a, s
  return p, a, p / (2 * math.pi) * math.asin(c/a) -- p,a,s
end
function tween.easing.inElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1  then return b + c end
  p,a,s = tween.calculatePAS(p,a,c,d)
  t = t - 1
  return -(a * (2 ^ (10 * t)) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
end
function tween.easing.outElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1 then return b + c end
  p,a,s = tween.calculatePAS(p,a,c,d)
  return a * (2 ^ (-10 * t)) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
end
function tween.easing.inOutElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d * 2
  if t == 2 then return b + c end
  p,a,s = tween.calculatePAS(p,a,c,d)
  t = t - 1
  if t < 0 then return -0.5 * (a * (2 ^ (10 * t)) * math.sin((t * d - s) * (2 * math.pi) / p)) + b end
  return a * (2 ^ (-10 * t)) * math.sin((t * d - s) * (2 * math.pi) / p ) * 0.5 + c + b
end
function tween.easing.outInElastic(t, b, c, d, a, p)
  if t < d / 2 then return tween.easing.outElastic(t * 2, b, c / 2, d, a, p) end
  return tween.easing.inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

-- back
function tween.easing.inBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end
function tween.easing.outBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end
function tween.easing.inOutBack(t, b, c, d, s)
  s = (s or 1.70158) * 1.525
  t = t / d * 2
  if t < 1 then return c / 2 * (t * t * ((s + 1) * t - s)) + b end
  t = t - 2
  return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end
function tween.easing.outInBack(t, b, c, d, s)
  if t < d / 2 then return tween.easing.outBack(t * 2, b, c / 2, d, s) end
  return tween.easing.inBack((t * 2) - d, b + c / 2, c / 2, d, s)
end

-- bounce
function tween.easing.outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  end
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end
function tween.easing.inBounce(t, b, c, d) return c - tween.easing.outBounce(d - t, 0, c, d) + b end
function tween.easing.inOutBounce(t, b, c, d)
  if t < d / 2 then return tween.easing.inBounce(t * 2, 0, c, d) * 0.5 + b end
  return tween.outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
end
function tween.easing.outInBounce(t, b, c, d)
  if t < d / 2 then return tween.easing.outBounce(t * 2, b, c / 2, d) end
  return tween.easing.inBounce((t * 2) - d, b + c / 2, c / 2, d)
end

-- private stuff

function tween.copyTables(destination, keysTable, valuesTable)
  valuesTable = valuesTable or keysTable
  local mt = getmetatable(keysTable)
  if mt and getmetatable(destination) == nil then
    setmetatable(destination, mt)
  end
  for k,v in pairs(keysTable) do
    if type(v) == 'table' then
      destination[k] = tween.copyTables({}, v, valuesTable[k])
    else
      destination[k] = valuesTable[k]
    end
  end
  return destination
end

function tween.checkSubjectAndTargetRecursively(subject, target, path)
  path = path or {}
  local targetType, newPath
  for k,targetValue in pairs(target) do
    targetType, newPath = type(targetValue), tween.copyTables({}, path)
    table.insert(newPath, tostring(k))
    if targetType == 'number' then
      assert(type(subject[k]) == 'number', "Parameter '" .. table.concat(newPath,'/') .. "' is missing from subject or isn't a number")
    elseif targetType == 'table' then
      tween.checkSubjectAndTargetRecursively(subject[k], targetValue, newPath)
    else
      assert(targetType == 'number', "Parameter '" .. table.concat(newPath,'/') .. "' must be a number or table of numbers")
    end
  end
end

function tween.checkNewParams(duration, subject, target, easing)
  assert(type(duration) == 'number' and duration > 0, "duration must be a positive number. Was " .. tostring(duration))
  local tsubject = type(subject)
  assert(tsubject == 'table' or tsubject == 'userdata', "subject must be a table or userdata. Was " .. tostring(subject))
  assert(type(target)== 'table', "target must be a table. Was " .. tostring(target))
  assert(type(easing)=='function', "easing must be a function. Was " .. tostring(easing))
  tween.checkSubjectAndTargetRecursively(subject, target)
end

function tween.getEasingFunction(easing)
  easing = easing or "linear"
  if type(easing) == 'string' then
    local name = easing
    easing = tween.easing[name]
    if type(easing) ~= 'function' then
      error("The easing function name '" .. name .. "' is invalid")
    end
  end
  return easing
end

function tween.performEasingOnSubject(subject, target, initial, clock, duration, easing)
  local t,b,c,d
  for k,v in pairs(target) do
    if type(v) == 'table' then
      tween.performEasingOnSubject(subject[k], v, initial[k], clock, duration, easing)
    else
      t,b,c,d = clock, initial[k], v - initial[k], duration
      subject[k] = easing(t,b,c,d)
    end
  end
end

-- Tween methods

local Tween = {}
Tween_mt = {__index = Tween}

function Tween:set(clock)
  assert(type(clock) == 'number', "clock must be a positive number or 0")

  self.initial = self.initial or tween.copyTables({}, self.target, self.subject)
  self.clock = clock

  if self.clock <= 0 then

    self.clock = 0
    tween.copyTables(self.subject, self.initial)

  elseif self.clock >= self.duration then -- the tween has expired

    self.clock = self.duration
    tween.copyTables(self.subject, self.target)

  else

    tween.performEasingOnSubject(self.subject, self.target, self.initial, self.clock, self.duration, self.easing)

  end

  return self.clock >= self.duration
end

function Tween:reset()
  return self:set(0)
end

function Tween:update(dt)
  assert(type(dt) == 'number', "dt must be a number")
  return self:set(self.clock + dt)
end


-- Public interface

function tween.new(duration, subject, target, easing)
  easing = tween.getEasingFunction(easing)
  tween.checkNewParams(duration, subject, target, easing)
  return setmetatable({
    duration  = duration,
    subject   = subject,
    target    = target,
    easing    = easing,
    clock     = 0
  }, Tween_mt)
end