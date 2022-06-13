states = {}

function states.ser()
  return {
      currentState = states.currentStateObject,
      current = states.currentStatePath,
      switched = states.switched,
      recordOnSwitch = states.recordOnSwitch,
      openRecord = states.openRecord,
      queue = states.queue
    }
end

function states.deser(t)
  states.currentStateObject = t.currentState
  states.currentStatePath = t.current
  states.switched = t.switched
  states.recordOnSwitch = t.recordOnSwitch
  states.openRecord = t.openRecord
  states.queue = t.queue
end

states.currentStateObject = nil
states.currentStatePath = nil
states.queue = nil

state = class:extend()

function state:init() end
function state:begin() end
function state:update(dt) end
function state:draw() end
function state:switching() end
function state:unload() end

function states.set(p, before, after)
  states.switched = false
  if before then before() end
  
  local path = p
  local isStage = path and (path:sub(-10) == ".stage.lua" or path:sub(-10) == ".stage.tmx")
  local map
  local mapArgs = {}
  local sp = "|???|"
  
  if path then
    if path:sub(-10) == ".state.tmx" or path:sub(-10) == ".stage.tmx" then
      map = megautils.createMapEntity(path)
      local p = map.map.properties
      
      if p then
        local otherp = path:sub(0, -11)
        if p.state and p.state ~= "" then
          sp = p.state
        elseif love.filesystem.getInfo(otherp .. ".lua") then
          sp = otherp .. ".lua"
        end
        
        mapArgs.mPath = p.musicPath and p.musicPath ~= "" and p.musicPath
        mapArgs.mVolume = p.musicVolume or 1
        mapArgs.mTrack = p.gmeTrack or 0
        
        mapArgs.fadeIn = p.fadeIn == nil or p.fadeIn
      end
    else
      sp = path
    end
  end
  
  local lastState = states.currentStateObject
  
  if lastState then
    lastState:switching()
    entities.clear()
  end
  
  view.x, view.y = 0, 0
  states.switched = true
  
  local nextState = states.currentStateChunk
  
  if not nextState or states.currentStatePath ~= sp then
    if sp == "|???|" then
      nextState = state:extend()
    else
      nextState = love.filesystem.load(sp)
    end
  end
  
  states.currentStatePath = path
  
  if megautils.reloadState then
    megautils.runCallback(megautils.reloadStateFuncs)
  end
  
  if not nextState then
    error("State does not exist: \"" .. tostring(states.currentStatePath) .. "\"")
  end
  
  if megautils.reloadState and megautils.resetGameObjects then
    if lastState then
      lastState:unload()
      megautils.unload()
    end
    
    if isStage then
      megautils.runCallback(megautils.resetGameObjectsFuncs)
    end
    
    states.currentStateObject = nextState()
    
    if after then after() end
    
    states.currentStateObject:init()
  else
    states.currentStateObject = nextState()
    
    if after then after() end
  end
  
  if map then
    if mapArgs.mPath then
      music.playq(mapArgs.mPath, mapArgs.mVolume, mapArgs.mTrack)
    end
    
    entities.adde(map):addObjects()
    
    if mapArgs.fadeIn then
      entities.add(fade, false):setAfter(fade.remove)
    end
  end
  
  states.currentStateObject:begin()
  
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

function states.fadeToState(path, before, after)
  local tmp = fade(true, gap, nil, function(se)
      states.setq(se._path, se._before, se._after)
    end)
  tmp._path = path
  tmp._before = before
  tmp._after = after
  
  entities.adde(tmp)
end

function states.update(dt)
  if not states.currentStateObject then return end
  states.currentStateObject:update(dt)
end

function states.draw()
  if not states.currentStateObject then return end
  states.currentStateObject:draw()
end