section = basicEntity:extend()

addobjects.register("section", function(v)
  megautils.state().sectionHandler:add(v.x, v.y, v.width, v.height, v.properties.infiniteX, v.properties.infiniteY,
    v.properties.infiniteW, v.properties.infiniteH, v.properties.boundsX, v.properties.boundsY)
end, 1)

function section:new(x, y, w, h, ix, iy, iw, ih, bx, by)
  section.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.scrollx = ix and -math.huge or x
  self.scrolly = iy and -math.huge or y
  self.scrollw = iw and math.huge or w
  self.scrollh = ih and math.huge or h
  self.boundsX = (bx == nil) or bx
  self.boundsY = (by == nil) or by
  if not self.boundsX then
    self.scrollw = 0
  end
  if not self.boundsY then
    self.scrollh = 0
  end
  self.group = self:collisionTable(megautils.groups().despawnable)
end

sectionHandler = class:extend()

function sectionHandler:new()
  self.sections = {}
  self.current = nil
  self.next = nil
end

function sectionHandler:updateEntity(e)
  for k, v in ipairs(self.sections) do
    if table.contains(v.group, e) then
      table.removevaluearray(v.group, e)
      break
    end
  end
  local tmp = e:collisionTable(self.sections)[1]
  tmp.group[#tmp.group+1] = e
end

function sectionHandler:removeEntity(e)
  for k, v in ipairs(self.sections) do
    if table.contains(v.group, e) then
      table.removevaluearray(v.group, e)
      break
    end
  end
end

function sectionHandler:iterate(func)
  for k, v in ipairs(self.sections) do
    for i, j in ipairs(v.group) do
      if func(j) == true then
        break
      end
    end
  end
end

function sectionHandler:add(...)
  self.sections[#self.sections+1] = section(...)
end

function sectionHandler:updateAll()
  if not self.current then
    for k, v in pairs(self.sections) do
      if v.boundsX or v.boundsY then
        for i, j in pairs(v.group) do
          megautils.remove(j)
        end
      end
    end
  else
    self.current.group = self.current:collisionTable(megautils.groups().despawnable)
    if self.current.boundsX or self.current.boundsY then
      for k, v in pairs(self.current.group) do
        if not v.dontRemove and not table.contains(self.next.group, v) then
          megautils.remove(v)
        end
      end
    end
  end
  if self.next then
    for k, v in pairs(self.next.group) do
      if not v.dontRemove and not v.isAdded and not (self.current and table.contains(self.current.group, v)) then
        megautils.adde(v)
      end
    end
    self.current = self.next
    self.next = nil
  end
end

lockSection = basicEntity:extend()

addobjects.register("lockSection", function(v)
  megautils.add(lockSection, v.x, v.y, v.width, v.height, v.properties.name, v.properties.infiniteX, v.properties.infiniteY,
    v.properties.infiniteW, v.properties.infiniteH, v.properties.boundsX, v.properties.boundsY)
end, 1)

function lockSection:new(x, y, w, h, name, ix, iy, iw, ih, bx, by)
  lockSection.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.name = name
  self.scrollx = ix and -math.huge or x
  self.scrolly = iy and -math.huge or y
  self.scrollw = iw and math.huge or w
  self.scrollh = ih and math.huge or h
  self.boundsX = (bx == nil) or bx
  self.boundsY = (by == nil) or by
  if not self.boundsX then
    self.scrollw = 0
  end
  if not self.boundsY then
    self.scrollh = 0
  end
  self.section = self:collisionTable(megautils.state().sectionHandler.sections)[1]
  self.added = function(self)
    self:addToGroup("lock")
    self:addStatic()
  end
end