local weaponGetState = state:extend()

function weaponGetState:begin()
  megautils.runFile("entities/misc/starfield.lua")
  entities.add(banner)
  entities.add(smallStar, 32, 32, 180, 2)
  entities.add(smallStar, 112, 200, 180, 2)
  entities.add(smallStar, 16, 240, 180, 2)
  entities.add(smallStar, 64, 96, 180, 2)
  entities.add(smallStar, 220, 112, 180, 2)
  entities.add(star, 10, 100, 180, 4)
  entities.add(star, 50, 210, 180, 4)
  entities.add(star, 140, 32, 180, 4)
  entities.add(largeStar, 0, 32, 180, 6)
  entities.add(largeStar, 90, 220, 180, 6)
  entities.add(megaMan)
  entities.add(fade, false, nil, nil, fade.remove)
  music.play("assets/sfx/mm5.nsf", nil, 20)
end

return weaponGetState