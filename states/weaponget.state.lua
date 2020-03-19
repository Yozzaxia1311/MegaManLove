local weaponGetState = states.state:extend()

function weaponGetState:begin()
  loader.clear()
  megautils.runFile("entities/misc/starfield.lua")
  megautils.add(banner)
  megautils.add(smallStar, 32, 32, 180, 2)
  megautils.add(smallStar, 112, 200, 180, 2)
  megautils.add(smallStar, 16, 240, 180, 2)
  megautils.add(smallStar, 64, 96, 180, 2)
  megautils.add(smallStar, 220, 112, 180, 2)
  megautils.add(star, 10, 100, 180, 4)
  megautils.add(star, 50, 210, 180, 4)
  megautils.add(star, 140, 32, 180, 4)
  megautils.add(largeStar, 0, 32, 180, 6)
  megautils.add(largeStar, 90, 220, 180, 6)
  if globals.weaponGet == "stick" then
    megautils.runFile("entities/demo/stickman.lua")
    megautils.add(megamanStick)
  end
  view.x, view.y = 0, 0
  megautils.add(fade, false, nil, nil, fade.remove)
  mmMusic.playFromFile("assets/sfx/music/get.ogg")
end

function weaponGetState:update(dt)
  megautils.update(self, dt)
end

function weaponGetState:draw()
  megautils.draw(self)
end

megautils.cleanFuncs.weaponGet = function()
  globals.weaponGet = nil
  megautils.cleanFuncs.weaponGet = nil
end

return weaponGetState