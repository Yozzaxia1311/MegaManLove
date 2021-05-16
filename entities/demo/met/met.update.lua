local self = ...

if self.state == 0 then
  if self.closest and math.between(self.closest.x, self.x - 120, self.x + 120) then
    self.timer = math.min(self.timer+1, 80)
  else
    self.timer = 0
  end
  if self.timer == 80 then
    self.timer = 0
    self.state = 1
    self.canBeInvincible.global = false
    self.tex:setQuad(self.upQuad)
  end
elseif self.state == 1 then
  self.timer = math.min(self.timer+1, 20)
  if self.timer == 20 then
    self.timer = 0
    self.state = 2
    megautils.add(metBullet, {x = self.x+4, y = self.y+4, user = self,
      vx = self.side*megautils.calcX(45)*2, vy = -megautils.calcY(45)*2})
    megautils.add(metBullet, {x = self.x+4, y = self.y+4, user = self,
      vx = self.side*megautils.calcX(45)*2, vy = megautils.calcY(45)*2})
    megautils.add(metBullet, {x = self.x+4, y = self.y+4, user = self,
      vx = self.side*2, vy = 0})
  end
elseif self.state == 2 then
  self.timer = math.min(self.timer+1, 20)
  if self.timer == 20 then
    self.tex:setQuad(self.safeQuad)
    self.canBeInvincible.global = true
    self.timer = 0
    self.state = 0
  end
end