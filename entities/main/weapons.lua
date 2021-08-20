megautils.loadResource("assets/sfx/buster.ogg", "buster", true)
megautils.loadResource("assets/sfx/reflect.ogg", "dink", true)

weapon = entity:extend()

weapon.autoClean = false

function weapon.ser()
  return {
      removeGroups = weapon.removeGroups,
      resources = weapon.resources,
      colors = weapon.colors,
      chargeColors = weapon.chargeColors,
      chargeSounds = weapon.chargeSounds,
      icons = weapon.icons,
      segments = weapon.segments,
      sevenWayAnim = weapon.sevenWayAnim,
      throwAnim = weapon.throwAnim,
      stopOnShot = weapon.stopOnShot,
      shootFrames = weapon.shootFrames,
      rapidFire = weapon.rapidFire,
      shootFuncs = weapon.shootFuncs,
      rapidFireFuncs = weapon.rapidFireFuncs,
      chargeShotFuncs = weapon.chargeShotFuncs,
      autoCleanWeaponData = weapon.autoCleanWeaponData,
      ignoreEnergy = weapon.ignoreEnergy,
      _activeQuad = weapon._activeQuad,
      _inactiveQuad = weapon._inactiveQuad
    }
end

function weapon.deser(t)
  weapon.removeGroups = t.removeGroups
  weapon.resources = t.resources
  weapon.colors = t.colors
  weapon.chargeColors = t.chargeColors
  weapon.chargeSounds = t.chargeSounds
  weapon.icons = t.icons
  weapon.segments = t.segments
  weapon.sevenWayAnim = t.sevenWayAnim
  weapon.throwAnim = t.throwAnim
  weapon.stopOnShot = t.stopOnShot
  weapon.shootFrames = t.shootFrames
  weapon.rapidFire = t.rapidFire
  weapon.shootFuncs = t.shootFuncs
  weapon.rapidFireFuncs = t.rapidFireFuncs
  weapon.chargeShotFuncs = t.chargeShotFuncs
  weapon.autoCleanWeaponData = t.autoCleanWeaponData
  weapon.ignoreEnergy = t.ignoreEnergy
  weapon._activeQuad = t._activeQuad
  weapon._inactiveQuad = t._inactiveQuad
end

weapon.DAMAGENONE = 0
weapon.DAMAGEPLAYER = 1
weapon.DAMAGEENEMY = 2
weapon.DAMAGEBOTH = 3

weapon.removeGroups = {}
weapon.resources = {}
weapon.colors = {}
weapon.chargeColors = {}
weapon.chargeSounds = {}
weapon.icons = {}
weapon.segments = {}
weapon.sevenWayAnim = {}
weapon.throwAnim = {}
weapon.stopOnShot = {}
weapon.rapidFireFuncs = {}
weapon.chargeShotFuncs = {}
weapon.shootFrames = {}
weapon.rapidFire = {}
weapon.shootFuncs = {}
weapon.autoCleanWeaponData = {}
weapon.ignoreEnergy = {}

weapon._activeQuad = quad(0, 0, 16, 16)
weapon._inactiveQuad = quad(16, 0, 16, 16)

function weapon.drawIcon(p, on, x, y)
  local tex = megautils.getResource(weapon.icons[p])
  if on == nil or on then
    tex:draw(weapon._activeQuad, x, y)
  else
    tex:draw(weapon._inactiveQuad, x, y)
  end
end

megautils.cleanFuncs.weaponAutoCleaner = {func=function()
    for k, v in pairs(weapon.autoCleanWeaponData) do
      if v then
        weapon.removeGroups[k] = nil
        weapon.resources[k] = nil
        weapon.colors[k] = nil
        weapon.chargeColors[k] = nil
        weapon.chargeSounds[k] = nil
        weapon.icons[k] = nil
        weapon.segments[k] = nil
        weapon.sevenWayAnim[k] = nil
        weapon.throwAnim[k] = nil
        weapon.stopOnShot[k] = nil
        weapon.rapidFireFuncs[k] = nil
        weapon.chargeShotFuncs[k] = nil
        weapon.shootFrames[k] = nil
        weapon.rapidFire[k] = nil
        weapon.shootFuncs[k] = nil
      end
      
      weapon.autoCleanWeaponData[k] = nil
    end
  end, autoClean=false}

function weapon:new(p, enWeapon)
  weapon.super.new(self)
  if not self.recycling then
    self:setRectangleCollision(8, 8)
    self.autoHit = true
    self.sound = "buster"
    self.soundOnDink = "dink"
    self.damage = -1
    self.flipWithUser = true
    self.weaponGroup = nil
    self.removeWhenOutside = true
    self.autoGravity.global = false
    self.doAutoCollisionBeforeUpdate = true
    self.doDink = true
    self.applyAutoFace = false
    self.flipFace = false
    self.noSlope = false
    self.maxFallingSpeed = 7
  end
  
  self.dinkedBy = nil
  self._didCol = false
  self.dinked = false
  self.user = p
  self.damageType = weapon.DAMAGEENEMY
  self.damageTypeOnDink = weapon.DAMAGENONE
  self.pierceType = pierce.NOPIERCE
  self.isEnemyWeapon = false
  self.autoFace = -1
  self.side = -1
  if enWeapon then
    self.isEnemyWeapon = true
    self.damageType = weapon.DAMAGEPLAYER
    self.damageTypeOnDink = weapon.DAMAGEENEMY
    self.pierceType = pierce.PIERCE
  end
end

function weapon:added()
  if self.weaponGroup then
    self:addToGroup(self.weaponGroup)
    if self.user and megaMan.weaponHandler[self.user.player] then
      self:addToGroup(self.weaponGroup .. tostring(megaMan.weaponHandler[self.user.player].id))
    end
  end
  self:addToGroup("removeOnTransition")
  self:addToGroup("weapon")
  if self.isEnemyWeapon then
    self:addToGroup("enemyWeapon")
  else
    self:addToGroup("playerWeapon")
  end
  if self.sound then
    if megautils.getResource(self.sound) then
      megautils.playSound(self.sound)
    else
      megautils.playSoundFromFile(self.sound)
    end
  end
end

function weapon:grav()
  self.velY = math.clamp(self.velY + self.gravity, -self.maxFallingSpeed, self.maxFallingSpeed)
end

function weapon:dink(e)
  if self.doDink then
    if self.isEnemyWeapon then
      self.velX = -self.velX
      self.velY = -self.velY
    else
      self.velX = self.velX >= 0 and -4 or 4
      self.velY = (self.gravity >= 0) and -4 or 4
    end
    self.dinked = true
    self.dinkedBy = e
    self.blockCollision.global = false
    self.damageType = self.damageTypeOnDink
    if self.soundOnDink then
      if megautils.getResource(self.soundOnDink) then
        megautils.playSound(self.soundOnDink)
      else
        megautils.playSoundFromFile(self.soundOnDink)
      end
    end
  end
end

function weapon:dinking(e, dt) end

function weapon:_beforeUpdate(dt)
  for i = 1, #self.gfx do
    self.gfx[i]:_update(dt)
  end
  
  if self.flipWithUser and self.user and self.user.gravityMultipliers then
    self:setGravityMultiplier("flipWithUser", self.user.gravityMultipliers.gravityFlip or 1)
  end
  local s = megautils.side(self, self.user, true)
  self.autoFace = s or self.autoFace
  if self.applyAutoFace then
    self.side = self.autoFace
  end
  for i = 1, #self.gfx do
    self.gfx[i]:flip(self.side == (self.flipFace and 1 or -1))
  end
  
  self:beforeUpdate(dt)
end

function weapon:_update(dt)
  if self.dinked and self.doDink then
    self:dinking(self.dinkedBy, dt)
  else
    self:update(dt)
  end
end

function weapon:_afterUpdate(dt)
  if self.autoHit then
    if self.damageType == weapon.DAMAGEENEMY or self.damageType == weapon.DAMAGEBOTH then
      self:interact(self:collisionTable(megautils.filterByGroup(self:getSurroundingEntities(), "interactable")), self.damage)
    end
    if self.damageType == weapon.DAMAGEPLAYER or self.damageType == weapon.DAMAGEBOTH then
      self:interact(self:collisionTable(megaMan.allPlayers), self.damage)
    end
  end
  if self.removeWhenOutside and megautils.outside(self) then
    megautils.remove(self)
  end
  
  self:afterUpdate(dt)
end

weapon.removeGroups["P.BUSTER"] = {"megaBuster", "protoChargedBuster"}

weapon.resources["P.BUSTER"] = function()
    megautils.loadResource("assets/misc/weapons/buster.png", "busterTex")
    megautils.loadResource("assets/misc/weapons/protoBuster.png", "protoBuster")
    megautils.loadResource("assets/sfx/semi.ogg", "semiCharged")
    megautils.loadResource("assets/sfx/protoCharge.ogg", "protoCharge")
    megautils.loadResource("assets/sfx/protoCharged.ogg", "protoCharged")
    megautils.loadResource("assets/misc/weapons/protoBuster.anim", "protoBusterAnim")
  end

weapon.icons["P.BUSTER"] = "assets/misc/weapons/icons/protoBuster.png"

weapon.colors["P.BUSTER"] = {
    outline = {0, 0, 0},
    one = {216, 40, 0},
    two = {184, 184, 184}
  }

weapon.ignoreEnergy["P.BUSTER"] = true

weapon.chargeSounds["P.BUSTER"] = "protoCharge"

weapon.chargeColors["P.BUSTER"] = {
    outline = {
      {
        {216, 40, 0},
        {0, 0, 0}
      },
      {
        {184, 184, 184},
        {216, 40, 0},
        {0, 0, 0}
      }
    },
    one = {
      {
        {216, 40, 0},
        {216, 40, 0}
      },
      {
        {0, 0, 0},
        {184, 184, 184},
        {216, 40, 0}
      }
    },
    two = {
      {
        {184, 184, 184},
        {184, 184, 184}
      },
      {
        {184, 184, 184},
        {0, 0, 0},
        {216, 40, 0}
      }
    }
  }

weapon.shootFuncs["P.BUSTER"] = function(player)
    if player:numberOfShots("megaBuster") < 3 and player:numberOfShots("protoChargedBuster") < 1 then
      return megautils.add(megaBuster, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side)
    end
  end

weapon.chargeShotFuncs["P.BUSTER"] = function(player, charge)
    if player:numberOfShots("megaBuster") < 3 then
      if charge == 1 then
        return megautils.add(protoSemiBuster, player.x + player:shootOffX(2), player.y + player:shootOffY(), player, player.side, "protoBuster")
      elseif charge == 2 and player:numberOfShots("protoChargedBuster") < 1 then
        return megautils.add(protoChargedBuster, player.x + player:shootOffX(8), player.y + player:shootOffY(), player, player.side, "protoBuster")
      end
    end
  end

weapon.removeGroups["R.BUSTER"] = {"megaBuster", "protoChargedBuster"}

weapon.resources["R.BUSTER"] = function()
    megautils.loadResource("assets/misc/weapons/buster.png", "busterTex")
    megautils.loadResource("assets/misc/weapons/rollBuster.png", "rollBuster")
    megautils.loadResource("assets/sfx/semi.ogg", "semiCharged")
    megautils.loadResource("assets/sfx/charge.ogg", "charge")
    megautils.loadResource("assets/sfx/protoCharged.ogg", "protoCharged")
    megautils.loadResource("assets/misc/weapons/protoBuster.anim", "protoBusterAnim")
  end

weapon.icons["R.BUSTER"] = "assets/misc/weapons/icons/rollBuster.png"

weapon.colors["R.BUSTER"] = {
    outline = {0, 0, 0},
    one = {248, 56, 0},
    two = {0, 168, 0}
  }

weapon.ignoreEnergy["R.BUSTER"] = true

weapon.chargeSounds["R.BUSTER"] = "charge"

weapon.chargeColors["R.BUSTER"] = {
    outline = {
      {
        {248, 56, 0},
        {0, 0, 0}
      },
      {
        {0, 168, 0},
        {248, 56, 0},
        {0, 0, 0}
      }
    },
    one = {
      {
        {248, 56, 0},
        {248, 56, 0}
      },
      {
        {0, 0, 0},
        {0, 168, 0},
        {248, 56, 0}
      }
    },
    two = {
      {
        {0, 168, 0},
        {0, 168, 0}
      },
      {
        {0, 168, 0},
        {0, 0, 0},
        {248, 56, 0}
      }
    }
  }

weapon.shootFuncs["R.BUSTER"] = function(player)
    if player:numberOfShots("megaBuster") < 3 and player:numberOfShots("protoChargedBuster") < 1 then
      return megautils.add(megaBuster, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side)
    end
  end

weapon.chargeShotFuncs["R.BUSTER"] = function(player, charge)
    if player:numberOfShots("megaBuster") < 3 then
      if charge == 1 then
        return megautils.add(protoSemiBuster, player.x + player:shootOffX(2), player.y + player:shootOffY(), player, player.side, "rollBuster")
      elseif charge == 2 and player:numberOfShots("protoChargedBuster") < 1 then
        return megautils.add(protoChargedBuster, player.x + player:shootOffX(8), player.y + player:shootOffY(), player, player.side, "rollBuster")
      end
    end
  end

protoSemiBuster = weapon:extend()

protoSemiBuster.autoClean = false

function protoSemiBuster:new(x, y, p, dir, skin)
  protoSemiBuster.super.new(self, p)
  self.x = (x or 0) - 5
  self.y = (y or 0) - 5
  self:setRectangleCollision(10, 10)
  self.skin = skin
  self:addGFX("tex", image(self.skin, quad(0, 0, 10, 10)))
  self.side = dir or 1
  self.velX = self.side * 5
  self.weaponGroup = "megaBuster"
  self.sound = "semiCharged"
  self.damage = -1
end

protoChargedBuster = weapon:extend()

protoChargedBuster.autoClean = false

function protoChargedBuster:new(x, y, p, dir, skin)
  protoChargedBuster.super.new(self, p)
  self.x = (x or 0) - 14
  self.y = (y or 0) - 4
  self:setRectangleCollision(29, 8)
  self.skin = skin
  self.tex = megautils.getResource(self.skin)
  self.anim = animation("protoBusterAnim")
  self.side = dir or 1
  self.velX = self.side * 6
  self.pierceType = pierce.PIERCEIFKILLING
  self.sound = "protoCharged"
  self.weaponGroup = "protoChargedBuster"
  self.damage = -2
end

function protoChargedBuster:dinking()
  self.anim:update(1/60)
end

function protoChargedBuster:update()
  self.anim:update(1/60)
end

function protoChargedBuster:draw()
  self.tex:draw(self.anim, math.floor(self.x), math.floor(self.y)-1,
    nil, nil, nil, nil, nil, nil, nil, self.side ~= 1)
end

weapon.removeGroups["B.BUSTER"] = {"bassBuster"}

weapon.resources["B.BUSTER"] = function()
    megautils.loadResource("assets/misc/weapons/bassBuster.png", "bassBuster")
  end

weapon.icons["B.BUSTER"] = "assets/misc/weapons/icons/bassBuster.png"

weapon.colors["B.BUSTER"] = {
    outline = {0, 0, 0},
    one = {248, 152, 56},
    two = {112, 112, 112}
  }

weapon.sevenWayAnim["B.BUSTER"] = true

weapon.rapidFire["B.BUSTER"] = 5

weapon.stopOnShot["B.BUSTER"] = true

weapon.ignoreEnergy["B.BUSTER"] = true

weapon.rapidFireFuncs["B.BUSTER"] = function(player)
    player.shootFrames = 15
    if player:numberOfShots("bassBuster") < 4 then
      local dir = player.side == 1 and 0 or 180
      
      if input.down["up" .. tostring(player.input)] or player.tUp then
        if input.down["left" .. tostring(player.input)] or player.tLeft then
          dir = -45+180
        elseif input.down["right" .. tostring(player.input)] or player.tRight then
          dir = 45
        else
          if player.gravity >= 0 then
            dir = 90
          else
            dir = player.side == 1 and 45 or -45+180
          end
        end
      elseif input.down["down" .. tostring(player.input)] or player.tDown then
        if input.down["left" .. tostring(player.input)] or player.tLeft then
          dir = 45+180
        elseif input.down["right" .. tostring(player.input)] or player.tRight then
          dir = -45
        else
          if player.gravity >= 0 then
            dir = player.side == 1 and -45 or 45+180
          else
            dir = -90
          end
        end
      end
      
      return megautils.add(bassBuster, player.x+player:shootOffX(tx), player.y+player:shootOffY(ty), player, dir)
    end
  end

bassBuster = weapon:extend()

bassBuster.autoClean = false

function bassBuster:new(x, y, p, dir, t)
  bassBuster.super.new(self, p)
  
  if not self.recycling then
    self:setRectangleCollision(6, 6)
    self:addGFX("tex", image("bassBuster"):off(-1, -1))
    self.weaponGroup = "bassBuster"
    self.recycle = true
  end
  
  self.x = (x or 0) - 3
  self.y = (y or 0) - 3
  self.velX = megautils.calcX(dir or 1) * 5
  self.velY = megautils.calcY(dir or 1) * 5
  self.side = self.velX < 0 and -1 or 1
  self.treble = t
  if not self.treble then
    self.damage = -0.5
  end
end

function bassBuster:update()
  local col = collision.checkSolid(self, self.velX, self.velY)
  if not self.treble and not self.dinked and col then
    megautils.remove(self)
  end
end

weapon.removeGroups["M.BUSTER"] = {"megaBuster", "megaChargedBuster"}

weapon.resources["M.BUSTER"] = function()
    megautils.loadResource("assets/misc/weapons/buster.png", "busterTex")
    megautils.loadResource("assets/sfx/semi.ogg", "semiCharged")
    megautils.loadResource("assets/sfx/charge.ogg", "charge")
    megautils.loadResource("assets/sfx/charged.ogg", "charged")
    megautils.loadResource("assets/misc/weapons/megaChargedBuster.anim", "megaChargedBusterAnim")
    megautils.loadResource("assets/misc/weapons/megaSemiBuster.anim", "megaSemiBuster")
  end

weapon.icons["M.BUSTER"] = "assets/misc/weapons/icons/megaBuster.png"

weapon.colors["M.BUSTER"] = {
    outline = {0, 0, 0},
    one = {0, 120, 248},
    two = {0, 232, 216}
  }

weapon.chargeSounds["M.BUSTER"] = "charge"

weapon.chargeColors["M.BUSTER"] = {
    outline = {
      {
        {0, 232, 216},
        {0, 0, 0}
      },
      {
        {0, 120, 248},
        {0, 0, 0},
        {0, 232, 216}
      }
    },
    one = {
      {
        {0, 120, 248},
        {0, 120, 248}
      },
      {
        {0, 232, 216},
        {0, 120, 248},
        {0, 0, 0}
      }
    },
    two = {
      {
        {0, 232, 216},
        {0, 232, 216}
      },
      {
        {0, 0, 0},
        {0, 232, 216},
        {0, 120, 248}
      }
    }
  }

weapon.ignoreEnergy["M.BUSTER"] = true

weapon.shootFuncs["M.BUSTER"] = function(player)
    if player:numberOfShots("megaBuster") < 3 and player:numberOfShots("megaChargedBuster") < 1 then
      return megautils.add(megaBuster, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side)
    end
  end

weapon.chargeShotFuncs["M.BUSTER"] = function(player, charge)
    if player:numberOfShots("megaBuster") < 3 then
      if charge == 1 then
        return megautils.add(megaSemiBuster, player.x + player:shootOffX(2), player.y + player:shootOffY(), player, player.side)
      elseif charge == 2 and player:numberOfShots("megaChargedBuster") < 1 then
        return megautils.add(megaChargedBuster, player.x + player:shootOffX(4), player.y + player:shootOffY(), player, player.side)
      end
    end
  end

megaBuster = weapon:extend()

megaBuster.autoClean = false

function megaBuster:new(x, y, p, dir)
  megaBuster.super.new(self, p)
  
  if self.recycling then
    self.velY = 0
  else
    self:setRectangleCollision(8, 6)
    self:addGFX("tex", image("busterTex", quad(0, 31, 8, 6)))
    self.weaponGroup = "megaBuster"
    self.recycle = true
  end
  
  self.x = (x or 0) - 4
  self.y = (y or 0) - 3
  self.side = dir or 1
  self.velX = self.side * 5
end

megaSemiBuster = weapon:extend()

megaSemiBuster.autoClean = false

function megaSemiBuster:new(x, y, p, dir)
  megaSemiBuster.super.new(self, p)
  self.x = (x or 0) - 8
  self.y = (y or 0) - 5
  self:setRectangleCollision(16, 10)
  self.anim = animation("megaSemiBuster"):off(0, -3):flip(self.side ~= 1)
  self:addGFX("anim", self.anim)
  self.side = dir or 1
  self.velX = self.side * 5
  self.sound = "semiCharged"
  self.weaponGroup = "megaBuster"
end

function megaSemiBuster:update()
  self.anim:flip(self.side ~= 1)
end

megaChargedBuster = weapon:extend()

megaChargedBuster.autoClean = false

function megaChargedBuster:new(x, y, p, dir)
  megaChargedBuster.super.new(self, p)
  self.x = (x or 0) - 12
  self.y = (y or 0) - 12
  self:setRectangleCollision(24, 24)
  self.side = dir or 1
  self.velX = self.side * 5.5
  self.pierceType = pierce.PIERCEIFKILLING
  self.sound = "charged"
  self.weaponGroup = "megaChargedBuster"
  self.damage = -2
  
  self.anim = animation("megaChargedBusterAnim"):off(self.side == 1 and -8 or 0, -3):flip(self.side ~= 1)
  self:addGFX("anim", self.anim)
end

function megaChargedBuster:update()
  self.anim:off(self.side == 1 and -8 or 0, -3):flip(self.side ~= 1)
end

weapon.removeGroups["T. BOOST"] = {"trebleBoost", "bassBuster"}

weapon.resources["T. BOOST"] = function()
    megautils.loadResource("assets/misc/weapons/bassBuster.png", "bassBuster")
    megautils.loadResource("assets/misc/weapons/treble.png", "trebleTex")
    megautils.loadResource("assets/sfx/treble.ogg", "treble")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/misc/weapons/treble.animset", "trebleAnims")    
  end

weapon.icons["T. BOOST"] = "assets/misc/weapons/icons/trebleBoost.png"

weapon.colors["T. BOOST"] = {
    outline = {0, 0, 0},
    one = {128, 0, 240},
    two = {112, 112, 112}
  }

weapon.ignoreEnergy["T. BOOST"] = true -- Treble Boost's energy is handled internally by the player.

weapon.shootFuncs["T. BOOST"] = function(player)
    if player.treble == 3 then
      if player:numberOfShots("bassBuster") < 1 then
        local ox, oy = player:shootOffX(), player:shootOffY()
        return {
            megautils.add(bassBuster, player.x + ox, player.y + oy,
              player, player.side==1 and 0 or 180, true),
            megautils.add(bassBuster, player.x + ox, player.y + oy,
              player, player.side==1 and 45 or 180+45, true),
            megautils.add(bassBuster, player.x + ox, player.y + oy,
              player, player.side==1 and -45 or 180-45, true)
          }
      end
    elseif player:checkWeaponEnergy("T. BOOST") and player:numberOfShots("trebleBoost") < 1 then
      return megautils.add(trebleBoost, player.x + player:shootOffX(16), 
        player.y + player:shootOffY(-16), player, player.side)
    end
  end

trebleBoost = weapon:extend()

trebleBoost.autoClean = false

function trebleBoost:new(x, y, p, side)
  trebleBoost.super.new(self, p)
  self.x = (x or 0) - 10
  self.y = view.y-8
  self.toY = (y or 0) - 9
  self:setRectangleCollision(20, 19)
  self.tex = megautils.getResource("trebleTex")
  self.anims = animationSet("trebleAnims")
  self.side = side or -1
  self.s = 0
  self.timer = 0
  self.blockCollision.global = true
  self.sound = nil
  self.applyAutoFace = true
  self.weaponGroup = "trebleBoost"
  self.doDink = false
  self.damage = 0
end

function trebleBoost:added()
  trebleBoost.super.added(self)
  
  self:addToGroup("submergable")
end

function trebleBoost:update()
  self.anims:update(1/60)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.y = math.min(self.y+8, self.toY)
    if self.y == self.toY then
      if not collision.checkSolid(self) then
        self.s = 1
        self.velY = 8
        self.blockCollision.global = true
        self.autoGravity.global = true
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    if self.ground then
      self.anims:set("spawnLand")
      self.s = 2
    end
  elseif self.s == 2 then
    if self.anims:looped() then
      self.anims:set("idle")
      self.s = 3
      megautils.playSound("start")
    end
  elseif self.s == 3 then
    if self.user and not self.user.climb and self.user.ground and self.user:collision(self) then
      self.user:resetStates()
      self.user.treble = 1
      self.user.velX = 0
      self.s = 4
      self.anims:set("start")
    end
  elseif self.s == 4 then
    if self.anims:looped() then
      self.s = 5
    end
  elseif self.s == 5 then
    self.timer = self.timer + 1
    if self.timer == 20 then
      megautils.remove(self)
    end
  end
end

function trebleBoost:draw()
  self.tex:draw(self.anims, math.floor(self.x)-6, math.floor(self.y)-12+(self.gravity >= 0 and 0 or 11),
    nil, nil, nil, nil, nil, nil, nil, self.side == 1, self.gravity < 0)
end

weapon.removeGroups["RUSH JET"] = {"rushJet", "megaBuster"}

weapon.resources["RUSH JET"] = function()
    megautils.loadResource("assets/misc/weapons/rush.png", "rush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/misc/weapons/rush.animset", "rushAnims")
    
    weapon.resources["M.BUSTER"]() -- So it's possible to use the Mega Buster shots even if the weapon wasn't already loaded in for some reason...
  end

weapon.icons["RUSH JET"] = "assets/misc/weapons/icons/rushJet.png"

weapon.colors["RUSH JET"] = {
    outline = {0, 0, 0},
    one = {248, 56, 0},
    two = {255, 255, 255}
  }

weapon.ignoreEnergy["RUSH JET"] = true -- Rush Jet's energy is handled by the object itself.

weapon.shootFuncs["RUSH JET"] = function(player)
    if player:checkWeaponEnergy("RUSH JET") and player:numberOfShots("rushJet") < 1 then
      return megautils.add(rushJet, player.x + player:shootOffX(16), player.y + player:shootOffY(), player, player.side, "rush")
    elseif player:numberOfShots("megaBuster") < 3 then
      return megautils.add(megaBuster, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side)
    end
  end

weapon.removeGroups["PROTO JET"] = {"rushJet", "megaBuster"}

weapon.resources["PROTO JET"] = function()
    megautils.loadResource("assets/misc/weapons/protoRush.png", "protoRush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/misc/weapons/rush.animset", "rushAnims")
    
    weapon.resources["P.BUSTER"]()
  end

weapon.icons["PROTO JET"] = "assets/misc/weapons/icons/protoJet.png"

weapon.colors["PROTO JET"] = {
    outline = {0, 0, 0},
    one = {248, 56, 0},
    two = {255, 255, 255}
  }

weapon.ignoreEnergy["PROTO JET"] = true -- Proto Jet's energy is handled by the object itself.

weapon.shootFuncs["PROTO JET"] = function(player)
    if player:checkWeaponEnergy("PROTO JET") and player:numberOfShots("rushJet") < 1 then
      return megautils.add(rushJet, player.x + player:shootOffX(16), player.y + player:shootOffY(), player, player.side, "protoRush")
    elseif player:numberOfShots("megaBuster") < 3 then
      return megautils.add(megaBuster, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side)
    end
  end

weapon.removeGroups["TANGO JET"] = {"rushJet", "megaBuster"}

weapon.resources["TANGO JET"] = function()
    megautils.loadResource("assets/misc/weapons/tango.png", "tango")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/misc/weapons/rush.animset", "rushAnims")
    
    weapon.resources["R.BUSTER"]()
  end

weapon.icons["TANGO JET"] = "assets/misc/weapons/icons/tangoJet.png"

weapon.colors["TANGO JET"] = {
    outline = {0, 0, 0},
    one = {0, 168, 0},
    two = {255, 255, 255}
  }

weapon.ignoreEnergy["TANGO JET"] = true -- Tango Jet's energy is handled by the object itself.

weapon.shootFuncs["TANGO JET"] = function(player)
    if player:checkWeaponEnergy("TANGO JET") and player:numberOfShots("rushJet") < 1 then
      return megautils.add(rushJet, player.x + player:shootOffX(16), player.y + player:shootOffY(), player, player.side, "tango")
    elseif player:numberOfShots("megaBuster") < 3 then
      return megautils.add(megaBuster, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side)
    end
  end

rushJet = weapon:extend()

rushJet.autoClean = false

function rushJet:new(x, y, p, side, skin)
  rushJet.super.new(self, p)
  self.x = (x or 0) - 14
  self.y = view.y
  self.toY = (y or 0) - 4
  self:setRectangleCollision(27, 8)
  self.skin = skin
  self.tex = megautils.getResource(skin)
  self.anims = animationSet("rushAnims")
  self.side = side or 1
  self.s = 0
  self.timer = 0
  self.blockCollision.global = true
  self.playerOn = false
  self.exclusivelySolidFor = {self.user}
  self.sound = nil
  self.weaponGroup = "rushJet"
  self.doDink = false
  self.damage = 0
end

function rushJet:added()
  rushJet.super.added(self)
  
  self:addToGroup("submergable")
end

function rushJet:update()
  self.anims:update(1/60)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.y = math.min(self.y+8, self.toY)
    if self.y == self.toY then
      if not collision.checkSolid(self) then
        self.anims:set("spawnLand")
        self.s = 1
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    if self.anims:looped() then
      self.anims:set("jet")
      self.s = 2
      self.solidType = collision.ONEWAY
      megautils.playSound("start")
    end
  elseif self.s == 2 then
    if self.user and self.user.ground and self.user:collision(self, 0, self.user.gravity >= 0 and 1 or -1) and
      not self.user:collision(self) then
      self.s = 3
      self.velX = self.side
      self.user.canWalk.rj = false
      self.playerOn = true
    end
  elseif self.s == 3 then
    if self.playerOn and self.user and (not self.user.ground or
      (not self:collision(self.user, 0, self.user.gravity >= 0 and -1 or 1) and
      not self:collision(self.user, 0, self.user.gravity >= 0 and 1 or -1))) then
      self.user.canWalk.rj = true
      self.playerOn = false
    end
    if self.playerOn and self.user then
      if input.down["up" .. tostring(self.user.input)] or self.user.tUp then
        self.velY = -1
      elseif input.down["down" .. tostring(self.user.input)] or self.user.tDown then
        self.velY = 1
      else
        self.velY = 0
      end
    else
      self.velY = 0
      if self.user and self.user.ground and self.user:collision(self, 0, self.user.gravity >= 0 and 1 or -1) and
        not self.user:collision(self) then
        self.s = 3
        self.velX = self.side
        self.user.canWalk.rj = false
        self.playerOn = true
      end
    end
    if megaMan.weaponHandler[self.user.player].energy[megaMan.weaponHandler[self.user.player].currentSlot] == 0 or self.xColl ~= 0 or
      (self.playerOn and self.user and collision.checkSolid(self.user, 0, self.user.gravity >= 0 and -4 or 4)) then
      if self.playerOn then self.user.canWalk.rj = true end
      self.anims:set("spawnLand")
      self.blockCollision.global = false
      self.s = 4
      self.solidType = collision.NONE
      self.velX = 0
      self.velY = 0
      megautils.playSound("ascend")
    end
    self.timer = math.min(self.timer+1, 60)
    if self.timer == 60 then
      self.timer = 0
      if self.user then
        megaMan.weaponHandler[self.user.player]:updateCurrent(megaMan.weaponHandler[self.user.player]:currentWE() - 1)
      end
    end
  elseif self.s == 4 then
    if self.anims:looped() then
      self.s = 5
      self.anims:set("spawn")
      self.velY = -8
    end
  end
end

function rushJet:removed()
  if self.user then
    self.user.canWalk.rj = true
  end
end

function rushJet:draw()
  if (self.anims.current == "spawn" or self.anims.current == "spawnLand") and self.user then
    self.tex:draw(self.anims, math.floor(self.x)-4, math.floor(self.y)+(self.user.gravity >= 0 and -16 or -6))
  else
    self.tex:draw(self.anims, math.floor(self.x)-4, math.floor(self.y)-12,
      nil, nil, nil, nil, nil, nil, nil, self.side ~= 1, self.gravity < 0)
  end
end

weapon.removeGroups["RUSH C."] = {"rushCoil", "megaBuster"}

weapon.resources["RUSH C."] = function()
    megautils.loadResource("assets/misc/weapons/rush.png", "rush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/misc/weapons/rush.animset", "rushAnims")
    
    weapon.resources["M.BUSTER"]() -- So it's possible to use the Mega Buster shots even if the weapon wasn't already loaded in for some reason...
  end

weapon.icons["RUSH C."] = "assets/misc/weapons/icons/rushCoil.png"

weapon.colors["RUSH C."] = {
    outline = {0, 0, 0},
    one = {248, 56, 0},
    two = {255, 255, 255}
  }

weapon.ignoreEnergy["RUSH C."] = true -- Rush Coil's energy is handled by the object itself.

weapon.shootFuncs["RUSH C."] = function(player)
    if player:checkWeaponEnergy("RUSH C.") and player:numberOfShots("rushCoil") < 1 then
      return megautils.add(rushCoil, player.x + player:shootOffX(16), player.y + player:shootOffY(-16), player, player.side, "rush")
    elseif player:numberOfShots("megaBuster") < 3 then
      return megautils.add(megaBuster, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side)
    end
  end

weapon.removeGroups["PROTO C."] = {"rushCoil", "megaBuster"}

weapon.resources["PROTO C."] = function()
    megautils.loadResource("assets/misc/weapons/protoRush.png", "protoRush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/misc/weapons/rush.animset", "rushAnims")
    
    weapon.resources["P.BUSTER"]()
  end

weapon.icons["PROTO C."] = "assets/misc/weapons/icons/protoCoil.png"

weapon.colors["PROTO C."] = {
    outline = {0, 0, 0},
    one = {248, 56, 0},
    two = {255, 255, 255}
  }

weapon.ignoreEnergy["PROTO C."] = true -- Proto Coil's energy is handled by the object itself.

weapon.shootFuncs["PROTO C."] = function(player)
    if player:checkWeaponEnergy("PROTO C.") and player:numberOfShots("rushCoil") < 1 then
      return megautils.add(rushCoil, player.x + player:shootOffX(16), player.y + player:shootOffY(-16), player, player.side, "protoRush")
    elseif player:numberOfShots("megaBuster") < 3 then
      return megautils.add(megaBuster, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side)
    end
  end

weapon.removeGroups["TANGO C."] = {"rushCoil", "megaBuster"}

weapon.resources["TANGO C."] = function()
    megautils.loadResource("assets/misc/weapons/tango.png", "tango")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/misc/weapons/rush.animset", "rushAnims")
    
    weapon.resources["R.BUSTER"]()
  end

weapon.icons["TANGO C."] = "assets/misc/weapons/icons/tangoCoil.png"

weapon.colors["TANGO C."] = {
    outline = {0, 0, 0},
    one = {0, 168, 0},
    two = {255, 255, 255}
  }

weapon.ignoreEnergy["TANGO C."] = true -- Tango Coil's energy is handled by the object itself.

weapon.shootFuncs["TANGO C."] = function(player)
    if player:checkWeaponEnergy("TANGO C.") and player:numberOfShots("rushCoil") < 1 then
      return megautils.add(rushCoil, player.x + player:shootOffX(16), player.y + player:shootOffY(-16), player, player.side, "tango")
    elseif player:numberOfShots("megaBuster") < 3 then
      return megautils.add(megaBuster, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side)
    end
  end

rushCoil = weapon:extend()

rushCoil.autoClean = false

function rushCoil:new(x, y, p, side, skin)
  rushCoil.super.new(self, p)
  self.x = (x or 0) - 10
  self.y = view.y-8
  self.toY = (y or 0) - 9
  self:setRectangleCollision(20, 19)
  self.skin = skin
  self.tex = megautils.getResource(skin)
  self.anims = animationSet("rushAnims")
  self.side = side or 1
  self.s = 0
  self.timer = 0
  self.weaponGroup = "rushCoil"
  self.sound = nil
  self.doDink = false
  self.damage = 0
end

function rushCoil:added()
  rushCoil.super.added(self)
  
  self:addToGroup("submergable")
end

function rushCoil:update()
  self.anims:update(1/60)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.y = math.min(self.y+8, self.toY)
    if self.y == self.toY then
      if not collision.checkSolid(self) then
        self.s = 1
        self.velY = 8
        self.autoGravity.global = true
        self.blockCollision.global = true
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    if self.ground then
      self.anims:set("spawnLand")
      self.s = 2
    end
  elseif self.s == 2 then
    if self.anims:looped() then
      self.anims:set("idle")
      self.s = 3
      megautils.playSound("start")
    end
  elseif self.s == 3 then
    if self.user and not self.user.climb and
      (self.user.gravity >= 0 and (self.user.velY > 0) or (self.user.velY < 0)) and
      math.between(self.user.x+self.user.collisionShape.w/2,
      self.x, self.x+self.collisionShape.w) and
      self.user:collision(self) then
      self.user:resetStates()
      self.user.canStopJump.global = false
      self.user.velY = -7.5 * (self.user.gravity >= 0 and 1 or -1)
      self.s = 4
      self.anims:set("coil")
      megaMan.weaponHandler[self.user.player]:updateCurrent(megaMan.weaponHandler[self.user.player]:currentWE() - 7)
    end
  elseif self.s == 4 then
    self.timer = math.min(self.timer+1, 40)
    if self.timer == 40 then
      self.s = 5
      self.anims:set("spawnLand")
      self.autoGravity.global = false
      self.blockCollision.global = false
      megautils.playSound("ascend")
    end
  elseif self.s == 5 then
    if self.anims:looped() then
      self.s = 6
      self.anims:set("spawn")
      self.velY = -8
    end
  end
end

function rushCoil:draw()
  self.tex:draw(self.anims, math.floor(self.x)-8, math.floor(self.y)-12+(self.gravity >= 0 and 0 or 11),
    nil, nil, nil, nil, nil, nil, nil, self.side ~= 1, self.gravity < 0)
end

weapon.removeGroups["STICK W."] = {"stickWeapon"}

weapon.resources["STICK W."] = function()
    megautils.loadResource("assets/misc/weapons/stickWeapon.png", "stickWeapon")
  end

weapon.icons["STICK W."] = "assets/misc/weapons/icons/stickWeapon.png"

weapon.colors["STICK W."] = {
    outline = {0, 0, 0},
    one = {180, 180, 180},
    two = {127, 127, 127}
  }

weapon.stopOnShot["STICK W."] = true

weapon.throwAnim["STICK W."] = true

weapon.shootFuncs["STICK W."] = function(player)
    if player:numberOfShots("stickWeapon") < 1 then
      return megautils.add(stickWeapon, player.x + player:shootOffX(), player.y + player:shootOffY(), player, player.side), -2
    end
  end

stickWeapon = weapon:extend()

stickWeapon.autoClean = false

function stickWeapon:new(x, y, p, dir)
  stickWeapon.super.new(self, p)
  self.x = (x or 0) - 4
  self.y = (y or 0) - 3
  self:setRectangleCollision(8, 6)
  self.tex = megautils.getResource("stickWeapon")
  self.side = dir or 1
  self.velX = self.side * 8
  self.weaponGroup = "stickWeapon"
end

function stickWeapon:draw()
  self.tex:draw(math.floor(self.x), math.floor(self.y))
end
