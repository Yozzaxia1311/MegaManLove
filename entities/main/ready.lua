ready = entity:extend()

function ready:new(text, proto, loop, intro, vol)
  ready.super.new(self)
  self.proto = proto
  self.added = function(self)
    self:addToGroup("ready")
    if self.proto then
      mmSfx.play("protoReady")
    end
  end
  if self.proto then
    self.inf = intro
    self.lf = loop
    self.vol = vol
  end
  self:setLayer(9)
  self.once = false
  self.render = false
  self.blinkTimer = 0
  self.maxBlinkTime = 6
  self.blinkCount = 0
  self.blinks = self.proto and 32 or 12
  self.text = text or "ready"
  self.width = self.text:len() * 8
  megautils.freeze()
end

function ready:update(dt)
  megautils.freeze()
  self.blinkTimer = math.min(self.blinkTimer+1, self.maxBlinkTime)
  if self.blinkTimer == self.maxBlinkTime then
    self.blinkTimer = 0
    self.blinkCount = self.blinkCount + 1
    self.render = not self.render
    if self.blinkCount == self.blinks then
      megautils.unfreeze()
      if self.proto then
        mmMusic.playFromFile(self.lf, self.inf, self.vol)
      end
      megautils.remove(self, true)
    end
  end
end

function ready:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(mmFont)
  love.graphics.print(self.text, view.x+(view.w/2)-(self.width/2), view.y+(view.h/2))
end