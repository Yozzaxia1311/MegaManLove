loader.load("demo/met/met.png", "met")

met = advancedEntity:extend()

mapEntity.register(met, nil, nil, 0, 2, 14, 14)

function met:new(overrideX, overrideY)
  met.super.new(self)
  
  self.x = overrideX or self.x or 0
  self.y = overrideY or self.y or 0
  self:setRectangleCollision(14, 14)
  
  self.quads = {safe = quad(0, 0, 18, 15), attack = quad(18, 0, 18, 15)}
  self:addGFX("metImage", image("met", self.quads.safe))
  
  self.health = 2
  self.canBeInvincible.global = true
  
  self.timer = 0
  self.state = 0
end

function met:weaponTable(other)
  if other:is(megaSemiBuster) then
    return megautils.diffValue(-1, {easy=-2})
  elseif other:is(megaChargedBuster) then
    return megautils.diffValue(-2, {easy=-3})
  elseif other:is(protoSemiBuster) then
    return megautils.diffValue(-1, {easy=-2})
  elseif other:is(protoChargedBuster) then
    return megautils.diffValue(-2, {easy=-3})
  elseif other:is(bassBuster) then
    if other.treble then
      return megautils.diffValue(-1, {easy=-2})
    else
      return megautils.diffValue(-0.5, {easy=-1})
    end
  end
  
  return -1
end

function met:update()
  if self.state == 0 then
    if self.closest and math.between(self.closest.x, self.x - 120, self.x + 120) then
      self.timer = math.min(self.timer + 1, 80)
    else
      self.timer = 0
    end
    if self.timer == 80 then
      self.timer = 0
      self.state = 1
      self:getGFXByName("metImage"):setQuad(self.quads.attack)
      self.canBeInvincible.global = false
    end
  elseif self.state == 1 then
    self.timer = math.min(self.timer + 1, 20)
    if self.timer == 20 then
      self.timer = 0
      self.state = 2
      megautils.add(metBullet, self.x + 4, self.y + 4, self,
        self.side * megautils.calcX(45) * 2, -megautils.calcY(45) * 2)
      megautils.add(metBullet, self.x + 4, self.y + 4, self,
        self.side * megautils.calcX(45) * 2, megautils.calcY(45) * 2)
      megautils.add(metBullet, self.x + 4, self.y + 4, self,
        self.side * 2, 0)
    end
  elseif self.state == 2 then
    self.timer = math.min(self.timer + 1, 20)
    if self.timer == 20 then
      self:getGFXByName("metImage"):setQuad(self.quads.safe)
      self.canBeInvincible.global = true
      self.timer = 0
      self.state = 0
    end
  end
end

metBullet = weapon:extend()

function metBullet:new(x, y, user, vx, vy)
  metBullet.super.new(self, user, true) -- Set as TRUE for enemy weapons.
  
  self.x = x or 0
  self.y = y or 0
  self.velX = vx or 1
  self.velY = vy or 1
  
  self.recycle = true
  
  if not self.recycling then
    self:addGFX("bullet", image("met", quad(36, 0, 6, 6)))
    self.damage = -2
  end
end