megautils.loadResource("assets/global/entities/met.png", "met")

met = advancedEntity:extend()

mapEntity.register("met", function(v)
  megautils.add(spawner, v.x, v.y+2, 14, 14, nil, met, v.x, v.y+2)
end)

function met:new(x, y)
  met.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(14, 14)
  self.t = megautils.getResource("met")
  self.c = "safe"
  self.quads = {safe=quad(0, 0, 18, 15), up=quad(18, 0, 18, 15)}
  self.s = 0
  self.canBeInvincible.global = true
  self.timer = 0
  self.damage = megautils.diffValue(-2, {easy=-1, normal=-2, hard=-3})
  self.health = 2
end

function met:weaponTable(o)
  if o:is(megaBuster) then
    return -1
  elseif o:is(megaSemiBuster) then
    return megautils.diffValue(-1, {easy=-2})
  elseif o:is(megaChargedBuster) then
    return megautils.diffValue(-2, {easy=-3})
  elseif o:is(protoSemiBuster) then
    return megautils.diffValue(-1, {easy=-2})
  elseif o:is(protoChargedBuster) then
    return megautils.diffValue(-2, {easy=-3})
  elseif o:is(bassBuster) then
    if o.treble then
      return megautils.diffValue(-1, {easy=-2})
    else
      return megautils.diffValue(-0.5, {easy=-1})
    end
  end
end

function met:determineDink(o)
  return checkTrue(self.canBeInvincible)
end

function met:update(dt)
  if self.s == 0 then
    if self.closest and math.between(self.closest.x, 
      self.x - 120, self.x + 120) then
      self.timer = math.min(self.timer+1, 80)
    else
      self.timer = 0
    end
    if self.timer == 80 then
      self.timer = 0
      self.s = 1
      self.canBeInvincible.global = false
      self.c = "up"
    end
  elseif self.s == 1 then
    self.timer = math.min(self.timer+1, 20)
    if self.timer == 20 then
      self.timer = 0
      self.s = 2
      megautils.add(metBullet, self.x+4, self.y+4, self, self.side*megautils.calcX(45)*2, -megautils.calcY(45)*2)
      megautils.add(metBullet, self.x+4, self.y+4, self, self.side*megautils.calcX(45)*2, megautils.calcY(45)*2)
      megautils.add(metBullet, self.x+4, self.y+4, self, self.side*2, 0)
    end
  elseif self.s == 2 then
    self.timer = math.min(self.timer+1, 20)
    if self.timer == 20 then
      self.c = "safe"
      self.canBeInvincible.global = true
      self.timer = 0
      self.s = 0
    end
  end
end

function met:draw()
  self.t:draw(self.quads[self.c], math.floor(self.x), math.floor(self.y),
    nil, nil, nil, nil, nil, nil, nil, self.side == 1, self.gravity < 0)
end

metBullet = weapon:extend()

function metBullet:new(x, y, p, vx, vy)
  metBullet.super.new(self, p, true)
  
  if not self.recycling then
    self:setRectangleCollision(6, 6)
    self.tex = megautils.getResource("met")
    self.quad = quad(36, 0, 6, 6)
    self.recycle = true
  end
  
  self.x = x or 0
  self.y = y or 0
  self.velX = vx or 0
  self.velY = vy or 0
  self.damage = megautils.diffValue(-2, {easy=-1, normal=-2, hard=-3})
end

function metBullet:draw()
  self.tex:draw(self.quad, math.floor(self.x), math.floor(self.y))
end