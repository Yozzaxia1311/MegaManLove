bossdoor = entity:extend()

addobjects.register("boss_door", function(v)
  local seg = (v.properties["dir"]=="up" or v.properties["dir"]=="down") and 
    math.round(v.width/16) or math.round(v.height/16)
  megautils.add(bossdoor(v.x, v.y, seg, v.properties["dir"],
  v.properties["doScrollX"], v.properties["doScrollY"]))
end)

bossdoor.animGrid = anim8.newGrid(32, 64, 160, 64)

function bossdoor:new(x, y, seg, dir, scrollx, scrolly, spd)
  bossdoor.super.new(self)
  self.added = function(self)
    self:addToGroup("boss_door")
    self:addToGroup("despawnable")
  end
  self.transform.y = y
  self.transform.x = x
  self.tex = loader.get("boss_door")
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.quad = love.graphics.newQuad(0, 0, 32, 16, 32, 16)
  self.timer = 0
  self.segments = seg
  self.maxSegments = seg
  self.spd = spd or 1
  self.state = 0
  self.player = nil
  self:setDirection(dir)
  self.spawnEarlyDuringTransition = true
end

function bossdoor:setDirection(dir)
  self:setRectangleCollision((dir=="up" or dir=="down") and self.maxSegments*16 or 32,
    (dir=="up" or dir=="down") and 32 or self.maxSegments*16)
  self.dir = dir or "right"
end

function bossdoor:update(dt)
  if not camera.main or not rectOverlaps(self.transform.x, self.transform.y, self.collisionShape.w,
    self.collisionShape.h, camera.main.scrollx, camera.main.scrolly, camera.main.scrollw, camera.main.scrollh) then return end
  if ((self.transform.x < camera.main.scrollx and self.dir == "left") or
    (self.transform.x+self.collisionShape.w > camera.main.scrollx+camera.main.scrollw and self.dir == "right") or
    (self.transform.y < camera.main.scrolly and self.dir == "up") or
    (self.transform.y+self.collisionShape.h > camera.main.scrolly+camera.main.scrollh and self.dir == "down")) then
    self.isSolid = 0
  else
    self.isSolid = 1
  end
  if self.state == 0 then
    self.timer = 0
    if camera.main and not camera.main.transition then
      for i=1, #globals.allPlayers do
        local player = globals.allPlayers[i]
        if player.control and self:collision(player) then
          self.player = player
          self.state = 1
          for j=1, #globals.allPlayers do
            globals.allPlayers[j].control = false
            globals.allPlayers[j].doAnimation = false
          end
          megautils.freeze(globals.allPlayers)
          if megautils.groups()["removeOnTransition"] then
            for k, v in pairs(megautils.groups()["removeOnTransition"]) do
              megautils.remove(v, true)
            end
          end
        end
      end
    end
  elseif self.state == 1 then
    self.timer = math.min(self.timer+1, 8)
    if self.timer == 8 then
      self.timer = 0
      self.segments = math.max(self.segments-1, 0)
      mmSfx.play("boss_door_sfx")
    end
    if self.segments <= 0 then
      self.state = 2
      self.timer = 0
      self.c = "open"
      self.player.doAnimation = true
      camera.main.transX = (self.dir=="up" or self.dir=="down") and 0 or 
        (self.dir=="left" and camera.main.scrollx-self.player.collisionShape.w-28 or
          camera.main.scrollx+camera.main.scrollw+28)
      camera.main.transY = (self.dir=="up" or self.dir=="down") and
        (self.dir=="up" and camera.main.scrolly-self.player.collisionShape.h-28 or
          camera.main.scrolly+camera.main.scrollh+28) or 0
      camera.main.transitiondirection = self.dir
      camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
      camera.main.transition = true
      camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 
        (self.dir=="left" or self.dir=="right") and (self.dir=="left" and -16 or 16) or 0,
        (self.dir=="up" or self.dir=="down") and (self.dir=="up" and -16 or 16) or 0)[1]
      camera.main.speed = self.spd
      camera.main.player = self.player
      camera.main.updateSections = false
      camera.main.freeze = false
    end
  elseif self.state == 2 then
    if not camera.main.transition then
      self.player.doAnimation = false
      camera.main.transXSpeed = .35
      camera.main.transYSpeed = .45
      self.state = 3
    end
  elseif self.state == 3 then
    self.timer = math.min(self.timer+1, 8)
    if self.timer == 8 then
      self.timer = 0
      self.segments = math.min(self.segments+1, self.maxSegments)
      mmSfx.play("boss_door_sfx")
    end
    if self.segments >= self.maxSegments then
      self.timer = 0
      for i=1, #globals.allPlayers do
        globals.allPlayers[i].control = true
        globals.allPlayers[i].doAnimation = true
      end
      camera.main.freeze = true
      camera.main.updateSections = true
      megautils.state().system.afterUpdate = function()
        camera.main:updateBounds()
        camera.main.toSection = nil
        megautils.unfreeze(globals.allPlayers)
        megautils.state().system.afterUpdate = nil
      end
      self.state = 0
    end
  end
end

function bossdoor:draw()
  if megautils.outside(self) then return end
  love.graphics.setColor(1, 1, 1, 1)
  for i=1, self.segments do
    if self.dir == "left" or self.dir == "right" then
      love.graphics.draw(self.tex, self.quad, self.transform.x, self.transform.y + (i*16) - 16)
    else
      love.graphics.draw(self.tex, self.quad, self.transform.x + (i*16), self.transform.y, math.rad(90))
    end
  end
end