states = {}

states.currentstate = nil
states.current = nil
states.switched = false
states.recordOnSwitch = false
states.openRecord = nil

states.state = class:extend()

function states.state:begin() end
function states.state:update(dt) end
function states.state:draw() end
function states.state:stop() end

function states.set(n, s, after)
  local nick = n
  if states.currentstate then
    states.currentstate:stop()
  end
  if states.openRecord then
    control.record = table.stringtonumberkeys(save.load(states.openRecord))
    control.recPos = 1
    nick = control.record.state
    states.openRecord = nil
    globals = control.record.globals
    love.math.setRandomSeed(control.record.seed)
    control.demo = true
    states.set(nick)
    return
  end
  if states.recordOnSwitch then
    states.recordOnSwitch = false
    control.recordInput = true
    control.record = {}
    control.recPos = 1
    control.record.globals = table.clone(globals)
    control.record.state = nick
    control.record.seed = love.math.getRandomSeed()
  end
  if states.currentChunk == nil or states.current ~= nick then
    states.currentChunk = love.filesystem.load(nick)
  end
  states.current = nick
  states.currentstate = s or states.currentChunk()
  states.currentstate.system = states.currentstate.system or entitysystem()
  states.switched = true
  if after then after() end
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
