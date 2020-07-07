megautils.loadResource("assets/global/bosses/stickMan.png", "stickMan")
megautils.loadResource("assets/sfx/enemyHit.ogg", "enemyHit")

stickMan = entity:extend()

addobjects.register("stickMan", function(v)
  megautils.add(spawner, v.x, v.y, 12, 28, function(s)
    megautils.add(stickMan, v.x, v.y, s)
  end)
end)

function stickMan:new(x, y, s)
  stickMan.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(12, 24)
  self.t = megautils.getResource("stickMan")
  self.side = -1
  self.s = 0
  self.spawner = s
  self.canDraw.global = false
  self.ss = 1
  self.hBar = healthHandler({128, 128, 128}, {255, 255, 255}, {0, 0, 0}, nil, nil, 7)
  self.hBar:instantUpdate(0)
  camera.main.funcs.stick = function(s)
    self.hBar.transform.x = view.x + view.w - 24
    self.hBar.transform.y = view.y + 80
  end
  self.velocity = velocity()
  self.velocity.vely = 8
  self.blockCollision = true
end

function stickMan:added(self)
  self:addToGroup("freezable")
  self:addToGroup("hurtable")
  self.canBeInvincible.global = true
  megautils.stopMusic()
end

function stickMan:gettingHurt(o, c, i)
  if o:is(megaSemiBuster) or checkTrue(self.canBeInvincible) or (o.dinked and not o.reflectedBack) then --Semi charged shots get reflected
    if o.dink and not o.dinked then
      o:dink(self)
    end
    return
  end
  if c < 0 and not o:is(megaChargedBuster) then --Remove shots
    megautils.removeq(o)
  end
  if self.iFrames ~= 0 then return end
  if o:is(stickWeapon) then --The weakness
    self.changeHealth = -8
  elseif o:is(megaChargedBuster) then --Semi-weakness
    self.changeHealth = -3
  else
    self.changeHealth = -1
  end
  self.hBar:updateThis(self.hBar.health + self.changeHealth)
  self.iFrames = 60
  if self.hBar.health <= 0 then
    if megautils.groups().removeOnDefeat then
      for k, v in ipairs(megautils.groups().removeOnDefeat) do
        megautils.removeq(v)
      end
    end
    explodeParticle.createExplosion(self.transform.x+((self.collisionShape.w/2)-24/2),
      self.transform.y+((self.collisionShape.h/2)-24/2))
    megautils.stopMusic()
    timer.absorbCutscene(function()
        globals.defeats.stickMan = true
        globals.weaponGet = "stick"
        globals.skin = megaMan.mainPlayer.playerName
        megautils.reloadState = true
        megautils.resetGameObjects = true
        megautils.gotoState("states/weaponget.state.lua")
      end)
    megautils.removeq(self)
    megautils.playSoundFromFile("assets/sfx/dieExplode.ogg")
  elseif self.changeHealth < 0 then
    megautils.add(harm, self)
    if o:is(megaChargedBuster) then
      megautils.removeq(o)
    end
    megautils.playSound("enemyHit")
  end
end

function stickMan:update(dt)
  if self.s == 0 then
    if globals.defeats.stickMan then
      timer.winCutscene(function()
          megautils.reloadState = true
          megautils.resetGameObjects = true
          megautils.gotoState("states/menu.state.lua")
        end)
      megautils.removeq(self)
    elseif megaMan.mainPlayer then
      self.s = 1
      megaMan.mainPlayer.canControl.global = false
      megaMan.mainPlayer.velocity.velx = 0
      megaMan.mainPlayer:resetStates()
      if not megaMan.mainPlayer.ground then
        megaMan.mainPlayer.curAnim = "jump"
      end
      megaMan.mainPlayer.side = self.transform.x>megaMan.mainPlayer.transform.x and 1 or -1
      megaMan.mainPlayer:face(megaMan.mainPlayer.side)
    end
  elseif self.s == 1 then
    if self.ss == 1 then
      if megaMan.mainPlayer then
        collision.doGrav(megaMan.mainPlayer)
        megaMan.mainPlayer:phys()
        megaMan.mainPlayer.curAnim = "jump"
        if megaMan.mainPlayer.ground then
          self.ss = 0
          megaMan.mainPlayer.curAnim = "idle"
          self.s = 2
          if isWeb then
            megautils.playMusic("assets/sfx/music/bossLoop.ogg", "assets/sfx/music/bossIntro.ogg")
          else
            megautils.playMusic("assets/sfx/music/boss.wav", true, 162898, 444759)
          end
          self.canDraw.global = true
        end
      end
    end
  elseif self.s == 2 then
    collision.doCollision(self)
    if self.ground then
      self.canBeInvincible.global = false
      self.hBar:updateThis(28)
      megautils.adde(self.hBar)
      megaMan.mainPlayer.canUpdate.hb = true
      self.s = 3
    end
  elseif self.s == 3 then
    megaMan.mainPlayer.canControl.global = true
    self.s = 4
  end
  self:hurt(self:collisionTable(megaMan.allPlayers), -4, 80)
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
  self.t = megautils.getResource("stickMan")
  self.c = "idle"
  self.text = "STICK MAN"
  self.pos = 0
  self.textTimer = 0
  self.timer = 0
  self.s = 0
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
      megautils.stopMusic()
      megautils.transitionToState("states/demo.stage.lua")
      self.s = 5
    end
  end
end

function stickManIntro:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.t, self.transform.x, self.transform.y)
  love.graphics.setFont(mmFont)
  love.graphics.print(string.sub(self.text, 0, self.pos), 85, 141)
end

megamanStick = basicEntity:extend()

function megamanStick:new()
  megamanStick.super.new(self)
  self.transform.y = -60
  self.transform.x = 100
  if globals.skin == "mega" then
    self.texOutline = megautils.loadResource("assets/players/megaman/megaManOutline.png", "megaManOutline")
    self.texOne = megautils.loadResource("assets/players/megaman/megaManOne.png", "megaManOne")
    self.texTwo = megautils.loadResource("assets/players/megaman/megaManTwo.png", "megaManTwo")
    self.texFace = megautils.loadResource("assets/players/megaman/megaManFace.png", "megaManFace")
    self.grid = megautils.loadResource("megaManGrid", 41, 30, 164, 330)
  elseif globals.skin == "proto" then
    self.texOutline = megautils.loadResource("assets/players/proto/protoManOutline.png", "protoManOutline")
    self.texOne = megautils.loadResource("assets/players/proto/protoManOne.png", "protoManOne")
    self.texTwo = megautils.loadResource("assets/players/proto/protoManTwo.png", "protoManTwo")
    self.texFace = megautils.loadResource("assets/players/proto/protoManFace.png", "protoManFace")
    self.grid = megautils.loadResource("megaManGrid", 41, 30, 164, 330)
  elseif globals.skin == "bass" then
    self.texOutline = megautils.loadResource("assets/players/bass/bassOutline.png", "bassOutline")
    self.texOne = megautils.loadResource("assets/players/bass/bassOne.png", "bassOne")
    self.texTwo = megautils.loadResource("assets/players/bass/bassTwo.png", "bassTwo")
    self.texFace = megautils.loadResource("assets/players/bass/bassFace.png", "bassFace")
    self.grid = megautils.loadResource("bassGrid", 45, 41, 180, 533)
  elseif globals.skin == "roll" then
    self.texOutline = megautils.loadResource("assets/players/roll/rollOutline.png", "rollOutline")
    self.texOne = megautils.loadResource("assets/players/roll/rollOne.png", "rollOne")
    self.texTwo = megautils.loadResource("assets/players/roll/rollTwo.png", "rollTwo")
    self.texFace = megautils.loadResource("assets/players/roll/rollFace.png", "rollFace")
    self.grid = megautils.loadResource("rollGrid", 45, 34, 180, 374)
  end
  weapons.resources.stickWeapon()
  self.curAnim = pose and "pose" or "idle"
  self.animations = {}
  self.animations.idle = anim8.newAnimation(self.grid(1, 1, 2, 1), {2.5, 0.1})
  self.animations.idleShoot = anim8.newAnimation(self.grid(1, 4), 1)
  self:face(1)
  self.text = "WEAPON GET... STICK WEAPON!"
  self.pos = 0
  self.textTimer = 0
  self.timer = 0
  self.timer2 = 0
  self.shootTimer = 14
  self.s = 0
  self.megaOne = banner.colorOne
  self.megaTwo = banner.colorTwo
  self.toOne = {255, 255, 255}
  self.toTwo = {128, 128, 128}
  banner.colorOne = table.clone(self.megaOne)
  banner.colorTwo = table.clone(self.megaTwo)
  banner.colorOutline = {0, 0, 0}
  self.wh = {}
  self.wh.currentSlot = 1
end

function megamanStick:face(n)
  self.animations[self.curAnim].flippedH = (n == 1) and true or false
end

function megamanStick:update(dt)
  self.animations[self.curAnim]:update(defaultFramerate)
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
      megautils.add(stickWeapon, self.transform.x+17, self.transform.y+7, 1, self.wh)
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
      megautils.transitionToState("states/menu.state.lua")
      megautils.removeq(self)
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
  self.animations[self.curAnim]:draw(self.texOutline, math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(banner.colorOne[1]/255, banner.colorOne[2]/255, banner.colorOne[3]/255, 1)
  self.animations[self.curAnim]:draw(self.texOne, math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(banner.colorTwo[1]/255, banner.colorTwo[2]/255, banner.colorTwo[3]/255, 1)
  self.animations[self.curAnim]:draw(self.texTwo, math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(1, 1, 1, 1)
  self.animations[self.curAnim]:draw(self.texFace, math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  
  love.graphics.setFont(mmFont)
  love.graphics.printf(string.sub(self.text, 0, self.pos), 0, (120/2)+81, view.w, "center")
end

megautils.cleanFuncs.stickMan = function()
  stickMan = nil
  stickManIntro = nil
  megamanStick = nil
  addobjects.unregister("stickMan")
  megautils.cleanFuncs.stickMan = nil
end
