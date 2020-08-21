local titleState = state:extend()

function titleState:begin()
  megautils.loadResource("assets/misc/title.png", "title")
  megautils.add(title)
  megautils.setMusicLock(false)
end

title = basicEntity:extend()

function title:new()
  title.super.new(self)
  self.tex = megautils.getResource("title")
  self.textTimer = 0
  self.drawText = false
  self.cont = false
  self.text = "name + year"
  self.textPos = 128-(self.text:len()*8)/2
  self.timer = 0
  self.s = 0
  self.quad1 = quad(0, 0, 256, 115)
  self.quad2 = quad(0, 115, 256, 109)
  self.oneOff = 256
  self.twoOff = -256
  self.doIntro = love.filesystem.getInfo("assets/misc/intro.ogv") ~= nil
end

function title:added()
  self:addToGroup("freezable")
end

function title:update()
  if self.s < 2 and (control.startPressed[1] or control.jumpPressed[1]) then
    self.s = 3
    self.oneOff = 0
    self.twoOff = 0
    megautils.playMusic("assets/sfx/music/title.ogg")
    return
  end
  if self.s == 0 then
    self.oneOff = math.max(self.oneOff-8, 0)
    if self.oneOff == 0 then
      self.s = 1
    end
  elseif self.s == 1 then
    self.twoOff = math.min(self.twoOff+8, 0)
    if self.twoOff == 0 then
      self.s = 2
      megautils.playMusic("assets/sfx/music/title.ogg")
    end
  elseif self.s == 2 then
    self.s = 3
  elseif self.s == 3 then
    self.timer = self.timer + 1
    self.textTimer = math.wrap(self.textTimer+1, 0, 40)
    if self.doIntro and self.timer == 1440*1.2 then
      self.s = 4
      cscreen.setFade(0)
      megautils.stopMusic()
    elseif control.startPressed[1] then
      megautils.stopMusic()
      self.drawText = false
      megautils.transitionToState(globals.menuState)
    end
  elseif self.s == 4 then
    if cscreen.getFade() < 0.2 then
      megautils.transitionToState("assets/states/menus/intro.state.lua", nil, nil, 16)
    end
  end
end

function title:draw()
  self.quad1:draw(self.tex, self.oneOff, self.transform.y)
  self.quad2:draw(self.tex, self.twoOff, self.transform.y+115)
  if self.s == 3 then
    love.graphics.print(self.text, self.textPos, 208)
    if self.textTimer < 20 then
      love.graphics.print("PRESS START", 56, 144)
    end
  end
end

return titleState