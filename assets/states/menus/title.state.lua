local titleState = state:extend()

function titleState:begin()
  megautils.add(title)
  megautils.setMusicLock(false)
end

megautils.loadResource("assets/misc/title.png", "title")

title = basicEntity:extend()

title.invisibleToHash = true

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
    --self.timer = self.timer + 1
    self.textTimer = math.wrap(self.textTimer+1, 0, 40)
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
    elseif control.startPressed[1] then
      megautils.stopMusic()
      self.drawText = false
      megautils.transitionToState(globals.menuState)
    end
  end
end

function title:draw()
  self.tex:draw(self.quad1, self.oneOff, self.y)
  self.tex:draw(self.quad2, self.twoOff, self.y+115)
  if self.s == 3 then
    love.graphics.print(self.text, self.textPos, 208)
    if self.textTimer < 20 then
      love.graphics.print("PRESS START", 56, 144)
    end
  end
end

return titleState