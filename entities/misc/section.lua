section = entity:extend()

addobjects.register("section", function(v)
  megautils.state().sectionHandler:add(section(v.x, v.y, v.width, v.height))
end, 1)

function section:new(x, y, w, h)
  section.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.group = self:collisionTable(megautils.groups()["despawnable"])
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

function sectionHandler:add(s)
  self.sections[#self.sections+1] = s
end

function sectionHandler:updateAll()
  if not self.current then
    for k, v in pairs(self.sections) do
      for i, j in pairs(v.group) do
        j:addStatic()
      end
    end
  else
    self.current.group = self.current:collisionTable(megautils.groups()["despawnable"])
    for k, v in pairs(self.current.group) do
      if not v.dontRemove and not table.contains(self.next.group, v) then
        v:addStatic()
      end
    end
  end
  if self.next then
    for k, v in pairs(self.next.group) do
      if not v.dontRemove and v.static and not (self.current and table.contains(self.current.group, v)) then
        v:removeStatic()
      end
    end
    self.current = self.next
    self.next = nil
  end
end