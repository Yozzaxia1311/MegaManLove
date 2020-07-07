timer = basicEntity:extend()

function timer:new(time, func)
  timer.super.new(self)
  self.time = 0
  self.max = time
  self.func = func
end

function timer:added()
  self:addToGroup("freezable")
end

function timer:update(dt)
  self.time = math.min(self.time+1, self.max)
  if self.time == self.max then
    if self.func then self.func(self) end
    return true
  end
end

function timer.winCutscene(func)
  megautils.add(timer, 150, function(s)
    if not s.state then
      if megaMan.mainPlayer then
        s.timer = 0
        s.state = 0
        megautils.stopMusic()
        megaMan.mainPlayer:resetStates()
        megaMan.mainPlayer.velocity.velx = 0
        megaMan.mainPlayer.canControl.global = false
        megaMan.mainPlayer.doAnimation = false
        megaMan.mainPlayer.canSwitchWeapons.global = false
        if megaMan.mainPlayer.slide then
          megaMan.mainPlayer.slide = false
          megaMan.mainPlayer:slideToReg()
          megaMan.mainPlayer.curAnim = "idle"
        end
      end
    elseif s.state == 0 then
      collision.doGrav(megaMan.mainPlayer)
      megaMan.mainPlayer:phys()
      if megaMan.mainPlayer.ground then
        megaMan.mainPlayer.curAnim = "idle"
      else
        megaMan.mainPlayer.curAnim = "jump"
      end
      megaMan.mainPlayer:face(megaMan.mainPlayer.side)
      s.timer = math.min(s.timer+1, 60)
      if s.timer == 60 then
        s.state = 1
        s.timer = 0
        megaMan.mainPlayer.rise = true
        megaMan.mainPlayer.doAnimation = true
      end
    elseif s.state == 1 then
      s.timer = math.min(s.timer+1, 80)
      if s.timer == 80 then
        s.state = -1
        banner.colorOne = megaMan.weaponHandler[1].colorOne[0]
        banner.colorTwo = megaMan.weaponHandler[1].colorTwo[0]
        megautils.add(fade, true, nil, nil, func)
      end
    end
  end)
end

function timer.absorbCutscene(func, music)
  megautils.add(timer, 150, function(s)
      if not s.state then
        megautils.playMusic(music or "assets/sfx/music/win.ogg")
        if megaMan.mainPlayer then
          s.state = 0
          s.timer = 0
          s.to = (view.x+view.w/2)-megaMan.mainPlayer.collisionShape.w/2
          megaMan.mainPlayer:resetStates()
          megaMan.mainPlayer.canControl.global = false
          megaMan.mainPlayer.doAnimation = false
          megaMan.mainPlayer.canSwitchWeapons.global = false
          if not megaMan.mainPlayer.ground then
            megaMan.mainPlayer.curAnim = "jump"
          end
          megaMan.mainPlayer:face(megaMan.mainPlayer.side)
          megaMan.mainPlayer.animations[megaMan.mainPlayer.curAnim]:update(defaultFramerate)
        end
      elseif s.state == 0 then
        if megaMan.mainPlayer then
          s.state = 1
          megaMan.mainPlayer.velocity.velx = 0
        if megaMan.mainPlayer.slide then
          megaMan.mainPlayer.slide = false
          megaMan.mainPlayer:slideToReg()
          megaMan.mainPlayer.curAnim = "idle"
        end
          s.timer = 0
        end
      elseif s.state == 1 then
        s.timer = math.min(s.timer+1, 300)
        if s.timer == 300 then
          if not s.once then
            s.once = true
            megaMan.mainPlayer.side = (megaMan.mainPlayer.transform.x > s.to and -1 or 1)
          end
          megaMan.mainPlayer.velocity.velx = 1.3 * megaMan.mainPlayer.side
          if megaMan.mainPlayer.ground then
            megaMan.mainPlayer.curAnim = "run"
          elseif collision.checkSolid(self, megaMan.mainPlayer.side, 0) then
            megaMan.mainPlayer.curAnim = "jump"
            megaMan.mainPlayer.velocity.vely = megaMan.mainPlayer.jumpSpeed * (megaMan.mainPlayer.gravity >= 0 and 1 or -1)
            megaMan.mainPlayer:face(megaMan.mainPlayer.side)
          else
            megaMan.mainPlayer.curAnim = "jump"
          end
          if (megaMan.mainPlayer.side == -1 and megaMan.mainPlayer.transform.x < s.to) or
            (megaMan.mainPlayer.side == 1 and megaMan.mainPlayer.transform.x > s.to) then
            s.state = 2
            s.timer = 0
            megaMan.mainPlayer.velocity.velx = 0
            megaMan.mainPlayer.curAnim = "jump"
            megaMan.mainPlayer.velocity.vely = megaMan.mainPlayer.jumpSpeed * (megaMan.mainPlayer.gravity >= 0 and 1 or -1)
            megaMan.mainPlayer:face(megaMan.mainPlayer.side)
            return
          end
        else
          megaMan.mainPlayer.curAnim = "idle"
        end
        megaMan.mainPlayer.animations[megaMan.mainPlayer.curAnim]:update(defaultFramerate)
        collision.doGrav(megaMan.mainPlayer)
        megaMan.mainPlayer:phys()
        if not megaMan.mainPlayer.ground then
          megaMan.mainPlayer.curAnim = "jump"
        end
        megaMan.mainPlayer:face(megaMan.mainPlayer.side)
      elseif s.state == 2 then
        megaMan.mainPlayer.velocity:slowY(0.25)
        megaMan.mainPlayer:moveBy(megaMan.mainPlayer.velocity.velx, megaMan.mainPlayer.velocity.vely)
        if megaMan.mainPlayer.velocity.vely == 0 then
          megautils.add(absorb, megaMan.mainPlayer)
          s.state = 3
          s.timer = 0
        end
      elseif s.state == 3 then
        s.timer = math.min(s.timer+1, 230)
        if s.timer == 230 then
          megaMan.mainPlayer.rise = true
          megaMan.mainPlayer.doAnimation = true
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
