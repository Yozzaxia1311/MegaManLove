local titleState = states.state:extend()

function titleState:begin()
  megautils.loadResource("assets/misc/title.png", "title")
  megautils.add(title)
  megautils.setMusicLock(false)
end

function titleState:update(dt)
  megautils.update(self, dt)
end

function titleState:stop()
  megautils.unload()
end

function titleState:draw()
  megautils.draw(self)
end

megautils.cleanFuncs.title = function()
  title = nil
  megautils.cleanFuncs.title = nil
end

title = entity:extend()

function title:new()
  title.super.new(self)
  self.transform.y = 256
  self.transform.x = 37
  self.tex = megautils.getResource("title")
  self.once = false
  self.textTimer = 0
  self.drawText = false
  self.cont = false
  self.text = "name + year"
  self.textPos = 128-(self.text:len()*8)/2
  self.timer = 0
  self:addToGroup("freezable")
end

function title:update(dt)
  self.transform.y = math.max(self.transform.y-8, 32)
  if self.transform.y == 32 and not self.once then
    self.once = true
    self.drawText = true
    megautils.playMusic(nil, "assets/sfx/music/title.ogg")
  end
  if self.drawText then
    self.timer = self.timer + 1
    if self.timer == 400 then
      states.openRecord = "assets/demo.rd"
      megautils.add(fade, true, nil, nil, function(s)
          megautils.setMusicLock(true)
          control.drawDemoFunc = function()
              if control.demo and math.wrap(control.recPos, 0, 40) < 20 then
                love.graphics.setFont(mmFont)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.print("demo", view.w - 48, view.h - 16)
              end
            end
          control.returning = function()
              megautils.add(fade, true, nil, nil, function(s) megautils.resetGame("states/title.state.lua", false, true) end)
            end
          states.set()
        end)
    end
    self.textTimer = math.wrap(self.textTimer+1, 0, 40)
    if control.startDown[1] then
      megautils.stopMusic()
      self.drawText = false
      megautils.gotoState("states/menu.state.lua")
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

return titleState