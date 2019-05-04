client_fade = entity:extend()

client_fade.netName = "c_fad"
megautils.netNames[client_fade.netName] = client_fade

function client_fade:new(fadeToColor, color, id)
  client_fade.super.new(self)
  self.alpha = fadeToColor and 0 or 255
  self.fadeToColor = fadeToColor
  self.color = color or {0, 0, 0}
  self.networkID = id
end

function client_fade:update(dt)
  if self.networkData then
    self.alpha = self.networkData.a or self.alpha
    if self.networkData.r then
      megautils.remove(self, true)
    end
  end
end

function client_fade:draw()
  love.graphics.setColor(self.color[1]/255, self.color[2]/255, self.color[3]/255, self.alpha/255)
  love.graphics.rectangle("fill", view.x, view.y, view.w, view.h)
end

fade = entity:extend()

fade.netName = "fade"
megautils.netNames[fade.netName] = fade

function fade:new(fadeToColor, gap, color, after, id)
  fade.super.new(self)
  self.alpha = fadeToColor and 0 or 255
  self.fadeToColor = fadeToColor
  self.gap = gap or 4
  self.after = after
  self.timer = 0
  self.color = color or {0, 0, 0}
  megautils.freeze()
  self:setLayer(10)
  fade.main = self
  self.networkID = id
end

function fade:setAfter(f)
  self.after = f
  return self
end

function fade:update(dt)
  if (self.alpha == 255 and self.fadeToColor) or (self.alpha == 0 and not self.fadeToColor) then
    if not self.once2 then
      self.once2 = true
      megautils.unfreeze()
    end
    self.after(self)
  else
    megautils.freeze()
  end
  self.timer = math.min(self.timer+1, self.gap)
  if self.timer == self.gap then
    self.timer = 0
    self.alpha = self.fadeToColor and math.min(self.alpha+(255/3), 255) or math.max(self.alpha-(255/3), 0)
  end
  if megautils.networkGameStarted and megautils.networkMode == "server" then
    megautils.net:sendToAll("u", {a=self.alpha, id=self.networkID})
  end
end

function fade:draw()
  love.graphics.setColor(self.color[1]/255, self.color[2]/255, self.color[3]/255, self.alpha/255)
  love.graphics.rectangle("fill", view.x, view.y, view.w, view.h)
end

function fade:removed()
  if megautils.networkGameStarted and megautils.networkMode == "server" then
    megautils.net:sendToAll("u", {r=true, id=self.networkID})
  end
end

function fade.remove(s)
  megautils.remove(s, true)
end

function fade.ready(s)
  megautils.remove(s, true)
  megautils.freeze()
end