megautils = {}

megautils.resetStateFuncs = {}
megautils.cleanFuncs = {}

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
  globals.resetState = true
  globals.manageStageResources = true
  megautils.unload()
  initEngine()
  states.set(s or "states/disclaimer.state.lua")
end

local function checkExt(ext, list)
  for k, v in ipairs(list) do
    if ext:lower() == v then
      return true
    end
  end
  return false
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
  elseif w == false then
    loader.unlock(nick)
  end
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
    loader.load(nil, nick, t, {args[2], args[3], args[4], args[5],
        (type(args[6]) ~= "boolean") and args[6], (type(args[7]) ~= "boolean") and args[7]}, locked)
  elseif checkExt(t, {"png", "jpeg", "jpg", "bmp", "tga", "hdr", "pic", "exr"}) then
    t = "texture"
    if #args == 4 then
      locked = args[4]
      loader.load(path, nick, t, {args[3]}, locked)
    else
      locked = args[3]
      loader.load(path, nick, t, nil, locked)
    end
  elseif checkExt(t, {"ogg", "mp3", "wav", "flac", "oga", "ogv", "xm", "it", "mod", "mid", "669", "amf", "ams", "dbm", "dmf", "dsm", "far",
      "j2b", "mdl", "med", "mt2", "mtm", "okt", "psm", "s3m", "stm", "ult", "umx", "abc", "pat"}) then
    if args[3] == "music" or args[3] == "sound" then
      t = args[3]
      locked = args[4]
      loader.load(path, nick, t, nil, locked)
    else
      error("megautils.load requires the 3rd argument to be \"music\" or \"sound\" when loading audio")
    end
  else
    error("Could not detect resource type of \"" .. path .. "\" based on file extension")
  end
end

function megautils.loadGlobalResources()
  megautils.loadResource("assets/players/megaman/megaManOne.png", "megaManOne", true)
  megautils.loadResource("assets/players/megaman/megaManTwo.png", "megaManTwo", true)
  megautils.loadResource("assets/players/megaman/megaManOutline.png", "megaManOutline", true)
  megautils.loadResource("assets/players/megaman/megaManFace.png", "megaManFace", true)
  megautils.loadResource("assets/players/proto/protoManOne.png", "protoManOne", true)
  megautils.loadResource("assets/players/proto/protoManTwo.png", "protoManTwo", true)
  megautils.loadResource("assets/players/proto/protoManOutline.png", "protoManOutline", true)
  megautils.loadResource("assets/players/proto/protoManFace.png", "protoManFace", true)
  megautils.loadResource("assets/players/bass/bassOne.png", "bassOne", true)
  megautils.loadResource("assets/players/bass/bassTwo.png", "bassTwo", true)
  megautils.loadResource("assets/players/bass/bassOutline.png", "bassOutline", true)
  megautils.loadResource("assets/players/bass/bassFace.png", "bassFace", true)
  megautils.loadResource("assets/players/roll/rollOne.png", "rollOne", true)
  megautils.loadResource("assets/players/roll/rollTwo.png", "rollTwo", true)
  megautils.loadResource("assets/players/roll/rollOutline.png", "rollOutline", true)
  megautils.loadResource("assets/players/roll/rollFace.png", "rollFace", true)
  megautils.loadResource("assets/players/bar/barOne.png", "barOne", true)
  megautils.loadResource("assets/players/bar/barTwo.png", "barTwo", true)
  megautils.loadResource("assets/players/bar/barOutline.png", "barOutline", true)
  megautils.loadResource("assets/misc/weapons/weaponSelect.png", "weaponSelect", true)
  megautils.loadResource("assets/misc/weapons/weaponSelectIcon.png", "weaponSelectIcon", true)
  megautils.loadResource("assets/misc/particles.png", "particles", true)
  megautils.loadResource("assets/misc/particlesOutline.png", "particlesOutline", true)
  megautils.loadResource("assets/misc/particlesOne.png", "particlesOne", true)
  megautils.loadResource("assets/misc/particlesTwo.png", "particlesTwo", true)
  megautils.loadResource("assets/misc/weaponSelect.png", "weaponSelectImg", true)
  megautils.loadResource("assets/global/bossDoor.png", "bossDoor", true)
  megautils.loadResource("assets/misc/menuSelect.png", "menuSelect", true)
  megautils.loadResource("assets/misc/weapons/stickWeapon.png", "stickWeapon", true)
  megautils.loadResource("assets/sfx/mmStart.ogg", "start", "sound", true)
  megautils.loadResource("assets/sfx/semi.ogg", "semiCharged", "sound", true)
  megautils.loadResource("assets/sfx/charged.ogg", "charged", "sound", true)
  megautils.loadResource("assets/sfx/protoCharge.ogg", "protoCharge", "sound", true)
  megautils.loadResource("assets/sfx/protoCharged.ogg", "protoCharged", "sound", true)
  megautils.loadResource("assets/sfx/mmLand.ogg", "land", "sound", true)
  megautils.loadResource("assets/sfx/mmHurt.ogg", "hurt", "sound", true)
  megautils.loadResource("assets/sfx/life.ogg", "life", "sound", true)
  megautils.loadResource("assets/sfx/dieExplode.ogg", "die", "sound", true)
  megautils.loadResource("assets/sfx/bossDoor.ogg", "bossDoorSfx", "sound", true)
  megautils.loadResource("assets/sfx/buster.ogg", "buster", "sound", true)
  megautils.loadResource("assets/sfx/enemyHit.ogg", "enemyHit", "sound", true)
  megautils.loadResource("assets/sfx/enemyExplode.ogg", "enemyExplode", "sound", true)
  megautils.loadResource("assets/sfx/reflect.ogg", "dink", "sound", true)
  megautils.loadResource("assets/sfx/hugeExplode.ogg", "hugeExplode", "sound", true)
  megautils.loadResource("assets/sfx/mmHeal.ogg", "heal", "sound", true)
  megautils.loadResource("assets/sfx/absorb.ogg", "absorb", "sound", true)
  megautils.loadResource("assets/sfx/ascend.ogg", "ascend", "sound", true)
  megautils.loadResource("assets/sfx/selected.ogg", "selected", "sound", true)
  megautils.loadResource("assets/sfx/pause.ogg", "pause", "sound", true)
  megautils.loadResource("assets/sfx/splash.ogg", "splash", "sound", true)
  megautils.loadResource("assets/sfx/pause.ogg", "pause", "sound", true)
  megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove", "sound", true)
  megautils.loadResource("assets/sfx/charge.ogg", "charge", "sound", true)
  megautils.loadResource("assets/sfx/switch.ogg", "switch", "sound", true)
  megautils.loadResource("assets/sfx/selected.ogg", "selected", "sound", true)
  megautils.loadResource("assets/sfx/error.ogg", "error", "sound", true)
  megautils.loadResource("assets/sfx/treble.ogg", "trebleStart", "sound", true)
  megautils.loadResource("assets/sfx/protoReady.ogg", "protoReady", "sound", true)
  megautils.loadResource("assets/sfx/gravityFlip.ogg", "gravityFlip", "sound", true)
  megautils.loadResource("assets/misc/weapons/buster.png", "busterTex", true)
  megautils.loadResource("assets/misc/weapons/protoBuster.png", "protoBuster", true)
  megautils.loadResource("assets/misc/weapons/rollBuster.png", "rollBuster", true)
  megautils.loadResource("assets/misc/weapons/bassBuster.png", "bassBuster", true)
  megautils.loadResource("assets/misc/weapons/rush.png", "rush", true)
  megautils.loadResource("assets/misc/weapons/protoRush.png", "protoRush", true)
  megautils.loadResource("assets/misc/weapons/tango.png", "tango", true)
  megautils.loadResource("assets/misc/weapons/treble.png", "treble", true)
  megautils.loadResource("assets/misc/slopes/slopeLeft.png", "slopeLeft", true, true)
  megautils.loadResource("assets/misc/slopes/slopeRight.png", "slopeRight", true, true)
  megautils.loadResource("assets/misc/slopes/slopeLeftLong.png", "slopeLeftLong", true, true)
  megautils.loadResource("assets/misc/slopes/slopeRightLong.png", "slopeRightLong", true, true)
  megautils.loadResource("assets/misc/slopes/slopeLeftInvert.png", "slopeLeftInvert", true, true)
  megautils.loadResource("assets/misc/slopes/slopeRightInvert.png", "slopeRightInvert", true, true)
  megautils.loadResource("assets/misc/slopes/slopeLeftLongInvert.png", "slopeLeftLongInvert", true, true)
  megautils.loadResource("assets/misc/slopes/slopeRightLongInvert.png", "slopeRightLongInvert", true, true)
  megautils.loadResource("assets/misc/slopes/slopeLeftHalf.png", "slopeLeftHalf", true, true)
  megautils.loadResource("assets/misc/slopes/slopeRightHalf.png", "slopeRightHalf", true, true)
  megautils.loadResource("assets/misc/slopes/slopeLeftHalfInvert.png", "slopeLeftHalfInvert", true, true)
  megautils.loadResource("assets/misc/slopes/slopeRightHalfInvert.png", "slopeRightHalfInvert", true, true)
  megautils.loadResource("assets/misc/slopes/slopeLeftHalfUpper.png", "slopeLeftHalfUpper", true, true)
  megautils.loadResource("assets/misc/slopes/slopeRightHalfUpper.png", "slopeRightHalfUpper", true, true)
  megautils.loadResource("assets/misc/slopes/slopeLeftHalfUpperInvert.png", "slopeLeftHalfUpperInvert", true, true)
  megautils.loadResource("assets/misc/slopes/slopeRightHalfUpperInvert.png", "slopeRightHalfUpperInvert", true, true)
  megautils.loadResource("slideParticleGrid", 8, 8, 128, 98, true)
  megautils.loadResource("explodeParticleGrid", 24, 24, 128, 98, 0, 46, true)
  megautils.loadResource("megaManGrid", 41, 30, 164, 330, true)
  megautils.loadResource("bassGrid", 45, 41, 180, 533, true)
  megautils.loadResource("trebleGrid", 33, 32, 264, 32, true)
  megautils.loadResource("rollGrid", 45, 34, 180, 374, true)
  megautils.loadResource("smallHealthGrid", 8, 8, 128, 98, 24, 0, true)
  megautils.loadResource("healthGrid", 16, 16, 128, 98, 40, 0, true)
  megautils.loadResource("smallEnergyGrid", 8, 8, 128, 98, 72, 0, true)
  megautils.loadResource("energyGrid", 16, 12, 128, 98, 88, 0, true)
  megautils.loadResource("tankGrid", 16, 16, 128, 98, 72, 12, true)
  megautils.loadResource("splashGrid", 32, 28, 128, 98, 0, 70, true)
  megautils.loadResource("damageSteamGrid", 5, 8, 128, 98, 108, 28, true)
  megautils.loadResource("smallChargeGrid", 17, 16, 133, 47, 8, 31, true)
  megautils.loadResource("chargeGrid", 33, 30, 133, 47, true)
  megautils.loadResource("rushGrid", 32, 32, 128, 64, true)
  megautils.loadResource("protoBusterGrid", 29, 10, 68, 10, 10, 0, true)
end

megautils._curM = nil
megautils._lockM = false

function megautils.setMusicLock(w)
  megautils._lockM = w
end

function megautils.getCurrentMusic()
  return megautils._curM
end

function megautils.playMusic(path, loop, lp, vol)
  if megautils._lockM or (megautils._curM and megautils._curM.id == path) then return end
  megautils.stopMusic()
  
  megautils._curM = mmMusic(love.audio.newSource(path, "stream"))
  megautils._curM.id = path
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
  if not stack then
    megautils.getResource(p):stop()
  end
  megautils.getResource(p):setLooping(l or false)
  megautils.getResource(p):setVolume(v or 1)
  megautils.getResource(p):play()
end

function megautils.stopSound(s)
  megautils.getResource(s):stop()
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
  if globals.resetState then
    for k, v in pairs(megautils.resetStateFuncs) do
      v()
    end
    if globals.manageStageResources then
      for k, v in pairs(megautils.cleanFuncs) do
        v()
      end
      megautils.unloadAllResources()
    end
    megautils.frozen = {}
  end
  collectgarbage()
end

function megautils.loadStage(self, path)
  self.sectionHandler = sectionHandler()
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

function megautils.remove(o, queue)
  states.currentstate.system:remove(o, queue)
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

megautils.resetGameObjectsFuncs = {}

function megautils.resetGameObjects()
  globals.mainPlayer = nil
  globals.allPlayers = {}
  globals.manageStageResources = true
  globals.checkpoint = "start"
  globals.lives = globals.lives > 2 and globals.lives or globals.startingLives
  for k, v in pairs(megautils.resetGameObjectsFuncs) do
    v()
  end
end

function megautils.revivePlayer(p)
  megaman.weaponHandler[p]:switch(0)
  megaman.colorOutline[p] = megaman.weaponHandler[p].colorOutline[0]
  megaman.colorOne[p] = megaman.weaponHandler[p].colorOne[0]
  megaman.colorTwo[p] = megaman.weaponHandler[p].colorTwo[0]
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
  return o.collisionShape and camera.main and
    not rectOverlapsRect(camera.main.scrollx-(ex or 0), camera.main.scrolly-(ey or 0), camera.main.scrollw+((ex or 0)*2), camera.main.scrollh+((ey or 0)*2), 
    o.transform.x, o.transform.y, o.collisionShape.w, o.collisionShape.h)
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
