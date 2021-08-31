local self, super, args = ...

if not self.regValues then
  self.x = args.x or 0
  self.y = args.y or 0
end

self.damage = megautils.diffValue(-2, {easy=-1, normal=-2, hard=-3})

self.safeQuad = quad(0, 0, 18, 15)
self.upQuad = quad(18, 0, 18, 15)
self.tex = self:getGFXByName("image1"):setQuad(self.safeQuad)

self.state = 0
self.timer = 0