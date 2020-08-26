timer = basicEntity:extend()

timer.autoClean = false

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
        s.state = 1
        megautils.stopMusic()
        megaMan.mainPlayer:resetStates()
        megaMan.mainPlayer.velocity.velx = 0
        megaMan.mainPlayer.canControl.global = false
        megaMan.mainPlayer.doAnimation = false
        megaMan.mainPlayer.canSwitchWeapons.global = false
        if megaMan.mainPlayer.ground then
          megaMan.mainPlayer.anims:set("idle")
        else
          megaMan.mainPlayer.anims:set("jump")
        end
        megaMan.mainPlayer.anims.flipX = megaMan.mainPlayer.side == 1
      end
      megautils.removePlayerShots()
    elseif s.state == 1 then
      collision.doGrav(megaMan.mainPlayer)
      megaMan.mainPlayer:phys()
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
          megaMan.mainPlayer.side = (megaMan.mainPlayer.transform.x > s.to and -1 or 1)
          megaMan.mainPlayer.anims:update(1/60)
          megaMan.mainPlayer.velocity.velx = 0
          s.timer = 0
        end
        megautils.removePlayerShots()
        megautils.playMusic(music or "assets/sfx/music/win.ogg")
      elseif s.state == 1 then
        s.timer = math.min(s.timer+1, 300)
        if s.timer == 300 then
          if not s.once then
            s.once = true
            megaMan.mainPlayer.anims.flipX = megaMan.mainPlayer.side == 1
          end
          megaMan.mainPlayer.velocity.velx = 1.3 * megaMan.mainPlayer.side
          if megaMan.mainPlayer.ground then
            megaMan.mainPlayer.anims:set("run")
          elseif collision.checkSolid(self, megaMan.mainPlayer.side, 0) then
            megaMan.mainPlayer.velocity.vely = megaMan.mainPlayer.jumpSpeed * (megaMan.mainPlayer.gravity >= 0 and 1 or -1)
          end
          if megaMan.mainPlayer.ground and ((megaMan.mainPlayer.side == -1 and megaMan.mainPlayer.transform.x < s.to) or
            (megaMan.mainPlayer.side == 1 and megaMan.mainPlayer.transform.x > s.to)) then
            s.state = 2
            s.timer = 0
            megaMan.mainPlayer.velocity.velx = 0
            megaMan.mainPlayer.velocity.vely = megaMan.mainPlayer.jumpSpeed * (megaMan.mainPlayer.gravity >= 0 and 1 or -1)
            megaMan.mainPlayer.ground = false
            megaMan.mainPlayer.anims:set("jump")
            s.cg = megaMan.mainPlayer.transform.y
            return
          end
        else
          megaMan.mainPlayer.anims:set("idle")
        end
        megaMan.mainPlayer.anims:update(1/60)
        collision.doGrav(megaMan.mainPlayer)
        megaMan.mainPlayer:phys()
        if not megaMan.mainPlayer.ground then
          megaMan.mainPlayer.anims:set("jump")
        end
      elseif s.state == 2 then
        megaMan.mainPlayer.velocity:slowY(0.25)
        megaMan.mainPlayer:moveBy(megaMan.mainPlayer.velocity.velx, megaMan.mainPlayer.velocity.vely)
        if megaMan.mainPlayer.velocity.vely == 0 then
          megautils.add(absorb, megaMan.mainPlayer)
          s.state = 3
          s.timer = 0
        end
      elseif s.state == 3 then
        s.timer = math.min(s.timer+1, 180)
        if s.timer == 180 then
          s.timer = 0
          s.state = 4
        end
      elseif s.state == 4 then
        collision.doGrav(megaMan.mainPlayer)
        megaMan.mainPlayer:phys()
        if megaMan.mainPlayer.ground or ((megaMan.mainPlayer.gravity >= 0 and
          megaMan.mainPlayer.transform.y > s.cg) or (megaMan.mainPlayer.gravity < 0 and megaMan.mainPlayer.transform.y < s.cg)) then
          megaMan.mainPlayer.rise = true
          megaMan.mainPlayer.doAnimation = true
          s.state = 5
        end
      elseif s.state == 5 then
        s.timer = math.min(s.timer+1, 80)
        if s.timer == 80 then
          s.state = -1
          megautils.add(fade, true, nil, nil, func)
        end
      end
    end)
end
