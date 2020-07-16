local continueState = states.state:extend()

function continueState:begin()
  megautils.loadResource("assets/misc/cont.png", "cont")
  megautils.loadResource("assets/misc/menuSelect.png", "menuSelect")
  megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove")
  megautils.add(contPanels)
end

megautils.cleanFuncs.gameOver = function()
  contPanels = nil
  globals.gameOverContinueState = nil
  megautils.cleanFuncs.gameOver = nil
end

contPanels = entity:extend()

function contPanels:new()
  contPanels.super.new(self)
  self.tex = megautils.getResource("cont")
  self.quadOne = quad(0, 0, 176, 48)
  self.quadTwo = quad(0, 48, 160, 56)
  self.state = 0
  self.timer = 0
end

function contPanels:begin()
  self:addToGroup("freezable")
end

function contPanels:update(dt)
  self.timer = math.min(self.timer+1, 199)
  if self.timer == 198 then
    self.state = 1
    megautils.add(contSelect)
    megautils.playMusic("assets/sfx/music/menu.ogg", true)
  end
end

function contPanels:draw()
  if self.state == 1 then
    self.quadTwo:draw(self.tex, 48, 128)
  end
  self.quadOne:draw(self.tex, 40, 56)
end

contSelect = entity:extend()

function contSelect:new()
  contSelect.super.new(self)
  self.transform.x = 56
  self.transform.y = 144
  self.tex = megautils.getResource("menuSelect")
  self.pick = 0
  self.offY = self.transform.y
  self.picked = false
  self:setLayer(2)
end

function contSelect:update(dt)
  local old = self.pick
  if control.upPressed[1] then
    self.pick = math.wrap(self.pick-1, 0, 1)
  elseif control.downPressed[1] then
    self.pick = math.wrap(self.pick+1, 0, 1)
  end
  if old ~= self.pick then
    megautils.playSound("cursorMove")
  end
  if (control.jumpPressed[1] or control.startPressed[1]) and not self.picked then
    if self.pick == 1 then
      self.picked = true
      self.canDraw.global = false
      megautils.stopMusic()
      megautils.transitionToState(globals.gameOverContinueState)
    elseif self.pick == 0 then
      self.picked = true
      self.canDraw.global = false
      megautils.transitionToState("assets/states/menus/menu.state.tmx")
    end
  end
  self.transform.y = self.offY + self.pick*16
end

function contSelect:draw()
  love.graphics.draw(self.tex, self.transform.x, self.transform.y)
end

return continueState