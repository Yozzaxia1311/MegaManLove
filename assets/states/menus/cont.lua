local continueState = state:extend()

function continueState:begin()
  megautils.loadResource("assets/misc/cont.png", "cont")
  megautils.loadResource("assets/misc/menuSelect.png", "menuSelect")
  megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove")
  megautils.add(contPanels)
end

contPanels = basicEntity:extend()

contPanels.invisibleToHash = true

function contPanels:new()
  contPanels.super.new(self)
  self.tex = megautils.getResource("cont")
  self.quadOne = quad(0, 0, 176, 48)
  self.quadTwo = quad(0, 48, 160, 56)
  self.state = 0
  self.timer = 0
  if mmMusic._queue then
    self.mq = mmMusic._queue
    megautils.stopMusic()
  end
  megautils.playMusic("assets/sfx/mm5.nsf", nil, 18)
end

function contPanels:update()
  self.timer = math.min(self.timer+1, 199)
  if self.timer == 198 then
    self.state = 1
    megautils.add(contSelect)
    if self.mq then
      megautils.playMusic(unpack(self.mq))
      self.mq = nil
    end
  end
end

function contPanels:draw()
  if self.state == 1 then
    self.tex:draw(self.quadTwo, 48, 128)
  end
  self.tex:draw(self.quadOne, 40, 56)
end

contSelect = entity:extend()

function contSelect:new()
  contSelect.super.new(self)
  self.x = 64
  self.y = 144
  self.tex = megautils.getResource("menuSelect")
  self.pick = 0
  self.offY = self.y
  self.picked = false
  self:setLayer(2)
end

function contSelect:update()
  local old = self.pick
  if input.pressed.up1 then
    self.pick = math.wrap(self.pick-1, 0, 1)
  elseif input.pressed.down1 then
    self.pick = math.wrap(self.pick+1, 0, 1)
  end
  local touched = false
  if input.length(input.touchPressed) ~= 0 then
    for i = 0, 1 do
      local x, y, w, h = self.x + 8, self.offY + (i * 16), 96, 8
      y = y - 4
      h = h + 8
      if input.touchPressedOverlaps(x, y, w, h) then
        self.pick = i
        touched = true
      end
    end
  end
  if old ~= self.pick and not input.usingTouch then
    megautils.playSound("cursorMove")
  end
  if (input.pressed.start1 or input.pressed.jump1 or touched) and not self.picked then
    if self.pick == 1 then
      self.picked = true
      self.canDraw.global = false
      megautils.stopMusic()
      megautils.transitionToState(globals.gameOverContinueState)
      globals.gameOverContinueState = nil
    elseif self.pick == 0 then
      self.picked = true
      self.canDraw.global = false
      megautils.transitionToState(globals.menuState)
    end
  end
  self.y = self.offY + self.pick*16
end

function contSelect:draw()
  if not input.usingTouch then
    self.tex:draw(self.x, self.y)
  end
end

return continueState
