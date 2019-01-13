megautils = {}

megautils.resetStateFuncs = {}
megautils.cleanFuncs = {}

function megautils.load()
  loader.load("assets/players/megaman/mega_man_one.png", "mega_man_one", "texture", nil, true)
  loader.load("assets/players/megaman/mega_man_two.png", "mega_man_two", "texture", nil, true)
  loader.load("assets/players/megaman/mega_man_outline.png", "mega_man_outline", "texture", nil, true)
  loader.load("assets/players/megaman/mega_man_face.png", "mega_man_face", "texture", nil, true)
  loader.load("assets/players/bar/bar_one.png", "bar_one", "texture", nil, true)
  loader.load("assets/players/bar/bar_two.png", "bar_two", "texture", nil, true)
  loader.load("assets/players/bar/bar_outline.png", "bar_outline", "texture", nil, true)
  loader.load("assets/misc/weapons/weapon_select.png", "weapon_select", "texture", nil, true)
  loader.load("assets/misc/weapons/weapon_select_icon.png", "weapon_select_icon", "texture", nil, true)
  loader.load("assets/misc/particles.png", "particles", "texture", nil, true)
  loader.load("assets/misc/particles_outline.png", "particles_outline", "texture", nil, true)
  loader.load("assets/misc/particles_one.png", "particles_one", "texture", nil, true)
  loader.load("assets/misc/particles_two.png", "particles_two", "texture", nil, true)
  loader.load("assets/global/bossdoors/boss_door.png", "boss_door", "texture", nil, true)
  loader.load("assets/sfx/mm_start.ogg", "start", "sound", nil, true)
  loader.load("assets/sfx/semi.ogg", "semi_charged", "sound", nil, true)
  loader.load("assets/sfx/charged.ogg", "charged", "sound", nil, true)
  loader.load("assets/sfx/mm_land.ogg", "land", "sound", nil, true)
  loader.load("assets/sfx/mm_hurt.ogg", "hurt", "sound", nil, true)
  loader.load("assets/sfx/life.ogg", "life", "sound", nil, true)
  loader.load("assets/sfx/die_explode.ogg", "die", "sound", nil, true)
  loader.load("assets/sfx/boss_door.ogg", "boss_door_sfx", "sound", nil, true)
  loader.load("assets/sfx/buster.ogg", "buster", "sound", nil, true)
  loader.load("assets/sfx/enemy_hit.ogg", "enemy_hit", "sound", nil, true)
  loader.load("assets/sfx/enemy_explode.ogg", "enemy_explode", "sound", nil, true)
  loader.load("assets/sfx/reflect.ogg", "dink", "sound", nil, true)
  loader.load("assets/sfx/huge_explode.ogg", "huge_explode", "sound", nil, true)
  loader.load("assets/sfx/mm_heal.ogg", "heal", "sound", nil, true)
  loader.load("assets/sfx/absorb.ogg", "absorb", "sound", nil, true)
  loader.load("assets/sfx/ascend.ogg", "ascend", "sound", nil, true)
  loader.load("assets/sfx/selected.ogg", "selected", "sound", nil, true)
  loader.load("assets/sfx/pause.ogg", "pause", "sound", nil, true)
  loader.load("assets/sfx/splash.ogg", "splash", "sound", nil, true)
  loader.load("assets/sfx/pause.ogg", "pause", "sound", nil, true)
  loader.load("assets/sfx/cursor_move.ogg", "cursor_move", "sound", nil, true)
  loader.load("assets/sfx/charge.ogg", "charge", "sound", nil, true)
  loader.load("assets/sfx/switch.ogg", "switch", "sound", nil, true)
  loader.load("assets/sfx/selected.ogg", "selected", "sound", nil, true)
  loader.load("assets/sfx/error.ogg", "error", "sound", nil, true)
  loader.load("assets/misc/mm.png", "font", "font", nil, true)
  loader.load("assets/misc/weapons/buster.png", "buster_tex", "texture", nil, true)
  loader.load("assets/misc/weapons/rush.png", "rush", "texture", nil, true)
  loader.load("assets/misc/weapons/stick_weapon.png", "stick_weapon", "texture", nil, true)
  loader.load("assets/misc/slopes/slope_left.csv", "slope_left", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slope_right.csv", "slope_right", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slope_left_long.csv", "slope_left_long", "texture", {true, 32}, true)
  loader.load("assets/misc/slopes/slope_right_long.csv", "slope_right_long", "texture", {true, 32}, true)
  loader.load("assets/misc/slopes/slope_left_invert.csv", "slope_left_invert", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slope_right_invert.csv", "slope_right_invert", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slope_left_long_invert.csv", "slope_left_long_invert", "texture", {true, 32}, true)
  loader.load("assets/misc/slopes/slope_right_long_invert.csv", "slope_right_long_invert", "texture", {true, 32}, true)
  loader.load("assets/misc/slopes/slope_left_half.csv", "slope_left_half", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slope_right_half.csv", "slope_right_half", "texture", {true, 16}, nil, true)
  loader.load("assets/misc/slopes/slope_left_half_invert.csv", "slope_left_half_invert", "texture", {true, 16}, true)
  loader.load("assets/misc/slopes/slope_right_half_invert.csv", "slope_right_half_invert", "texture", {true, 16}, true)
  loader.load(nil, "ready_grid", "grid", {81, 17, 81, 187}, true)
  loader.load(nil, "slide_particle_grid", "grid", {8, 8, 128, 98}, true)
  loader.load(nil, "explode_particle_grid", "grid", {24, 24, 128, 98, 0, 46}, true)
  loader.load(nil, "mega_man_grid", "grid", {41, 30, 164, 330}, true)
  loader.load(nil, "small_health_grid", "grid", {8, 8, 128, 98, 24, 0}, true)
  loader.load(nil, "health_grid", "grid", {16, 16, 128, 98, 40, 0}, true)
  loader.load(nil, "small_energy_grid", "grid", {8, 8, 128, 98, 72, 0}, true)
  loader.load(nil, "energy_grid", "grid", {16, 12, 128, 98, 88, 0}, true)
  loader.load(nil, "tank_grid", "grid", {16, 16, 128, 98, 72, 12}, true)
  loader.load(nil, "splash_grid", "grid", {32, 28, 128, 98, 0, 70}, true)
  loader.load(nil, "damage_steam_grid", "grid", {5, 8, 128, 98, 108, 28}, true)
  loader.load(nil, "small_charge_grid", "grid", {17, 16, 133, 47, 8, 31}, true)
  loader.load(nil, "charge_grid", "grid", {33, 30, 133, 47}, true)
  loader.load(nil, "rush_grid", "grid", {32, 32, 128, 64}, true)
end

function megautils.update(self, dt)
  if mmMusic.cur ~= nil then
    mmMusic.cur:update()
  end
  self.system:update(dt)
end

function megautils.draw(self)
  view.draw(self.system)
  if showFPS then
    local fps = love.timer.getFPS()
    love.graphics.setFont(mmFont)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print(fps, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(fps, 8, 8)
  end
end

function megautils.unload(self)
  if globals.resetState then
    for k, v in pairs(megautils.resetStateFuncs) do
      v()
    end
    self.system:clear()
    globals.mainPlayer = nil
    if globals.manageStageResources then
      for k, v in pairs(megautils.cleanFuncs) do
        v()
      end
      loader.clear()
      self.sectionHandler = nil
    end
  end
  collectgarbage()
end

function megautils.loadStage(self, path, call)
  self.sectionHandler = sectionHandler()
  local map = sti(path)
  local tLayers = {}
  local objs = {}
  for k, v in pairs(map.layers) do
    if type(k) == "number" then
      if v.type == "tilelayer" then
        tLayers[#tLayers+1] = v
      elseif v.type == "objectgroup" then
        for i, j in pairs(v.objects) do
          objs[#objs+1] = j
        end
      end
    end
  end
  for k, v in pairs(tLayers) do
    local l = mapentity(v, map)
    if call ~= nil then call(l) end
    megautils.add(l)
  end
  addobjects.add(objs)
  local tmp = trigger(function(s, dt)
    s.map:update(1/60)
  end)
  tmp:addToGroup("freezable")
  tmp.map = map
  megautils.add(tmp)
end

function megautils.gotoState(s, before, after, chunk)
  megautils.add(fade(true, nil, nil, function(se)
        if before ~= nil then before() end
        megautils.remove(se)
        states.set(s, chunk)
        if after ~= nil then after() end
      end))
end

function megautils.remove(o, queue)
  states.currentstate.system:remove(o, queue)
end

function megautils.state()
  return states.currentstate
end

function megautils.add(o, queue)
  states.currentstate.system:add(o, queue)
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

function megautils.calcPath(x, y, x2, y2, rad)
  local a = math.deg(math.atan2(y - y2, x2 - x))
  return a
end

function megautils.circlePathX(x, deg, dist)
  return x + (megautils.calcX(deg) * dist)
end
function megautils.circlePathY(y, deg, dist)
  return y + (megautils.calcY(deg) * dist)
end

function megautils.resetGame()
  globals.mainPlayer = nil
  globals.allPlayers = {}
  healthhandler.playerTimers = {-2, -2, -2, -2}
  globals.manageStageResources = true
  globals.checkpoint = "start"
  globals.lives = ternary(globals.lives > 2, globals.lives, 2)
  wTank.banIds = {}
  eTank.banIds = {}
  life.banIds = {}
  energy.banIds = {}
  smallEnergy.banIds = {}
  health.banIds = {}
  smallHealth.banIds = {}
  megaman.weaponHandler = {}
  megaman.colorOutline = {}
  megaman.colorOne = {}
  megaman.colorTwo = {}
  for i=1, maxPlayerCount do
    megaman.weaponHandler[i] = weaponhandler(nil, nil, 10)
    megaman.weaponHandler[i]:register(0, "megaBuster", {0, 120, 248}, {0, 232, 216}, {0, 0, 0})
    megaman.weaponHandler[i]:register(9, "rushCoil", {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
    megaman.weaponHandler[i]:register(10, "rushJet", {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
    if globals.defeats.stickMan then
      megaman.weaponHandler[i]:register(1, "stickWeapon", {255, 255, 255}, {128, 128, 128}, {0, 0, 0})
    end
    megaman.colorOutline[i] = megaman.weaponHandler[i].colorOutline[0]
    megaman.colorOne[i] = megaman.weaponHandler[i].colorOne[0]
    megaman.colorTwo[i] = megaman.weaponHandler[i].colorTwo[0]
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

function megautils.freeze(e, name)
  for k, v in pairs(megautils.groups()["freezable"] or {}) do
    if e == nil or not table.contains(e, v) then
      megautils.frozen[#megautils.frozen+1] = v
      if name ~= nil and v.otherUpdates[name] ~= nil then
        v.otherUpdates[name] = false
      else
        v.updated = false
      end
    end
  end
end
function megautils.unfreeze(e, name)
  for k, v in pairs(megautils.groups()["freezable"] or {}) do
    if e == nil or not table.contains(e, v) then
      table.removevalue(megautils.frozen, v)
      if name ~= nil and v.otherUpdates[name] ~= nil then
        v.otherUpdates[name] = true
      else
        v.updated = true
      end
    end
  end
end

function megautils.outside(o)
  if o.collisionShape == nil then
    return false
  end
  if camera.main ~= nil and not camera.main.isRemoved then
    return not o:collision(camera.main)
  end
  return not rectOverlaps(view.x, view.y, view.w, view.h, 
    o.transform.x, o.transform.y, o.collisionShape.w, o.collisionShape.h)
end

function megautils.outsideSection(o)
  if o.collisionShape ~= nil and camera.main ~= nil and not camera.main.isRemoved then
    return not rectOverlaps(camera.main.scrollx, camera.main.scrolly, camera.main.scrollw, camera.main.scrollh, 
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
    love.graphics.translate(ternary(megautils.shakeSide, megautils.shakeX, -megautils.shakeX),
      ternary(megautils.shakeSide, megautils.shakeY, -megautils.shakeY))
  else
    megautils.shakeSide = false
    megautils.shakeTimer = 0
  end
end

function megautils.setShake(x, y, t)
  megautils.shakeX = x
  megautils.shakeY = y
  megautils.maxShakeTime = t or megautils.maxShakeTime
  megautils.shake = nil, true
end

function megautils.dropItem(x, y)
  local rnd = love.math.random(10000)
  if math.between(rnd, 0, 39) then
    local rnd2 = love.math.random(0, 2)
    if rnd2 == 0 then
      megautils.add(life(x, y, true))
    elseif rnd2 == 1 then
      megautils.add(eTank(x, y, true))
    else
      megautils.add(wTank(x, y, true))
    end
  elseif math.between(rnd, 50, 362) then
    if math.randomboolean() then
      megautils.add(health(x, y, true))
    else
      megautils.add(energy(x, y, true))
    end
  elseif math.between(rnd, 370, 995) then
    if math.randomboolean() then
      megautils.add(smallHealth(x, y, true))
    else
      megautils.add(smallEnergy(x, y, true))
    end
  end
end