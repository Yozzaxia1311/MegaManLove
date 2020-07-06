ready = basicEntity:extend()

function ready:new(text, proto, music)
  ready.super.new(self)
  self.proto = proto
  if self.proto then
    self.music = music
  end
  self:setLayer(9)
  self.once = false
  self.canDraw.global = false
  self.blinkTimer = 0
  self.maxBlinkTime = 6
  self.blinkCount = 0
  self.blinks = self.proto and 32 or 12
  self.text = text or "READY"
  self.width = self.text:len() * 8
  megautils.freeze()
end

function ready:added()
  self:addToGroup("ready")
  if self.proto then
    megautils.playSoundFromFile("assets/sfx/protoReady.ogg")
  end
end

function ready:update(dt)
  megautils.freeze()
  self.blinkTimer = math.min(self.blinkTimer+1, self.maxBlinkTime)
  if self.blinkTimer == self.maxBlinkTime then
    self.blinkTimer = 0
    self.blinkCount = self.blinkCount + 1
    self.canDraw.global = not self.canDraw.global
    if self.blinkCount == self.blinks then
      megautils.unfreeze()
      if self.proto and self.music then
        if self.proto == "old" then
          megautils.playMusicWithSeperateIntroFile(unpack(self.music))
        else
          megautils.playMusic(unpack(self.music))
        end
      end
      megautils.removeq(self)
    end
  end
end

function ready:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(mmFont)
  love.graphics.print(self.text, view.x+(view.w/2)-(self.width/2), view.y+(view.h/2))
end