anim8 = {
  _VERSION     = 'anim8 v2.3.0',
  _DESCRIPTION = 'An animation library for LÖVE',
  _URL         = 'https://github.com/kikito/anim8',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2011 Enrique García Cota

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

local Grid = {}

local function assertPositiveInteger(value, name)
  if type(value) ~= 'number' then error(("%s should be a number, was %q"):format(name, tostring(value))) end
  if value < 1 then error(("%s should be a positive number, was %d"):format(name, value)) end
  if value ~= math.floor(value) then error(("%s should be an integer, was %d"):format(name, value)) end
end

local function createFrame(self, x, y)
  local fw, fh = self.frameWidth, self.frameHeight
  local result = quad(
    self.left + self.border + (x - 1) * (fw + (self.border * 2)),
    self.top + self.border + (y - 1) * (fh + (self.border * 2)),
    fw,
    fh
  )
  result.fx = x
  result.fy = y
  return result
end

local function getGridKey(...)
  return table.concat( {...} ,'-' )
end

local function getOrCreateFrame(self, x, y)
  local key = self.key
  self._frames[key]       = self._frames[key]       or {}
  self._frames[key][x]    = self._frames[key][x]    or {}
  self._frames[key][x][y] = self._frames[key][x][y] or createFrame(self, x, y)
  return self._frames[key][x][y]
end

local function parseInterval(str)
  if type(str) == "number" then return str,str,1 end
  str = str:gsub('%s', '') -- remove spaces
  local min, max = str:match("^(%d+)-(%d+)$")
  assert(min and max, ("Could not parse interval from %q"):format(str))
  min, max = tonumber(min), tonumber(max)
  local step = min <= max and 1 or -1
  return min, max, step
end

function Grid:getFrames(...)
  local result, args = {}, {...}
  local minx, maxx, stepx, miny, maxy, stepy

  for i=1, #args, 2 do
    minx, maxx, stepx = parseInterval(args[i])
    miny, maxy, stepy = parseInterval(args[i+1])
    for y = miny, maxy, stepy do
      for x = minx, maxx, stepx do
        result[#result+1] = getOrCreateFrame(self,x,y)
      end
    end
  end

  return result
end

function Grid:release()
  for _, key in pairs(self._frames) do
    for _, rows in pairs(key) do
      for _, data in pairs(rows) do
        data:release()
      end
    end
  end
  
  self.frames = {}
end

Gridmt = {
  __index = Grid,
  __call  = Grid.getFrames
}

binser.register(Gridmt, "grid", function(o)
    return {
        frameWidth=o.frameWidth,
        frameHeight=o.frameHeight,
        left=o.left,
        right=o.right,
        top=o.top,
        border=o.border
      }
  end, function(o)
    return anim8.newGrid(o.frameWidth, o.frameHeight, o.left, o.top, o.border)
  end)

local function newGrid(frameWidth, frameHeight, left, top, border)
  assertPositiveInteger(frameWidth,  "frameWidth")
  assertPositiveInteger(frameHeight, "frameHeight")

  left   = left   or 0
  top    = top    or 0
  border = border or 0

  local key  = getGridKey(frameWidth, frameHeight, left, top, border)

  local grid = setmetatable(
    {
      frameWidth  = frameWidth,
      frameHeight = frameHeight,
      left        = left,
      top         = top,
      border      = border,
      key         = key,
      _frames      = {}
    },
    Gridmt
  )
  return grid
end

-----------------------------------------------------------

local Animation = {}

local function cloneArray(arr)
  local result = {}
  for i=1,#arr do result[i] = arr[i] end
  return result
end

local function parseDurations(durations, frameCount)
  local result = {}
  if type(durations) == 'number' then
    for i=1,frameCount do result[i] = durations end
  else
    local min, max, step
    for key,duration in pairs(durations) do
      assert(type(duration) == 'number', "The value [" .. tostring(duration) .. "] should be a number")
      min, max, step = parseInterval(key)
      for i = min,max,step do result[i] = duration end
    end
  end

  if #result < frameCount then
    error("The durations table has length of " .. tostring(#result) .. ", but it should be >= " .. tostring(frameCount))
  end

  return result
end

local function parseIntervals(durations)
  local result, time = {0},0
  for i=1,#durations do
    time = time + durations[i]
    result[i+1] = time
  end
  return result, time
end

Animationmt = { __index = Animation }
local nop = function() end

binser.register(Animationmt, "animation", function(o)
    return {
        frames=o.frames,
        durations=o.durations,
        onLoop=o.onLoop,
        timer=o.timer,
        position=o.position,
        status=o.status,
        _looped=o._looped
      }
  end, function(o)
    local result = anim8.newAnimation(o.frames, o.durations, o.onLoop)
    
    result.timer = o.timer
    result.position = o.position
    result.status = o.status
    result._looped = o._looped
    
    return result
  end)

local function newAnimation(frames, durations, onLoop)
  local td = type(durations)
  if (td ~= 'number' or durations <= 0) and td ~= 'table' then
    error("durations must be a positive number. Was " .. tostring(durations) )
  end
  onLoop = onLoop or nop
  durations = parseDurations(durations, #frames)
  local intervals, totalDuration = parseIntervals(durations)
  local framePositions = {}
  for i=1, #frames do
    framePositions[i] = {frames[i].fx, frames[i].fy}
  end
  
  return setmetatable({
      frames         = cloneArray(frames),
      framePositions = framePositions,
      durations      = durations,
      intervals      = intervals,
      totalDuration  = totalDuration,
      onLoop         = onLoop,
      timer          = 0,
      position       = 1,
      status         = "playing",
      _looped        = false
    },
    Animationmt
  )
end

function Animation:setDurations(durations)
  durations = parseDurations(durations, #self.frames)
  local intervals, totalDuration = parseIntervals(durations)
  local setTo = false
  if self.timer > totalDuration then
    setTo = true
  end
  self.intervals = intervals
  self.durations = durations
  self.totalDuration = totalDuration
  if setTo then
    self.position = #self.frames
    self.timer = self.totalDuration
  end
  self._looped = false
end

function Animation:clone()
  local newAnim = newAnimation(self.frames, self.durations, self.onLoop)
  return newAnim
end

local function seekFrameIndex(intervals, timer)
  local high, low, i = #intervals-1, 1, 1

  while(low <= high) do
    i = math.floor((low + high) / 2)
    if     timer >  intervals[i+1] then low  = i + 1
    elseif timer <= intervals[i]   then high = i - 1
    else
      return i
    end
  end

  return i
end

function Animation:update(dt)
  self._looped = false
  if self.status ~= "playing" then return end

  self.timer = self.timer + dt
  local loops = math.floor(self.timer / self.totalDuration)
  if loops ~= 0 then
    self.timer = self.timer - self.totalDuration * loops
    local f = type(self.onLoop) == 'function' and self.onLoop or self[self.onLoop]
    f(self, loops)
    self._looped = true
  end

  self.position = seekFrameIndex(self.intervals, self.timer)
end

function Animation:getFramePosition(f)
  return unpack(self.framePositions[f or self.position])
end

function Animation:pause()
  self.status = "paused"
end

function Animation:looped()
  return self._looped
end

function Animation:gotoFrame(position)
  self._looped = false
  self.position = math.clamp(position, 0, #self.frames)
  self.timer = self.intervals[self.position]
end

function Animation:pauseAtEnd()
  self.position = #self.frames
  self.timer = self.totalDuration
  self:pause()
end

function Animation:pauseAtStart()
  self.position = 1
  self.timer = 0
  self:pause()
end

function Animation:resume()
  self.status = "playing"
end

function Animation:draw(image, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY)
  local frame = self.frames[self.position]
  local vx, vy, vw, vh = frame:getViewport()
  frame:setViewport(vx, vy, vw, vh, image:getDimensions())
  
  frame:draw(image, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY)
end

function Animation:getDimensions()
  local _,_,w,h = self.frames[self.position]:getViewport()
  return w,h
end

-----------------------------------------------------------

anim8.newGrid       = newGrid
anim8.newAnimation  = newAnimation