states = {}

function states.ser()
  return {
      currentState = states.currentState,
      current = states.current,
      switched = states.switched,
      recordOnSwitch = states.recordOnSwitch,
      openRecord = states.openRecord,
      queue = states.queue
    }
end

function states.deser(t)
  states.currentState = t.currentState
  states.current = t.current
  states.switched = t.switched
  states.recordOnSwitch = t.recordOnSwitch
  states.openRecord = t.openRecord
  states.queue = t.queue
end

states.currentState = nil
states.current = nil
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
function state:switching()
  self.system:clear()
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
  local sp = "|???|"
  
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
        mapArgs.mVolume = p.musicVolume or 1
        
        mapArgs.fadeIn = p.fadeIn == nil or p.fadeIn
      end
    else
      sp = nick
    end
  end
  
  local lastState = states.currentState
  
  if lastState then
    lastState:switching()
  end
  
  view.x, view.y = 0, 0
  states.switched = true
  
  local nextState = states.currentChunk
  
  if not nextState or states.current ~= sp then
    if sp == "|???|" then
      nextState = state:extend()
    else
      nextState = love.filesystem.load(sp)
    end
  end
  
  states.current = nick
  
  if megautils.reloadState then
    for _, v in pairs(megautils.reloadStateFuncs) do
      if type(v) == "function" then
        v()
      else
        v.func()
      end
    end
  end
  
  if not nextState then
    error("State does not exist: \"" .. tostring(states.current) .. "\"")
  end
  
  if megautils.reloadState and megautils.resetGameObjects then
    if lastState then
      lastState:unload()
    end
    
    if isStage then
      for _, v in pairs(megautils.resetGameObjectsFuncs) do
        if type(v) == "function" then
          v()
        else
          v.func()
        end
      end
    end
    
    states.currentState = nextState()
    states.currentState.system = entitySystem()
    
    if after then after() end
    
    states.currentState:init()
  else
    states.currentState = nextState()
    states.currentState.system = entitySystem()
    
    if after then after() end
  end
  
  if map then
    if mapArgs.mPath then
      megautils.playMusic(mapArgs.mPath, mapArgs.mVolume)
    end
    
    states.currentState.system:adde(map):addObjects()
    
    if mapArgs.fadeIn then
      states.currentState.system:add(fade, false):setAfter(fade.remove)
    end
  end
  
  states.currentState:begin()
  
  collectgarbage()
  collectgarbage()
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