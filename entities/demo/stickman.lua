megautils.loadResource("assets/global/bosses/stickMan.png", "stickMan")
megautils.loadResource(0, 0, 21, 32, "stickManGrid")

stickMan = bossEntity:extend()

mapEntity.register("stickMan", function(v)
    megautils.add(spawner, v.x, v.y-8, 12, 24, nil, stickMan, v.x, v.y-8)
  end)

function stickMan:new(x, y)
  stickMan.super.new(self)
  self.y = y or 0
  self.x = x or 0
  self:setRectangleCollision(12, 24)
  self.anims = animationSet("stickMan"):off(-4, -8)
  self.anims:add("idle", animation("stickManGrid", {1, 1}))
  self.anims:add("pose", animation("stickManGrid", {2, 1, 1, 1, 3, 1, 1, 1, 2, 1, 1, 1, 3, 1}, 1/10, "pauseAtEnd"))
  self:addGFX("anims", self.anims)
  self:useHealthBar({128, 128, 128}, {255, 255, 255})
  
  -- Stage select exclusive
  self.mugshotPath = "assets/global/bosses/stickManMug.png"
  
  -- Boss intro exclusive.
  self.bossIntroText = "STICK MAN"
  self.stageState = "assets/states/demo.stage.tmx"
  
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

function stickMan:weaponTable(o)
  if o:is(stickWeapon) then -- The weakness
    return -8
  elseif o:is(megaChargedBuster) then -- Semi-weakness
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

function stickMan:act()
  if self.state == 0 then
    self.anims:set("idle")
    self.state = 1
  end
end

--function stickMan:draw()
--  stickMan.super.draw(self)
--  self.t:draw(self.anims, math.floor(self.x)-4, math.floor(self.y)-8)
--end

return stickMan