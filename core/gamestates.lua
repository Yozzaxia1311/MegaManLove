states = {}

states.currentState = nil
states.current = nil
states.switched = false
states.recordOnSwitch = false
states.openRecord = nil
states.queue = nil

states.baseState = class:extend()

function states.baseState:new()
  self.system = entitySystem()
end

function states.baseState:begin() end
function states.baseState:update(dt) end
function states.baseState:draw() end
function states.baseState:switching() end
function states.baseState:unload() end
function states.baseState:init() end

states.state = states.baseState:extend()

function states.state:update(dt)
  megautils.update(self, dt)
end
function states.state:draw()
  megautils.draw(self)
end
function states.state:unload()
  megautils.unload()
end

function states.set(n, before, after)
  if before then before() end
  
  local nick = n
  
  local map
  local mapArgs = {}
  local sp
  if nick:sub(-4) == ".tmx" or (nick:sub(-10) ~= ".state.lua" and nick:sub(-4) == ".lua") then
    map = megautils.createMapEntity(nick)
    local p = states._map.map.properties
    
    if p then
      if p.state and p.state ~= "" then
        sp = p.state
      else
        sp = "states/map.state.lua"
        mapArgs.musicPath = p.musicPath and p.musicPath ~= "" and p.musicPath
        mapArgs.musicLoopPoint = p.musicLoopPoint
        mapArgs.musicLoopEndPoint = p.musicLoopEndPoint
        mapArgs.loopMusic = p.loopMusic
        mapArgs.musicVolume = p.musicVolume or 1
      end
    end
    
    map = true
  else
    sp = nick
  end
  
  if states.currentState then
    states.currentState:switching()
    if megautils.reloadState and megautils.resetGameObjects then
      states.currentState:unload()
    end
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
    states.set(states.current)
    return
  end
  
  if states.recordOnSwitch then
    states.recordOnSwitch = false
    control.drawDemoFunc = control.baseDrawDemoFunc
    control.resetRec()
    control.recordInput = true
    control.record.globals = table.clone(globals)
    control.record.convars = table.clone(convar)
    control.record.state = states.current
    control.record.seed = love.math.getRandomSeed()
  end
  
  if not states.currentChunk or states.current ~= sp then
    states.currentChunk = love.filesystem.load(sp)
  end
  states.currentState = states.currentState()
  states.switched = true
  
  if after then after() end
  
  if map then
    states.currentState.system:adde(map)
    states.currentState.musicPath = mapArgs.musicPath
    states.currentState.loopMusic = mapArgs.loopMusic
    states.currentState.musicLoopPoint = mapArgs.musicLoopPoint
    states.currentState.musicLoopEndPoint = mapArgs.musicLoopEndPoint
    states.currentState.musicVolume = mapArgs.musicVolume
  end
  
  if map and megautils.reloadState and megautils.resetGameObjects then
    for k, v in pairs(megautils.resetGameObjectsFuncs) do
      v()
    end
    states.currentState:init()
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
end

function states.update(dt)
  if not states.currentState then return end
  states.currentState:update(dt)
end

function states.draw()
  if not states.currentState then return end
  states.currentState:draw()
end
