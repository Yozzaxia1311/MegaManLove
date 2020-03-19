local stageSelectState = states.state:extend()

function stageSelectState:begin()
  megautils.loadResource("assets/misc/select.png", "mugshots")
  megautils.loadStage(self, "assets/maps/stageSelect.tmx")
  megautils.add(stageSelect)
  megautils.add(fade, false, nil, nil, fade.remove)
  view.x, view.y = 0, 0
  megautils.playMusic("assets/sfx/music/selectLoop.ogg", "assets/sfx/music/selectIntro.ogg")
end

function stageSelectState:update(dt)
  megautils.update(self, dt)
end

function stageSelectState:stop()
  megautils.unload()
end

function stageSelectState:draw()
  megautils.draw(self)
end

megautils.cleanFuncs.stageSelect = function()
  stageSelect = nil
  megautils.cleanFuncs.stageSelect = nil
end

stageSelect = entity:extend()

function stageSelect:new()
  stageSelect.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.transform.y = 8
  self.transform.x = 24
  self.quad = love.graphics.newQuad(81, 296, 15, 7, 96, 303)
  self.megaQuad = love.graphics.newQuad(0, 0, 32, 32, 96, 303)
  self.protoQuad = love.graphics.newQuad(0, 160, 32, 32, 96, 303)
  self.rollQuad = love.graphics.newQuad(0, 192, 32, 32, 96, 303)
  self.bassQuad = love.graphics.newQuad(0, 224, 32, 32, 96, 303)
  self.stickQuad = love.graphics.newQuad(32*2, 0, 32, 32, 96, 303)
  self.tex = megautils.getResource("mugshots")
  self.timer = 0
  self.oldX = self.transform.x
  self.oldY = self.transform.y
  self.oldNewX = 0
  self.oldNewY = 0
  self.x = 1
  self.y = 1
  self.transform.x = self.oldX + self.x*80
  self.transform.y = self.oldY + self.y*80
  self.blink = false
  self.stop = false
end

function stageSelect:update(dt)
  local oldx, oldy = self.x, self.y
  
  if control.leftPressed[1] then
    self.x = self.x-1
  elseif control.rightPressed[1] then
    self.x = self.x+1
  elseif control.upPressed[1] then
    self.y = self.y-1
  elseif control.downPressed[1] then
    self.y = self.y+1
  end
  
  self.x = math.wrap(self.x, 0, 2)
  self.y = math.wrap(self.y, 0, 2)
  
  if oldx ~= self.x or oldy ~= self.y then
    megautils.playSound("cursorMove")
    local newx, newy = 0, 0
    if self.x == 0 and self.y == 0 then
      newx = 1
      newy = 0
    elseif self.x == 1 and self.y == 0 then
      newx = 0
      newy = 1
    elseif self.x == 2 and self.y == 0 then
      newx = 1
      newy = 1
    elseif self.x == 0 and self.y == 1 then
      newx = 0
      newy = 2
    elseif self.x == 1 and self.y == 1 then
      newx = 0
      newy = 0
    elseif self.x == 2 and self.y == 1 then
      newx = 1
      newy = 2
    elseif self.x == 0 and self.y == 2 then
      newx = 0
      newy = 3
    elseif self.x == 1 and self.y == 2 then
      newx = 1
      newy = 3
    elseif self.x == 2 and self.y == 2 then
      newx = 0
      newy = 4
    end
    self.megaQuad:setViewport(newx*32, newy*32, 32, 32)
  end
  
  self.timer = math.wrap(self.timer+1, 0, 14)
  self.blink = self.timer < 7
  self.transform.x = self.oldX + self.x*80
  self.transform.y = self.oldY + self.y*72
  
  if (control.startPressed[1] or control.jumpPressed[1]) and not self.stop then
    if self.x == 2 and self.y == 1 then
      megautils.stopMusic()
      megautils.playSound("selected")
      megautils.add(fade, false, 4, {255, 255, 255}, function(s)
        if globals.defeats.stickMan then
          megautils.gotoState("states/demo.state.lua")
        else
          globals.bossIntroBoss = "stick"
          megautils.gotoState("states/bossintro.state.lua")
        end
        megautils.remove(s, true)
      end)
      self.stop = true
    end
  elseif control.selectPressed[1] and not self.stop then
    self.stop = true
    megautils.gotoState("states/menu.state.lua")
    megautils.stopMusic()
  end
end

function stageSelect:allDefeated()
  for k, v in pairs(globals.defeats) do
    if not v then
      return false
    end
  end
  return true
end

function stageSelect:draw()
  if not self:allDefeated() then
    if globals.player[1] == "proto" then
      love.graphics.draw(self.tex, self.protoQuad, 112, 88)
    elseif globals.player[1] == "bass" then
      love.graphics.draw(self.tex, self.bassQuad, 112, 88)
    elseif globals.player[1] == "roll" then
      love.graphics.draw(self.tex, self.rollQuad, 112, 88)
    else
      love.graphics.draw(self.tex, self.megaQuad, 112, 88)
    end
  end --else
    --Draw Dr. Wily icon here
  --end
  if not globals.defeats.stickMan then
    love.graphics.draw(self.tex, self.stickQuad, 192, 88)
  end
  if self.blink and not self.stop then
    love.graphics.draw(self.tex, self.quad, self.transform.x, self.transform.y)
    love.graphics.draw(self.tex, self.quad, self.transform.x+32, self.transform.y)
    love.graphics.draw(self.tex, self.quad, self.transform.x, self.transform.y+40)
    love.graphics.draw(self.tex, self.quad, self.transform.x+32, self.transform.y+40)
  end
end

return stageSelectState