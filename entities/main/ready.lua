ready = basicEntity:extend()

ready.autoClean = false
ready.noHash = true

function ready:new(text, blinks)
  ready.super.new(self)
  self:setLayer(9)
  self.canDraw.global = false
  self.blinkTimer = 0
  self.maxBlinkTime = 6
  self.blinkCount = 0
  self.blinks = blinks or 12
  self.text = text or "READY"
  self.width = self.text:len() * 8
  self.noFreeze = true
end

function ready:added()
  ready.super.added(self)
  
  megautils.freeze("ready")
end

function ready:update(dt)
  self.blinkTimer = math.min(self.blinkTimer+1, self.maxBlinkTime)
  if self.blinkTimer == self.maxBlinkTime then
    self.blinkTimer = 0
    self.blinkCount = self.blinkCount + 1
    self.canDraw.global = not self.canDraw.global
    if self.blinkCount == self.blinks then
      megautils.unfreeze("ready")
      megautils.removeq(self)
    end
  end
end

function ready:draw()
  love.graphics.setFont(mmFont)
  love.graphics.print(self.text, view.x+(view.w/2)-(self.width/2), view.y+(view.h/2))
end