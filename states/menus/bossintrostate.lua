local bossintrostate = states.state:extend()

function bossintrostate:begin()
  loader.load("assets/global/objects/bosses/stick_man.png", "stick_man", "texture")
  loader.load("assets/misc/star_field.png", "star_field", "texture")
  loader.load("assets/misc/star_field_one.png", "star_field_one", "texture")
  loader.load("assets/misc/title.png", "title", "texture")
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
  if globals.bossIntroBoss == "stick" then
    love.filesystem.load("entities/enemies/bosses/stickman.lua")()
    megautils.add(stickManIntro())
  end
  megautils.add(fade(false):setAfter(fade.remove))
  mmMusic.playFromFile(nil, "assets/sfx/music/stage_start.ogg")
end

function bossintrostate:update(dt)
  megautils.update(self, dt)
end

function bossintrostate:stop()
  megautils.unload(self)
end

function bossintrostate:draw()
  megautils.draw(self)
end

megautils.cleanFuncs["unload_bossintro"] = function()
  globals.bossIntroBoss = nil
  megautils.cleanFuncs["unload_bossintro"] = nil
end

return bossintrostate