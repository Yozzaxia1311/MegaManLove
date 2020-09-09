megautils.loadResource("assets/global/bosses/stickMan.png", "stickMan")

stickMan = bossEntity:extend()

mapEntity.register("stickMan", function(v)
    megautils.add(spawner, v.x, v.y-8, 12, 24, nil, stickMan, v.x, v.y-8)
  end)

function stickMan:new(x, y)
  stickMan.super.new(self)
  self.transform.y = y or 0
  self.transform.x = x or 0
  self:setRectangleCollision(12, 24)
  self.t = megautils.getResource("stickMan")
  self.canDraw.global = false
  self.gravity = 0
  self.health = 1
  self:useHealthBar({128, 128, 128}, {255, 255, 255})
  
  -- Boss intro exclusive.
  self.bossIntroText = "STICK MAN"
  self.stageState = "assets/states/demo.stage.tmx"
  
  -- Weapon get exclusive.
  self.weaponGetText = "WEAPON GET... STICK WEAPON!"
  self.weaponGetBehaviour = function(m)
      return true
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

function stickMan:draw()
  stickMan.super.draw(self)
  love.graphics.setColor(1, 1, 1, 1)
  self.t:draw(math.floor(self.transform.x)-4, math.floor(self.transform.y)-8)
end

return stickMan