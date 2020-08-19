states = {}

function states.ser()
  return {
      currentState = binser.serialize(states.currentState),
      current = states.current,
      switched = states.switched,
      recordOnSwitch = states.recordOnSwitch,
      openRecord = states.openRecord,
      queue = states.queue and table.clone(states.queue)
    }
end

function states.deser(t)
  states.currentState = binser.deserialize(t.currentState)
  states.current = t.current
  states.switched = t.switched
  states.recordOnSwitch = t.recordOnSwitch
  states.openRecord = t.openRecord
  states.queue = t.queue
end

states.currentState = nil
states.current = nil
states.switched = false
states.recordOnSwitch = false
states.openRecord = nil
states.queue = nil

baseState = class:extend()

function baseState:begin() end
function baseState:update(dt) end
function baseState:draw() end
function baseState:switching() end
function baseState:unload() end
function baseState:init() end

state = baseState:extend()

function state:update(dt)
  self.system:update(dt)
end
function state:draw()
  self.system:draw()
end
function state:unload()
  megautils.unload()
end

function states.set(n, before, after)
  states.switched = false
  if before then before() end
  
  local nick = n
  local isStage = nick and (nick:sub(-10) == ".stage.lua" or nick:sub(-10) == ".stage.tmx")
  local map
  local mapArgs = {}
  local sp = "assets/states/blank.lua"
  
  if nick then
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
    
    lastPressed = nil
    lastTextInput = nil
    lastTouch = nil
    keyboardCheck = {}
    gamepadCheck = {}
    megautils._q = {}
    
    control.demo = true
    
    control.oldContext = states.ser()
    states.deser(control.record.context)
    return
  end
  
  view.x, view.y = 0, 0
  states.switched = true
  
  if not states.currentChunk or states.current ~= sp then
    states.currentChunk = love.filesystem.load(sp)
  end
  
  states.current = nick
  
  if states.recordOnSwitch then
    lastPressed = nil
    lastTextInput = nil
    lastTouch = nil
    keyboardCheck = {}
    gamepadCheck = {}
    megautils._q = {}
    states.recordOnSwitch = false
    control.updateDemoFunc = nil
    control.drawDemoFunc = nil
    control.resetRec()
    control.recordInput = true
    
    control.record.context = states.ser()
    
    control.record.state = sp
  end
  
  if megautils.reloadState then
    for k, v in pairs(megautils.reloadStateFuncs) do
      if type(v) == "function" then
        v()
      else
        v.func()
      end
    end
  end
  
  states.currentState = states.currentChunk()
  states.currentState.system = entitySystem()
  
  if after then after() end
  
  if megautils.reloadState and megautils.resetGameObjects then
    if isStage then
      for k, v in pairs(megautils.resetGameObjectsFuncs) do
        if type(v) == "function" then
          v()
        else
          v.func()
        end
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

function states.setq(n, before, after)
  states.queue = {n, before, after}
end

function states.checkQueue()
  if states.queue then
    local q = states.queue
    states.queue = nil
    states.set(q[1], q[2], q[3])
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