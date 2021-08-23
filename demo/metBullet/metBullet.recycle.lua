local self, super, args = ...

self.x = args.x
self.y = args.y
self.velX = args.vx or 0
self.velY = args.vy or 0

self.damage = megautils.diffValue(-2, {easy=-1, normal=-2, hard=-3})