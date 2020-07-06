states = {}

states.currentState = nil
states.current = nil
states.switched = false
states.recordOnSwitch = false
states.openRecord = nil
states.queue = nil

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

function states.set(n, s, before, after)
  if before then before() end
  local nick = n
  if states.currentState then
    states.currentState:stop()
  end
  if states.openRecord then
    control.resetRec()
    control.record = save.load(states.openRecord)
    nick = control.record.state
    states.openRecord = nil
    control.oldGlobals = globals
    globals = control.record.globals
    control.oldConvars = convar
    convar = control.record.convars
    love.math.setRandomSeed(control.record.seed)
    control.demo = true
    states.set(nick)
    return
  end
  if states.recordOnSwitch then
    states.recordOnSwitch = false
    control.drawDemoFunc = control.baseDrawDemoFunc
    control.resetRec()
    control.recordInput = true
    control.record.globals = table.clone(globals)
    control.record.convars = table.clone(convar)
    control.record.state = nick
    control.record.seed = love.math.getRandomSeed()
  end
  if states.currentChunk == nil or states.current ~= nick then
    states.currentChunk = love.filesystem.load(nick)
  end
  states.current = nick
  states.currentState = s or states.currentChunk()
  states.currentState.system = states.currentState.system or entitySystem()
  states.switched = true
  if after then after() end
  if megautils.reloadState and megautils.resetGameObjects then
    for k, v in pairs(megautils.resetGameObjectsPreFuncs) do
      v()
    end
  end
  states.currentState:begin()
end

function states.setq(n, s, after)
  states.queue = {n, s, after}
end

function states.checkQueue()
  if states.queue then
    states.set(unpack(states.queue))
    states.queue = nil
  end
  states.switched = false
end

function states.update(dt)
  if not states.currentState then return end
  states.currentState:update(dt)
end

function states.draw()
  if not states.currentState then return end
  states.currentState:draw()
end
