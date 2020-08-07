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
function states.baseState:switching() end
function states.baseState:unload() end
function states.baseState:init() end

states.state = states.baseState:extend()

function states.state:update(dt)
  megautils.update(self, dt)
end
function states.state:draw()
  self.system:draw()
end
function states.state:unload()
  megautils.unload()
end

function states.set(n, before, after)
  if before then before() end
  
  local nick = n
  local isStage = nick:sub(-10) == ".stage.lua" or nick:sub(-10) == ".stage.tmx"
  local map
  local mapArgs = {}
  local sp = "assets/states/blank.lua"
    
  if nick:sub(-10) == ".state.tmx" or nick:sub(-10) == ".stage.tmx" then
    map = megautils.createMapEntity(nick)
    local p = map.map.properties
    
    if p then
      local otherp = nick:sub(0, -11)
      if p.state and p.state ~= "" then
        sp = p.state
      elseif love.filesystem.getInfo(otherp .. ".lua") then
        sp = otherp .. ".lua"
      end
      
      mapArgs.mPath = p.musicPath and p.musicPath ~= "" and p.musicPath
      mapArgs.mLoopPoint = (p.musicLoopPoint and p.musicLoopPoint ~= 0) and p.musicLoopPoint
      mapArgs.mLoopEndPoint = (p.musicLoopEndPoint and p.musicLoopEndPoint ~= 0) and p.musicLoopEndPoint
      mapArgs.mLoop = p.musicLoop == nil or p.musicLoop
      mapArgs.mVolume = p.musicVolume or 1
      
      mapArgs.fadeIn = p.fadeIn == nil or p.fadeIn
    end
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
  
  if megautils.reloadState then
    for k, v in pairs(megautils.reloadStateFuncs) do
      v()
    end
  end
  
  if not states.currentChunk or states.current ~= sp then
    states.currentChunk = love.filesystem.load(sp)
  end
  
  view.x, view.y = 0, 0
  
  states.current = nick
  states.currentState = states.currentChunk()
  states.currentState.system = entitySystem()
  states.switched = true
  
  if after then after() end
  
  if megautils.reloadState and megautils.resetGameObjects then
    if isStage then
      for k, v in pairs(megautils.resetGameObjectsFuncs) do
        v()
      end
    end
    states.currentState:init()
  end
  
  if map then
    states.currentState.system:adde(map):addObjects()
    
    if mapArgs.fadeIn then
      states.currentState.system:add(fade, false):setAfter(fade.remove)
    end
    
    if mapArgs.mPath then
      megautils.playMusic(mapArgs.mPath, mapArgs.mLoop, mapArgs.mLoopPoint, mapArgs.mLoopEndPoint, mapArgs.mVolume)
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
end

function states.update(dt)
  if not states.currentState then return end
  states.currentState:update(dt)
end

function states.draw()
  if not states.currentState then return end
  states.currentState:draw()
end
