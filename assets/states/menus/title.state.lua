local titleState = state:extend()

function titleState:begin()
  megautils.loadResource("assets/misc/title.png", "title")
  megautils.add(title)
  megautils.setMusicLock(false)
end

title = basicEntity:extend()

function title:new()
  title.super.new(self)
  self.transform.x = 37
  self.transform.y = 256
  self.tex = megautils.getResource("title")
  self.once = false
  self.textTimer = 0
  self.drawText = false
  self.cont = false
  self.text = "name + year"
  self.textPos = 128-(self.text:len()*8)/2
  self.timer = 0
end

function title:added()
  self:addToGroup("freezable")
end

function title:update()
  self.transform.y = math.max(self.transform.y-8, 32)
  if self.transform.y == 32 and not self.once then
    self.once = true
    self.drawText = true
    megautils.playMusic("assets/sfx/music/title.ogg")
  end
  if self.drawText then
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
    if control.startDown[1] then
      megautils.stopMusic()
      self.drawText = false
      megautils.transitionToState("assets/states/menus/menu.state.tmx")
    end
  end
end

function title:draw()
  if self.drawText then
    love.graphics.setFont(mmFont)
    love.graphics.print(self.text, self.textPos, 208)
    if self.textTimer < 20 then
      love.graphics.print("PRESS START", 84, 124)
    end
  end
  love.graphics.draw(self.tex, self.transform.x, self.transform.y)
end

return titleState