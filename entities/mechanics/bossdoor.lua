megautils.loadResource("assets/global/bossDoor.png", "bossDoor", true)
megautils.loadResource("assets/sfx/bossDoor.ogg", "bossDoorSfx", true)

bossDoor = basicEntity:extend()

bossDoor.autoClean = false

binser.register(bossDoor, "bossDoor", function(o)
    local result = {}
    
    bossDoor.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.timer = o.timer
    result.segments = o.segments
    result.maxSegments = o.maxSegments
    result.spd = o.spd
    result.state = o.state
    result.player = o.player
    result.canWalkThrough = o.canWalkThrough
    result.isLocked = o.isLocked
    result.tileWidth = o.tileWidth
    result.tileHeight = o.tileHeight
    result.tileSpeed = o.tileSpeed
    result.useMapTiles = o.useMapTiles
    result.name = o.name
    result.dir = o.dir
    
    return result
  end, function(o)
    local result = bossDoor()
    
    bossDoor.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.timer = o.timer
    result.segments = o.segments
    result.maxSegments = o.maxSegments
    result.spd = o.spd
    result.state = o.state
    result.player = o.player
    result.canWalkThrough = o.canWalkThrough
    result.isLocked = o.isLocked
    result.tileWidth = o.tileWidth
    result.tileHeight = o.tileHeight
    result.tileSpeed = o.tileSpeed
    result.useMapTiles = o.useMapTiles
    result.name = o.name
    result.dir = o.dir
    
    return result
  end)

mapEntity.register("bossDoor", function(v)
  local seg = (v.properties.dir=="up" or v.properties.dir=="down") and 
    math.round(v.width/v.properties.tileWidth) or math.round(v.height/v.properties.tileHeight)
  megautils.add(bossDoor, v.x, v.y, seg, v.properties.dir,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed,
    v.properties.tileLayer, v.properties.toSection, v.properties.tileWidth, v.properties.tileHeight,
    v.properties.tileSpeed)
end, 0, true)

function bossDoor:new(x, y, seg, dir, scrollx, scrolly, spd, umt, n, tw, th, ts)
  bossDoor.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setLayer(0)
  self.tex = megautils.getResource("bossDoor")
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
end

function bossDoor:added()
  self:addToGroup("bossDoor")
  self:addToGroup("handledBySections")
  self:addToGroup("collision")
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
  local s = self:collisionTable(section.getSections(self.transform.x-self.tileWidth, self.transform.y,
    self.collisionShape.w, self.collisionShape.h), -self.tileWidth, 0)[1]
  camera.main.toSection = s
  camera.main.transform.x = self.transform.x+self.tileWidth
  camera.main.transX = camera.main.transform.x-camera.main.player.collisionShape.w-28
  camera.main.curBoundName = self.name
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
  local s = self:collisionTable(section.getSections(self.transform.x+self.tileWidth, self.transform.y,
    self.collisionShape.w, self.collisionShape.h), self.tileWidth, 0)[1]
  camera.main.toSection = s
  camera.main.transform.x = self.transform.x+self.tileWidth-camera.main.collisionShape.w
  camera.main.transX = camera.main.transform.x+camera.main.collisionShape.w+28
  camera.main.curBoundName = self.name
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
  local s = self:collisionTable(section.getSections(self.transform.x, self.transform.y-self.tileHeight,
    self.collisionShape.w, self.collisionShape.h), 0, -self.tileHeight)[1]
  camera.main.toSection = s
  camera.main.transform.y = self.transform.y+self.tileHeight
  camera.main.transY = camera.main.transform.y-camera.main.player.collisionShape.h-28
  camera.main.curBoundName = self.name
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
  local s = self:collisionTable(section.getSections(self.transform.x, self.transform.y+self.tileHeight,
    self.collisionShape.w, self.collisionShape.h), 0, self.tileHeight)[1]
  camera.main.toSection = s
  camera.main.transform.y = self.transform.y+self.tileHeight-camera.main.collisionShape.h
  camera.main.transY = camera.main.transform.y+camera.main.collisionShape.h+28
  camera.main.curBoundName = self.name
  camera.main.dontUpdateSections = true
  camera.main.freeze = false
end

function bossDoor:update()
  if not megaMan.mainPlayer or not camera.main or not rectOverlapsRect(self.transform.x, self.transform.y, self.collisionShape.w,
    self.collisionShape.h, camera.main.scrollx, camera.main.scrolly,
    camera.main.scrollw, camera.main.scrollh) then return end
  if ((self.transform.x < camera.main.scrollx and self.dir == "left") or
    (self.transform.x+self.collisionShape.w > camera.main.scrollx+camera.main.scrollw and self.dir == "right") or
    (self.transform.y < camera.main.scrolly and self.dir == "up") or
    (self.transform.y+self.collisionShape.h > camera.main.scrolly+camera.main.scrollh and self.dir == "down")) then
    self.canWalkThrough = not checkTrue(self.isLocked)
  else
    self.canWalkThrough = false
  end
  if self.state == 0 then
    self.timer = 0
    if camera.main and not camera.main.transition then
      for i=1, #megaMan.allPlayers do
        local player = megaMan.allPlayers[i]
        if checkFalse(player.canControl) and self:collision(player) then
          self.player = player
          self.state = 1
          for j=1, #megaMan.allPlayers do
            megaMan.allPlayers[j].canControl.trans = false
            megaMan.allPlayers[j].doAnimation = false
          end
          megautils.freeze(megaMan.allPlayers)
          if megautils.groups().removeOnTransition then
            for k, v in pairs(megautils.groups().removeOnTransition) do
              megautils.removeq(v)
            end
          end
          if self.useMapTiles then
            self.tileList = {}
            if megautils.groups().map then
              for k, v in ipairs(megautils.groups().map) do
                local layer = v:getLayerByName(self.useMapTiles)
                if layer then
                  local oldx
                  local oldy
                  self.tileList[v] = {}
                  for x=1, (self.dir=="right" or self.dir=="left") and (2*self.tileWidth) or (self.maxSegments*self.tileHeight) do
                    self.tileList[v][x] = {}
                    for y=1, (self.dir=="right" or self.dir=="left") and (self.maxSegments*self.tileWidth) or (2*self.tileHeight) do
                      local gid = layer:getTileAtPixelPosition(self.transform.x+(x*self.tileWidth)-self.tileWidth,
                        self.transform.y+(y*self.tileHeight)-self.tileHeight)
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
          if megautils.groups().map then
            for k, v in ipairs(megautils.groups().map) do
              local layer = v:getLayerByName(self.useMapTiles)
              if layer then
                layer:setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and
                  self.transform.x or (self.transform.x+(self.segments*self.tileWidth)),
                  (self.dir=="right" or self.dir=="left") and
                  (self.transform.y+((self.segments)*self.tileHeight)) or self.transform.y, -1)
                layer:setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and
                  self.transform.x+self.tileWidth or self.transform.x+(self.segments*self.tileWidth),
                  (self.dir=="right" or self.dir=="left") and
                  self.transform.y+((self.segments)*self.tileHeight) or self.transform.y+self.tileHeight, -1)
              end
            end
          end
        end
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
      for i=1, self.tileSpeed do
        if self.segments == self.maxSegments then
          break
        end
        self.segments = math.min(self.segments+1, self.maxSegments)
        if self.useMapTiles then
          if megautils.groups().map then
            for k, v in ipairs(megautils.groups().map) do
              local layer = v:getLayerByName(self.useMapTiles)
              if layer and self.tileList[v] then
                layer
                  :setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and
                    self.transform.x or self.transform.x+(self.segments*self.tileWidth)-self.tileWidth,
                    (self.dir=="right" or self.dir=="left") and
                    self.transform.y+(self.segments*self.tileHeight)-self.tileHeight or self.transform.y,
                    self.tileList[v]
                    [(self.dir=="right" or self.dir=="left") and 1 or self.segments]
                    [(self.dir=="right" or self.dir=="left") and self.segments or 1])
                layer
                  :setTileAtPixelPosition((self.dir=="right" or self.dir=="left") and
                    self.transform.x+16 or self.transform.x+(self.segments*self.tileWidth)-self.tileWidth,
                    (self.dir=="right" or self.dir=="left") and
                    self.transform.y+(self.segments*self.tileHeight)-self.tileHeight or self.transform.y+self.tileHeight,
                    self.tileList[v]
                    [(self.dir=="right" or self.dir=="left") and 2 or self.segments]
                    [(self.dir=="right" or self.dir=="left") and self.segments or 2])
              end
            end
          end
        end
      end
      megautils.playSound("bossDoorSfx")
    end
    if self.segments >= self.maxSegments then
      self.timer = 0
      self.tileList = {}
      camera.main.freeze = true
      camera.main.dontUpdateSections = false
      megautils.state().system.cameraUpdate = function()
        camera.main:updateBounds()
        camera.main.tweenFinished = false
        megautils.unfreeze(megaMan.allPlayers)
        for i=1, #megaMan.allPlayers do
          megaMan.allPlayers[i].canControl.trans = true
          megaMan.allPlayers[i].doAnimation = true
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
  for i=1, self.segments do
    if self.dir == "left" or self.dir == "right" then
      self.quad:draw(self.tex, self.transform.x, self.transform.y + (i*16) - 16)
    else
      self.quad:draw(self.tex, self.transform.x + (i*16), self.transform.y, math.rad(90))
    end
  end
end