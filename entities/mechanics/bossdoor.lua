loader.load("assets/misc/bossDoor.png", true)
loader.load("assets/sfx/bossDoor.ogg", true)

bossDoor = basicEntity:extend()

bossDoor.autoClean = false

mapEntity.register("bossDoor", function(v)
  local seg = (v.properties.dir=="up" or v.properties.dir=="down") and 
    math.round(v.width/v.properties.tileWidth) or math.round(v.height/v.properties.tileHeight)
  entities.add(bossDoor, v.x, v.y, seg, v.properties.dir,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed,
    v.properties.tileLayer, v.properties.toSection, v.properties.tileWidth, v.properties.tileHeight,
    v.properties.tileSpeed)
end, 0, true)

function bossDoor:new(x, y, seg, dir, scrollx, scrolly, spd, umt, n, tw, th, ts)
  bossDoor.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setLayer(-1)
  self.tex = loader.get("assets/misc/bossDoor.png")
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.quad = quad(0, 0, 32, 16)
  self.timer = 0
  self.segments = seg or 4
  self.maxSegments = seg or 4
  self.spd = spd or 1
  self.state = 0
  self.player = nil
  self.solidType = collision.SOLID
  self.canWalkThrough = false
  self.isLocked = {global=false}
  self.spawnEarlyDuringTransition = true
  self.tileWidth = tw or 16
  self.tileHeight = th or 16
  self.tileSpeed = ts or 1
  self.useMapTiles = umt
  if self.useMapTiles == "" then
    self.useMapTiles = nil
  end
  self.name = n
  if self.name == "" then
    self.name = nil
  end
  self:setDirection(dir)
  self.visibleDuringPause = true
  self.noFreeze = {"trans"}
end

function bossDoor:added()
  self:addToGroup("bossDoor")
  self:addToGroup("handledBySections")
end

function bossDoor:setDirection(dir)
  self:setRectangleCollision((dir=="up" or dir=="down") and (self.maxSegments*self.tileWidth) or (2*self.tileWidth),
    (dir=="up" or dir=="down") and (2*self.tileHeight) or (self.maxSegments*self.tileHeight))
  self.dir = dir or "right"
end

function bossDoor:left()
  camera.main.transitionDirection = "left"
  camera.main.transition = true
  camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
  camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
  camera.main.player = self.player
  camera.main.speed = self.spd
  local s = self:collisionTable(section.getSections(self.x-self.tileWidth, self.y,
    self.collisionShape.w, self.collisionShape.h), -self.tileWidth, 0)
  for _, v in ipairs(s) do
    if v.name == self.name then
      s = v
      break
    end
  end
  camera.main.toSection = s
  camera.main.x = self.x+self.tileWidth
  camera.main.transX = camera.main.x-camera.main.player.collisionShape.w-28
  camera.main.dontUpdateSections = true
  camera.main.freeze = false
end

function bossDoor:right()
  camera.main.transitionDirection = "right"
  camera.main.transition = true
  camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
  camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
  camera.main.player = self.player
  camera.main.speed = self.spd
  local s = self:collisionTable(section.getSections(self.x+self.tileWidth, self.y,
    self.collisionShape.w, self.collisionShape.h), self.tileWidth, 0)
  for _, v in ipairs(s) do
    if v.name == self.name then
      s = v
      break
    end
  end
  camera.main.toSection = s
  camera.main.x = self.x+self.tileWidth-camera.main.collisionShape.w
  camera.main.transX = camera.main.x+camera.main.collisionShape.w+28
  camera.main.dontUpdateSections = true
  camera.main.freeze = false
end

function bossDoor:up()
  camera.main.transitionDirection = "up"
  camera.main.transition = true
  camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
  camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
  camera.main.player = self.player
  camera.main.speed = self.spd
  local s = self:collisionTable(section.getSections(self.x, self.y-self.tileHeight,
    self.collisionShape.w, self.collisionShape.h), 0, -self.tileHeight)
  for _, v in ipairs(s) do
    if v.name == self.name then
      s = v
      break
    end
  end
  camera.main.toSection = s
  camera.main.y = self.y+self.tileHeight
  camera.main.transY = camera.main.y-camera.main.player.collisionShape.h-28
  camera.main.dontUpdateSections = true
  camera.main.freeze = false
end

function bossDoor:down()
  camera.main.transitionDirection = "down"
  camera.main.transition = true
  camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
  camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
  camera.main.player = self.player
  camera.main.speed = self.spd
  local s = self:collisionTable(section.getSections(self.x, self.y+self.tileHeight,
    self.collisionShape.w, self.collisionShape.h), 0, self.tileHeight)
  for _, v in ipairs(s) do
    if v.name == self.name then
      s = v
      break
    end
  end
  camera.main.toSection = s
  camera.main.y = self.y+self.tileHeight-camera.main.collisionShape.h
  camera.main.transY = camera.main.y+camera.main.collisionShape.h+28
  camera.main.dontUpdateSections = true
  camera.main.freeze = false
end

function bossDoor:update()
  if not megaMan.mainPlayer or not camera.main or not rectOverlapsRect(self.x, self.y, self.collisionShape.w,
    self.collisionShape.h, camera.main.scrollx, camera.main.scrolly,
    camera.main.scrollw, camera.main.scrollh) then return end
  if ((self.x < camera.main.scrollx and self.dir == "left") or
    (self.x+self.collisionShape.w > camera.main.scrollx+camera.main.scrollw and self.dir == "right") or
    (self.y < camera.main.scrolly and self.dir == "up") or
    (self.y+self.collisionShape.h > camera.main.scrolly+camera.main.scrollh and self.dir == "down")) then
    self.canWalkThrough = not checkTrue(self.isLocked)
  else
    self.canWalkThrough = false
  end
  if self.state == 0 then
    self.timer = 0
    if self.canWalkThrough and camera.main and not camera.main.transition then
      for i=1, #megaMan.allPlayers do
        local player = megaMan.allPlayers[i]
        if checkFalse(player.canControl) and self:collision(player) then
          self.player = player
          self.state = 1
          for j=1, #megaMan.allPlayers do
            megaMan.allPlayers[j].canControl.trans = false
            megaMan.allPlayers[j].doAnimation = false
            megaMan.allPlayers[j].noFreeze = true
            megaMan.allPlayers[i].autoGravity.transition = false
            megaMan.allPlayers[i].autoCollision.transition = false
          end
          entities.freeze("trans")
          if entities.groups.removeOnTransition then
            for _, v in pairs(entities.groups.removeOnTransition) do
              entities.remove(v)
            end
          end
          if self.useMapTiles then
            self.tileList = {}
            if entities.groups.map then
              for _, v in ipairs(entities.groups.map) do
                local layer = v:getLayerByName(self.useMapTiles)
                if layer then
                  local oldx
                  local oldy
                  self.tileList[v] = {}
                  for x=1, (self.dir=="right" or self.dir=="left") and (2*self.tileWidth) or
                    (self.maxSegments*self.tileHeight) do
                    self.tileList[v][x] = {}
                    for y=1, (self.dir=="right" or self.dir=="left") and (self.maxSegments*self.tileWidth)
                      or (2*self.tileHeight) do
                      local gid = layer:getTileAtPixelPosition(self.x+(x*self.tileWidth)-self.tileWidth,
                        self.y+(y*self.tileHeight)-self.tileHeight)
                      if gid >= 0 and (oldx ~= math.floor((x/self.tileWidth)*self.tileWidth) or
                        oldy ~= math.floor((y/self.tileHeight)*self.tileHeight)) then
                        oldx = math.floor((x/self.tileWidth)*self.tileWidth)
                        oldy = math.floor((y/self.tileHeight)*self.tileHeight)
                        self.tileList[v][x][y] = gid
                      end
                    end
                  end
                end
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
      for i=1, self.tileSpeed do
        if self.segments == 0 then
          break
        end
        self.segments = math.max(self.segments-1, 0)
        if self.useMapTiles then
          if entities.groups.map then
            for _, v in ipairs(entities.groups.map) do
              local layer = v:getLayerByName(self.useMapTiles)
              if layer then
                layer:setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and
                  self.x or (self.x+(self.segments*self.tileWidth)),
                  (self.dir=="right" or self.dir=="left") and
                  (self.y+((self.segments)*self.tileHeight)) or self.y, -1)
                layer:setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and
                  self.x+self.tileWidth or self.x+(self.segments*self.tileWidth),
                  (self.dir=="right" or self.dir=="left") and
                  self.y+((self.segments)*self.tileHeight) or self.y+self.tileHeight, -1)
              end
            end
          end
        end
      end
      sfx.play("assets/sfx/bossDoor.ogg")
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
      for i=1, self.tileSpeed do
        if self.segments == self.maxSegments then
          break
        end
        self.segments = math.min(self.segments+1, self.maxSegments)
        if self.useMapTiles then
          if entities.groups.map then
            for _, v in ipairs(entities.groups.map) do
              local layer = v:getLayerByName(self.useMapTiles)
              if layer and self.tileList[v] then
                layer
                  :setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and
                    self.x or self.x+(self.segments*self.tileWidth)-self.tileWidth,
                    (self.dir=="right" or self.dir=="left") and
                    self.y+(self.segments*self.tileHeight)-self.tileHeight or self.y,
                    self.tileList[v]
                    [(self.dir=="right" or self.dir=="left") and 1 or self.segments]
                    [(self.dir=="right" or self.dir=="left") and self.segments or 1])
                layer
                  :setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and
                    self.x+16 or self.x+(self.segments*self.tileWidth)-self.tileWidth,
                    (self.dir=="right" or self.dir=="left") and
                    self.y+(self.segments*self.tileHeight)-self.tileHeight or self.y+self.tileHeight,
                    self.tileList[v]
                    [(self.dir=="right" or self.dir=="left") and 2 or self.segments]
                    [(self.dir=="right" or self.dir=="left") and self.segments or 2])
              end
            end
          end
        end
      end
      sfx.play("assets/sfx/bossDoor.ogg")
    end
    if self.segments >= self.maxSegments then
      self.timer = 0
      self.tileList = {}
      camera.main.freeze = true
      camera.main.dontUpdateSections = false
      entities.cameraUpdate = function()
        camera.main.curBoundName = camera.main.toSection.name
        camera.main.toSection = nil
        camera.main:updateBounds()
        camera.main.tweenFinished = false
        for i=1, #megaMan.allPlayers do
          megaMan.allPlayers[i].canControl.trans = nil
          megaMan.allPlayers[i].doAnimation = true
          megaMan.allPlayers[i].noFreeze = nil
          megaMan.allPlayers[i].autoGravity.transition = nil
          megaMan.allPlayers[i].autoCollision.transition = nil
        end
        entities.unfreeze("trans")
        camera.main.once = false
        camera.main.transition = false
        camera.main.preTrans = false
        entities.cameraUpdate = nil
        
        collectgarbage()
        collectgarbage()
      end
      self.state = 0
    end
  end
end

function bossDoor:draw()
  if self.useMapTiles or megautils.outside(self) then return end
  for i=1, self.segments do
    if self.dir == "left" or self.dir == "right" then
      self.tex:draw(self.quad, self.x, self.y + (i*16) - 16)
    else
      self.tex:draw(self.quad, self.x + (i*16), self.y, 90)
    end
  end
end
