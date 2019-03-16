states = {}

states.currentstate = nil
states.current = nil
states.switched = false

states.state = class:extend()

function states.state:begin() end
function states.state:update(dt) end
function states.state:draw() end
function states.state:stop() end

function states.set(n, s, ignoreGamePath)
  local nick = n
  if states.currentstate then
    states.currentstate:stop()
  end
  if not s and (not states.currentChunk or states.current ~= nick) then
    if ignoreGamePath then
      states.currentChunk = love.filesystem.load(nick)
    else
      states.currentChunk = love.filesystem.load(gamePath .. "/" .. nick)
    end
  end
  states.current = nick
  states.currentstate = s or states.currentChunk()
  states.currentstate.system = states.currentstate.system or entitysystem()
  states.switched = true
  states.currentstate:begin()
end

function states.update(dt)
  if not states.currentstate then return end
  states.currentstate:update(dt)
end

function states.draw()
  if not states.currentstate then return end
  states.currentstate:draw()
end