timer = entity:extend()

function timer:new(time, func)
  timer.super.new(self)
  self.time = 0
  self.max = time
  self.func = func
  self:setLayer(-5)
  self.added = function(self)
    self:addToGroup("freezable")
  end
end

function timer:update(dt)
  self.time = math.min(self.time+1, self.max)
  if self.time == self.max then
    self.func(self)
  end
end

function timer.winCutscene(func)
  megautils.add(timer, 150, function(s)
    if not s.state then
      if globals.mainPlayer then
        s.timer = 0
        s.state = 0
        mmMusic.stopMusic()
        globals.mainPlayer:resetStates()
        globals.mainPlayer.velocity.velx = 0
        globals.mainPlayer.control = false
        globals.mainPlayer.doAnimation = false
        globals.mainPlayer.canSwitchWeapons.global = false
        if globals.mainPlayer.slide then
          globals.mainPlayer.slide = false
          globals.mainPlayer:slideToReg()
          globals.mainPlayer.curAnim = "idle"
        end
      end
    elseif s.state == 0 then
      globals.mainPlayer:phys()
      if globals.mainPlayer.ground then
        globals.mainPlayer.curAnim = "idle"
      else
        globals.mainPlayer.curAnim = "jump"
      end
      globals.mainPlayer:face(globals.mainPlayer.side)
      s.timer = math.min(s.timer+1, 60)
      if s.timer == 60 then
        s.state = 1
        s.timer = 0
        globals.mainPlayer.rise = true
        globals.mainPlayer.doAnimation = true
      end
    elseif s.state == 1 then
      s.timer = math.min(s.timer+1, 80)
      if s.timer == 80 then
        s.state = -1
        megautils.add(fade, true, nil, nil, func)
      end
    end
  end)
end

function timer.absorbCutscene(func, music)
  megautils.add(timer, 150, function(s)
      if not s.state then
        mmMusic.playFromFile(nil, music or "assets/sfx/music/win.ogg", nil, not music)
        if globals.mainPlayer then
          s.state = 0
          s.timer = 0
          s.to = (view.x+view.w/2)-globals.mainPlayer.collisionShape.w/2
          globals.mainPlayer:resetStates()
          globals.mainPlayer.control = false
          globals.mainPlayer.doAnimation = false
          globals.mainPlayer.canSwitchWeapons.global = false
          if not globals.mainPlayer.ground then
            globals.mainPlayer.curAnim = "jump"
          end
          globals.mainPlayer:face(globals.mainPlayer.side)
          globals.mainPlayer.animations[globals.mainPlayer.curAnim]:update(1/60)
        end
      elseif s.state == 0 then
        if globals.mainPlayer then
          s.state = 1
          globals.mainPlayer.velocity.velx = 0
        if globals.mainPlayer.slide then
          globals.mainPlayer.slide = false
          globals.mainPlayer:slideToReg()
          globals.mainPlayer.curAnim = "idle"
        end
          s.timer = 0
        end
      elseif s.state == 1 then
        s.timer = math.min(s.timer+1, 300)
        if s.timer == 300 then
          if not s.once then
            s.once = true
            globals.mainPlayer.side = (globals.mainPlayer.transform.x > s.to and -1 or 1)
          end
          globals.mainPlayer.velocity.velx = 1.3 * globals.mainPlayer.side
          if globals.mainPlayer.ground then
            globals.mainPlayer.curAnim = "run"
          elseif collision.checkSolid(self, globals.mainPlayer.side, 0) then
            globals.mainPlayer.curAnim = "jump"
            globals.mainPlayer.velocity.vely = globals.mainPlayer.jumpSpeed * (globals.mainPlayer.gravity >= 0 and 1 or -1)
            globals.mainPlayer:face(globals.mainPlayer.side)
          else
            globals.mainPlayer.curAnim = "jump"
          end
          if (globals.mainPlayer.side == -1 and globals.mainPlayer.transform.x < s.to) or
            (globals.mainPlayer.side == 1 and globals.mainPlayer.transform.x > s.to) then
            s.state = 2
            s.timer = 0
            globals.mainPlayer.velocity.velx = 0
            globals.mainPlayer.curAnim = "jump"
            globals.mainPlayer.velocity.vely = globals.mainPlayer.jumpSpeed * (globals.mainPlayer.gravity >= 0 and 1 or -1)
            globals.mainPlayer:face(globals.mainPlayer.side)
            return
          end
        else
          globals.mainPlayer.curAnim = "idle"
        end
        globals.mainPlayer.animations[globals.mainPlayer.curAnim]:update(1/60)
        globals.mainPlayer:phys()
        if not globals.mainPlayer.ground then
          globals.mainPlayer.curAnim = "jump"
        end
        globals.mainPlayer:face(globals.mainPlayer.side)
      elseif s.state == 2 then
        globals.mainPlayer.velocity:slowY(0.25)
        globals.mainPlayer:moveBy(globals.mainPlayer.velocity.velx, globals.mainPlayer.velocity.vely)
        if globals.mainPlayer.velocity.vely == 0 then
          megautils.add(absorb, globals.mainPlayer)
          s.state = 3
          s.timer = 0
        end
      elseif s.state == 3 then
        s.timer = math.min(s.timer+1, 230)
        if s.timer == 230 then
          globals.mainPlayer.rise = true
          globals.mainPlayer.doAnimation = true
          s.timer = 0
          s.state = 4
        end
      elseif s.state == 4 then
        s.timer = math.min(s.timer+1, 80)
        if s.timer == 80 then
          s.state = -1
          megautils.add(fade, true, nil, nil, func)
        end
      end
    end)
end
