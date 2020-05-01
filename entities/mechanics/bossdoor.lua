bossDoor = entity:extend()

addobjects.register("bossDoor", function(v)
  local seg = (v.properties.dir=="up" or v.properties.dir=="down") and 
    math.round(v.width/16) or math.round(v.height/16)
  megautils.add(bossDoor, v.x, v.y, seg, v.properties.dir,
  v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.useTileLayer)
end)

function bossDoor:new(x, y, seg, dir, scrollx, scrolly, spd, umt)
  bossDoor.super.new(self)
  self.added = function(self)
    self:addToGroup("bossDoor")
    self:addToGroup("despawnable")
  end
  self.transform.y = y
  self.transform.x = x
  self:setLayer(0)
  self.tex = megautils.getResource("bossDoor")
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.quad = love.graphics.newQuad(0, 0, 32, 16, 32, 16)
  self.timer = 0
  self.segments = seg
  self.maxSegments = seg
  self.spd = spd
  self.state = 0
  self.player = nil
  self:setDirection(dir)
  self.isSolid = 1
  self.canWalkThrough = false
  self.isLocked = {global=false}
  self.spawnEarlyDuringTransition = true
  self.useMapTiles = megautils.getMapLayer(umt) and umt
end

function bossDoor:setDirection(dir)
  self:setRectangleCollision((dir=="up" or dir=="down") and self.maxSegments*16 or 32,
    (dir=="up" or dir=="down") and 32 or self.maxSegments*16)
  self.dir = dir or "right"
end

function bossDoor:left()
  camera.main.transitionDirection = "left"
  camera.main.transition = true
  camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
  camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
  camera.main.player = self.player
  camera.main.speed = self.spd or 1
  local s = self:collisionTable(section.getSections(self.transform.x-16, self.transform.y, self.collisionShape.w, self.collisionShape.h), -16, 0)[1]
  camera.main.toSection = s
  camera.main.transform.x = self.transform.x+16
  camera.main.transX = camera.main.transform.x-camera.main.player.collisionShape.w-28
  camera.main.curBoundName = to.name
  camera.main.dontUpdateSections = true
  camera.main.freeze = false
end

function bossDoor:right()
  camera.main.transitionDirection = "right"
  camera.main.transition = true
  camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
  camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
  camera.main.player = self.player
  camera.main.speed = self.spd or 1
  local s = self:collisionTable(section.getSections(self.transform.x+16, self.transform.y, self.collisionShape.w, self.collisionShape.h), 16, 0)[1]
  camera.main.toSection = s
  camera.main.transform.x = self.transform.x+16-camera.main.collisionShape.w
  camera.main.transX = camera.main.transform.x+camera.main.collisionShape.w+28
  camera.main.curBoundName = s.name
  camera.main.dontUpdateSections = true
  camera.main.freeze = false
end

function bossDoor:up()
  camera.main.transitionDirection = "up"
  camera.main.transition = true
  camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
  camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
  camera.main.player = self.player
  camera.main.speed = self.spd or 1
  local s = self:collisionTable(section.getSections(self.transform.x, self.transform.y-16, self.collisionShape.w, self.collisionShape.h), 0, -16)[1]
  camera.main.toSection = s
  camera.main.transform.y = self.transform.y+16
  camera.main.transY = camera.main.transform.y-camera.main.player.collisionShape.h-28
  camera.main.curBoundName = s.name
  camera.main.dontUpdateSections = true
  camera.main.freeze = false
end

function bossDoor:down()
  camera.main.transitionDirection = "down"
  camera.main.transition = true
  camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
  camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
  camera.main.player = self.player
  camera.main.speed = self.spd or 1
  local s = self:collisionTable(section.getSections(self.transform.x, self.transform.y+16, self.collisionShape.w, self.collisionShape.h), 0, 16)[1]
  camera.main.toSection = s
  camera.main.transform.y = self.transform.y+16-camera.main.collisionShape.h
  camera.main.transY = camera.main.transform.y+camera.main.collisionShape.h+28
  camera.main.curBoundName = s.name
  camera.main.dontUpdateSections = true
  camera.main.freeze = false
end

function bossDoor:update(dt)
  if not globals.mainPlayer or not camera.main or not rectOverlapsRect(self.transform.x, self.transform.y, self.collisionShape.w,
    self.collisionShape.h, camera.main.scrollx, camera.main.scrolly,
    camera.main.scrollw, camera.main.scrollh) then return end
  if ((self.transform.x < camera.main.scrollx and self.dir == "left") or
    (self.transform.x+self.collisionShape.w > camera.main.scrollx+camera.main.scrollw and self.dir == "right") or
    (self.transform.y < camera.main.scrolly and self.dir == "up") or
    (self.transform.y+self.collisionShape.h > camera.main.scrolly+camera.main.scrollh and self.dir == "down")) then
    self.canWalkThrough = not self:checkTrue(self.isLocked)
  else
    self.canWalkThrough = false
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
          if megautils.groups().removeOnTransition then
            for k, v in pairs(megautils.groups().removeOnTransition) do
              megautils.removeq(v)
            end
          end
          if self.useMapTiles then
            self.tileList = {}
            for x=1, (self.dir=="right" or self.dir=="left") and 2 or self.maxSegments do
              self.tileList[x] = {}
              for y=1, (self.dir=="right" or self.dir=="left") and self.maxSegments or 2 do
                self.tileList[x][y] = megautils.getMapLayer(self.useMapTiles)
                  :getTileAtPixelPosition(self.transform.x+(x*16)-16, self.transform.y+(y*16)-16)
              end
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
      if self.useMapTiles then
        megautils.getMapLayer(self.useMapTiles)
        :setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and self.transform.x or self.transform.x+(self.segments*16),
          (self.dir=="right" or self.dir=="left") and self.transform.y+((self.segments)*16) or self.transform.y, -1)
        megautils.getMapLayer(self.useMapTiles)
        :setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and self.transform.x+16 or self.transform.x+(self.segments*16),
          (self.dir=="right" or self.dir=="left") and self.transform.y+((self.segments)*16) or self.transform.y+16, -1)
      end
      megautils.playSound("bossDoorSfx")
    end
    if self.segments <= 0 then
      self.state = 2
      self.timer = 0
      self.player.doAnimation = true
      if self.dir == "left" then
        self:left()
      elseif self.dir == "right" then
        self:right()
      elseif self.dir == "up" then
        self:up()
      elseif self.dir == "down" then
        self:down()
      end
    end
  elseif self.state == 2 then
    if camera.main.tweenFinished then
      self.player.doAnimation = false
      self.state = 3
    end
  elseif self.state == 3 then
    self.timer = math.min(self.timer+1, 8)
    if self.timer == 8 and self.segments < self.maxSegments then
      self.timer = 0
      self.segments = math.min(self.segments+1, self.maxSegments)
      if self.useMapTiles then
        megautils.getMapLayer(self.useMapTiles)
          :setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and self.transform.x or self.transform.x+(self.segments*16)-16,
          (self.dir=="right" or self.dir=="left") and self.transform.y+(self.segments*16)-16 or self.transform.y,
          self.tileList[(self.dir=="right" or self.dir=="left") and 1 or self.segments][(self.dir=="right" or self.dir=="left") and self.segments or 1])
        megautils.getMapLayer(self.useMapTiles)
          :setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and self.transform.x+16 or self.transform.x+(self.segments*16)-16,
          (self.dir=="right" or self.dir=="left") and self.transform.y+(self.segments*16)-16 or self.transform.y+16,
          self.tileList[(self.dir=="right" or self.dir=="left") and 2 or self.segments][(self.dir=="right" or self.dir=="left") and self.segments or 2])
      end
      megautils.playSound("bossDoorSfx")
    end
    if self.segments >= self.maxSegments then
      self.timer = 0
      camera.main.freeze = true
      camera.main.dontUpdateSections = false
      megautils.state().system.cameraUpdate = function()
        camera.main:updateBounds()
        camera.main.tweenFinished = false
        megautils.unfreeze(globals.allPlayers)
        for i=1, #globals.allPlayers do
          globals.allPlayers[i].control = true
          globals.allPlayers[i].doAnimation = true
        end
        camera.main.once = false
        camera.main.transition = false
        camera.main.preTrans = false
        megautils.state().system.cameraUpdate = nil
      end
      self.state = 0
    end
  end
end

function bossDoor:draw()
  if self.useMapTiles or megautils.outside(self) then return end
  love.graphics.setColor(1, 1, 1, 1)
  for i=1, self.segments do
    if self.dir == "left" or self.dir == "right" then
      love.graphics.draw(self.tex, self.quad, self.transform.x, self.transform.y + (i*16) - 16)
    else
      love.graphics.draw(self.tex, self.quad, self.transform.x + (i*16), self.transform.y, math.rad(90))
    end
  end
end