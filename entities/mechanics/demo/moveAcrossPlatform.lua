addobjects.register("move_across_platform", function(v)
  local tmp = spawner(v.x, v.y, 32, 16, function(s)
    megautils.add(moveAcrossPlatform(s.transform.x, s.transform.y, s.toX, s.toY, s))
  end)
  tmp.toX = v.properties["to_x"]
  tmp.toY = v.properties["to_y"]
  megautils.add(tmp)
end)

moveAcrossPlatform = entity:extend()

function moveAcrossPlatform:new(x, y, toX, toY, s)
  moveAcrossPlatform.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
    self:addToGroup("removeOnCutscene")
  end
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(32, 16)
  self.tex = loader.get("demo_objects")
  self.quad = love.graphics.newQuad(0, 0, 32, 16, 100, 100)
  self.spawner = s
  self.velocity = velocity()
  self.tween = tween.new(1, self.transform, {x=toX, y=toY}, "inOutBack")
  self.state = 0
end

function moveAcrossPlatform:removed()
  if self.spawner ~= nil then
    self.spawner.canSpawn = true
  end
   movingOneway.clean(self)
end

function moveAcrossPlatform:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

function moveAcrossPlatform:afterUpdate(dt)
  if self.state == 0 then
    for i=1, #globals.allPlayers do
      local player = globals.allPlayers[i]
      if oneway.collision(player, self, player.velocity.velx, player.velocity.vely+1) then
        self.state = 1
      end
    end
  elseif self.state == 1 then
    local dx, dy = self.transform.x, self.transform.y
    self.tween:update(1/60)
    self.transform.x = math.round(self.transform.x)
    self.transform.y = math.round(self.transform.y)
    self.velocity.velx = self.transform.x - dx
    self.velocity.vely = self.transform.y - dy
  end
  movingOneway.shift(self, megautils.groups()["carry"])
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

megautils.cleanFuncs["unload_move_across_platform"] = function()
  moveAcrossPlatform = nil
  addobjects.unregister("move_across_platform")
  megautils.cleanFuncs["unload_move_across_platform"] = nil
end