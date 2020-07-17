megautils.loadResource("assets/global/bosses/stickMan.png", "stickMan")
megautils.loadResource("assets/sfx/enemyHit.ogg", "enemyHit")

stickMan = bossEntity:extend()

addObjects.register("stickMan", function(v)
    megautils.add(spawner, v.x, v.y-8, 12, 24, nil, stickMan, v.x, v.y-8)
  end)

function stickMan:new(x, y)
  stickMan.super.new(self)
  self.transform.y = y or 0
  self.transform.x = x or 0
  self:setRectangleCollision(12, 24)
  self.t = megautils.getResource("stickMan")
  self.canDraw.global = false
  self.defeatSlot = "stickMan"
  self.bossIntroText = "STICK MAN"
  self.stageState = "assets/states/templates/templateStage.stage.tmx"
  self.gravity = 0
  self.health = 1
  self:useHealthBar({128, 128, 128}, {255, 255, 255})
end

function stickMan:weaponTable(o)
  if o:is(stickWeapon) then -- The weakness
    return -8
  elseif o:is(megaChargedBuster) then -- Semi-weakness
    return -3
  elseif self.changeHealth < 0 then
    return -1
  end
end

function stickMan:determineDink(o)
  return o:is(megaSemiBuster)
end

function stickMan:draw()
  stickMan.super.draw(self)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.t, math.round(self.transform.x)-4, math.round(self.transform.y)-8)
  --self:drawCollision()
end

stickManIntro = entity:extend()

function stickManIntro:new()
  stickManIntro.super.new(self)
  self.transform.y = -60
  self.transform.x = 108
  self.t = megautils.getResource("stickMan")
  self.c = "idle"
  self.text = "STICK MAN"
  self.pos = 0
  self.textTimer = 0
  self.timer = 0
  self.s = 0
  banner.colorOne = {255, 255, 255}
  banner.colorTwo = {128, 128, 128}
end

function stickManIntro:update(dt)
  if self.s == 0 then
    self.transform.y = math.min(self.transform.y+10, 96)
    if self.transform.y == 96 then
      self.s = 1
    end
  elseif self.s == 1 then
    self.timer = math.min(self.timer+1, 15)
    if self.timer == 15 then
      self.timer = 0
      --self.c = "pose"
      self.s = 2
    end
  elseif self.s == 2 then
    self.timer = math.min(self.timer+1, 40)
    if self.timer == 40 then
      self.timer = 0
      self.s = 3
    end
  elseif self.s == 3 then
    self.textTimer = math.min(self.textTimer+1, 8)
    if self.textTimer == 8 then
      self.textTimer = 0
      self.pos = math.min(self.pos+1, self.text:len())
    end
    if self.pos == self.text:len() then
      self.s = 4
    end
  elseif self.s == 4 then
    self.timer = math.min(self.timer+1, 300)
    if self.timer == 300 then
      megautils.stopMusic()
      megautils.transitionToState("assets/states/stages/demo.stage.tmx")
      self.s = 5
    end
  end
end

function stickManIntro:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.t, self.transform.x, self.transform.y)
  love.graphics.setFont(mmFont)
  love.graphics.print(string.sub(self.text, 0, self.pos), 85, 141)
end

megamanStick = basicEntity:extend()

function megamanStick:new()
  megamanStick.super.new(self)
  self.transform.y = -60
  self.transform.x = 100
  local grid
  if globals.skin == "mega" then
    self.texOutline = megautils.loadResource("assets/players/megaman/megaManOutline.png", "megaManOutline")
    self.texOne = megautils.loadResource("assets/players/megaman/megaManOne.png", "megaManOne")
    self.texTwo = megautils.loadResource("assets/players/megaman/megaManTwo.png", "megaManTwo")
    self.texFace = megautils.loadResource("assets/players/megaman/megaManFace.png", "megaManFace")
    megautils.loadResource(41, 30, "megaManGrid")
    grid = "megaManGrid"
  elseif globals.skin == "proto" then
    self.texOutline = megautils.loadResource("assets/players/proto/protoManOutline.png", "protoManOutline")
    self.texOne = megautils.loadResource("assets/players/proto/protoManOne.png", "protoManOne")
    self.texTwo = megautils.loadResource("assets/players/proto/protoManTwo.png", "protoManTwo")
    self.texFace = megautils.loadResource("assets/players/proto/protoManFace.png", "protoManFace")
    megautils.loadResource(41, 30, "megaManGrid")
    grid = "megaManGrid"
  elseif globals.skin == "bass" then
    self.texOutline = megautils.loadResource("assets/players/bass/bassOutline.png", "bassOutline")
    self.texOne = megautils.loadResource("assets/players/bass/bassOne.png", "bassOne")
    self.texTwo = megautils.loadResource("assets/players/bass/bassTwo.png", "bassTwo")
    self.texFace = megautils.loadResource("assets/players/bass/bassFace.png", "bassFace")
    megautils.loadResource(45, 41, "bassGrid")
    grid = "bassGrid"
  elseif globals.skin == "roll" then
    self.texOutline = megautils.loadResource("assets/players/roll/rollOutline.png", "rollOutline")
    self.texOne = megautils.loadResource("assets/players/roll/rollOne.png", "rollOne")
    self.texTwo = megautils.loadResource("assets/players/roll/rollTwo.png", "rollTwo")
    self.texFace = megautils.loadResource("assets/players/roll/rollFace.png", "rollFace")
    megautils.loadResource(45, 34, "rollGrid")
    grid = "rollGrid"
  end
  weapons.resources.stickWeapon()
  self.curAnim = pose and "pose" or "idle"
  self.anims = animationSet()
  self.anims:add("idle", megautils.newAnimation(grid, {1, 1, 2, 1}, globals.skin == "proto" and (1/8) or {2.5, 0.1}))
  self.anims:add("idleShoot", megautils.newAnimation(grid, {1, 4}))
  self.text = "WEAPON GET... STICK WEAPON!"
  self.pos = 0
  self.textTimer = 0
  self.timer = 0
  self.timer2 = 0
  self.shootTimer = 14
  self.s = 0
  self.megaOne = banner.colorOne
  self.megaTwo = banner.colorTwo
  self.toOne = {255, 255, 255}
  self.toTwo = {128, 128, 128}
  banner.colorOne = table.clone(self.megaOne)
  banner.colorTwo = table.clone(self.megaTwo)
  banner.colorOutline = {0, 0, 0}
  self.wh = {}
  self.wh.currentSlot = 1
end

function megamanStick:update(dt)
  self.anims:update(defaultFramerate)
  if self.s == 0 then
    self.transform.y = math.min(self.transform.y+10, 104)
    if self.transform.y == 104 then
      self.s = 1
    end
  elseif self.s == 1 then
    self.timer = math.min(self.timer+1, 60)
    if self.timer == 60 then
      self.timer = 0
      self.s = 2
    end
  elseif self.s == 2 then
    self.timer = math.min(self.timer+1, 8)
    if self.timer == 8 then
      self.timer = 0
      self.timer2 = self.timer2 + 1
      if math.wrap(self.timer2, 0, 1) == 0 then
        banner.colorOne = self.toOne
        banner.colorTwo = self.toTwo
      else
        banner.colorOne = self.megaOne
        banner.colorTwo = self.megaTwo
      end
      if self.timer2 == 16 then
        self.s = 3
        self.timer2 = 0
      end
    end
  elseif self.s == 3 then
    self.textTimer = math.min(self.textTimer+1, 8)
    if self.textTimer == 8 then
      self.textTimer = 0
      self.pos = math.min(self.pos+1, self.text:len())
    end
    self.timer = math.min(self.timer+1, 15)
    if self.timer == 15 then
      self.timer = 0
      self.s = 4
    end
  elseif self.s == 4 then
    self.textTimer = math.min(self.textTimer+1, 8)
    if self.textTimer == 8 then
      self.textTimer = 0
      self.pos = math.min(self.pos+1, self.text:len())
    end
    self.timer = math.min(self.timer+1, 50)
    if self.timer == 50 then
      self.timer = 0
      self.timer2 = self.timer2 + 1
      self.shootTimer = 0
      megautils.add(stickWeapon, self.transform.x+17, self.transform.y+7, 1, self.wh)
      if self.timer2 == 4 then
        self.timer2 = 0
        self.s = 5
      end
    end
  elseif self.s == 5 then
    self.textTimer = math.min(self.textTimer+1, 8)
    if self.textTimer == 8 then
      self.textTimer = 0
      self.pos = math.min(self.pos+1, self.text:len())
    end
    if self.pos == self.text:len() then
      self.s = 6
    end
  elseif self.s == 6 then
    self.timer = math.min(self.timer+1, 60)
    if self.timer == 60 then
      megautils.transitionToState("assets/states/menus/menu.state.lua")
      megautils.removeq(self)
    end
  end
  self.shootTimer = math.min(self.shootTimer+1, 14)
  if self.shootTimer == 14 then
    self.anims:set("idle")
  else
    self.anims:set("idleShoot")
  end
end

function megamanStick:draw()
  love.graphics.setColor(1, 1, 1, 1)
  local offsety = 1
  
  love.graphics.setColor(banner.colorOutline[1]/255, banner.colorOutline[2]/255, banner.colorOutline[3]/255, 1)
  self.animations[self.curAnim]:draw(self.texOutline, math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(banner.colorOne[1]/255, banner.colorOne[2]/255, banner.colorOne[3]/255, 1)
  self.animations[self.curAnim]:draw(self.texOne, math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(banner.colorTwo[1]/255, banner.colorTwo[2]/255, banner.colorTwo[3]/255, 1)
  self.animations[self.curAnim]:draw(self.texTwo, math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(1, 1, 1, 1)
  self.animations[self.curAnim]:draw(self.texFace, math.round(self.transform.x-14),
    math.round(self.transform.y-8+offsety))
  
  love.graphics.setFont(mmFont)
  love.graphics.printf(string.sub(self.text, 0, self.pos), 0, (120/2)+81, view.w, "center")
end

megautils.cleanFuncs.stickMan = function()
  stickMan = nil
  stickManIntro = nil
  megamanStick = nil
  megautils.cleanFuncs.stickMan = nil
end

return stickMan