local titlestate = states.state:extend()

function titlestate:begin()
  loader.load("assets/misc/title.png", "title", "texture")
  megautils.add(title())
end

function titlestate:update(dt)
  megautils.update(self, dt)
end

function titlestate:stop()
  megautils.unload(self)
end

function titlestate:draw()
  megautils.draw(self)
end

megautils.cleanFuncs["unload_title"] = function()
  title = nil
  megautils.cleanFuncs["unload_title"] = nil
end

title = entity:extend()

function title:new()
  title.super.new(self)
  self.transform.y = 256
  self.transform.x = 37
  self.tex = loader.get("title")
  self.once = false
  self.textTimer = 0
  self.drawText = false
  self.cont = false
  self.text = "name + year"
  self.textPos = 128-(self.text:len()*8)/2
end

function title:update(dt)
  self.transform.y = math.max(self.transform.y-8, 32)
  if self.transform.y == 32 and not self.once then
    self.once = true
    self.drawText = true
    mmMusic.playFromFile(nil, "assets/sfx/music/title.ogg")
  end
  if self.drawText then
    self.textTimer = math.wrap(self.textTimer+1, 0, 40)
    if control.startDown and not self.cont then
      self.cont = true
      mmMusic.stopMusic()
      self.drawText = false
      megautils.gotoState("states/menus/menustate.lua")
    end
  end
end

function title:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if self.drawText then
    love.graphics.setFont(mmFont)
    love.graphics.print(self.text, self.textPos, 208)
    if self.textTimer < 20 then
      love.graphics.print("press start", 84, 124)
    end
  end
  love.graphics.draw(self.tex, self.transform.x, self.transform.y)
end

return titlestate