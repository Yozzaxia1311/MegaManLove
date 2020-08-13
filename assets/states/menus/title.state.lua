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
end

function title:added()
  self:addToGroup("freezable")
end

function title:update()
  if self.s ~= 2 and (control.startPressed[1] or control.jumpPressed[1]) then
    self.s = 2
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
    --self.timer = self.timer + 1
    if self.timer == 400 then
      states.openRecord = "assets/demo.rd"
      megautils.add(fade, true, nil, nil, function(s)
          megautils.setMusicLock(true)
          control.drawDemoFunc = function()
              if control.demo and math.wrap(control.recPos, 0, 40) < 20 then
                love.graphics.setFont(mmFont)
                love.graphics.print("DEMO", view.w - 48, view.h - 16)
              end
            end
          control.returning = function()
              megautils.add(fade, true, nil, nil, function(s) megautils.resetGame("assets/states/menus/title.state.lua", false, true) end)
            end
          megautils.gotoState()
        end)
    end
    self.textTimer = math.wrap(self.textTimer+1, 0, 40)
    if control.startPressed[1] then
      megautils.stopMusic()
      self.drawText = false
      megautils.transitionToState("assets/states/menus/menu.state.tmx")
    end
  end
end

function title:draw()
  self.quad1:draw(self.tex, self.oneOff, self.transform.y)
  self.quad2:draw(self.tex, self.twoOff, self.transform.y+115)
  if self.s == 2 then
    love.graphics.print(self.text, self.textPos, 208)
    if self.textTimer < 20 then
      love.graphics.print("PRESS START", 56, 144)
    end
  end
end

return titleState