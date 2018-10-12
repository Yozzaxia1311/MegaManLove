local weapongetstate = states.state:extend()

function weapongetstate:begin()
  loader.clear()
  megautils.load()
  loader.load("assets/misc/star_field.png", "star_field", "texture")
  loader.load("assets/misc/star_field_one.png", "star_field_one", "texture")
  megautils.add(banner())
  megautils.add(smallStar(32, 32, 180, 2))
  megautils.add(smallStar(112, 200, 180, 2))
  megautils.add(smallStar(16, 240, 180, 2))
  megautils.add(smallStar(64, 96, 180, 2))
  megautils.add(smallStar(220, 112, 180, 2))
  megautils.add(star(10, 100, 180, 4))
  megautils.add(star(50, 210, 180, 4))
  megautils.add(star(140, 32, 180, 4))
  megautils.add(largeStar(0, 32, 180, 6))
  megautils.add(largeStar(90, 220, 180, 6))
  if globals.weaponGet == "stick" then
    love.filesystem.load("entities/enemies/bosses/stickman.lua")()
    megautils.add(megamanStick())
  end
  view.x, view.y = 0, 0
  megautils.add(fade(false):setAfter(fade.remove))
  mmMusic.playFromFile("assets/sfx/music/get.ogg")
end

function weapongetstate:update(dt)
  megautils.update(self, dt)
end

function weapongetstate:draw()
  megautils.draw(self)
end

megautils.cleanFuncs["unload_weaponget"] = function()
  globals.weaponGet = nil
  megautils.cleanFuncs["unload_weaponget"] = nil
end

return weapongetstate