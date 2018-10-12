states = {}

states.currentstate = nil
states.current = nil
states.switched = false

states.state = class:extend()

function states.state:begin() end
function states.state:update(dt) end
function states.state:draw() end
function states.state:stop() end

function states.set(n, s)
  local nick = n
  if states.currentstate ~= nil then
    states.currentstate:stop()
  end
  if s == nil and (states.currentChunk == nil or states.current ~= nick) then
    states.currentChunk = love.filesystem.load(nick)
  end
  states.current = nick
  states.currentstate = s or states.currentChunk()
  states.currentstate.system = states.currentstate.system or entitysystem()
  states.switched = true
  states.currentstate:begin()
end

function states.update(dt)
  if states.currentstate == nil then return end
  states.currentstate:update(dt)
end

function states.draw()
  if states.currentstate == nil then return end
  states.currentstate:draw()
end