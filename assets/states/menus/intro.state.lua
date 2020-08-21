local introState = state:extend()

function introState:begin()
  self.lastW = view.w
  self.lastH = view.h
  self.lastS = view.scale
  view.init(640, 480, 1)
  cscreen.init(640, 480)
  self.video = love.graphics.newVideo("assets/misc/intro.ogv")
  self.video:play()
end

function introState:update(dt)
  introState.super.update(self, dt)
  if not self.once and (not self.video:isPlaying() or control.anyPressed) then
    self.once = true
    self.video:pause()
    cscreen.setFade(1)
    view.init(self.lastW, self.lastH, self.lastS)
    cscreen.init(view.w*view.scale, view.h*view.scale)
    megautils.transitionToState(globals.titleState)
  end
end

function introState:draw()
  introState.super.draw(self)
  love.graphics.draw(self.video)
end

return introState