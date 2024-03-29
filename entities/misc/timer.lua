timer = basicEntity:extend()

timer.autoClean = false
timer.invisibleToHash = true

function timer:new(time, func)
  timer.super.new(self)
  self.time = 0
  self.max = time
  self.func = func
end

function timer:update(dt)
  self.time = math.min(self.time+1, self.max)
  if self.time == self.max then
    if self.func then self.func(self) end
    return true
  end
end

function timer.winCutscene(func)
  entities.add(timer, 100, function(s)
    if not s.state then
      if megaMan.mainPlayer then
        s.timer = 0
        s.state = 1
        music.stop()
        megaMan.mainPlayer:resetStates()
        megaMan.mainPlayer.velX = 0
        megaMan.mainPlayer.canControl.global = false
        megaMan.mainPlayer.doAnimation = false
        megaMan.mainPlayer.canSwitchWeapons.global = false
        if megaMan.mainPlayer.ground then
          megaMan.mainPlayer.anims:set("idle")
        else
          megaMan.mainPlayer.anims:set("jump")
        end
      end
      megautils.removePlayerShots()
    elseif s.state == 1 then
      if megaMan.mainPlayer.ground then
        megaMan.mainPlayer.anims:set("idle")
      else
        megaMan.mainPlayer.anims:set("jump")
      end
      s.timer = math.min(s.timer+1, 60)
      if s.timer == 60 then
        s.state = 2
        s.timer = 0
        megaMan.mainPlayer.rise = true
        megaMan.mainPlayer.doAnimation = true
      end
    elseif s.state == 2 then
      s.timer = math.min(s.timer+1, 80)
      if s.timer == 80 then
        s.state = -1
        entities.add(fade, true, nil, nil, func)
      end
    end
  end)
end

function timer.absorbCutscene(func, mus)
  entities.add(timer, 150, function(s)
      if not s.state then
        if megaMan.mainPlayer then
          s.state = 1
          s.timer = 0
          s.to = (view.x+view.w/2)-megaMan.mainPlayer.collisionShape.w/2
          megaMan.mainPlayer:resetStates()
          megaMan.mainPlayer.canControl.global = false
          megaMan.mainPlayer.doAnimation = false
          megaMan.mainPlayer.canSwitchWeapons.global = false
          if megaMan.mainPlayer.ground then
            megaMan.mainPlayer.anims:set("idle")
          else
            megaMan.mainPlayer.anims:set("jump")
          end
          megaMan.mainPlayer.anims:update(1/60)
          megaMan.mainPlayer.velX = 0
          s.timer = 0
        end
        megautils.removePlayerShots()
        music.playq(mus or "assets/sfx/mm5.nsf", nil, 17)
      elseif s.state == 1 then
        s.timer = math.min(s.timer+1, 300)
        if s.timer == 300 then
          if not s.once then
            s.once = true
            megaMan.mainPlayer.side = (megaMan.mainPlayer.x > s.to and -1 or 1)
          end
          megaMan.mainPlayer.velX = 1.3 * megaMan.mainPlayer.side
          if megaMan.mainPlayer.ground then
            megaMan.mainPlayer.anims:set("run")
          elseif collision.checkSolid(self, megaMan.mainPlayer.side, 0) then
            megaMan.mainPlayer.velY = megaMan.mainPlayer.jumpSpeed * (megaMan.mainPlayer.gravity >= 0 and 1 or -1)
          end
          if megaMan.mainPlayer.ground and ((megaMan.mainPlayer.side == -1 and megaMan.mainPlayer.x < s.to) or
            (megaMan.mainPlayer.side == 1 and megaMan.mainPlayer.x > s.to)) then
            s.state = 2
            s.timer = 0
            megaMan.mainPlayer.velX = 0
            megaMan.mainPlayer.velY = megaMan.mainPlayer.jumpSpeed * (megaMan.mainPlayer.gravity >= 0 and 1 or -1)
            megaMan.mainPlayer.ground = false
            megaMan.mainPlayer.anims:set("jump")
            megaMan.mainPlayer.autoCollision.absorb = false
            megaMan.mainPlayer.autoGravity.absorb = false
            s.cg = megaMan.mainPlayer.y
            return
          end
        else
          megaMan.mainPlayer.anims:set("idle")
        end
        megaMan.mainPlayer.anims:update(1/60)
        if not megaMan.mainPlayer.ground then
          megaMan.mainPlayer.anims:set("jump")
        end
      elseif s.state == 2 then
        megaMan.mainPlayer.velY = math.approach(megaMan.mainPlayer.velY, 0, 0.25)
        megaMan.mainPlayer:moveBy(megaMan.mainPlayer.velX, megaMan.mainPlayer.velY)
        if megaMan.mainPlayer.velY == 0 then
          entities.add(absorb, megaMan.mainPlayer)
          s.state = 3
          s.timer = 0
        end
      elseif s.state == 3 then
        s.timer = math.min(s.timer+1, 180)
        if s.timer == 180 then
          megaMan.mainPlayer.autoGravity.absorb = nil
          megaMan.mainPlayer.autoCollision.absorb = nil
          s.timer = 0
          s.state = 4
        end
      elseif s.state == 4 then
        if megaMan.mainPlayer.ground or ((megaMan.mainPlayer.gravity >= 0 and
          megaMan.mainPlayer.y > s.cg) or (megaMan.mainPlayer.gravity < 0 and megaMan.mainPlayer.y < s.cg)) then
          megaMan.mainPlayer.rise = true
          megaMan.mainPlayer.doAnimation = true
          s.state = 5
        end
      elseif s.state == 5 then
        s.timer = math.min(s.timer+1, 80)
        if s.timer == 80 then
          s.state = -1
          entities.add(fade, true, nil, nil, func)
        end
      end
    end)
end
