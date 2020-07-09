local stageSelectState = states.state:extend()

function stageSelectState:begin()
  megautils.loadResource("assets/misc/select.png", "mugshots")
  megautils.addMapEntity("assets/maps/stageSelect.tmx")
  megautils.add(stageSelect)
  megautils.add(fade, false, nil, nil, fade.remove)
  view.x, view.y = 0, 0
  if isWeb then
    megautils.playMusicWithSeperateIntroFile("assets/sfx/music/selectLoop.ogg", "assets/sfx/music/selectIntro.ogg")
  else
    megautils.playMusic("assets/sfx/music/select.wav", true, 80724, 315541)
  end
  love.graphics.setBackgroundColor(0, 0, 0, 1)
end

megautils.cleanFuncs.stageSelect = function()
  stageSelect = nil
  megautils.cleanFuncs.stageSelect = nil
end

stageSelect = entity:extend()

megautils.loadResource("assets/sfx/ascend.ogg", "selected")
megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove")
megautils.loadResource("protoGrid", 32, 32, 288, 176, 0, 96)

function stageSelect:new()
  stageSelect.super.new(self)
  self.transform.y = 8
  self.transform.x = 24
  self.blinkQuad = love.graphics.newQuad(0, 128, 48, 48, 288, 176)
  self.megaQuad = love.graphics.newQuad(32, 32, 32, 32, 288, 176)
  self.protoAnim = anim8.newAnimation(megautils.getResource("protoGrid")("1-4", 1), 1/28, "pauseAtStart")
  self.protoAnim:pause()
  self.bassQuad = love.graphics.newQuad(128, 32, 32, 32, 288, 176)
  self.rollQuad = love.graphics.newQuad(224, 32, 32, 32, 288, 176)
  --self.stickQuad = love.graphics.newQuad(32*2, 0, 32, 32, 288, 176)
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
  self.selected = false
  self.selectBlink = 0
end

function stageSelect:added()
  self:addToGroup("freezable")
end

function stageSelect:update(dt)
  self.protoAnim:update(defaultFramerate)
  
  local oldx, oldy = self.x, self.y
  
  if not self.stop then
    if control.leftPressed[1] then
      self.x = self.x-1
    elseif control.rightPressed[1] then
      self.x = self.x+1
    elseif control.upPressed[1] then
      self.y = self.y-1
    elseif control.downPressed[1] then
      self.y = self.y+1
    end
  end
  
  self.x = math.wrap(self.x, 0, 2)
  self.y = math.wrap(self.y, 0, 2)
  
  if oldx ~= self.x or oldy ~= self.y then
    megautils.playSound("cursorMove")
    local newx, newy = 0, 0
    if self.x == 0 and self.y == 0 then
      newx = 0
      newy = 0
    elseif self.x == 1 and self.y == 0 then
      newx = 1
      newy = 0
    elseif self.x == 2 and self.y == 0 then
      newx = 2
      newy = 0
    elseif self.x == 0 and self.y == 1 then
      newx = 0
      newy = 1
    elseif self.x == 1 and self.y == 1 then
      newx = 1
      newy = 1
    elseif self.x == 2 and self.y == 1 then
      newx = 2
      newy = 1
    elseif self.x == 0 and self.y == 2 then
      newx = 0
      newy = 2
    elseif self.x == 1 and self.y == 2 then
      newx = 1
      newy = 2
    elseif self.x == 2 and self.y == 2 then
      newx = 2
      newy = 2
    end
    self.megaQuad:setViewport(newx*32, newy*32, 32, 32)
    self.protoAnim:resume()
    self.bassQuad:setViewport(128+(newx*32), newy*32, 32, 32)
    self.rollQuad:setViewport(192+(newx*32), newy*32, 32, 32)
    self.timer = 0
  end
  
  if self.stop and self.selected then
    self.timer = self.timer + 1
    if self.timer == 6 then
      self.timer = 0
      self.selectBlink = self.selectBlink + 1
      if math.wrap(self.selectBlink, 0, 1) == 1 then
        love.graphics.setBackgroundColor(1, 1, 1, 1)
      else
        love.graphics.setBackgroundColor(0, 0, 0, 1)
      end
      if self.selectBlink == 12 then
        self.selected = false
        if self.x == 2 and self.y == 1 then
          if globals.defeats.stickMan then
            megautils.transitionToState("states/demo.state.lua")
          else
            globals.bossIntroBoss = "stick"
            megautils.transitionToState("states/bossintro.state.lua")
          end
        end
      end
    end
  elseif (control.startPressed[1] or control.jumpPressed[1]) and not self.stop then
    if self.x ~= 1 or self.y ~= 1 then
      self.stop = true
      self.selected = true
      self.timer = 0
      megautils.stopMusic()
      megautils.playSound("selected")
    end
  elseif control.selectPressed[1] and not self.stop then
    self.stop = true
    megautils.transitionToState("states/menu.state.lua")
    megautils.stopMusic()
  else
    self.timer = math.wrap(self.timer+1, 0, 14)
    self.blink = self.timer < 7
    self.transform.x = self.oldX + self.x*80
    self.transform.y = self.oldY + self.y*72
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
    if megautils.getPlayer(1) == "proto" then
      self.protoAnim:draw(self.tex, 112, 88)
    elseif megautils.getPlayer(1) == "bass" then
      love.graphics.draw(self.tex, self.bassQuad, 112, 88)
    elseif megautils.getPlayer(1) == "roll" then
      love.graphics.draw(self.tex, self.rollQuad, 112, 88)
    else
      love.graphics.draw(self.tex, self.megaQuad, 112, 88)
    end
    
    if not globals.defeats.stickMan then
      --love.graphics.draw(self.tex, self.stickQuad, 192, 88)
    end
  end --else
    --Draw Dr. Wily icon here
  --end
  if (self.blink and not self.stop) or self.selected then
    love.graphics.draw(self.tex, self.blinkQuad, self.transform.x, self.transform.y)
  end
end

return stageSelectState