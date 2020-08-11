local stageSelectState = state:extend()

function stageSelectState:begin()
  megautils.loadResource("assets/misc/select.png", "mugshots")
  megautils.add(stageSelect)
  love.graphics.setBackgroundColor(0, 0, 0, 1)
end

stageSelect = basicEntity:extend()

megautils.loadResource("assets/sfx/ascend.ogg", "selected")
megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove")
megautils.loadResource(0, 0, 63, 62, 2, "megaManGrid")

function stageSelect:new()
  stageSelect.super.new(self)
  self.transform.y = 8
  self.transform.x = 24
  self.blinkQuad = quad(0, 128, 48, 48)
  
  self.anims = animationSet()
  self.anims:add("0-0", megautils.newAnimation("megaManGrid", {1, 1}))
  self.anims:add("1-0", megautils.newAnimation("megaManGrid", {7, 6}))
  self.anims:add("2-0", megautils.newAnimation("megaManGrid", {8, 6}))
  self.anims:add("0-1", megautils.newAnimation("megaManGrid", {6, 7}))
  self.anims:add("1-1", megautils.newAnimation("megaManGrid", {7, 7}))
  self.anims:add("2-1", megautils.newAnimation("megaManGrid", {8, 7}))
  self.anims:add("0-2", megautils.newAnimation("megaManGrid", {6, 8}))
  self.anims:add("1-2", megautils.newAnimation("megaManGrid", {7, 8}))
  self.anims:add("2-2", megautils.newAnimation("megaManGrid", {8, 8}))
  self.anims:add("proto", megautils.newAnimation("megaManGrid", {7, 7}))
  self.anims:add("protoGlint", megautils.newAnimation("megaManGrid", {"6-8", 6}, 1/28))
  
  if megaMan.getSkin(1).traits.protoMug then
    self.anims:set("proto")
    self.anims:pause()
  else
    self.anims:set("1-1")
  end
  
  self.wilyQuad = quad(320, 32, 32, 32)
  
  self.quad11 = quad(288, 0, 32, 32)
  self.quad21 = quad(320, 0, 32, 32)
  self.quad31 = quad(352, 0, 32, 32)
  
  self.quad12 = quad(288, 32, 32, 32)
  self.quad32 = quad(352, 32, 32, 32)
  
  self.quad13 = quad(288, 64, 32, 32)
  self.quad23 = quad(320, 64, 32, 32)
  self.quad33 = quad(352, 64, 32, 32)
  
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

function stageSelect:update()
  self.anims:update(defaultFramerate)
  
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
  
  if self.anims.current == "protoGlint" and self.anims:looped() then
    self.anims:set("proto")
  end
  
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
    if megaMan.getSkin(1).traits.protoMug then
      self.anims:set("protoGlint")
    else
      self.anims:set(tostring(self.x) .. "-" .. tostring(self.y))
    end
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
            megautils.transitionToState("assets/states/stages/demo.stage.tmx")
          else
            globals.bossIntroBoss = "entities/demo/stickman.lua"
            megautils.transitionToState("assets/states/menus/bossintro.state.lua")
          end
        else
          error("Slot " .. tostring(self.x) .. ", " .. tostring(self.y) .. " doesn't lead anywhere.")
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
    megautils.transitionToState("assets/states/menus/menu.state.tmx")
    megautils.stopMusic()
  else
    self.timer = math.wrap(self.timer+1, 0, 14)
    self.blink = self.timer < 7
    self.transform.x = self.oldX + self.x*80
    self.transform.y = self.oldY + self.y*72
  end
end

function stageSelect:draw()
  if not checkFalse(globals.defeats) then
    self.anims:draw(megaMan.getSkin(1).texture, 112, 88, 0, 1, 1, 16, 15)
    
    if false then -- For select slot 1, 1
      self.quad11:draw(self.tex, self.oldX+(1*56), self.oldY+(1*40))
    end
    if false then -- For select slot 2, 1
      self.quad21:draw(self.tex, self.oldX+(2*56), self.oldY+(1*40))
    end
    if false then -- For select slot 3, 1
      self.quad31:draw(self.tex, self.oldX+(3*56), self.oldY+(1*40))
    end
    if false then -- For select slot 1, 2
      self.quad12:draw(self.tex, self.oldX+(1*56), self.oldY+(2*40))
    end
    if not globals.defeats.stickMan then -- For select slot 3, 2
      self.quad32:draw(self.tex, self.oldX+(3*56), self.oldY+(2*40))
    end
    if false then -- For select slot 1, 3
      self.quad13:draw(self.tex, self.oldX+(1*56), self.oldY+(3*40))
    end
    if false then -- For select slot 2, 3
      self.quad23:draw(self.tex, self.oldX+(2*56), self.oldY+(3*40))
    end
    if false then -- For select slot 3, 3
      self.quad33:draw(self.tex, self.oldX+(3*56), self.oldY+(3*40))
    end
  else
    self.wilyQuad:draw(self.tex, 112, 88)
  end
  if (self.blink and not self.stop) or self.selected then
    self.blinkQuad:draw(self.tex, self.transform.x, self.transform.y)
  end
end

return stageSelectState