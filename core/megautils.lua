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
    }
  
  for i=1, #callbacks do
    local name = callbacks[i]
    for k, v in pairs(megautils[name]) do
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

megautils._ranFiles = {}

function megautils.runFile(path, runOnce, ...)
  if runOnce then
    if not table.icontains(megautils._ranFiles, path) then
      megautils._ranFiles[#megautils._ranFiles+1] = path
      if love.filesystem.getInfo(path).type == "directory" then
        return megautils._runFolderStructure(path, ...)
      else
        return love.filesystem.load(path)(...)
      end
    end
  else
    if not table.icontains(megautils._ranFiles, path) then
      megautils._ranFiles[#megautils._ranFiles+1] = path
    end
    if love.filesystem.getInfo(path).type == "directory" then
      return megautils._runFolderStructure(path, ...)
    else
      return love.filesystem.load(path)(...)
    end
  end
end

megautils._fsCache = {}

function megautils.runFSEvent(self, event, ...)
  assert(self.__index._meta, "Object provided is not a folder structure object")
  local path = self.__index._meta.path
  local name = path:split("/")
  name = name[#name]
  local file
  if event then
    file = path .. "/" .. name .. "." .. event .. ".lua"
  else
    file = path .. "/" .. name .. ".lua"
  end
  
  if not megautils._fsCache[file] then
    megautils._fsCache[file] = love.filesystem.getInfo(file) and love.filesystem.load(file) or true
  end
  
  if megautils._fsCache[file] ~= true then
    return megautils._fsCache[file](self, self.__index.super, ...)
  end
end

function megautils._runFolderStructure(path, ...)
  local f = love.filesystem.getInfo(path)
  assert(f and f.type == "directory", "\"" .. tostring(path) .. "\" is not a valid folder structure")
  assert(love.filesystem.getInfo(path .. "/conf.txt"), "\"" .. tostring(path) .. "/conf.txt\" does not exist")
  
  local conf = parseConf(path .. "/conf.txt")
  
  local name = path:split("/")
  name = name[#name]
  local baseClass = conf.baseClass or "advancedEntity"
  local result = _G[baseClass]:extend()
  _G[name] = result
  
  local autoClean = conf.autoClean == nil or conf.autoClean
  local collision
  local enemyWeapon = conf.enemyWeapon == nil or conf.enemyWeapon
  local register = conf.register == nil or conf.register
  local spawner = conf.spawner or "regular"
  local interval = 120
  if type(spawner) == "table" then
    interval = spawner[2]
    spawner = spawner[1]
  end
  local recycle = conf.recycle
  local healthBar = conf.healthBar
  local health = conf.health
  local x = conf.x
  local y = conf.y
  local mugshot = conf.mugshot
  local bossIntroText = conf.bossIntroText
  local stageState = conf.stageState
  local weaponGetText = conf.weaponGetText
  local defeatSlot = conf.defeatSlot
  local weapon = conf.weapon
  local explosion = conf.explosion
  local removeOnDeath = conf.removeOnDeath
  local dropItem = conf.dropItem
  
  if conf.collision then
    if type(conf.collision) == "table" then
      if conf.collision[2] then
        collision = {type = "rect", w = conf.collision[1], h = conf.collision[2]}
      else
        collision = {type = "circle", r = conf.collision[1], w = conf.collision[1] * 2, h = conf.collision[1] * 2}
      end
    else
      if not megautils.getResource(conf.collision) then
        megautils.loadResource(conf.collision, conf.collision, conf.autoClean)
      end
      local w, h = megautils.getResource(conf.collision):getDimensions()
      collision = {type = "image", img = conf.collision, w = w, h = h}
    end
  end
  
  result._meta = {
      path = path,
      name = name,
      collision = collision,
      enemyWeapon = enemyWeapon,
      baseClass = baseClass,
      recycle = recycle,
      healthBar = healthBar,
      health = health,
      x = x,
      y = y,
      mugshot = mugshot,
      bossIntroText = bossIntroText,
      stageState = stageState,
      weaponGetText = weaponGetText,
      defeatSlot = defeatSlot,
      weapon = weapon,
      explosion = explosion,
      removeOnDeath = removeOnDeath,
      dropItem = dropItem
    }
  
  function result:new(args)
    if not args then
      args = {}
    end
    
    if self:is(weapon) then
      self.__index.super.new(self, args.user, self.__index._meta.enemyWeapon)
    elseif self:is(pickUp) then
      self.__index.super.new(self, args.despawn, args.gravDir, args.flipWithPlayer, args.id, args.path)
    end
    
    if self.__index._meta.collision then
      if self.__index._meta.collision.type == "rect" then
        self:setRectangleCollision(self.__index._meta.collision.w, self.__index._meta.collision.h)
      elseif self.__index._meta.collision.type == "circle" then
        self:setCircleCollision(self.__index._meta.collision.r)
      elseif self.__index._meta.collision.type == "image" then
        self:setImageCollision(self.__index._meta.collision.img)
      end
    end
    
    if self.__index._meta.x then
      self.x = self.__index._meta.x
    end
    
    if self.__index._meta.y then
      self.y = self.__index._meta.y
    end
    
    if self:is(advancedEntity) then
      if self:is(bossEntity) then
        self.mugshotPath = self.__index._meta.mugshot
        self.bossIntroText = self.__index._meta.bossIntroText
        self.stageState = self.__index._meta.stageState
        self.weaponGetText = self.__index._meta.weaponGetText
        self.weaponGetBehaviour = function(m)
            if megautils.runFSEvent(self, "weaponget", m) then
              return true
            end
          end
      end
      
      if self.__index._meta.explosion == "small" then
        self.explosionType = advancedEntity.SMALLBLAST
      elseif self.__index._meta.explosion == "big" then
        self.explosionType = advancedEntity.BIGBLAST
      elseif self.__index._meta.explosion == "death" then
        self.explosionType = advancedEntity.DEATHBLAST
      end
      
      if self.__index._meta.removeOnDeath then
        self.removeOnDeath = self.__index._meta.removeOnDeath
      end
      
      if self.__index._meta.dropItem then
        self.dropItem = self.__index._meta.dropItem
      end
      
      if self.__index._meta.health then
        self.health = self.__index._meta.health
      end
      
      self.defeatSlot = self.__index._meta.defeatSlot
      
      if self.__index._meta.weapon then
        self.defeatSlotValue = {weaponName = self.__index._meta.weapon[1], weaponSlot = self.__index._meta.weapon[2]}
      end
      
      if self.__index._meta.healthBar then
        self:useHealthBar({self.__index._meta.healthBar[1], self.__index._meta.healthBar[2], self.__index._meta.healthBar[3]},
          {self.__index._meta.healthBar[4], self.__index._meta.healthBar[5], self.__index._meta.healthBar[6]})
      end
    end
    
    if not self.recycling then
      self.recycle = self.__index._meta.recycle
      megautils.runFSEvent(self, "new")
    else
      megautils.runFSEvent(self, "recycle")
    end
  end
  
  function result:added()
    self.__index.super.added(self)
    
    megautils.runFSEvent(self, "added")
  end
  
  function result:begin()
    self.__index.super.begin(self)
    
    megautils.runFSEvent(self, "begin")
  end
  
  function result:beforeUpdate(dt)
    megautils.runFSEvent(self, "beforeupdate", dt)
  end
  
  function result:update(dt)
    megautils.runFSEvent(self, "update", dt)
  end
  
  function result:afterUpdate(dt)
    megautils.runFSEvent(self, "afterupdate", dt)
  end
  
  function result:removed()
    self.__index.super.removed(self)
    
    megautils.runFSEvent(self, "removed")
  end
  
  function result:interactedWith(o, c)
    megautils.runFSEvent(self, "interacted", o, c)
  end
  
  if result:is(advancedEntity) then
    function result:grav()
      megautils.runFSEvent(self, "grav")
    end
    
    function result:crushed(o)
      megautils.runFSEvent(self, "crushed", o)
    end
    
    function result:hit(o)
      megautils.runFSEvent(self, "hit", o)
    end
    
    function result:die(o)
      megautils.runFSEvent(self, "die", o)
    end
    
    function result:determineDink(o)
      megautils.runFSEvent(self, "determinedink", o)
    end
    
    function result:weaponTable(o)
      megautils.runFSEvent(self, "weapontable", o)
    end
    
    function result:heal(o)
      megautils.runFSEvent(self, "heal", o)
    end
  end
  
  local i = 1
  while conf["resource" .. tostring(i)] do
    megautils.loadResource(unpack(conf["resource" .. tostring(i)]))
    i = i + 1
  end
  
  if register then
    mapEntity.register(tostring(name), function(v, map, s, r)
        local args = {x = v.x, y = v.y, width = v.width, height = v.height}
        for k, v in pairs(v.properties) do
          args[k] = v
        end
        local w, h = r.__index._meta.collision and r.__index._meta.collision.w or 16,
          r.__index._meta.collision and r.__index._meta.collision.h or 16
        
        if s == "regular" then
          megautils.add(spawner, w, h, nil, r, args)
        elseif s == "interval" then
          megautils.add(intervalSpawner, w, h, r.__index._meta.interval, nil, r, args)
        elseif s == "custom" then
          megautils.add(r, args)
        end
      end, nil, nil, spawner, result)
  end
  
  megautils.runFSEvent(result)
end

function megautils.resetGame(s, saveSfx, saveMusic)
  if not saveSfx then
    megautils.stopAllSounds()
  end
  if not saveMusic then
    megautils.stopMusic()
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

function megautils.getResource(nick)
  return loader.get(nick)
end

function megautils.getResourceTable(nick)
  return loader.getTable(nick)
end

function megautils.getAllResources()
  local all = {}
  for k, v in pairs(loader.locked) do
    all[k] = v[1]
  end
  for k, v in pairs(loader.resources) do
    all[k] = v[1]
  end
  return all
end

function megautils.getAllResourceTables()
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

function megautils.loadResource(...)
  local args = {...}
  if #args < 2 then error("megautils.loadResource takes at least two arguments") end
  local locked = false
  local path = args[1]
  local nick = args[2]
  local t = ""
  if type(path) == "string" then
    t = path:split("%.")
    t = t[#t]
  end
  
  local function checkExt(ext, list)
    for _, v in ipairs(list) do
      if ext:lower() == v then
        return true
      end
    end
    return false
  end
  
  if type(args[1]) == "number" and type(args[2]) == "number" then
    local grid
    t = "grid"
    path = nil
    if type(args[5]) == "number" then
      nick = args[6]
      locked = args[7]
      grid = {args[3], args[4], args[1], args[2], args[5]}
    elseif type(args[3]) == "number" and type(args[4]) == "number" then
      nick = args[5]
      locked = args[6]
      grid = {args[3], args[4], args[1], args[2]}
    else
      nick = args[3]
      locked = args[4]
      grid = {args[1], args[2]}
    end
    loader.load(nil, nick, t, grid, locked)
    return loader.get(nick)
  elseif checkExt(t, {"anim"}) then
    t = "anim"
    locked = args[3]
    loader.load(path, nick, t, nil, locked)
    return loader.get(nick)
  elseif checkExt(t, {"animset"}) then
    t = "animSet"
    locked = args[3]
    loader.load(path, nick, t, nil, locked)
    return loader.get(nick)
  elseif checkExt(t, {"png", "jpeg", "jpg", "bmp", "tga", "hdr", "pic", "exr"}) then
    local ext = t
    t = "texture"
    if #args == 4 then
      locked = args[4]
      loader.load(path, nick, t, {args[3]}, locked)
      return loader.get(nick)
    else
      locked = args[3]
      loader.load(path, nick, t, nil, locked)
      return loader.get(nick)
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
    loader.load(path, nick, t, nil, locked)
    return loader.get(nick)
  else
    error("Could not detect resource type of \"" .. nick .. "\" based on given info.")
  end
end

function megautils.setMusicLock(w)
  mmMusic.setLock(w)
end

function megautils.isMusicLocked()
  return mmMusic.locked
end

function megautils.setMusicVolume(v)
  mmMusic.setVolume(v)
end

function megautils.getMusicVolume()
  return mmMusic.getVolume()
end

function megautils.getCurrentMusic()
  return mmMusic.music
end

function megautils.playMusic(...)
  mmMusic.playq(...)
end

function megautils.stopMusic()
  mmMusic.stop()
end

function megautils.musicIsStopped()
  return mmMusic.stopped()
end

function megautils.pauseMusic()
  mmMusic.pause()
end

function megautils.unpauseMusic()
  mmMusic.unpause()
end

function megautils.setMusicLooping(w)
  mmMusic.setLooping(w)
end

function megautils.musicIsLooping()
  return mmMusic.isLooping()
end

function megautils.playSound(p, l, v, stack)
  if megautils.getResource(p) then
    if not stack then
      megautils.getResource(p):stop()
    end
    megautils.getResource(p):setLooping(l or false)
    megautils.getResource(p):setVolume(v or 1)
    megautils.getResource(p):play()
  else
    error("Sound \"" .. p .. "\" doesn't exist.")
  end
end

megautils._curS = {}

function megautils.playSoundFromFile(p, l, v, stack)
  local s = megautils._curS.sfx
  if s and not stack then
    s:stop()
  end
  if not s or megautils._curS.id ~= p then
    if s then
      s:release()
    end
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
  for _, v in pairs(loader.resources) do
    if v.type == "sound" then
      v.data:stop()
    end
  end
  for _, v in pairs(loader.locked) do
    if v.type == "sound" then
      v.data:stop()
    end
  end
  if megautils._curS.sfx then
    megautils._curS.sfx:stop()
  end
end

function megautils.unload()
  for _, v in pairs(megautils.cleanFuncs) do
    if type(v) == "function" then
      v()
    else
      v.func()
    end
  end
  megautils.cleanCallbacks()
  megautils.unloadAllResources()
  megautils._ranFiles = {}
  megautils._fsCache = {}
end

function megautils.addMapEntity(path)
  return megautils.add(mapEntity, cartographer.load(path))
end

function megautils.createMapEntity(path)
  return mapEntity(cartographer.load(path))
end

function megautils.getCurrentState()
  return states.current
end

function megautils.transitionToState(s, before, after, gap)
  local tmp = fade(true, gap, nil, function(se)
      megautils.gotoState(se._state, se._before, se._after)
    end)
  tmp._state = s
  tmp._before = before
  tmp._after = after
  
  megautils.adde(tmp)
end

function megautils.gotoState(st, before, after)
  states.setq(st, before, after)
end

function megautils.setLayerFlicker(l, b)
  states.currentState.system:setLayerFlicker(l, b)
end

function megautils.remove(o)
  states.currentState.system:remove(o)
end

function megautils.removeq(o)
  states.currentState.system:removeq(o)
end

function megautils.inAddQueue(o)
  return table.icontains(states.currentState.system.addQueue, o)
end

function megautils.inRemoveQueue(o)
  return table.icontains(states.currentState.system.removeQueue, o)
end

function megautils.stopAddQueue(o)
  table.quickremovevaluearray(states.currentState.system.addQueue, o)
end

function megautils.stopRemoveQueue(o)
  table.quickremovevaluearray(states.currentState.system.removeQueue, o)
end

function megautils.state()
  return states.currentState
end

function megautils.add(o, ...)
  return states.currentState.system:add(o, ...)
end

function megautils.adde(o)
  return states.currentState.system:adde(o)
end

function megautils.addq(o, ...)
  return states.currentState.system:addq(o, ...)
end

function megautils.addeq(o)
  return states.currentState.system:addeq(o)
end

function megautils.getAllEntities()
  return megautils.state().system.all
end

function megautils.getRecycled(o, ...)
  return states.currentState.system:getRecycled(o, ...)
end

function megautils.emptyRecycling(c, num)
  states.currentState.system:emptyRecycling(c, num)
end

function megautils.groups()
  return states.currentState.system.groups
end

function megautils.filterByGroup(g, groupName)
  local result = {}
  
  for i = 1, #g do
    if table.icontains(g[i].groupNames, groupName) then
      result[#result + 1] = g[i]
    end
  end
  
  return result
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
  if not megaMan.mainPlayer then
    megaMan.mainPlayer = e
  end
  megaMan.allPlayers[#megaMan.allPlayers+1] = e
  
  if #megaMan.allPlayers > 1 then
    local keys = {}
    local vals = {}
    for k, v in pairs(megaMan.allPlayers) do
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

function megautils.unregisterPlayer(e)
  table.removevaluearray(megaMan.allPlayers, e)
  if megaMan.mainPlayer == e then
    megaMan.mainPlayer = megaMan.allPlayers[1]
  end
end

function megautils.getSurroundingEntities(x, y, w, h)
  return megautils.state().system:getSurroundingEntities(x, y, w, h)
end

function megautils.freeze(name)
  megautils.state().system:freeze(name)
end

function megautils.unfreeze(name)
  megautils.state().system:unfreeze(name)
end

function megautils.checkFrozen(name)
  for _, v in ipairs(megautils.state().system.frozen) do
    if v == name then
      return true
    end
  end
  
  return false
end

function megautils.outside(o, ex, ey)
  return o.collisionShape and not rectOverlapsRect(view.x-(ex or 0), view.y-(ey or 0), view.w+((ex or 0)*2), view.h+((ey or 0)*2), 
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
      return megautils.add(life, x, y, true)
    elseif rnd2 == 1 then
      return megautils.add(eTank, x, y, true)
    else
      return megautils.add(wTank, x, y, true)
    end
  elseif math.between(rnd, 50, 362) then
    if love.math.random(0, 1) == 0 then
      return megautils.add(health, x, y, true)
    else
      return megautils.add(energy, x, y, true)
    end
  elseif math.between(rnd, 370, 995) then
    if love.math.random(0, 1) == 0 then
      return megautils.add(smallHealth, x, y, true)
    else
      return megautils.add(smallEnergy, x, y, true)
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
    if closest.x+closest.collisionShape.w/2 >
      e.x+e.collisionShape.w/2 then
      side = 1
    elseif closest.x+closest.collisionShape.w/2 <
      e.x+e.collisionShape.w/2 then
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

function megautils.diff(...)
  for _, v in pairs({...}) do
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

function megautils.removeEnemyShots()
  if megautils.state().system.all then
    for _, v in ipairs(megautils.state().system.all) do
      if v.isEnemyWeapon then
        megautils.removeq(v)
      end
    end
  end
end

function megautils.removePlayerShots()
  if megaMan.allPlayers and megaMan.weaponHandler then
    for _, v in ipairs(megaMan.allPlayers) do
      megaMan.weaponHandler[v.player]:removeWeaponShots()
    end
  end
end

function megautils.removeAllShots()
  megautils.removeEnemyShots()
  megautils.removePlayerShots()
end

function megautils.getClassName(e)
  for k, v in pairs(_G) do
    if e.__index == v then
      return k
    end
  end
end
