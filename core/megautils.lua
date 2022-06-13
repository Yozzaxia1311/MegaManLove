megautils = {}

function megautils.ser()
  local result = {}
  local callbacks = {
      "reloadStateFuncs",
      "cleanFuncs",
      "resetGameObjectsFuncs",
      "initEngineFuncs",
      "addMapFuncs",
      "removeMapFuncs",
      "sectionChangeFuncs",
      "difficultyChangeFuncs",
      "postAddObjectsFuncs",
      "skinChangeFuncs",
      "playerCreatedFuncs",
      "playerTransferFuncs",
      "playerGroundFuncs",
      "playerAirFuncs",
      "playerSlideFuncs",
      "playerClimbFuncs",
      "playerKnockbackFuncs",
      "playerTrebleFuncs",
      "playerInteractedWithFuncs",
      "playerDeathFuncs",
      "playerAttemptWeaponFuncs",
      "playerPauseFuncs",
      "playerControlUpdateFuncs"
    }
  
  for _, v in ipairs(callbacks) do
    result[v] = megautils[v]
  end
  
  result._q = megautils._q
  result._ranFiles = megautils._ranFiles
  result.shake = megautils.shake
  result.shakeX = megautils.shakeX
  result.shakeY = megautils.shakeY
  result.shakeSide = megautils.shakeSide
  result.shakeTimer = megautils.shakeTimer
  result.maxShakeTime = megautils.maxShakeTime
  result.shakeLength = megautils.shakeLength
  
  return result
end

function megautils.deser(t)
  local callbacks = {
      "reloadStateFuncs",
      "cleanFuncs",
      "resetGameObjectsFuncs",
      "initEngineFuncs",
      "addMapFuncs",
      "removeMapFuncs",
      "sectionChangeFuncs",
      "difficultyChangeFuncs",
      "postAddObjectsFuncs",
      "skinChangeFuncs",
      "playerCreatedFuncs",
      "playerTransferFuncs",
      "playerGroundFuncs",
      "playerAirFuncs",
      "playerSlideFuncs",
      "playerClimbFuncs",
      "playerKnockbackFuncs",
      "playerTrebleFuncs",
      "playerInteractedWithFuncs",
      "playerDeathFuncs",
      "playerAttemptWeaponFuncs",
      "playerPauseFuncs",
      "playerControlUpdateFuncs"
    }
  
  for _, v in ipairs(callbacks) do
    megautils[v] = t[v]
  end
  
  megautils._q = t._q
  megautils.shake = t.shake
  megautils.shakeX = t.shakeX
  megautils.shakeY = t.shakeY
  megautils.shakeSide = t.shakeSide
  megautils.shakeTimer = t.shakeTimer
  megautils.maxShakeTime = t.maxShakeTime
  megautils.shakeLength = t.shakeLength
    
  for _, v in ipairs(t._ranFiles) do
    megautils.runFile(v, true)
  end
end

--Game / state callback functions.
--[[
  Examples:
  megautils.reloadStateFuncs.exampleFunc = function()
      *Code here will execute whenever the state is changed and `megautils.reloadState` is true.*
    end
  
  megautils.cleanFuncs.exampleFunc = function()
      *Code here will execute whenever the state is changed and `megautils.reloadState` and `megautils.resetGameObjects` is true*
    end
  
  megautils.resetGameObjectsFuncs.exampleFunc = function()
      *Code here will execute when you gameover, a boss dies and changes the state,
      or `initEngine` is called (usually when the game is first initialized, or is coming back from a demo)*
    end
]]--
megautils.reloadState = true
megautils.resetGameObjects = true

megautils.reloadStateFuncs = {}
megautils.cleanFuncs = {}
megautils.resetGameObjectsFuncs = {}
megautils.initEngineFuncs = {}
megautils.addMapFuncs = {}
megautils.removeMapFuncs = {}
megautils.sectionChangeFuncs = {}
megautils.difficultyChangeFuncs = {}
megautils.postAddObjectsFuncs = {}
megautils.skinChangeFuncs = {}

--Player callback functions. These apply to all active players.
megautils.playerCreatedFuncs = {}         --megautils.playerCreatedFuncs.exampleFunc = function(player) end
megautils.playerTransferFuncs = {}        --megautils.playerTransferFuncs.exampleFunc = function(fromPlayer, toPlayer) end
megautils.playerGroundFuncs = {}          --megautils.playerGroundFuncs.exampleFunc = function(player) end
megautils.playerAirFuncs = {}             --megautils.playerAirFuncs.exampleFunc = function(player) end
megautils.playerSlideFuncs = {}           --megautils.playerSlideFuncs.exampleFunc = function(player) end
megautils.playerClimbFuncs = {}           --megautils.playerClimbFuncs.exampleFunc = function(player) end
megautils.playerKnockbackFuncs = {}       --megautils.playerKnockbackFuncs.exampleFunc = function(player) end
megautils.playerTrebleFuncs = {}          --megautils.playerTrebleFuncs.exampleFunc = function(player) end
megautils.playerInteractedWithFuncs = {}  --megautils.playerInteractedWithFuncs.exampleFunc = function(player) end
megautils.playerDeathFuncs = {}           --megautils.playerDeathFuncs.exampleFunc = function(player) end
megautils.playerAttemptWeaponFuncs = {}   --megautils.playerAttemptWeaponFuncs.exampleFunc = function(player, shotsInTable) end
megautils.playerPauseFuncs = {}           --megautils.playerPauseFuncs.exampleFunc = function(player) end
megautils.playerControlUpdateFuncs = {}

function megautils.cleanCallbacks()
  local callbacks = {
      "reloadStateFuncs",
      "cleanFuncs",
      "resetGameObjectsFuncs",
      "initEngineFuncs",
      "addMapFuncs",
      "removeMapFuncs",
      "sectionChangeFuncs",
      "difficultyChangeFuncs",
      "postAddObjectsFuncs",
      "skinChangeFuncs",
      "playerCreatedFuncs",
      "playerTransferFuncs",
      "playerGroundFuncs",
      "playerAirFuncs",
      "playerSlideFuncs",
      "playerClimbFuncs",
      "playerKnockbackFuncs",
      "playerTrebleFuncs",
      "playerInteractedWithFuncs",
      "playerDeathFuncs",
      "playerAttemptWeaponFuncs",
      "playerPauseFuncs",
      "playerControlUpdateFuncs"
    }
  
  for i=1, #callbacks do
    local name = callbacks[i]
    for k, v in safepairs(megautils[name]) do
      if type(v) == "function" or (type(v) == "table" and (v.autoClean == nil or v.autoClean)) then
        megautils[name][k] = nil
      end
    end
  end
end

megautils._q = {}

function megautils.queue(func, ...)
  if func then
    megautils._q[#megautils._q+1] = {func, ...}
  end
end

function megautils.checkQueue()
  for i=#megautils._q, 1, -1 do
    megautils._q[i][1](megautils._q[i][2])
    megautils._q[i] = nil
  end
end

function megautils.setFullscreen(what)
  convar.setValue("fullscreen", what and 1 or 0, true)
end

function megautils.getFullscreen()
  return convar.getNumber("fullscreen") == 1
end

function megautils.setScale(what)
  convar.setValue("scale", what, true)
end

function megautils.getScale()
  return convar.getNumber("scale")
end

function megautils.setFPS(what)
  convar.setValue("fps", what, false)
end

function megautils.getFPS()
  return convar.getNumber("fps")
end

function megautils.showFPS(what)
  convar.setValue("showfps", what and 1 or 0, false)
end

function megautils.isShowingFPS()
  return convar.getNumber("showfps") == 1
end

function megautils.showEntityCount(what)
  convar.setValue("showentitycount", what and 1 or 0, false)
end

function megautils.isShowingEntityCount()
  return convar.getNumber("showentitycount") == 1
end

function megautils.setInfiniteLives(what)
  convar.setValue("infinitelives", what and 1 or 0, false)
end

function megautils.hasInfiniteLives()
  return convar.getNumber("infinitelives") == 1
end

function megautils.setInvincible(what)
  convar.setValue("inv", what and 1 or 0, false)
end

function megautils.isInvincible()
  return convar.getNumber("inv") == 1
end

function megautils.setNoClip(what)
  convar.setValue("noclip", what and 1 or 0, false)
end

function megautils.isNoClip()
  return convar.getNumber("noclip") == 1
end

function megautils.setLives(what)
  convar.setValue("lives", what, false)
end

function megautils.getLives()
  return convar.getNumber("lives")
end

function megautils.setETanks(what)
  convar.setValue("etanks", what, false)
end

function megautils.getETanks()
  return convar.getNumber("etanks")
end

function megautils.setWTanks(what)
  convar.setValue("wtanks", what, false)
end

function megautils.getWTanks()
  return convar.getNumber("wtanks")
end

function megautils.getDifficulty()
  return convar.getString("diff")
end

function megautils.setDifficulty(d)
  convar.setValue("diff", d or convar.getString("diff"), true)
end

function megautils.setCheating(what)
  convar.setValue("cheats", what and 1 or 0, false)
end

function megautils.isCheating()
  return convar.getNumber("cheats") == 1
end

function megautils.enableConsole()
  useConsole = true
end

function megautils.disableConsole()
  console.close()
  console.lines = {}
  console.y = -math.huge
  useConsole = false
end

function megautils.runCallback(tab, ...)
  if next(tab) ~= nil then
    for _, v in safepairs(tab) do
      if type(v) == "function" then
        v(...)
      else
        v.func(...)
      end
    end
  end
end

megautils._ranFiles = {}

function megautils.runFile(path, runOnce)
  if runOnce then
    if not table.icontains(megautils._ranFiles, path) then
      megautils._ranFiles[#megautils._ranFiles+1] = path
      return love.filesystem.load(path)()
    end
  else
    if not table.icontains(megautils._ranFiles, path) then
      megautils._ranFiles[#megautils._ranFiles+1] = path
    end
    return love.filesystem.load(path)()
  end
end

function megautils.resetGame(s, saveMusic)
  if not saveMusic then
    music.stop()
  end
  if not saveSfx and not saveMusic then
    love.audio.stop()
  end
  megautils.reloadState = true
  megautils.resetGameObjects = true
  megautils.unload()
  initEngine()
  states.set(s or globals.disclaimerState)
end

function megautils.unload()
  megautils.runCallback(megautils.cleanFuncs)
  megautils.cleanCallbacks()
  sfx.clear()
  loader.clear()
  megautils._ranFiles = {}
  megautils._fsCache = {}
end

function megautils.addMapEntity(path)
  return entities.add(mapEntity, cartographer.load(path))
end

function megautils.createMapEntity(path)
  return mapEntity(cartographer.load(path))
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

function megautils.revivePlayer(p)
  megaMan.weaponHandler[p]:switch(0)
  megaMan.colorOutline[p] = weapon.colors[megaMan.weaponHandler[p].current].outline
  megaMan.colorOne[p] = weapon.colors[megaMan.weaponHandler[p].current].one
  megaMan.colorTwo[p] = weapon.colors[megaMan.weaponHandler[p].current].two
end

function megautils.registerPlayer(e)
  if not table.contains(megaMan.allPlayers, e) then
    if not megaMan.mainPlayer then
      megaMan.mainPlayer = e
    end
    megaMan.allPlayers[#megaMan.allPlayers+1] = e
    
    if #megaMan.allPlayers > 1 then
      local keys = {}
      local vals = {}
      for k, v in safepairs(megaMan.allPlayers) do
        keys[#keys+1] = v.player
        vals[v.player] = v
        megaMan.allPlayers[k] = nil
      end
      table.sort(keys)
      for j=1, #keys do
        megaMan.allPlayers[j] = vals[keys[j]]
      end
    end
    
    if e == megaMan.allPlayers[1] then
      megaMan.mainPlayer = e
    end
  end
end

function megautils.unregisterPlayer(e)
  if table.contains(megaMan.allPlayers, e) then
    table.removevaluearray(megaMan.allPlayers, e)
    if megaMan.mainPlayer == e then
      megaMan.mainPlayer = megaMan.allPlayers[1]
    end
  end
end

function megautils.outside(o, ex, ey)
  return o.collisionShape and not rectOverlapsRect(view.x-(ex or 0), view.y-(ey or 0),
    view.w+((ex or 0)*2), view.h+((ey or 0)*2), 
    o.x, o.y, o.collisionShape.w, o.collisionShape.h)
end

function megautils.outsideSection(o, ex, ey)
  return camera.main and camera.main.bounds and
    not rectOverlapsRect(camera.main.scrollx-(ex or 0), camera.main.scrolly-(ey or 0),
      camera.main.scrollw+((ex or 0)*2), camera.main.scrollh+((ey or 0)*2),
      o.x, o.y, o.collisionShape.w, o.collisionShape.h)
end

megautils.shake = false
megautils.shakeX = 2
megautils.shakeY = 0
megautils.shakeSide = false
megautils.shakeTimer = 0
megautils.maxShakeTime = 5
megautils.shakeLength = 0

function megautils.updateShake()
  if megautils.shake then
    megautils.shakeLength = math.max(megautils.shakeLength-1, 0)
    if megautils.shakeLength == 0 then
      megautils.shake = false
    end
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
    megautils.shakeLength = 0
  end
end

function megautils.setShake(x, y, gap, time)
  megautils.shakeX = x
  megautils.shakeY = y
  megautils.maxShakeTime = gap or megautils.maxShakeTime
  megautils.shake = x ~= 0 or y ~= 0
  megautils.shakeLength = time or 60
end

function megautils.dropItem(x, y)
  local rnd = love.math.random(10000)
  if math.between(rnd, 0, 39) then
    local rnd2 = love.math.random(0, 2)
    if rnd2 == 0 then
      return entities.add(life, x, y, true)
    elseif rnd2 == 1 then
      return entities.add(eTank, x, y, true)
    else
      return entities.add(wTank, x, y, true)
    end
  elseif math.between(rnd, 50, 362) then
    if love.math.random(0, 1) == 0 then
      return entities.add(health, x, y, true)
    else
      return entities.add(energy, x, y, true)
    end
  elseif math.between(rnd, 370, 995) then
    if love.math.random(0, 1) == 0 then
      return entities.add(smallHealth, x, y, true)
    else
      return entities.add(smallEnergy, x, y, true)
    end
  end
end

function megautils.center(e)
  return e.x+e.collisionShape.w/2, e.y+e.collisionShape.h/2
end

function megautils.dist(e, e2)
  local cx, cy = megautils.center(e)
  local cx2, cy2 = megautils.center(e2)
  return math.dist2d(cx, cy, cx2, cy2)
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

function megautils.side(e, to, single)
  local closest = megautils.closest(e, to, single)
  local side
  if closest then
    if closest.x+(closest.collisionShape and closest.collisionShape.w or 0)/2 >
      e.x+(e.collisionShape and e.collisionShape.w or 0)/2 then
      side = 1
    elseif closest.x+(closest.collisionShape and closest.collisionShape.w or 0)/2 <
      e.x+(e.collisionShape and e.collisionShape.w or 0)/2 then
      side = -1
    end
  end
  return side, closest
end

function megautils.pointEntityVelAtEntity(e, to, spd, spdy)
  local cx, cy = megautils.center(e)
  local cx2, cy2 = megautils.center(to)
  local p = megautils.calcPath(cx, cy, cx2, cy2)
  return megautils.calcX(p)*(spd or 1), megautils.calcY(p)*(spdy or spd or 1)
end

function megautils.pointEntityAtEntity(e, to)
  local cx, cy = megautils.center(e)
  local cx2, cy2 = megautils.center(to)
  return megautils.calcPath(cx, cy, cx2, cy2)
end

function megautils.pointEntityVelAtPoint(e, x, y, spd, spdy)
  local cx, cy = megautils.center(e)
  local p = megautils.calcPath(cx, cy, x, y)
  return megautils.calcX(p)*(spd or 1), megautils.calcY(p)*(spdy or spd or 1)
end

function megautils.pointEntityAtPoint(e, x, y)
  local cx, cy = megautils.center(e)
  return megautils.calcPath(cx, cy, x, y)
end

function megautils.createVelFromPoints(x, y, x2, y2, spd, spdy)
  local p = megautils.calcPath(x, y, x2, y2)
  return megautils.calcX(p)*(spd or 1), megautils.calcY(p)*(spdy or spd or 1)
end

function megautils.createAngleFromPoints(x, y, x2, y2)
  return megautils.calcPath(x, y, x2, y2)
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

function megautils.removeEnemyShots()
  for _, v in safeipairs(entities.all) do
    if v.isEnemyWeapon then
      entities.remove(v)
    end
  end
end

function megautils.removePlayerShots()
  if megaMan.allPlayers and megaMan.weaponHandler then
    for _, v in safeipairs(megaMan.allPlayers) do
      megaMan.weaponHandler[v.player]:removeWeaponShots()
    end
  end
end

function megautils.removeAllShots()
  megautils.removeEnemyShots()
  megautils.removePlayerShots()
end