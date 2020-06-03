states = {}

states.currentstate = nil
states.current = nil
states.switched = false
states.recordOnSwitch = false
states.openRecord = nil

states.baseState = class:extend()

function states.baseState:begin() end
function states.baseState:update(dt) end
function states.baseState:draw() end
function states.baseState:stop() end

states.state = states.baseState:extend()

function states.state:begin() end
function states.state:update(dt)
  megautils.update(self, dt)
end
function states.state:draw()
  megautils.draw(self)
end
function states.state:stop()
  megautils.unload()
end

function states.set(n, s, after)
  local nick = n
  if states.currentstate then
    states.currentstate:stop()
  end
  if states.openRecord then
    control.resetRec()
    control.record = save.load(states.openRecord)
    nick = control.record.state
    states.openRecord = nil
    control.oldGlobals = globals
    globals = control.record.globals
    love.math.setRandomSeed(control.record.seed)
    control.demo = true
    megautils.gotoState(nick)
    return
  end
  if states.recordOnSwitch then
    states.recordOnSwitch = false
    control.drawDemoFunc = control.baseDrawDemoFunc
    control.resetRec()
    control.recordInput = true
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
  if megautils.reloadState and megautils.resetGameObjects then
    for k, v in pairs(megautils.resetGameObjectsPreFuncs) do
      v()
    end
  end
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
