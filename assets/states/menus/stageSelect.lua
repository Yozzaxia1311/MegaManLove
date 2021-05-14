local stageSelectState = state:extend()

function stageSelectState:begin()
  megautils.add(stageSelect)
  love.graphics.setBackgroundColor(0, 0, 0, 1)
end

megautils.loadResource("assets/misc/select.png", "mugshots")
megautils.loadResource("assets/sfx/ascend.ogg", "selected")
megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove")
megautils.loadResource(0, 0, 63, 62, 2, "megaManGrid")

stageSelect = basicEntity:extend()

stageSelect.invisibleToHash = true

function stageSelect:new()
  stageSelect.super.new(self)
  self.x = 24
  self.y = 24
  
  self.blinkQuad = quad(0, 32, 48, 48)
  
  self.anims = animationSet()
  self.anims:add("0-0", animation("megaManGrid", {6, 6}))
  self.anims:add("1-0", animation("megaManGrid", {7, 6}))
  self.anims:add("2-0", animation("megaManGrid", {8, 6}))
  self.anims:add("0-1", animation("megaManGrid", {6, 7}))
  self.anims:add("1-1", animation("megaManGrid", {7, 7}))
  self.anims:add("2-1", animation("megaManGrid", {8, 7}))
  self.anims:add("0-2", animation("megaManGrid", {6, 8}))
  self.anims:add("1-2", animation("megaManGrid", {7, 8}))
  self.anims:add("2-2", animation("megaManGrid", {8, 8}))
  self.anims:add("proto", animation("megaManGrid", {7, 7}))
  self.anims:add("protoGlint", animation("megaManGrid", {"6-8", 6}, 1/28))
  
  if megaMan.getSkin(1).traits.protoMug then
    self.anims:set("proto")
    self.anims:pause()
  else
    self.anims:set("1-1")
  end
  
  self.wilyQuad = quad(0, 0, 32, 32)
  
  self.tex = megautils.getResource("mugshots")
  self.timer = 0
  self.oldX = self.x
  self.oldY = self.y
  self.sx = 1
  self.sy = 1
  self.x = self.oldX + self.sx*80
  self.y = self.oldY + self.sy*80
  self.blink = false
  self.stop = false
  self.selected = false
  self.selectBlink = 0
  
  self.slots = {}
  self.images = {}
  for i = 1, 9 do
    local v = globals.robotMasterEntities[i]
    if v then
      if type(v) == "function" then
        self.slots[i] = v
      else
        self.slots[i] = megautils.runFile(v)()
        if self.slots[i].mugshotPath then
          self.images[i] = imageWrapper(self.slots[i].mugshotPath)
        end
      end
    end
  end
end

function stageSelect:begin()
  self:updateMap()
end

function stageSelect:updateMap()
  if megautils.groups().map then
    for _, v in ipairs(megautils.groups().map) do
      if input.usingTouch then
        v:getLayerByName("start").visible = false
        v:getLayerByName("touch").visible = true
      else
        v:getLayerByName("start").visible = true
        v:getLayerByName("touch").visible = false
      end
    end
  end
end

function stageSelect:removed()
  love.graphics.setBackgroundColor(0, 0, 0, 1)
  for i=1, 9 do
    if self.images[i] then
      self.images[i]:release()
    end
  end
end

function stageSelect:update()
  self.anims:update(1/60)
  
  local oldx, oldy = self.sx, self.sy
  local touched = false
  
  if not self.stop then
    if input.pressed.left1 then
      self.sx = self.sx-1
    elseif input.pressed.right1 then
      self.sx = self.sx+1
    elseif input.pressed.up1 then
      self.sy = self.sy-1
    elseif input.pressed.down1 then
      self.sy = self.sy+1
    end
    
    if input.length(input.touchPressed) ~= 0 then
      for x=0, 2 do
        for y=0, 2 do
          if input.touchPressedOverlaps(32+(x*81), 32+(y*64), 48, 48) then
            self.sx = x
            self.sy = y
            touched = true
          end
        end
      end
    end
  end
  
  self.sx = math.wrap(self.sx, 0, 2)
  self.sy = math.wrap(self.sy, 0, 2)
  
  if self.anims.current == "protoGlint" and self.anims:looped() then
    self.anims:set("proto")
  end
  
  if oldx ~= self.sx or oldy ~= self.sy then
    if not input.usingTouch then
      megautils.playSound("cursorMove")
    end
    local newx, newy = 0, 0
    if self.sx == 0 and self.sy == 0 then
      newx = 0
      newy = 0
    elseif self.sx == 1 and self.sy == 0 then
      newx = 1
      newy = 0
    elseif self.sx == 2 and self.sy == 0 then
      newx = 2
      newy = 0
    elseif self.sx == 0 and self.sy == 1 then
      newx = 0
      newy = 1
    elseif self.sx == 1 and self.sy == 1 then
      newx = 1
      newy = 1
    elseif self.sx == 2 and self.sy == 1 then
      newx = 2
      newy = 1
    elseif self.sx == 0 and self.sy == 2 then
      newx = 0
      newy = 2
    elseif self.sx == 1 and self.sy == 2 then
      newx = 1
      newy = 2
    elseif self.sx == 2 and self.sy == 2 then
      newx = 2
      newy = 2
    end
    if megaMan.getSkin(1).traits.protoMug then
      self.anims:set("protoGlint")
    else
      self.anims:set(tostring(self.sx) .. "-" .. tostring(self.sy))
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
        local pick = 1
        
        if self.sx == 0 and self.sy == 0 then
          pick = 1
        elseif self.sx == 1 and self.sy == 0 then
          pick = 2
        elseif self.sx == 2 and self.sy == 0 then
          pick = 3
        elseif self.sx == 0 and self.sy == 1 then
          pick = 4
        elseif self.sx == 1 and self.sy == 1 then
          pick = 5
        elseif self.sx == 2 and self.sy == 1 then
          pick = 6
        elseif self.sx == 0 and self.sy == 2 then
          pick = 7
        elseif self.sx == 1 and self.sy == 2 then
          pick = 8
        elseif self.sx == 2 and self.sy == 2 then
          pick = 9
        end
        
        if not self.slots[pick] then
          error("Slot " .. tostring(self.sx) .. ", " .. tostring(self.sy) .. " doesn't lead anywhere.")
        end
        
        if type(self.slots[pick]) == "function" then
          megautils.add(fade, true, nil, nil, function(f)
              f._func()
              megautils.removeq(f)
            end)._func = self.slots[pick]
        else
          if globals.defeats[self.slots[pick].defeatSlot] then
            megautils.transitionToState(self.slots[pick].stageState)
          else
            globals.bossIntroBoss = globals.robotMasterEntities[pick]
            megautils.transitionToState("assets/states/menus/bossintro.state.lua")
          end
        end
      end
    end
  elseif (input.pressed.start1 or input.pressed.jump1 or touched) and not self.stop then
    if self.sx ~= 1 or self.sy ~= 1 or self:checkRequirements() then
      self.stop = true
      self.selected = true
      self.timer = 0
      self.x = self.oldX + self.sx*80
      self.y = self.oldY + self.sy*64
      megautils.stopMusic()
      megautils.playSound("selected")
    end
  elseif (input.pressed.select1 or input.touchPressedOverlaps(8 - 4, (26 * 8) - 4, 32 + 8, 16 + 8)) and not self.stop then
    self.stop = true
    megautils.transitionToState(globals.menuState)
    megautils.stopMusic()
  else
    self.timer = math.wrap(self.timer+1, 0, 14)
    self.blink = self.timer < 7
    self.x = self.oldX + self.sx*80
    self.y = self.oldY + self.sy*64
  end
  
  self:updateMap()
end

function stageSelect:checkRequirements()
  for _, v in pairs(globals.defeatRequirementsForWily) do
    if not globals.defeats[v] then
      return false
    end
  end
  
  return true
end

function stageSelect:draw()
  if not self:checkRequirements() then
    megaMan.getSkin(1).texture:draw(self.anims, 32+(1*81), 32+(1*64), 0, 1, 1, 16, 15)
    
    for x=0, 2 do
      for y=0, 2 do
        local i = 1
        
        if x == 0 and y == 0 then
          i = 1
        elseif x == 1 and y == 0 then
          i = 2
        elseif x == 2 and y == 0 then
          i = 3
        elseif x == 0 and y == 1 then
          i = 4
        elseif x == 1 and y == 1 then
          i = 5
        elseif x == 2 and y == 1 then
          i = 6
        elseif x == 0 and y == 2 then
          i = 7
        elseif x == 1 and y == 2 then
          i = 8
        elseif x == 2 and y == 2 then
          i = 9
        end
        
        if i ~= 5 and globals.robotMasterEntities[i] and self.slots[i] and
          self.images[i] and not globals.defeats[self.slots[i].defeatSlot] then
          self.images[i]:draw(32+(x*81), 32+(y*64))
        end
      end
    end
  else
    self.tex:draw(self.wilyQuad, 32+(1*81), 32+(1*64))
  end
  if (self.blink and not self.stop) or self.selected then
    self.tex:draw(self.blinkQuad, self.x, self.y)
  end
end

return stageSelectState