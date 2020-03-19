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
    mmSfx.stopAll()
  end
  if not saveMusic then
    mmMusic.stopMusic()
  end
  globals.resetState = true
  globals.manageStageResources = true
  megautils.unload()
  initEngine()
  states.set(s or "states/disclaimer.state.lua")
end

function megautils.load()
  loader.load("assets/players/megaman/megaManOne.png", "megaManOne", "texture", nil, true)
  loader.load("assets/players/megaman/megaManTwo.png", "megaManTwo", "texture", nil, true)
  loader.load("assets/players/megaman/megaManOutline.png", "megaManOutline", "texture", nil, true)
  loader.load("assets/players/megaman/megaManFace.png", "megaManFace", "texture", nil, true)
  loader.load("assets/players/proto/protoManOne.png", "protoManOne", "texture", nil, true)
  loader.load("assets/players/proto/protoManTwo.png", "protoManTwo", "texture", nil, true)
  loader.load("assets/players/proto/protoManOutline.png", "protoManOutline", "texture", nil, true)
  loader.load("assets/players/proto/protoManFace.png", "protoManFace", "texture", nil, true)
  loader.load("assets/players/bass/bassOne.png", "bassOne", "texture", nil, true)
  loader.load("assets/players/bass/bassTwo.png", "bassTwo", "texture", nil, true)
  loader.load("assets/players/bass/bassOutline.png", "bassOutline", "texture", nil, true)
  loader.load("assets/players/bass/bassFace.png", "bassFace", "texture", nil, true)
  loader.load("assets/players/roll/rollOne.png", "rollOne", "texture", nil, true)
  loader.load("assets/players/roll/rollTwo.png", "rollTwo", "texture", nil, true)
  loader.load("assets/players/roll/rollOutline.png", "rollOutline", "texture", nil, true)
  loader.load("assets/players/roll/rollFace.png", "rollFace", "texture", nil, true)
  loader.load("assets/players/bar/barOne.png", "barOne", "texture", nil, true)
  loader.load("assets/players/bar/barTwo.png", "barTwo", "texture", nil, true)
  loader.load("assets/players/bar/barOutline.png", "barOutline", "texture", nil, true)
  loader.load("assets/misc/weapons/weaponSelect.png", "weaponSelect", "texture", nil, true)
  loader.load("assets/misc/weapons/weaponSelectIcon.png", "weaponSelectIcon", "texture", nil, true)
  loader.load("assets/misc/particles.png", "particles", "texture", nil, true)
  loader.load("assets/misc/particlesOutline.png", "particlesOutline", "texture", nil, true)
  loader.load("assets/misc/particlesOne.png", "particlesOne", "texture", nil, true)
  loader.load("assets/misc/particlesTwo.png", "particlesTwo", "texture", nil, true)
  loader.load("assets/misc/weaponSelect.png", "weaponSelectImg", "texture", nil, true)
  loader.load("assets/global/bossDoor.png", "bossDoor", "texture", nil, true)
  loader.load("assets/misc/menuSelect.png", "menuSelect", "texture", nil, true)
  loader.load("assets/misc/weapons/stickWeapon.png", "stickWeapon", "texture", nil, true)
  loader.load("assets/sfx/mmStart.ogg", "start", "sound", nil, true)
  loader.load("assets/sfx/semi.ogg", "semiCharged", "sound", nil, true)
  loader.load("assets/sfx/charged.ogg", "charged", "sound", nil, true)
  loader.load("assets/sfx/protoCharge.ogg", "protoCharge", "sound", nil, true)
  loader.load("assets/sfx/protoCharged.ogg", "protoCharged", "sound", nil, true)
  loader.load("assets/sfx/mmLand.ogg", "land", "sound", nil, true)
  loader.load("assets/sfx/mmHurt.ogg", "hurt", "sound", nil, true)
  loader.load("assets/sfx/life.ogg", "life", "sound", nil, true)
  loader.load("assets/sfx/dieExplode.ogg", "die", "sound", nil, true)
  loader.load("assets/sfx/bossDoor.ogg", "bossDoorSfx", "sound", nil, true)
  loader.load("assets/sfx/buster.ogg", "buster", "sound", nil, true)
  loader.load("assets/sfx/enemyHit.ogg", "enemyHit", "sound", nil, true)
  loader.load("assets/sfx/enemyExplode.ogg", "enemyExplode", "sound", nil, true)
  loader.load("assets/sfx/reflect.ogg", "dink", "sound", nil, true)
  loader.load("assets/sfx/hugeExplode.ogg", "hugeExplode", "sound", nil, true)
  loader.load("assets/sfx/mmHeal.ogg", "heal", "sound", nil, true)
  loader.load("assets/sfx/absorb.ogg", "absorb", "sound", nil, true)
  loader.load("assets/sfx/ascend.ogg", "ascend", "sound", nil, true)
  loader.load("assets/sfx/selected.ogg", "selected", "sound", nil, true)
  loader.load("assets/sfx/pause.ogg", "pause", "sound", nil, true)
  loader.load("assets/sfx/splash.ogg", "splash", "sound", nil, true)
  loader.load("assets/sfx/pause.ogg", "pause", "sound", nil, true)
  loader.load("assets/sfx/cursorMove.ogg", "cursorMove", "sound", nil, true)
  loader.load("assets/sfx/charge.ogg", "charge", "sound", nil, true)
  loader.load("assets/sfx/switch.ogg", "switch", "sound", nil, true)
  loader.load("assets/sfx/selected.ogg", "selected", "sound", nil, true)
  loader.load("assets/sfx/error.ogg", "error", "sound", nil, true)
  loader.load("assets/sfx/treble.ogg", "trebleStart", "sound", nil, true)
  loader.load("assets/sfx/protoReady.ogg", "protoReady", "sound", nil, true)
  loader.load("assets/misc/weapons/buster.png", "busterTex", "texture", nil, true)
  loader.load("assets/misc/weapons/protoBuster.png", "protoBuster", "texture", nil, true)
  loader.load("assets/misc/weapons/rollBuster.png", "rollBuster", "texture", nil, true)
  loader.load("assets/misc/weapons/bassBuster.png", "bassBuster", "texture", nil, true)
  loader.load("assets/misc/weapons/rush.png", "rush", "texture", nil, true)
  loader.load("assets/misc/weapons/protoRush.png", "protoRush", "texture", nil, true)
  loader.load("assets/misc/weapons/tango.png", "tango", "texture", nil, true)
  loader.load("assets/misc/weapons/treble.png", "treble", "texture", nil, true)
  loader.load("assets/misc/slopes/slopeLeft.csv", "slopeLeft", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slopeRight.csv", "slopeRight", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slopeLeftLong.csv", "slopeLeftLong", "texture", {true, 32}, true)
  loader.load("assets/misc/slopes/slopeRightLong.csv", "slopeRightLong", "texture", {true, 32}, true)
  loader.load("assets/misc/slopes/slopeLeftInvert.csv", "slopeLeftInvert", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slopeRightInvert.csv", "slopeRightInvert", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slopeLeftLongInvert.csv", "slopeLeftLongInvert", "texture", {true, 32}, true)
  loader.load("assets/misc/slopes/slopeRightLongInvert.csv", "slopeRightLongInvert", "texture", {true, 32}, true)
  loader.load("assets/misc/slopes/slopeLeftHalf.csv", "slopeLeftHalf", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slopeRightHalf.csv", "slopeRightHalf", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slopeLeftHalfInvert.csv", "slopeLeftHalfInvert", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slopeRightHalfInvert.csv", "slopeRightHalfInvert", "texture", {true, 16}, true)
  loader.load(nil, "slideParticleGrid", "grid", {8, 8, 128, 98}, true)
  loader.load(nil, "explodeParticleGrid", "grid", {24, 24, 128, 98, 0, 46}, true)
  loader.load(nil, "megaManGrid", "grid", {41, 30, 164, 330}, true)
  loader.load(nil, "bassGrid", "grid", {45, 41, 180, 533}, true)
  loader.load(nil, "trebleGrid", "grid", {33, 32, 264, 32}, true)
  loader.load(nil, "rollGrid", "grid", {45, 34, 180, 374}, true)
  loader.load(nil, "smallHealthGrid", "grid", {8, 8, 128, 98, 24, 0}, true)
  loader.load(nil, "healthGrid", "grid", {16, 16, 128, 98, 40, 0}, true)
  loader.load(nil, "smallEnergyGrid", "grid", {8, 8, 128, 98, 72, 0}, true)
  loader.load(nil, "energyGrid", "grid", {16, 12, 128, 98, 88, 0}, true)
  loader.load(nil, "tankGrid", "grid", {16, 16, 128, 98, 72, 12}, true)
  loader.load(nil, "splashGrid", "grid", {32, 28, 128, 98, 0, 70}, true)
  loader.load(nil, "damageSteamGrid", "grid", {5, 8, 128, 98, 108, 28}, true)
  loader.load(nil, "smallChargeGrid", "grid", {17, 16, 133, 47, 8, 31}, true)
  loader.load(nil, "chargeGrid", "grid", {33, 30, 133, 47}, true)
  loader.load(nil, "rushGrid", "grid", {32, 32, 128, 64}, true)
  loader.load(nil, "protoBusterGrid", "grid", {29, 10, 68, 10, 10, 0}, true)
end

function megautils.update(self, dt)
  if mmMusic.cur then
    mmMusic.cur:update()
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
      loader.clear()
    end
    megautils.frozen = {}
  end
  collectgarbage()
end

function megautils.loadStage(self, path, call)
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
  local bg = trigger(nil, function(s, dt) s.map:drawBackground() end)
  bg.map = map
  bg:setLayer(-5)
  megautils.adde(bg)
  megautils.setLayerFlicker(-5, false)
  addobjects.add(objs)
  local tmp = megautils.add(trigger, function(s, dt)
    s.map:update(1/60)
  end, function(s)
    s.map:draw()
  end)
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

function megautils.gotoState(s, before, after, chunk)
  megautils.add(fade, true, nil, nil, function(se)
        if before then before() end
        megautils.remove(se)
        states.set(s, chunk)
        if after then after() end
      end)
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
end

function megautils.unregisterPlayer(e)
  table.removevaluearray(globals.allPlayers, e)
  if globals.mainPlayer == e then
    globals.mainPlayer = globals.allPlayers[1]
  end
end

megautils.frozen = {}

function megautils.freeze(e)
  if megautils.groups().freezable then
    for k, v in pairs(megautils.groups().freezable) do
      if not e or not table.contains(e, v) then
        megautils.frozen[#megautils.frozen+1] = v
        v.updated = false
      end
    end
  end
end
function megautils.unfreeze(e, name)
  if megautils.groups().freezable then
    for k, v in pairs(megautils.groups().freezable) do
      if not e or not table.contains(e, v) then
        table.removevalue(megautils.frozen, v)
        v.updated = true
      end
    end
  end
end

function megautils.outside(o, ex, ey)
  if not o.collisionShape then
    return false
  end
  return not rectOverlapsRect(view.x-(ex or 0), view.y-(ey or 0), view.w+((ex or 0)*2), view.h+((ey or 0)*2), 
    o.transform.x, o.transform.y, o.collisionShape.w, o.collisionShape.h)
end

function megautils.outsideSection(o)
  if o.collisionShape and camera.main and not camera.main.isRemoved then
    return not rectOverlapsRect(camera.main.scrollx, camera.main.scrolly, camera.main.scrollw, camera.main.scrollh, 
      o.transform.x, o.transform.y, o.collisionShape.w, o.collisionShape.h)
  end
  return false
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
  local p = megautils.calcPath(megautils.center(e), megautils.center(to))
  return megautils.calcX(p), megautils.calcY(p)
end

function megautils.pointAt(e, to)
  return megautils.calcPath(megautils.center(e), megautils.center(to))
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