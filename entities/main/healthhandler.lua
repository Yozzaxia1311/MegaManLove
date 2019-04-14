healthhandler = entity:extend()

megautils.resetGameObjectsFuncs["healthhandler"] = function()
  healthhandler.playerTimers = {}
  for i=1, maxPlayerCount do
    healthhandler.playerTimers[i] = -2
  end
end

healthhandler.playerTimers = {}

for i=1, maxPlayerCount do
  healthhandler.playerTimers[i] = -2
end

function healthhandler:new(colorOne, colorTwo, colorOutline, side, r, segments, player)
  healthhandler.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.barOne = loader.get("bar_one")
  self.barTwo = loader.get("bar_two")
  self.barOutline = loader.get("bar_outline")
  self.colorOne = colorOne
  self.colorTwo = colorTwo
  self.colorOutline = colorOutline
  self.quads = {}
  self.quads[0] = love.graphics.newQuad(0, 48, 8, 8, 232, 56)
  self.quads[1] = love.graphics.newQuad(8, 48, 8, 8, 232, 56)
  self.quads[2] = love.graphics.newQuad(8*2, 48, 8, 8, 232, 56)
  self.quads[3] = love.graphics.newQuad(8*3, 48, 8, 8, 232, 56)
  self.quads[4] = love.graphics.newQuad(8*4, 48, 8, 8, 232, 56)
  self.segments = segments or 1
  self.side = side or 1
  self.health = self.segments*4
  self.change = 0
  self.rise = 0
  self.riseTimer = 4
  self:setLayer(9)
  self.rot = r or "y"
  self.onceA = false
  self.me = {self}
  self.player = player
  self.render3 = 0
end

function healthhandler:updateThis()
  if self.change > 0 then
    if self.health ~= 4*self.segments then
      megautils.freeze(self.me)
      self.rise = self.change
      self.riseTimer = 0
    end
  elseif self.change < 0 then
    self.health = self.health + self.change
  end
  self.change = 0
end

function healthhandler:update(dt)
  self.riseTimer = math.min(self.riseTimer+1, 4)
  if self.rise > 0 and self.riseTimer == 4 then
    megautils.freeze(self.me)
    self.change = 0
    self.health = self.health + 1
    self.riseTimer = 0
    self.rise = self.rise - 1
    mmSfx.play("heal")
    if self.rise == 0 or self.health >= 4*self.segments or self.health <= 0 then
      megautils.unfreeze({self})
      self.rise = 0
      mmSfx.stop("heal")
    end
  end
  self.health = math.clamp(self.health, 0, 4*self.segments)
  if self.player and self.player == globals.mainPlayer and self.player.control and self.player.updated then
    for i=1, playerCount do
      if healthhandler.playerTimers[i] > -1 then
        healthhandler.playerTimers[i] = math.max(healthhandler.playerTimers[i]-1, 0)
        if healthhandler.playerTimers[i] == 0 then
          healthhandler.playerTimers[i] = -1
        end
      elseif healthhandler.playerTimers[i] == -1 and control.startPressed[i] then
        if globals.lives > 0 then
          healthhandler.playerTimers[i] = -3
          self.t2 = {}
          self.t2.x = self.transform.x
          self.t2.y = self.transform.y+(i*8)
          self.t2.player = i
          self.tween = tween.new(0.4, self.t2, {x=view.x + 24 + (#globals.allPlayers*32) - 4, y=view.y + 72})
          megautils.freeze(self.me)
          mmSfx.play("selected")
        else
          mmSfx.play("error")
        end
      end
    end
  elseif self.player and self.player == globals.mainPlayer and self.tween and self.tween:update(1/60) then
    healthhandler.playerTimers[self.t2.player] = -2
    local p = megaman(self.player.transform.x, self.player.transform.y, self.player.side, true, self.t2.player)
    self.player:transferState(p)
    megautils.revivePlayer(self.t2.player)
    megautils.add(p)
    if not globals.infiniteLives then
      globals.lives = globals.lives - 1
    end
    self.t2 = nil
    self.tween = nil
    megautils.unfreeze()
  end
end

function healthhandler:draw()
  if self.player and (self.player == globals.mainPlayer or (not globals.mainPlayer and self.lifeRecord)) then
    if not globals.infiniteLives then
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.rectangle("fill", self.transform.x, self.transform.y, 8, 8)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.setFont(mmFont)
      self.lifeRecord = globals.lives
      love.graphics.print(tostring(self.lifeRecord), self.transform.x, self.transform.y)
    end
    if globals.mainPlayer == self.player then
      for i=1, playerCount do
        if healthhandler.playerTimers[i] == -1 then
          love.graphics.setColor(0, 0, 0, 1)
          love.graphics.rectangle("fill", self.transform.x, self.transform.y+(i*8), 32, 8)
          love.graphics.setColor(1, 1, 1, 1)
          if globals.lives <= 0 then
            love.graphics.print("p" .. tostring(i) .. " x", self.transform.x, self.transform.y+(i*8))
          else
            love.graphics.print("p" .. tostring(i) .. " `", self.transform.x, self.transform.y+(i*8))
          end
        elseif healthhandler.playerTimers[i] == -3 then
          if self.render3 < 10 then
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", math.round(self.t2.x), math.round(self.t2.y), 16, 8)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("p" .. tostring(i), math.round(self.t2.x), math.round(self.t2.y))
          end
          self.render3 = math.wrap(self.render3+1, 0, 20)
        elseif healthhandler.playerTimers[i] > -1 then
          love.graphics.setColor(0, 0, 0, 1)
          love.graphics.rectangle("fill", self.transform.x, self.transform.y+(i*8), 32, 8)
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.print("p" .. tostring(i) .. " " ..
            tostring(math.abs(math.ceil(healthhandler.playerTimers[i]/20))), self.transform.x, self.transform.y+(i*8))
        end
      end
    end
  else
    love.graphics.setColor(1, 1, 1, 1)
  end
  local curSeg = math.ceil(self.health/4)
  for i=1, self.segments do
    local bit = 0
    if i == curSeg then
      bit = 4 + (self.health-(i*4))
    elseif i > curSeg then
      bit = 0
    elseif i < curSeg then
      bit = 4
    end
    local tx, ty, tr = self.transform.x-(self.rot=="x" and (8*i)*self.side or 0), 
      self.transform.y-(self.rot=="y" and (8*i)*self.side or 0), math.rad(self.rot=="x" and 90 or 0)
    love.graphics.setColor(self.colorOutline[1]/255, 
      self.colorOutline[2]/255,
      self.colorOutline[3]/255, 1)
    love.graphics.draw(self.barOutline, self.quads[bit], tx, ty, tr)
    love.graphics.setColor(self.colorOne[1]/255, 
      self.colorOne[2]/255,
      self.colorOne[3]/255, 1)
    love.graphics.draw(self.barOne, self.quads[bit], tx, ty, tr)
    love.graphics.setColor(self.colorTwo[1]/255, 
      self.colorTwo[2]/255,
      self.colorTwo[3]/255, 1)
    love.graphics.draw(self.barTwo, self.quads[bit], tx, ty, tr)
  end
end
