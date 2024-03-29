local titleState = state:extend()

function titleState:begin()
  entities.add(title)
end

loader.load("assets/misc/title.png")

title = basicEntity:extend()

title.invisibleToHash = true

function title:new()
  title.super.new(self)
  self.tex = loader.get("assets/misc/title.png")
  self.textTimer = 0
  self.drawText = false
  self.cont = false
  self.text = "name + year"
  self.textPos = 128-(self.text:len()*8)/2
  self.startText = "PRESS START"
  self.startTextT = "TOUCH SCREEN"
  self.whichText = true
  self.timer = 0
  self.s = 0
  self.quad1 = quad(0, 0, 256, 115)
  self.quad2 = quad(0, 115, 256, 109)
  self.oneOff = 256
  self.twoOff = -256
end

function title:update()
  if self.s < 2 and (input.pressed.start1 or input.pressed.jump1 or input.length(input.touchPressed) ~= 0) then
    self.s = 3
    self.oneOff = 0
    self.twoOff = 0
    self.drawText = true
    music.play("assets/sfx/mm5.nsf", nil, 73)
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
      music.play("assets/sfx/mm5.nsf", nil, 73)
    end
  elseif self.s == 2 then
    self.s = 3
    self.drawText = true
  elseif self.s == 3 then
    --self.timer = self.timer + 1
    self.textTimer = math.wrap(self.textTimer+1, 0, 40)
    if self.textTimer == 21 then
      if input.usingTouch then
        self.whichText = not self.whichText
      else
        self.whichText = true
      end
    end
    if self.timer == 400 then
      states.openRecord = "assets/demo.rd"
      entities.add(fade, true, nil, nil, function(s)
          music.setLock(true)
          record.drawDemoFunc = function()
              if record.demo and math.wrap(record.recPos, 0, 40) < 20 then
                love.graphics.setFont(mmFont)
                love.graphics.print("DEMO", view.w - 48, view.h - 16)
              end
            end
          record.returning = function()
              entities.add(fade, true, nil, nil, function(s)
                  megautils.resetGame("assets/states/menus/title.state.lua", true)
                  music.setLock(false)
                end)
            end
          states.setq()
        end)
    elseif input.pressed.start1 or input.length(input.touchPressed) ~= 0 then
      music.stop()
      self.drawText = false
      states.fadeToState(globals.menuState)
    end
  end
end

function title:draw()
  self.tex:draw(self.quad1, self.oneOff, self.y)
  self.tex:draw(self.quad2, self.twoOff, self.y+115)
  if self.s == 3 then
    love.graphics.print(self.text, self.textPos, 208)
    if self.textTimer < 20 and self.drawText then
      love.graphics.print(self.whichText and self.startText or self.startTextT, 56, 144)
    end
  end
end

return titleState