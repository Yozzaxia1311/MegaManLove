--[[
CScreen v1.3 by CodeNMore
A simple way to make resolution-independent Love2D games
Tested for LOVE 0.10.1
See: https://github.com/CodeNMore/CScreen

Zlib License:
Copyright (c) 2016 CodeNMore

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from
the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software in
a product, an acknowledgment in the product documentation would be appreciated
but is not required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.

--]]

local CScreen = {}

local rx, ry, ctr = 800, 600, true
local rxv, ryv, fsv, fsvr = 800, 600, 1.0, 1.0
local tx, ty, rwf, rhf = 0, 0, 800, 600
local cr, cg, cb = 60/255, 188/255, 1
local ir, ig, ib = 1, 1, 1
local imgl, imgr, imglp, imgrp
local fadeAlpha, toFade = 0, 1

function CScreen.ser()
  return {
      rx=rx,
      ry=ry,
      rxv=rxv,
      ryv=ryv,
      fsv=fsv,
      fsvr=fsvr,
      tx=tx,
      ty=ty,
      rwf=rwf,
      rhf=rhf,
      cr=cr,
      cg=cg,
      cb=cb,
      ir=ir,
      ig=ig,
      ib=ib,
      imglp=imglp,
      imgrp=imgrp,
      fadeAlpha=fadeAlpha,
      toFade=toFade
    }
end

function CScreen.deser(t)
  CScreen.init(t.rx, t.ry, t.imglp, t.imgrp)
  cr=t.cr
  cg=t.cg
  cb=t.cb
  ir=t.ir
  ig=t.ig
  ib=t.ib
  fadeAlpha=t.fadeAlpha
  toFade=t.toFade
end

-- Initializes CScreen with the initial size values
function CScreen.init(tw, th, l, r)
	rx = tw or rx
	ry = th or ry
  if l and imglp ~= l then
    imgl = love.graphics.newImage(l)
    imgl:setFilter("linear")
  end
  if r and imgrp ~= r then
    imgr = love.graphics.newImage(r)
    imgr:setFilter("linear")
  end
  imglp = l
  imgrp = r
	CScreen.update(love.graphics.getWidth(), love.graphics.getHeight())
end

-- Draws letterbox borders
function CScreen.cease()
  local pr, pg, pb, pa = love.graphics.getColor()
  love.graphics.scale(fsvr, fsvr)

  if tx ~= 0 then
    if imgl then
      love.graphics.setColor(ir, ig, ib, fadeAlpha)
      love.graphics.setScissor(0, 0, tx, rhf)
      local ratio = math.max(tx/imgl:getWidth(), rhf/imgl:getHeight())
      love.graphics.draw(imgl, 0, rhf/2, 0, ratio, ratio, imgl:getWidth(), imgl:getHeight()/2)
      love.graphics.setScissor()
    else
      love.graphics.setColor(cr, cg, cb, fadeAlpha)
      love.graphics.rectangle("fill", -tx, 0, tx, rhf)
    end
    if imgr then
      love.graphics.setColor(ir, ig, ib, fadeAlpha)
      love.graphics.setScissor(rxv+tx, 0, tx, rhf)
      local ratio = math.max(tx/imgr:getWidth(), rhf/imgr:getHeight())
      love.graphics.draw(imgr, rxv, rhf/2, 0, ratio, ratio, 0, imgr:getHeight()/2)
      love.graphics.setScissor()
    else
      love.graphics.setColor(cr, cg, cb, fadeAlpha)
      love.graphics.rectangle("fill", rxv, 0, tx, rhf)
    end
  elseif ty ~= 0 then
    love.graphics.setColor(cr, cg, cb, fadeAlpha)
    love.graphics.rectangle("fill", 0, -ty, rwf, ty)
    love.graphics.rectangle("fill", 0, ryv, rwf, ty)
  end

  love.graphics.setColor(pr, pg, pb, pa)
end

-- Scales and centers all graphics properly
function CScreen.apply()
  love.graphics.translate(tx, ty)
	love.graphics.scale(fsv, fsv)
end

-- Updates CScreen when the window size changes
function CScreen.update(w, h)
	local sx = w / rx
	local sy = h / ry
	fsv = math.min(sx, sy)
	fsvr = 1 / fsv
	-- Centering
	if fsv == sx then -- Vertically
		tx = 0
		ty = (h / 2) - (ry * fsv / 2)
	elseif fsv == sy then -- Horizontally
		ty = 0
		tx = (w / 2) - (rx * fsv / 2)
	end
	-- Variable sets
	rwf = w
	rhf = h
	rxv = rx * fsv
	ryv = ry * fsv
end

-- Convert from window coordinates to target coordinates
function CScreen.project(x, y)
	return math.floor((x - tx) / fsv), math.floor((y - ty) / fsv)
end

function CScreen.unproject(x, y)
	return (tx + x) * fsv, (ty + y) * fsv
end

function CScreen.getScale()
  return fsv
end

function CScreen.getOffsets()
  return tx, ty
end

-- Change letterbox color
function CScreen.setColor(r, g, b)
	cr = r
	cg = g
	cb = b
  ir = r
  ig = g
  ib = b
end

-- Change image borders
function CScreen.setImageBorders(l, r)
  imgl = love.graphics.newImage(l) or imgl
  imgr = love.graphics.newImage(r) or imgr
  imglp = l
  imgrp = r
end

function CScreen.setFade(to)
  toFade = to
end

function CScreen.getFade()
  return fadeAlpha
end

function CScreen.updateFade()
  fadeAlpha = math.approach(fadeAlpha, toFade, 0.01)
end

-- Return the table for use
return CScreen