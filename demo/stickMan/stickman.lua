megautils.loadResource("demo/stickMan/stickMan.animset", "stickManAnims")

stickMan = bossEntity:extend()
mapEntity.register(stickMan, nil, nil, 0, 8, 12, 24)

function stickMan:new(overrideX, overrideY)
  stickMan.super.new(self)
  
  self.x = overrideX or self.x or 0
  self.y = overrideY or self.y or 0
  self:setRectangleCollision(12, 24)
  
  self.anims = animationSet("stickManAnims"):off(-4, -8)
  self:addGFX("anims", self.anims)
  self.flipFace = true
  
  -- Stage select and boss intro exclusive.
  self.mugshotPath = "demo/stickMan/stickManMug.png"
  self.bossIntroText = "STICK MAN"
  self.stageState = "demo/demo.stage.tmx"
  
  -- Weapon get exclusive.
  self.weaponGetText = "WEAPON GET... STICK WEAPON!"
  self.weaponGetBehaviour = function(m)
      if not m._stickTimer then
        m._stickTimer = 0
      end
      
      m._stickTimer = m._stickTimer + 1
      m.shootFrames = math.max(m.shootFrames - 1, 0)
      
      if m._stickTimer == 240 then
        return true
      elseif m._stickTimer % 60 == 0 then
        m.shootFrames = 14
        m:useThrowAnimation()
        megautils.add(stickWeapon, m.x+m:shootOffX(), 
          m.y+m:shootOffY(), m, m.side)
      end
      
      if m.shootFrames ~= 0 then
        m.anims:set(m.idleAnimation.shoot)
      else
        m.anims:set(m.idleAnimation.regular)
      end
    end
  self.defeatSlot = "stickMan"
  self.defeatSlotValue = {weaponSlot=1, weaponName="STICK W."}
end

function stickMan:added()
  stickMan.super.added(self)
  self:useHealthBar({128, 128, 128}, {255, 255, 255})
end

function stickMan:weaponTable(other)
  if other:is(stickWeapon) then -- The weakness
    return -8
  elseif other:is(megaChargedBuster) then -- Semi-weakness
    return -3
  elseif self.changeHealth < 0 then
    return -1
  end
end

function stickMan:determineDink(o)
  return o:is(megaSemiBuster)
end

function stickMan:pose()
  if self.anims.current ~= "pose" then
    self.anims:set("pose")
  end
  if self.anims:looped() then
    return true
  end
end

function stickMan:update()
  if self.state == 0 then
    self.anims:set("idle")
    self.state = 1
  end
end

return stickMan