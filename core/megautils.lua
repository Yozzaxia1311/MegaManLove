megautils = {}

--Game / state callback functions.
--[[
  Examples:
  megautils.reloadStateFuncs.exampleFunc = function()
      *Code here will execute whenever the state is changed and `megautils.reloadState` is true.*
    end
  
  megautils.cleanFuncs.exampleFunc = function()
      *Code here will execute whenever the state is changed and `megautils.reloadState` and `megautils.manageStageResources` is true*
    end
  
  megautils.resetGameObjectsFuncs.exampleFunc = function()
      *Code here will execute when you gameover, a boss dies and changes the state,
      or `initEngine` is called (usually when the game is first initialized, or is coming back from a demo)*
    end
]]--
megautils.reloadState = true
megautils.manageStageResources = true
megautils.reloadStateFuncs = {}
megautils.cleanFuncs = {}
megautils.resetGameObjectsFuncs = {}
megautils.initEngineFuncs = {}

--Player callback functions. These apply to all active players.
megautils.playerCreatedFuncs = {}       --megautils.playerCreatedFuncs.exampleFunc = function(player) end
megautils.playerTransferFuncs = {}      --megautils.playerTransferFuncs.exampleFunc = function(fromPlayer, toPlayer) end
megautils.playerGroundFuncs = {}        --megautils.playerGroundFuncs.exampleFunc = function(player) end
megautils.playerAirFuncs = {}           --megautils.playerAirFuncs.exampleFunc = function(player) end
megautils.playerSlideFuncs = {}         --megautils.playerSlideFuncs.exampleFunc = function(player) end
megautils.playerClimbFuncs = {}         --megautils.playerClimbFuncs.exampleFunc = function(player) end
megautils.playerKnockbackFuncs = {}     --megautils.playerKnockbackFuncs.exampleFunc = function(player) end
megautils.playerTrebleFuncs = {}        --megautils.playerTrebleFuncs.exampleFunc = function(player) end
megautils.playerHealthChangedFuncs = {} --megautils.playerHealthChangedFuncs.exampleFunc = function(player) end
megautils.playerDeathFuncs = {}         --megautils.playerDeathFuncs.exampleFunc = function(player) end
megautils.playerAttemptWeaponFuncs = {} --megautils.playerAttemptWeaponFuncs.exampleFunc = function(player, shotsInTable) end

function megautils.setFullscreen(what)
  convar.setValue("fullscreen", what and 1 or 0, true)
end

function megautils.getFullscreen()
  return convar.getNumber("fullscreen") == 1
end

function megautils.enableConsole()
  useConsole = true
end

function megautils.disableConsole()
  console.close()
  console.lines = {}
  console.y = -112*2
  useConsole = false
end

function megautils.runFile(path)
  return love.filesystem.load(path)()
end

function megautils.resetGame(s, saveSfx, saveMusic)
  if not saveSfx then
    megautils.stopAllSounds()
  end
  if not saveMusic then
    megautils.stopMusic()
  end
  megautils.reloadState = true
  megautils.manageStageResources = true
  megautils.unload()
  initEngine()
  states.set(s or "states/disclaimer.state.lua")
end

function megautils.getResource(nick)
  return loader.get(nick)
end

function megautils.getAllResources()
  local all = {}
  for k, v in pairs(loader.locked) do
    all[k] = v
  end
  for k, v in pairs(loader.resources) do
    all[k] = v
  end
  return all
end

function megautils.unloadResource(nick)
  loader.unload(nick)
end

function megautils.unloadAllResources()
  loader.clear()
end

function megautils.setResourceLock(nick, w)
  if w then
    loader.lock(nick)
  else
    loader.unlock(nick)
  end
end

local function checkExt(ext, list)
  for k, v in ipairs(list) do
    if ext:lower() == v then
      return true
    end
  end
  return false
end

function megautils.loadResource(...)
  local args = {...}
  if #args == 0 then error("megautils.load takes at least two arguments") end
  local locked = false
  local path = args[1]
  local nick = args[2]
  local t = path:split("%.")
  t = t[#t]
  
  if type(args[2]) == "number" and type(args[3]) == "number" then
    t = "grid"
    path = nil
    nick = args[1]
    if not args[4] or not args[5] then
      error("Missing arguments for grid")
    end
    if type(args[#args]) == "boolean" then
      locked = args[#args]
    end
    return loader.load(nil, nick, t, {args[2], args[3], args[4], args[5],
      (type(args[6]) ~= "boolean") and args[6], (type(args[7]) ~= "boolean") and args[7]}, locked)
  elseif checkExt(t, {"png", "jpeg", "jpg", "bmp", "tga", "hdr", "pic", "exr"}) then
    local ext = t
    t = "texture"
    if #args == 4 then
      locked = args[4]
      if is3DS then
        path = path:gsub(ext, ".csv")
      end
      return loader.load(path, nick, t, {args[3]}, locked)
    else
      locked = args[3]
      return loader.load(path, nick, t, nil, locked)
    end
  elseif checkExt(t, {"ogg", "mp3", "wav", "flac", "oga", "ogv", "xm", "it", "mod", "mid", "669", "amf", "ams", "dbm", "dmf", "dsm", "far",
      "j2b", "mdl", "med", "mt2", "mtm", "okt", "psm", "s3m", "stm", "ult", "umx", "abc", "pat"}) then
    if type(args[3]) == "string" then
      t = args[3]
      locked = args[4]
    else
      t = "sound"
      locked = args[3]
    end
    return loader.load(path, nick, t, nil, locked)
  else
    error("Could not detect resource type of \"" .. path .. "\" based on file extension")
  end
end

megautils._curM = nil
megautils._lockM = false

function megautils.setMusicLock(w)
  megautils._lockM = w
end

function megautils.getCurrentMusic()
  return megautils._curM
end

function megautils.playMusic(path, loop, lp, lep, vol)
  if megautils._lockM or (megautils._curM and megautils._curM.id == path and not megautils_curM:stopped()) then return end
  megautils.stopMusic()
  
  megautils._curM = mmMusic(love.audio.newSource(path, isWeb and "static" or "stream"))
  megautils._curM.id = path
  megautils._curM.playedVol = vol
  megautils._curM:play(loop, lp, lep, vol)
end

function megautils.playMusicWithSeperateIntroFile(lPath, iPath, vol)
  if megautils._lockM or (megautils._curM and megautils._curM.id == (lPath .. ", " .. iPath) and not megautils_curM:stopped()) then return end
  megautils.stopMusic()
  
  local t = isWeb and "static" or "stream"
  megautils._curM = mmMusicOld(love.audio.newSource(lPath, t), love.audio.newSource(iPath, t))
  megautils._curM.id = lPath .. ", " .. iPath
  megautils._curM.playedVol = vol
  megautils._curM:play(loop, lp, vol)
end

function megautils.stopMusic()
  if not megautils._lockM and megautils._curM then
    megautils._curM:pause()
    megautils._curM = nil
  end
end

function megautils.playSound(p, l, v, stack)
  if megautils.getResource(p) then
    if not stack then
      megautils.getResource(p):stop()
    end
    megautils.getResource(p):setLooping(l or false)
    megautils.getResource(p):setVolume(v or 1)
    megautils.getResource(p):play()
  end
end

megautils._curS = {}

function megautils.playSoundFromFile(p, l, v, stack)
  local s = megautils._curS.sfx
  if s and not stack then
    s:stop()
  end
  if not s or megautils._curS.id ~= p then
    s = love.audio.newSource(p, "static")
  end
  s:setLooping(l == true)
  s:setVolume(v or 1)
  s:play()
  megautils._curS.id = p
  megautils._curS.sfx = s
end

function megautils.stopSound(s)
  if megautils.getResource(s) then
    megautils.getResource(s):stop()
  end
  if s == megautils._curS.id and megautils._curS.sfx then
    megautils._curS.sfx:stop()
  end
end

function megautils.stopAllSounds()
  for k, v in pairs(loader.resources) do
    if v.type and v:type() == "Source" then
      v:stop()
    end
  end
  for k, v in pairs(loader.locked) do
    if v.type and v:type() == "Source" then
      v:stop()
    end
  end
  if megautils._curS.sfx then
    megautils._curS.sfx:stop()
  end
end

function megautils.update(self, dt)
  if megautils._curM then
    megautils._curM:update()
  end
  self.system:update(dt)
end

function megautils.draw(self)
  view.draw(self.system)
end

function megautils.unload()
  if megautils.reloadState then
    for k, v in pairs(megautils.reloadStateFuncs) do
      v()
    end
    if megautils.manageStageResources then
      for k, v in pairs(megautils.cleanFuncs) do
        v()
      end
      megautils.unloadAllResources()
    end
    megautils.frozen = {}
  end
end

function megautils.loadMap(self, path)
  self.currentMap = cartographer.load(path)
  local map = self.currentMap
  local function recursiveLayerChecking(tab, otab)
    for k, v in pairs(tab.layers) do
      if v.type == "objectgroup" then
        for i, j in pairs(v.objects) do
          otab[#otab+1] = j
        end
      elseif v.type == "group" then
        recursiveLayerChecking(v, otab)
      end
    end
    return otab
  end
  local objs = recursiveLayerChecking(map, {})
  addobjects.add(objs)
  local tmp = megautils.add(trigger, function(s, dt)
    s.map:update(1/60)
  end, function(s)
    s.map:setDrawRange(view.x, view.y, view.w, view.h)
    s.map:draw()
  end)
  tmp:setLayer(-5)
  tmp.map = map
end

function megautils.loadStage(self, path)
  if megautils.reloadState and megautils.manageStageResources then
    megautils.runFile("entities/mechanics/bossdoor.lua")
    megautils.runFile("entities/mechanics/death.lua")
    megautils.runFile("entities/mechanics/ladder.lua")
    megautils.runFile("entities/mechanics/checkpoint.lua")
    megautils.runFile("entities/mechanics/solid.lua")
    
    megautils.resetGameObjects()
  end
  
  megautils.loadMap(self, path)
end

function megautils.map()
  return states.currentstate.currentMap
end

function megautils.getMapLayer(name)
  local function recursiveCheck(tab, n)
    if tab and tab.layers then
      for k, v in pairs(tab.layers) do
        if v.name == n then
          return v
        elseif v.type == "group" then
          recursiveCheck(v, n)
        end
      end
    end
  end
  return recursiveCheck(megautils.map(), name)
end

function megautils.getMapLayerByID(name)
  local function recursiveCheck(tab, n)
    if tab and tab.layers then
      for k, v in pairs(tab.layers) do
        if v.id == n then
          return v
        elseif v.type == "group" then
          recursiveCheck(v, n)
        end
      end
    end
  end
  return recursiveCheck(megautils.map(), name)
end

function megautils.setMapLayerTile(name, x, y, gid, ts)
  local l = megautils.getMapLayer(name)
  l:setTileAtGridPosition(x, y, gid, ts)
end

function megautils.setMapLayerIDTile(name, x, y, gid, ts)
  local l = megautils.getMapLayerByID(name)
  l:setTileAtGridPosition(x, y, gid, ts)
end

function megautils.transitionToState(s, before, after, chunk)
  local tmp = megautils.add(fade, true, nil, nil, function(se)
        if before then before() end
        megautils.remove(se)
        megautils.gotoState(s, chunk)
        if after then after() end
      end)
end

function megautils.gotoState(s, chunk)
  states.set(s, chunk)
end

function megautils.setLayerFlicker(l, b)
  states.currentstate.system:setLayerFlicker(l, b)
end

function megautils.remove(o)
  states.currentstate.system:remove(o)
end

function megautils.removeq(o)
  states.currentstate.system:removeq(o)
end

function megautils.inAddQueue(o)
  return table.contains(states.currentstate.system.addQueue, o)
end

function megautils.inRemoveQueue(o)
  return table.contains(states.currentstate.system.removeQueue, o)
end

function megautils.stopAddQueue(o)
  table.quickremovevaluearray(states.currentstate.system.addQueue, o)
end

function megautils.stopRemoveQueue(o)
  table.quickremovevaluearray(states.currentstate.system.removeQueue, o)
end

function megautils.state()
  return states.currentstate
end

function megautils.add(o, ...)
  return states.currentstate.system:add(o, ...)
end

function megautils.adde(o)
  return states.currentstate.system:adde(o)
end

function megautils.addq(o, ...)
  return states.currentstate.system:addq(o, ...)
end

function megautils.addeq(o)
  return states.currentstate.system:addeq(o)
end

function megautils.getRecycled(o, ...)
  return states.currentstate.system:getRecycled(o, ...)
end

function megautils.emptyRecycling(c, num)
  states.currentstate.system:emptyRecycling(c, num)
end

function megautils.groups()
  return states.currentstate.system.groups
end

function megautils.calcX(angle)
  return math.cos(math.rad(angle))
end

function megautils.calcY(angle)
  return -math.sin(math.rad(angle))
end

function megautils.calcPath(x, y, x2, y2)
  return math.deg(math.atan2(y - y2, x2 - x))
end

function megautils.circlePathX(x, deg, dist)
  return x + (megautils.calcX(deg) * dist)
end
function megautils.circlePathY(y, deg, dist)
  return y + (megautils.calcY(deg) * dist)
end

function megautils.resetGameObjects()
  for k, v in pairs(megautils.resetGameObjectsFuncs) do
    v()
  end
end

function megautils.revivePlayer(p)
  megaMan.weaponHandler[p]:switch(0)
  megaMan.colorOutline[p] = megaMan.weaponHandler[p].colorOutline[0]
  megaMan.colorOne[p] = megaMan.weaponHandler[p].colorOne[0]
  megaMan.colorTwo[p] = megaMan.weaponHandler[p].colorTwo[0]
end

function megautils.registerPlayer(e, p)
  if not globals.mainPlayer then
    globals.mainPlayer = e
  end
  globals.allPlayers[#globals.allPlayers+1] = e
  e.player = p
  
  if #globals.allPlayers > 1 then
    local keys = {}
    local vals = {}
    for k, v in pairs(globals.allPlayers) do
      keys[#keys+1] = v.player
      vals[v.player] = v
      globals.allPlayers[k] = nil
    end
    table.sort(keys)
    for j=1, #keys do
      globals.allPlayers[j] = vals[keys[j]]
    end
  end
  
  if e == globals.allPlayers[1] then
    globals.mainPlayer = e
  end
end

function megautils.unregisterPlayer(e)
  table.removevaluearray(globals.allPlayers, e)
  if globals.mainPlayer == e then
    globals.mainPlayer = globals.allPlayers[1]
  end
end

megautils.frozen = {}

function megautils.freeze(e, name)
  if megautils.groups().freezable then
    for k, v in pairs(megautils.groups().freezable) do
      if not e or not table.contains(e, v) then
        megautils.frozen[#megautils.frozen+1] = v
        if name then
          v.updatedSpecial[name] = false
        else
          v.updated = false
        end
      end
    end
  end
end
function megautils.unfreeze(e, name)
  if megautils.groups().freezable then
    for k, v in pairs(megautils.groups().freezable) do
      if not e or not table.contains(e, v) then
        if name then
          v.updatedSpecial[name] = true
        else
          v.updated = true
        end
        if not v:checkTrue(v.updatedSpecial) then
          table.removevalue(megautils.frozen, v)
        end
      end
    end
  end
end

function megautils.outside(o, ex, ey)
  return o.collisionShape and not rectOverlapsRect(view.x-(ex or 0), view.y-(ey or 0), view.w+((ex or 0)*2), view.h+((ey or 0)*2), 
    o.transform.x, o.transform.y, o.collisionShape.w, o.collisionShape.h)
end

function megautils.outsideSection(o, ex, ey)
  local result = true
  if o.collisionShape and o.actualSectionGroups then
    local lw, lh = o.collisionShape.w, o.collisionShape.h
    o.collisionShape.w = o.collisionShape.w + ((ex or 0)*2)
    o.collisionShape.h = o.collisionShape.h + ((ey or 0)*2)
    for k, v in ipairs(o.actualSectionGroups) do
      if o:collision(v, -ex or 0, -ey or 0) then
        result = false
      end
    end
    o.collisionShape.w, o.collisionShape.h = lw, lh
  end
  return result
end

--w: Width of drawable
--h: Height of drawable
--x: X to draw to
--y: Y to draw to
function megautils.drawTiled(w, h, x, y, w2, h2, draw)
  for x2=1, math.round(w2/w) do
    for y2=1, math.round(h2/h) do
      draw(x+(w*x2)-w, y+(h*y2)-h)
    end
  end
end

megautils.shake = false
megautils.shakeX = 2
megautils.shakeY = 0
megautils.shakeSide = false
megautils.shakeTimer = 0
megautils.maxShakeTime = 5

function megautils.updateShake()
  if megautils.shake then
    megautils.shakeTimer = math.min(megautils.shakeTimer+1, megautils.maxShakeTime)
    if megautils.shakeTimer == megautils.maxShakeTime then
      megautils.shakeTimer = 0
      megautils.shakeSide = not megautils.shakeSide
    end
    love.graphics.translate(megautils.shakeSide and megautils.shakeX or -megautils.shakeX,
      megautils.shakeSide and megautils.shakeY or -megautils.shakeY)
  else
    megautils.shakeSide = false
    megautils.shakeTimer = 0
  end
end

function megautils.setShake(x, y, t)
  megautils.shakeX = x
  megautils.shakeY = y
  megautils.maxShakeTime = t or megautils.maxShakeTime
  megautils.shake = x ~= 0 or y ~= 0
end

function megautils.dropItem(x, y)
  local rnd = love.math.random(10000)
  if math.between(rnd, 0, 39) then
    local rnd2 = love.math.random(0, 2)
    if rnd2 == 0 then
      megautils.add(life, x, y, true)
    elseif rnd2 == 1 then
      megautils.add(eTank, x, y, true)
    else
      megautils.add(wTank, x, y, true)
    end
  elseif math.between(rnd, 50, 362) then
    if math.randomboolean() then
      megautils.add(health, x, y, true)
    else
      megautils.add(energy, x, y, true)
    end
  elseif math.between(rnd, 370, 995) then
    if math.randomboolean() then
      megautils.add(smallHealth, x, y, true)
    else
      megautils.add(smallEnergy, x, y, true)
    end
  end
end

function megautils.center(e)
  return e.transform.x+e.collisionShape.w/2, e.transform.y+e.collisionShape.h/2
end

function megautils.dist(e, e2)
  local cx, cy = megautils.center(e)
  local cx2, cy2 = megautils.center(e2)
  local path = megautils.calcPath(cx2, cy2, cx, cy)
  return math.dist2d(megautils.circlePathX(cx, path, e.collisionShape.w/2),
    megautils.circlePathY(cy, path, e.collisionShape.h/2),
    megautils.circlePathX(cx2, path, e2.collisionShape.w/2),
    megautils.circlePathY(cy2, path, e2.collisionShape.h/2))
end

function megautils.closest(e, group, single)
  if not group or single then return group end
  if #group == 1 then return group[1] end
  local closest = math.huge
  local result
  for i=1, #group do
    local p = group[i]
    local dist = megautils.dist(e, p)
    if closest > dist then
      result = p
      closest = dist
    end
  end
  return result
end

function megautils.autoFace(e, to, single)
  local closest = megautils.closest(e, to, single)
  if closest then
    if closest.transform.x+closest.collisionShape.w/2 >
      e.transform.x+e.collisionShape.w/2 then
      e.side = 1
    elseif closest.transform.x+closest.collisionShape.w/2 <
      e.transform.x+e.collisionShape.w/2 then
      e.side = -1
    end
  end
  return closest
end

function megautils.pointVelAt(e, to)
  local cx, cy = megautils.center(e)
  local cx2, cy2 = megautils.center(to)
  local p = megautils.calcPath(cx, cy, cx2, cy2)
  return megautils.calcX(p), megautils.calcY(p)
end

function megautils.pointAt(e, to)
  local cx, cy = megautils.center(e)
  local cx2, cy2 = megautils.center(to)
  return megautils.calcPath(cx, cy, cx2, cy2)
end

function megautils.arcXVel(yvel, grav, x, y, tox, toy)
  if not grav or grav == 0 then
    return megautils.calcX(megautils.calcPath(x, y, tox, toy))
  end
  
  local ly = y
  local py = ly
  local vel = yvel
  local time = 0
  
  while true do
    time = time + 1
    py = ly
    ly = ly + vel
    vel = vel + grav
    if grav > 0 and ((ly >= toy and py < toy) or (vel > 0 and ly > toy)) then
      break
    elseif grav < 0 and ((ly <= toy and py > toy) or (vel < 0 and ly < toy)) then
      break
    end
  end
  
  local result = (tox - x) / time
  
  return result
end

function megautils.getDifficulty()
  return convar.getString("diff")
end

function megautils.setDifficulty(d)
  convar.setValue("diff", d or convar.getString("diff"))
end

function megautils.diff(...)
  for k, v in pairs({...}) do
    if v == convar.getString("diff") then
      return true
    end
  end
  return false
end

function megautils.diffValue(def, t)
  for k, v in pairs(t) do
    if k == convar.getString("diff") then
      return v
    end
  end
  return def
end
