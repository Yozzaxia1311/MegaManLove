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

function sectionHandler:add(s)
  self.sections[#self.sections+1] = s
end

function sectionHandler:updateAll()
  if self.current == nil then
    for k, v in pairs(self.sections) do
      for i, j in pairs(v.group) do
        megautils.remove(j)
      end
    end
  else
    for k, v in pairs(self.current.group) do
      megautils.remove(v)
    end
  end
  if self.next ~= nil then
    for k, v in pairs(self.next.group) do
      megautils.add(v)
    end
    self.current = self.next
    self.next = nil
  end
end