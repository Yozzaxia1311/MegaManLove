ready = entity:extend()

ready.netName = "ready"
megautils.netNames[ready.netName] = ready

function ready:new(text, net, id)
  ready.super.new(self)
  self.added = function(self)
    self:addToGroup("ready")
  end
  self:setLayer(9)
  self.once = false
  self.render = false
  self.blinkTimer = 0
  self.maxBlinkTime = 6
  self.blinkCount = 0
  self.blinks = 12
  self.text = text or "ready"
  self.width = self.text:len() * 8
  megautils.freeze()
  self.net = net
  self.networkID = id
end

function ready:update(dt)
  megautils.freeze()
  self.blinkTimer = math.min(self.blinkTimer+1, self.maxBlinkTime)
  if self.blinkTimer == self.maxBlinkTime then
    self.blinkTimer = 0
    self.blinkCount = self.blinkCount + 1
    self.render = not self.render
    if self.blinkCount == self.blinks and not self.net then
      megautils.unfreeze()
      megautils.remove(self, true)
    end
  end
  if self.networkData and self.networkData.r then
    megautils.unfreeze()
    megautils.remove(self, true)
  end
end

function ready:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(mmFont)
  love.graphics.print(self.text, view.x+(view.w/2)-(self.width/2), view.y+(view.h/2))
end

function ready:removed()
  if megautils.networkGameStarted and megautils.networkMode == "server" then
    megautils.net:sendToAll("u", {r=true, id=self.networkID})
  end
end