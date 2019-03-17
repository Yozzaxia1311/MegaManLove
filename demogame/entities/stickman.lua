loader.load("assets/stick_man.png", "stick_man", "texture")

stickMan = entity:extend()

addobjects.register("stick_man", function(v)
  local tmp = spawner(v.x, v.y, 12, 28, function(s)
    megautils.add(stickMan(s.transform.x, s.transform.y, s))
  end)
  megautils.add(tmp)
end)

function stickMan:new(x, y, s)
  stickMan.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
    self:addToGroup("hurtable")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(12, 24)
  self.t = loader.get("stick_man")
  self.side = -1
  self.s = 0
  self:setLayer(1)
  self.spawner = s
  self.render = false
  self.ss = 0
  self.health = 28
  self.hBar = healthhandler({128, 128, 128}, {255, 255, 255}, {0, 0, 0}, nil, nil, 7)
  self.hBar.health = 0
  self.hBar.change = self.health
  camera.main.funcs["stick"] = function(s)
    self.hBar.transform.x = view.x + view.w - 24
    self.hBar.transform.y = view.y + 80
  end
  self.velocity = velocity()
  self.velocity.vely = 8
  mmMusic.stopMusic()
end

function stickMan:healthChanged(o, c, i)
  if c < 0 and not o:is(megaChargedBuster) and not o:is(megaSemiBuster) then --Remove shots
    megautils.remove(o, true)
  end
  if not self:iFrameIsDone() then return end
  if o:is(megaSemiBuster) then --Semi charged shots get reflected
    mmSfx.play("dink")
    o.dink = true
    self.iFrame = self.maxIFrame
    return
  end
  if o:is(stickWeapon) then --The weakness
    self.changeHealth = -8
  elseif o:is(megaChargedBuster) then --Semi-weakness
    self.changeHealth = -3
  else
    self.changeHealth = -1
  end
  self.health = self.health + self.changeHealth
  self.hBar.change = self.changeHealth
  self.hBar:updateThis()
  self.maxIFrame = 60
  self.iFrame = 0
  if self.health <= 0 then
    if megautils.groups()["removeOnDefeat"] then
      for k, v in ipairs(megautils.groups()["removeOnDefeat"]) do
        megautils.remove(v, true)
      end
    end
    mmSfx.play("die")
    explodeParticle.createExplosion(self.transform.x+((self.collisionShape.w/2)-24/2),
      self.transform.y+((self.collisionShape.h/2)-24/2))
    mmMusic.stopMusic()
    timer.absorbCutscene(function()
      globals.defeats.stickMan = true
      globals.weaponGet = "stick"
      megautils.resetGameObjects()
      states.set("states/weaponget.state.lua")
    end)
    megautils.remove(self, true)
  elseif self.changeHealth < 0 then
    self.hitTimer = 0
    mmSfx.play("enemy_hit")
    megautils.add(harm(self))
    if o:is(megaChargedBuster) then
      megautils.remove(o, true)
    end
  end
end

function stickMan:phys()
  self:resetCollisionChecks()
  solid.blockFromGroup(self, megautils.groups()["solid"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
end

function stickMan:update(dt)
  if self.s == 0 then
    if globals.defeats.stickMan then
      timer.winCutscene(function()
        megautils.resetGameObjects()
        states.set("states/menu.state.lua")
      end)
      megautils.remove(self, true)
    elseif globals.mainPlayer and globals.mainPlayer.control then
      self.s = 1
      globals.mainPlayer.control = false
    end
  elseif self.s == 1 then
    if self.ss == 0 then
      if globals.mainPlayer then
        local ly = globals.mainPlayer.velocity.vely
        globals.mainPlayer:resetStates()
        globals.mainPlayer.velocity.vely = ly
        globals.mainPlayer.control = false
        globals.mainPlayer.side = self.transform.x>globals.mainPlayer.transform.x and 1 or -1
        globals.mainPlayer:face(globals.mainPlayer.side)
        if not globals.mainPlayer:solid(0, 1) then
          globals.mainPlayer.curAnim = "jump"
        end
        self.ss = 1
      end
    elseif self.ss == 1 then
      if globals.mainPlayer then
        globals.mainPlayer:grav()
        globals.mainPlayer:phys()
        globals.mainPlayer.curAnim = "jump"
        if globals.mainPlayer.collisionChecks.ground then
          self.ss = 0
          globals.mainPlayer.curAnim = "idle"
          self.s = 2
          mmMusic.playFromFile("assets/boss_loop.ogg", "assets/boss_intro.ogg")
          self.render = true
        end
      end
    end
  elseif self.s == 2 then
    self:phys()
    if self.collisionChecks.ground then
      megautils.add(self.hBar)
      self.hBar:updateThis()
      globals.mainPlayer.control = true
      self.s = 3
    end
  end
  self:hurt(self:collisionTable(globals.allPlayers), -4, 80)
  self:updateIFrame()
  self:updateFlash()
end

function stickMan:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function stickMan:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.t, self.transform.x-4, self.transform.y-8)
  --self:drawCollision()
end

stickManIntro = entity:extend()

function stickManIntro:new()
  stickManIntro.super.new(self)
  self.transform.y = -60
  self.transform.x = 108
  self.t = loader.get("stick_man")
  self.c = "idle"
  self.text = "stick man"
  self.pos = 0
  self.textTimer = 0
  self.timer = 0
  self.s = 0
  self:setLayer(3)
  banner.colorOne = {255, 255, 255}
  banner.colorTwo = {128, 128, 128}
end

function stickManIntro:update(dt)
  if self.s == 0 then
    self.transform.y = math.min(self.transform.y+10, 96)
    if self.transform.y == 96 then
      self.s = 1
    end
  elseif self.s == 1 then
    self.timer = math.min(self.timer+1, 15)
    if self.timer == 15 then
      self.timer = 0
      --self.c = "pose"
      self.s = 2
    end
  elseif self.s == 2 then
    self.timer = math.min(self.timer+1, 40)
    if self.timer == 40 then
      self.timer = 0
      self.s = 3
    end
  elseif self.s == 3 then
    self.textTimer = math.min(self.textTimer+1, 8)
    if self.textTimer == 8 then
      self.textTimer = 0
      self.pos = math.min(self.pos+1, self.text:len())
    end
    if self.pos == self.text:len() then
      self.s = 4
    end
  elseif self.s == 4 then
    self.timer = math.min(self.timer+1, 300)
    if self.timer == 300 then
      mmMusic.stopMusic()
      megautils.gotoState("states/demo.state.lua")
      self.updated = false
    end
  end
end

function stickManIntro:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.t, self.transform.x, self.transform.y)
  love.graphics.setFont(mmFont)
  love.graphics.print(string.sub(self.text, 0, self.pos), 85, 141)
end

megamanStick = entity:extend()

function megamanStick:new()
  megamanStick.super.new(self)
  self.transform.y = -60
  self.transform.x = 100
  self.curAnim = pose and "pose" or "idle"
  self.animations = {}
  self.animations["idle"] = anim8.newAnimation(loader.get("mega_man_grid")(1, 1, 2, 1), {2.5, 0.1})
  self.animations["idleShoot"] = anim8.newAnimation(loader.get("mega_man_grid")(1, 4), 1)
  self:face(1)
  self.text = "weapon get... stick weapon!"
  self.pos = 0
  self.textTimer = 0
  self.timer = 0
  self.timer2 = 0
  self.shootTimer = 14
  self.s = 0
  self.layer = 3
  self.megaOne = {0, 120, 248}
  self.megaTwo = {0, 232, 216}
  self.toOne = {255, 255, 255}
  self.toTwo = {128, 128, 128}
  banner.colorOne = self.megaOne
  banner.colorTwo = self.megaTwo
  banner.colorOutline = {0, 0, 0}
  self.wh = {}
  self.wh.currentSlot = 1
end

function megamanStick:face(n)
  self.animations[self.curAnim].flippedH = (n == 1) and true or false
end

function megamanStick:update(dt)
  self.animations[self.curAnim]:update(1/60)
  if self.s == 0 then
    self.transform.y = math.min(self.transform.y+10, 104)
    if self.transform.y == 104 then
      self.s = 1
    end
  elseif self.s == 1 then
    self.timer = math.min(self.timer+1, 60)
    if self.timer == 60 then
      self.timer = 0
      self.s = 2
    end
  elseif self.s == 2 then
    self.timer = math.min(self.timer+1, 8)
    if self.timer == 8 then
      self.timer = 0
      self.timer2 = self.timer2 + 1
      if math.wrap(self.timer2, 0, 1) == 0 then
        banner.colorOne = self.toOne
        banner.colorTwo = self.toTwo
      else
        banner.colorOne = self.megaOne
        banner.colorTwo = self.megaTwo
      end
      if self.timer2 == 16 then
        self.s = 3
        self.timer2 = 0
      end
    end
  elseif self.s == 3 then
    self.textTimer = math.min(self.textTimer+1, 8)
    if self.textTimer == 8 then
      self.textTimer = 0
      self.pos = math.min(self.pos+1, self.text:len())
    end
    self.timer = math.min(self.timer+1, 15)
    if self.timer == 15 then
      self.timer = 0
      self.s = 4
    end
  elseif self.s == 4 then
    self.textTimer = math.min(self.textTimer+1, 8)
    if self.textTimer == 8 then
      self.textTimer = 0
      self.pos = math.min(self.pos+1, self.text:len())
    end
    self.timer = math.min(self.timer+1, 50)
    if self.timer == 50 then
      self.timer = 0
      self.timer2 = self.timer2 + 1
      self.shootTimer = 0
      megautils.add(stickWeapon(self.transform.x+17, self.transform.y+7, 1, self.wh))
      if self.timer2 == 4 then
        self.timer2 = 0
        self.s = 5
      end
    end
  elseif self.s == 5 then
    self.textTimer = math.min(self.textTimer+1, 8)
    if self.textTimer == 8 then
      self.textTimer = 0
      self.pos = math.min(self.pos+1, self.text:len())
    end
    if self.pos == self.text:len() then
      self.s = 6
    end
  elseif self.s == 6 then
    self.timer = math.min(self.timer+1, 60)
    if self.timer == 60 then
      globals.stopMusicMenu = true
      megautils.gotoState("states/menu.state.lua")
      self.updated = false
    end
  end
  self.shootTimer = math.min(self.shootTimer+1, 14)
  if self.shootTimer == 14 then
    self.curAnim = "idle"
  else
    self.curAnim = "idleShoot"
  end
  self:face(1)
end

function megamanStick:draw()
  love.graphics.setColor(1, 1, 1, 1)
  local offsety = 1
  
  love.graphics.setColor(banner.colorOutline[1]/255, banner.colorOutline[2]/255, banner.colorOutline[3]/255, 1)
  self.animations[self.curAnim]:draw(loader.get("mega_man_outline"), math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(banner.colorOne[1]/255, banner.colorOne[2]/255, banner.colorOne[3]/255, 1)
  self.animations[self.curAnim]:draw(loader.get("mega_man_one"), math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(banner.colorTwo[1]/255, banner.colorTwo[2]/255, banner.colorTwo[3]/255, 1)
  self.animations[self.curAnim]:draw(loader.get("mega_man_two"), math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(1, 1, 1, 1)
  self.animations[self.curAnim]:draw(loader.get("mega_man_face"), math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  
  love.graphics.setFont(mmFont)
  love.graphics.printf(string.sub(self.text, 0, self.pos), 0, (120/2)+81, view.w, "center")
end

megautils.cleanFuncs["unload_stickman"] = function()
  stickMan = nil
  stickManIntro = nil
  megamanStick = nil
  addobjects.unregister("stick_man")
  megautils.cleanFuncs["unload_stickman"] = nil
end