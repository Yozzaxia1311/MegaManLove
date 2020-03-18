local cartographer = {
  _VERSION = 'Cartographer',
  _DESCRIPTION = 'Simple Tiled map loading for LÖVE.',
  _URL = 'https://github.com/tesselode/cartographer',
  _LICENSE = [[
		MIT License

		Copyright (c) 2019 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

-- splits a path into directory, file (with filename), and just filename
-- i really only need the directory
-- https://stackoverflow.com/a/12191225
local function splitPath(path)
  return string.match(path, '(.-)([^\\/]-%.?([^%.\\/]*))$')
end

-- joins two paths together into a reasonable path that Lua can use.
-- handles going up a directory using ..
-- https://github.com/karai17/Simple-Tiled-Implementation/blob/master/sti/utils.lua#L5
local function formatPath(path)
  local npGen1, npGen2 = '[^SEP]+SEP%.%.SEP?', 'SEP+%.?SEP'
  local npPat1, npPat2 = npGen1:gsub('SEP', '/'), npGen2:gsub('SEP', '/')
  local k
  repeat path, k = path:gsub(npPat2, '/') until k == 0
  repeat path, k = path:gsub(npPat1, '') until k == 0
  if path == '' then path = '.' end
  return path
end

-- given a grid with w items per row, return the column and row of the nth item
-- (going from left to right, top to bottom)
-- https://stackoverflow.com/a/9816217
local function indexToCoordinates(n, w)
  return (n - 1) % w, math.floor((n - 1) / w)
end

local function coordinatesToIndex(x, y, w)
  return x + w * y + 1
end

local getByNameMetatable = {
  __index = function(self, key)
    for _, item in ipairs(self) do
      if item.name == key then return item end
    end
    return rawget(self, key)
  end,
}

local function getLayer(self, ...)
  local numberOfArguments = select('#', ...)
  if numberOfArguments == 0 then
    error('must specify at least one layer name', 2)
  end
  local layer
  local layerName = select(1, ...)
  if not self.layers[layerName] then return end
  layer = self.layers[layerName]
  for i = 2, numberOfArguments do
    layerName = select(i, ...)
    if not (layer.layers and layer.layers[layerName]) then return end
    layer = layer.layers[layerName]
  end
  return layer
end

-- Decompress tile layer data
-- https://github.com/karai17/Simple-Tiled-Implementation/blob/master/sti/utils.lua#L5
function getDecompressedData(data)
  local ffi = require "ffi"
  local d = {}
  local decoded = ffi.cast("uint32_t*", data)

  for i = 0, data:len() / ffi.sizeof("uint32_t") do
    table.insert(d, tonumber(decoded[i]))
  end
  return d
end

local Layer = {}

-- A common class for all layer types.
Layer.base = {}
Layer.base.__index = Layer.base

function Layer.base:_init(map)
  self._map = map
end

-- Converts grid coordinates to pixel coordinates for this layer.
function Layer.base:gridToPixel(x, y)
  x, y = x * self._map.tilewidth, y * self._map.tileheight
  x, y = x + self.offsetx, y + self.offsety
  return x, y
end

-- Converts pixel coordinates for this layer to grid coordinates.
function Layer.base:pixelToGrid(x, y)
  x, y = x - self.offsetx, y - self.offsety
  x, y = x / self._map.tilewidth, y / self._map.tileheight
  x, y = math.floor(x), math.floor(y)
  return x, y
end

--[[
	Represents any layer type that can contain tiles
	(currently tile layers and object layers).
	There's no layer type in Tiled called "item layers",
	it's just a parent class to share code between
	tile layers and object layers.
]]
Layer.spritelayer = setmetatable({}, Layer.base)
Layer.spritelayer.__index = Layer.spritelayer

function Layer.spritelayer:_initAnimations()
  self._animations = {}
  for _, tileset in ipairs(self._map.tilesets) do
    for _, tile in ipairs(tileset.tiles) do
      if tile.animation then
        local gid = tileset.firstgid + tile.id
        self._animations[gid] = {
          tileset = tileset,
          frames = tile.animation,
          currentFrame = 1,
          timer = tile.animation[1].duration,
        }
      end
    end
  end
end

function Layer.spritelayer:_createSpriteBatches()
  self._spriteBatches = {}
  for _, tileset in ipairs(self._map.tilesets) do
    if tileset.image then
      local image = self._map._images[tileset.image]
      self._spriteBatches[tileset] = love.graphics.newSpriteBatch(image)
    end
  end
end

--[[
	About sprites
	-------------
	In Tiled, both tile layers and object layers can display tiles.
	Since this behavior is similar for both layer types, I encapsulated
	them in a parent type called a "sprite layer".

	In this case, a "sprite" is just an occurrence of a tile in the map.
	Each sprite has a tile global ID, an x position, and a y position.

	Tiled has two kinds of tilesets: single-image tilesets and image
	collection tilesets. In single-image tilesets, each tile is a rectangular
	piece of a single image. In image collection tilesets, each tile is the
	entirety of a separate image.

	For single-image tilesets, it makes sense to use sprite batches to draw
	each tile that belongs to the same image. For image collection tilesets,
	it does not. Therefore, sprites can either be batched or unbatched.
	Batched sprites have two additional fields:
	- spriteBatch - the sprite batch that the sprite belongs to
	- id - the ID of the sprite in the sprite batch (sorry for the confusing
	terminology)

	The setTile function adds, changes, and removes sprites as needed, and it
	adds and removes sprites from sprite batches automatically (depending
	on whether the sprite's tile belongs to a single-image or image collection
	tileset).

	A sprite layer draws all of its sprite batches first, and then it
	manually draws each unbatched sprite.

	How sprites are stored
	======================
	Each sprite has the following fields:
	- tileGid (number)
	- x (number)
	- y (number)
	- spriteBatch (spriteBatch or nil)
	- id (number or nil)

	Normally, I'd represent a list of sprites like this:

	sprites = {
		{
			tileGid = tileGid,
			x = x,
			...
		},
		{
			tileGid = tileGid,
			x = x,
			...
		},
		...
	}

	However, since large maps have a lot of sprites, all of these
	tables use a lot of memory. So instead, since I know that every
	sprite has the same fields, I organize them like this:

	sprites = {
		exists = {sprite1Exists, sprite2Exists, ...},
		tileGid = {sprite1TileGid, sprite2TileGid, ...},
		x = {sprite1X, sprite2X, ...},
		...
	}

	It's a little awkward to work with, but it means that I only ever
	have 7 tables total dedicated to sprites for any given item layer.

	The biggest concern is that you have to insert and remove from all of the
	tables at the same time, otherwise the data for each sprite will get
	misaligned. To keep Lua's table functions working smoothly, I set
	spriteBatch and id to false instead of nil when I want to "remove" them;
	that way I don't make holes in the tables.

	Note: the exists field isn't really necessary, but I'd feel weird using
	the x/y/tileGid fields as indicators that a sprite exists.
]]

function Layer.spritelayer:_setSprite(x, y, gid)
  -- if the gid is 0 (empty), remove the sprite at (x, y)
  -- (if it exists)
  if gid == 0 then
    for i = #self._sprites.exists, 1, -1 do
      if self._sprites.x[i] == x and self._sprites.y[i] == y then
        if self._sprites.spriteBatch[i] then
          self._sprites.spriteBatch[i]:set(self._sprites.id[i], 0, 0, 0, 0, 0)
        end
        table.remove(self._sprites.exists, i)
        table.remove(self._sprites.tileGid, i)
        table.remove(self._sprites.x, i)
        table.remove(self._sprites.y, i)
        table.remove(self._sprites.spriteBatch, i)
        table.remove(self._sprites.id, i)
        break
      end
    end
    return
  end
  local index
  -- check if a sprite already exists at (x, y)
  for i = 1, #self._sprites.exists do
    if self._sprites.x[i] == x and self._sprites.y[i] == y then
      index = i
      break
    end
  end
  -- if the sprite doesn't exist, create a new one and add it to the sprite batch
  if not index then
    table.insert(self._sprites.exists, true)
    table.insert(self._sprites.tileGid, gid)
    table.insert(self._sprites.x, x)
    table.insert(self._sprites.y, y)
    table.insert(self._sprites.spriteBatch, false)
    table.insert(self._sprites.id, false)
    index = #self._sprites.exists
  end
  -- update the sprite's tile GID
  self._sprites.tileGid[index] = gid
  local tileset = self._map:getTileset(gid)
  -- if the sprite should be batched...
  if tileset.image then
    -- get the new quad
    local animation = self._animations[gid]
    local quad = self._map:_getTileQuad(gid, animation and animation.currentFrame)
    -- if the sprite isn't batched, add it to the sprite batch
    if not self._sprites.spriteBatch[index] then
      self._sprites.spriteBatch[index] = self._spriteBatches[tileset]
      self._sprites.id[index] = self._spriteBatches[tileset]:add(quad, x, y)
      -- otherwise, just update the sprite batch
    else
      self._sprites.spriteBatch[index]:set(self._sprites.id[index], quad, x, y)
    end
    -- otherwise...
  else
    -- if the sprite is batched, remove it from the sprite batch
    if self._sprites.spriteBatch[index] then
      self._sprites.spriteBatch[index]:set(self._sprites.id[index], 0, 0, 0, 0, 0)
      self._sprites.spriteBatch[index] = false
      self._sprites.id[index] = false
    end
  end
end

function Layer.spritelayer:_init(map)
  Layer.base._init(self, map)
  self:_initAnimations()
  self:_createSpriteBatches()
  self._sprites = {
    exists = {},
    tileGid = {},
    x = {},
    y = {},
    spriteBatch = {},
    id = {},
  }
end

function Layer.spritelayer:_updateAnimations(dt)
  for gid, animation in pairs(self._animations) do
    -- decrement the animation timer
    animation.timer = animation.timer - 1000 * dt
    while animation.timer <= 0 do
      -- move to the next frame of animation
      animation.currentFrame = animation.currentFrame + 1
      if animation.currentFrame > #animation.frames then
        animation.currentFrame = 1
      end
      -- increment the animation timer by the duration of the new frame
      animation.timer = animation.timer + animation.frames[animation.currentFrame].duration
      -- update sprites
      local tileset = self._map:getTileset(gid)
      if tileset.image then
        local quad = self._map:_getTileQuad(gid, animation.currentFrame)
        for i = 1, #self._sprites.exists do
          if self._sprites.tileGid[i] == gid then
            self._sprites.spriteBatch[i]:set(self._sprites.id[i], quad, self._sprites.x[i], self._sprites.y[i])
          end
        end
      end
    end
  end
end

function Layer.spritelayer:update(dt)
  self:_updateAnimations(dt)
end

function Layer.spritelayer:draw()
  love.graphics.push()
  love.graphics.translate(self.offsetx, self.offsety)
  -- draw the sprite batches
  for _, spriteBatch in pairs(self._spriteBatches) do
    love.graphics.draw(spriteBatch)
  end
  -- draw the unbatched sprites
  for i = 1, #self._sprites.exists do
    if not self._sprites.spriteBatch[i] then
      local animation = self._animations[self._sprites.tileGid[i]]
      local image = self._map:_getTileImage(self._sprites.tileGid[i], animation and animation.currentFrame)
      love.graphics.draw(image, self._sprites.x[i], self._sprites.y[i])
    end
  end
  love.graphics.pop()
end

-- Represents a tile layer in an exported Tiled map.
Layer.tilelayer = setmetatable({}, Layer.spritelayer)
Layer.tilelayer.__index = Layer.tilelayer

function Layer.tilelayer:_init(map)
  Layer.spritelayer._init(self, map)
  if self.encoding == "base64" then
    assert(require "ffi", "Compressed maps require LuaJIT FFI.\nPlease Switch your interperator to LuaJIT or your Tile Layer Format to \"CSV\".")
    local data = love.data.decode("string", "base64", self.data)
    if self.compression == "gzip" then
      data = love.data.decompress("string", "gzip", data)
    elseif self.compression == "zlib" then
      data = love.data.decompress("string", "zlib", data)
    end
    self.data = getDecompressedData(data)
  end
  for _, gid, _, _, pixelX, pixelY in self:getTiles() do
    self:_setSprite(pixelX, pixelY, gid)
  end
end

-- Gets the left, top, right, and bottom bounds of the layer (in tiles).
function Layer.tilelayer:getGridBounds()
  if self.chunks then
    local left, top, right, bottom
    for _, chunk in ipairs(self.chunks) do
      local chunkLeft = chunk.x
      local chunkTop = chunk.y
      local chunkRight = chunk.x + chunk.width - 1
      local chunkBottom = chunk.y + chunk.height - 1
      if not left or chunkLeft < left then left = chunkLeft end
      if not top or chunkTop < top then top = chunkTop end
      if not right or chunkRight > right then right = chunkRight end
      if not bottom or chunkBottom > bottom then bottom = chunkBottom end
    end
    return left, top, right, bottom
  end
  return self.x, self.y, self.x + self.width - 1, self.y + self.height - 1
end

-- Gets the left, top, right, and bottom bounds of the layer (in pixels).
function Layer.tilelayer:getPixelBounds()
  local left, top, right, bottom = self:getGridBounds()
  left, top = self:gridToPixel(left, top)
  right, bottom = self:gridToPixel(right, bottom)
  return left, top, right, bottom
end

-- Returns the global ID of the tile at the given grid position,
-- or false if the tile is empty.
function Layer.tilelayer:getTileAtGridPosition(x, y)
  local gid
  if self.chunks then
    for _, chunk in ipairs(self.chunks) do
      local pointInChunk = x >= chunk.x
      and x < chunk.x + chunk.width
      and y >= chunk.y
      and y < chunk.y + chunk.height
      if pointInChunk then
        gid = chunk.data[coordinatesToIndex(x - chunk.x, y - chunk.y, chunk.width)]
      end
    end
  else
    gid = self.data[coordinatesToIndex(x, y, self.width)]
  end
  gid = gid - 1
  if gid == -1 then return false end
  return gid
end

-- Sets the tile at the given grid position to the specified global ID.
function Layer.tilelayer:setTileAtGridPosition(x, y, id, tileset)
  local gid = self._map.tilesets[tileset or 1].firstgid + id
  if self.chunks then
    for _, chunk in ipairs(self.chunks) do
      local pointInChunk = x >= chunk.x
      and x < chunk.x + chunk.width
      and y >= chunk.y
      and y < chunk.y + chunk.height
      if pointInChunk then
        local index = coordinatesToIndex(x - chunk.x, y - chunk.y, chunk.width)
        chunk.data[index] = gid
      end
    end
  else
    self.data[coordinatesToIndex(x, y, self.width)] = gid
  end
  local pixelX, pixelY = self:gridToPixel(x, y)
  self:_setSprite(pixelX, pixelY, gid-1)
end

-- Returns the global ID of the tile at the given pixel position,
-- or false if the tile is empty.
function Layer.tilelayer:getTileAtPixelPosition(x, y)
  return self:getTileAtGridPosition(self:pixelToGrid(x, y))
end

-- Sets the tile at the given pixel position to the specified global ID.
function Layer.tilelayer:setTileAtPixelPosition(gridX, gridY, id, tileset)
  local gid = self._map.tilesets[tileset or 1].firstgid + id
  local pixelX, pixelY = self:pixelToGrid(gridX, gridY)
  return self:setTileAtGridPosition(pixelX, pixelY, gid)
end

function Layer.tilelayer:_getTileAtIndex(index)
  -- for infinite maps, treat all the chunk data like one big array
  if self.chunks then
    for _, chunk in ipairs(self.chunks) do
      if index <= #chunk.data then
        local gid = chunk.data[index]
        local gridX, gridY = indexToCoordinates(index, chunk.width)
        gridX, gridY = gridX + chunk.x, gridY + chunk.y
        local pixelX, pixelY = self:gridToPixel(gridX, gridY)
        return gid, gridX, gridY, pixelX, pixelY
      else
        index = index - #chunk.data
      end
    end
  elseif self.data[index] then
    local gid = self.data[index]
    local gridX, gridY = indexToCoordinates(index, self.width)
    local pixelX, pixelY = self:gridToPixel(gridX, gridY)
    return gid, gridX, gridY, pixelX, pixelY
  end
end

function Layer.tilelayer:_tileIterator(i)
  while true do
    i = i + 1
    local gid, gridX, gridY, pixelX, pixelY = self:_getTileAtIndex(i)
    if not gid then break end
    if gid ~= 0 then return i, gid, gridX, gridY, pixelX, pixelY end
  end
end

function Layer.tilelayer:getTiles()
  return self._tileIterator, self, 0
end

-- Represents an object layer in an exported Tiled map.
Layer.objectgroup = setmetatable({}, Layer.spritelayer)
Layer.objectgroup.__index = Layer.objectgroup

function Layer.objectgroup:_init(map)
  Layer.spritelayer._init(self, map)
  for _, object in ipairs(self.objects) do
    if object.gid and object.visible then
      self:_setSprite(object.x, object.y - object.height, object.gid)
    end
  end
end

-- Represents an image layer in an exported Tiled map.
Layer.imagelayer = setmetatable({}, Layer.base)
Layer.imagelayer.__index = Layer.imagelayer

function Layer.imagelayer:draw()
  love.graphics.draw(self._map._images[self.image], self.offsetx, self.offsety)
end

-- Represents a layer group in an exported Tiled map.
Layer.group = setmetatable({}, Layer.base)
Layer.group.__index = Layer.group

function Layer.group:_init(map)
  Layer.base._init(self, map)
  for _, layer in ipairs(self.layers) do
    setmetatable(layer, Layer[layer.type])
    layer:_init(map)
  end
  setmetatable(self.layers, getByNameMetatable)
end

Layer.group.getLayer = getLayer

function Layer.group:update(dt)
  for _, layer in ipairs(self.layers) do
    if layer.update then layer:update(dt) end
  end
end

function Layer.group:draw()
  for _, layer in ipairs(self.layers) do
    if layer.visible and layer.draw then layer:draw() end
  end
end

local Map = {}
Map.__index = Map

-- Loads an image if it hasn't already been loaded yet.
-- Images are stored in map._images, and the key is the relative
-- path to the image.
function Map:_loadImage(relativeImagePath)
  if self._images[relativeImagePath] then return end
  local imagePath = formatPath(self.dir .. relativeImagePath)
  self._images[relativeImagePath] = love.graphics.newImage(imagePath)
end

-- Loads all of the images used by the map.
function Map:_loadImages()
  self._images = {}
  for _, tileset in ipairs(self.tilesets) do
    if tileset.image then self:_loadImage(tileset.image) end
    for _, tile in ipairs(tileset.tiles) do
      if tile.image then self:_loadImage(tile.image) end
    end
  end
  for _, layer in ipairs(self.layers) do
    if layer.type == 'imagelayer' then
      self:_loadImage(layer.image)
    end
  end
end

function Map:_initLayers()
  for _, layer in ipairs(self.layers) do
    setmetatable(layer, Layer[layer.type])
    layer:_init(self)
  end
  setmetatable(self.layers, getByNameMetatable)
end

function Map:_init(path)
  self.dir = splitPath(path)
  self.quadCache = {}
  self:_loadImages()
  setmetatable(self.tilesets, getByNameMetatable)
  self:_initLayers()
end

-- Gets the quad of the tile with the given global ID.
-- Returns false if the tileset is an image collection.
function Map:_getTileQuad(gid, frame)
  frame = frame or 1
  local tileset = self:getTileset(gid)
  if not tileset.image then return false end
  local id = gid - tileset.firstgid
  local tile = self:getTile(gid)
  if tile and tile.animation then
    id = tile.animation[frame].tileid
  end
  local image = self._images[tileset.image]
  local gridWidth = math.floor(image:getWidth() / (tileset.tilewidth + tileset.spacing))
  local x, y = indexToCoordinates(id + 1, gridWidth)
  id = id + tileset.firstgid
  if not self.quadCache[id] then
    self.quadCache[id] = love.graphics.newQuad(
      x * (tileset.tilewidth + tileset.spacing),
      y * (tileset.tileheight + tileset.spacing),
      tileset.tilewidth, tileset.tileheight,
      image:getWidth(), image:getHeight()
    )
  end
  return self.quadCache[id]
end

-- Gets the quad of the tile with the given global ID.
-- Returns false if the tileset uses a single image.
function Map:_getTileImage(gid, frame)
  frame = frame or 1
  local tileset = self:getTileset(gid)
  if tileset.image then return false end
  local tile = self:getTile(gid)
  if tile and tile.animation then
    tile = self:getTile(tileset.firstgid + tile.animation[frame].tileid)
  end
  return self._images[tile.image]
end

-- Gets the tileset that has the tile with the given global ID.
function Map:getTileset(gid)
  for i = #self.tilesets, 1, -1 do
    local tileset = self.tilesets[i]
    if tileset.firstgid <= gid then
      return tileset
    end
  end
end

-- Gets the data table for the tile with the given global ID, if it exists.
function Map:getTile(gid)
  local tileset = self:getTileset(gid)
  for _, tile in ipairs(tileset.tiles) do
    if tileset.firstgid + tile.id == gid then
      return tile
    end
  end
end

-- Gets the type of the tile with the given global ID, if it exists.
function Map:getTileType(gid)
  local tile = self:getTile(gid)
  if not tile then return end
  return tile.type
end

-- Gets the value of the specified property on the tile
-- with the given global ID, if it exists.
function Map:getTileProperty(gid, propertyName)
  local tile = self:getTile(gid)
  if not tile then return end
  if not tile.properties then return end
  return tile.properties[propertyName]
end

-- Sets the value of the specified property on the tile
-- with the given global ID.
function Map:setTileProperty(gid, propertyName, propertyValue)
  local tile = self:getTile(gid)
  if not tile then
    local tileset = self:getTileset(gid)
    tile = {id = gid - tileset.firstgid}
    table.insert(tileset.tiles, tile)
  end
  tile.properties = tile.properties or {}
  tile.properties[propertyName] = propertyValue
end

Map.getLayer = getLayer

function Map:update(dt)
  for _, layer in ipairs(self.layers) do
    if layer.update then layer:update(dt) end
  end
end

function Map:drawBackground()
  if self.backgroundcolor then
    love.graphics.push 'all'
    local r = self.backgroundcolor[1] / 255
    local g = self.backgroundcolor[2] / 255
    local b = self.backgroundcolor[3] / 255
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('fill', 0, 0,
      self.width * self.tilewidth,
      self.height * self.tileheight)
    love.graphics.pop()
  end
end

function Map:draw()
  self:drawBackground()
  for _, layer in ipairs(self.layers) do
    if layer.visible and layer.draw then layer:draw() end
  end
end

local function finalXML2LuaTable(data, f)
  local tmp = string.split(f, "/")
  tmp = tmp[#tmp]:len()
  local path = f:sub(0, -tmp-1)
  local result = data.map
  
  if result.tileset then
    if not (type(result.tileset[1]) == "table" and type(result.tileset[2]) == "table") then
      result.tileset = {result.tileset}
    end
    result.tilesets = result.tileset
    result.tileset = nil
    
    for k, v in pairs(result.tilesets) do
      v.firstgid = tonumber(v.firstgid)
      if not love.filesystem.getInfo(path .. v.source) then
        error("No such tileset '" .. v.source .. "'")
      end
      
      local ts = xml2lua:parse(love.filesystem.read(path .. v.source)).tileset
      
      ts.filename = v.source
      ts.columns = tonumber(ts.columns)
      ts.tilecount = tonumber(ts.tilecount)
      ts.tilewidth = tonumber(ts.tilewidth)
      ts.tileheight = tonumber(ts.tileheight)
      ts.spacing = tonumber(ts.spacing) or 0
      ts.margin = tonumber(ts.margin) or 0
      
      if ts.grid then
        ts.grid.width = tonumber(ts.grid.width)
        ts.grid.height = tonumber(ts.grid.height)
      else
        ts.grid = {width=ts.tilewidth, height=ts.tileheight, orientation="orthogonal"}
      end
      
      if ts.tileoffset then
        ts.tileoffset.x = tonumber(ts.tileoffset.x)
        ts.tileoffset.y = tonumber(ts.tileoffset.y)
      else
        ts.tileoffset = {x=0, y=0}
      end
      
      if ts.image then
        tmp = ts.image
        ts.image = tmp.source
        ts.imagewidth = tmp.width
        ts.imageheight = tmp.height
      end
      
      ts.properties = ts.properties or {}
      local ref = ts.properties
      ts.properties = {}
      
      if ref.property then
        if not (type(ref.property[1]) == "table" and type(ref.property[2]) == "table") then
          ref.property = {ref.property}
        end
        
        for o, p in pairs(ref.property) do
          if p.type == "int" or p.type == "float" then
            ts.properties[p.name] = tonumber(p.value)
          elseif p.type == "bool" then
            ts.properties[p.name] = p.value == "true"
          else
            ts.properties[p.name] = p.value
          end
        end
      end
      
      ts.terraintypes = ts.terraintypes or {}
      ref = ts.terraintypes
      ts.terraintypes = nil
      ts.terrains = {}
      if ref.terrain then
        if not (type(ref.terrain[1]) == "table" and type(ref.terrain[2]) == "table") then
          ref.terrain = {ref.terrain}
        end
        
        for o, p in pairs(ref.terrain) do
          p.tile = tonumber(p.tile)
          
          p.properties = p.properties or {}
          local ref2 = p.properties
          p.properties = {}
          if ref2.property then
            if not (type(ref2.property[1]) == "table" and type(ref2.property[2]) == "table") then
              ref2.property = {ref2.property}
            end
            
            for o2, p2 in pairs(ref2.property) do
              if p2.type == "int" or p2.type == "float" then
                p.properties[p2.name] = tonumber(p2.value)
              elseif p2.type == "bool" then
                p.properties[p2.name] = p2.value == "true"
              else
                p.properties[p2.name] = p2.value
              end
            end
          end
          
          ts.terrains[#ts.terrains+1] = p
        end
      end
      
      if ts.tile then
        ts.tiles = ts.tile
        ts.tile = nil
        if not (type(ts.tiles[1]) == "table" and type(ts.tiles[2]) == "table") then
          ts.tiles = {ts.tiles}
        end
        
        for o, p in pairs(ts.tiles) do
          p.id = tonumber(p.id)
          p.probability = tonumber(p.probability)
          
          if p.properties then
            if not (type(p.properties.property[1]) == "table" and type(p.properties.property[2]) == "table") then
              p.properties.property = {p.properties.property}
            end
            
            local ref = p.properties.property
            p.properties = {}
            
            for o2, p2 in pairs(ref) do
              if p2.type == "int" or p2.type == "float" then
                p.properties[p2.name] = tonumber(p2.value)
              elseif p2.type == "bool" then
                p.properties[p2.name] = p2.value == "true"
              else
                p.properties[p2.name] = p2.value
              end
            end
          end
          
          if p.terrain then
            p.terrain = string.split(p.terrain, ",")
            for o2, p2 in pairs(p.terrain) do
              p.terrain[o2] = tonumber(p.terrain[o2]) or -1
            end
          end
          
          if p.animation then
            if not (type(p.animation.frame[1]) == "table" and type(p.animation.frame[2]) == "table") then
              p.animation.frame = {p.animation.frame}
            end
            
            for o2, p2 in pairs(p.animation.frame) do
              p2.duration = tonumber(p2.duration)
              p2.tileid = tonumber(p2.tileid)
            end
            
            p.animation = p.animation.frame
            p.animation.frame = nil
          end
          
        end
      end
      
      ts.firstgid = v.firstgid
      ts.firstgid = nil
      ts.version = nil
      ts.tiledversion = nil
      
      result.tilesets[k] = ts
    end
  end
  
  result.compressionLevel = nil
  result.height = tonumber(result.height)
  result.width = tonumber(result.width)
  result.infinite = nil
  result.editorsettings = nil
  result.nextlayerid = tonumber(result.nextlayerid)
  result.nextobjectid = tonumber(result.nextobjectid)
  result.luaversion = "5.1"
  result.tileheight = tonumber(result.tileheight)
  result.tilewidth = tonumber(result.tilewidth)
  
  if result.objectgroup then
    if not (type(result.objectgroup[1]) == "table" and type(result.objectgroup[2]) == "table") then
      result.objectgroup = {result.objectgroup}
    end
    
    for k, v in pairs(result.objectgroup) do
      v.type = "objectgroup"
      v.id = tonumber(v.id)
      v.visible = v.visible ~= "0"
      v.opacity = tonumber(v.opacity) or 1
      v.offsetx = tonumber(v.offsetx) or 0
      v.offsety = tonumber(v.offsety) or 0
      v.draworder = v.draworder or "topdown"
      
      if not (type(v.object[1]) == "table" and type(v.object[2]) == "table") then
        v.object = {v.object}
      end
      v.objects = v.object
      v.object = nil
      
      local function templateParenting(j, fcache)
        local tf = {}
        
        if j.template then
          if not fcache[path .. j.template] then
            if not love.filesystem.getInfo(path .. j.template) then
              error("No such template file '" .. j.template .. "'")
            end
            fcache[path .. j.template] = xml2lua:parse(love.filesystem.read(path .. j.template)).template
          end
          tf = templateParenting(fcache[path .. j.template], fcache)
        end
        
        j.type = j.type == nil and (tf.type == nil and "" or tf.type) or j.type
        j.name = j.name == nil and (tf.name == nil and "" or tf.name) or j.name
        j.width = tonumber(j.width) or tonumber(tf.width) or 0
        j.height = tonumber(j.height) or tonumber(tf.height) or 0
        j.x = tonumber(j.x) or tonumber(tf.x)
        j.y = tonumber(j.y) or tonumber(tf.y)
        j.rotation = tonumber(j.rotation) or tonumber(tf.rotation) or 0
        j.visible = j.visible == nil and tf.visible == "1" or j.visible == "1"
        j.id = tonumber(j.id) or tonumber(tf.id)
        
        if not j.point then
          j.point = tf.point
        elseif not j.ellipse then
          j.ellipse = tf.ellipse
        elseif not j.polyline then
          j.polyline = tf.polyline
        elseif not j.polygon then
          j.polygon = tf.polygon
        end
        
        if j.point then
          j.point = nil
          j.shape = "point"
        elseif j.ellipse then
          j.ellipse = nil
          j.shape = "ellipse"
        elseif j.polyline then
          j.shape = "polyline"
          
          j.polyline = string.split(j.polyline.points, " ")
          local ptmp = {}
          for o, p in pairs(j.polyline) do
            ptmp[o] = string.split(p, ",")
            for o2, p2 in pairs(ptmp[o]) do
              ptmp[o][o2] = tonumber(p2)
            end
          end
          j.polyline = ptmp          
        elseif j.polygon then
          j.shape = "polygon"
          
          j.polygon = string.split(j.polygon.points, " ")
          local ptmp = {}
          for o, p in pairs(j.polygon) do
            ptmp[o] = string.split(p, ",")
            for o2, p2 in pairs(ptmp[o]) do
              ptmp[o][o2] = tonumber(p2)
            end
          end
          j.polygon = ptmp  
        else
          j.shape = "rectangle"
          j.gid = tonumber(j.gid) or tonumber(tf.gid)
        end
        
        j.properties = j.properties or {}
        local ref = j.properties
        j.properties = {}
        if ref.property then
          if not (type(ref.property[1]) == "table" and type(ref.property[2]) == "table") then
            ref.property = {ref.property}
          end
          
          for o, p in pairs(ref.property) do
            if p.type == "int" or p.type == "float" then
              j.properties[p.name] = tonumber(p.value)
            elseif p.type == "bool" then
              j.properties[p.name] = p.value == "true"
            else
              j.properties[p.name] = p.value
            end
          end
        end
        
        if tf.properties then
          
        end
        
        return j
      end
      --end of func
      local tcache = {}
      for i, j in pairs(v.objects) do
        j = templateParenting(j, tcache)
      end
      
      v.properties = v.properties or {}
      ref = v.properties
      v.properties = {}
      if ref.property then
        if not (type(ref.property[1]) == "table" and type(ref.property[2]) == "table") then
          ref.property = {ref.property}
        end
        
        for i, j in pairs(ref.property) do
          if j.type == "int" or j.type == "float" then
            v.properties[j.name] = tonumber(j.value)
          elseif j.type == "bool" then
            v.properties[j.name] = j.value == "true"
          else
            v.properties[j.name] = j.value
          end
        end
      end
      
    end
  end
  
  if result.layer then
    if not (type(result.layer[1]) == "table" and type(result.layer[2]) == "table") then
      result.layer = {result.layer}
    end
    for k, v in pairs(result.layer) do
      v.type = "tilelayer"

      if v.data then
        if v.data.encoding then
          v.encoding = v.data.encoding
          v.data.encoding = nil
        end
        if v.data.compression then
          v.compression = v.data.compression
          v.data.compression = nil
        end
          
        if v.data.chunk then
          if not (type(v.data.chunk[1]) == "table" and type(v.data.chunk[2]) == "table") then
            v.data.chunk = {v.data.chunk}
          end
          v.chunks = v.data.chunk
          v.data.chunk = nil
          
          for i, j in pairs(v.chunks) do
            j.data = j[1]
            j[1] = nil
          end
          
          v.data = nil
          
          if v.encoding  == "csv" then
            for i, j in pairs(v.chunks) do
              local full = string.split(j.data, "\r\n")
              j.data = ""
              for o, p in ipairs(full) do
                j.data = j.data .. p
              end
              j.data = string.split(j.data, ",")
              for o, p in ipairs(j.data) do
                j.data[o] = tonumber(p)
              end
            end
          end
        else
          if not (type(v.data[1]) == "table" and type(v.data[2]) == "table") then
            v.data = {v.data}
          end
          
          if v.encoding == "csv" then
            local full = string.split(v.data[1], "\r\n")
            v.data[1] = ""
            for i, j in ipairs(full) do
              v.data[1] = v.data[1] .. j
            end
          end
          v.data = v.data[1]
          if v.encoding == "csv" then
            v.data = string.split(v.data, ",")
            for i, j in ipairs(v.data) do
              v.data[i] = tonumber(j)
            end
          end
        end
        
        v.x = tonumber(v.x) or 0
        v.y = tonumber(v.y) or 0
        v.visible = v.visible ~= "0"
        v.opacity = tonumber(v.opacity) or 1
        v.offsetx = tonumber(v.offsetx) or 0
        v.offsety = tonumber(v.offsety) or 0
        v.width = tonumber(v.width) or 0
        v.height = tonumber(v.height) or 0
        v.id = tonumber(id)
        
        v.properties = v.properties or {}
        local ref = v.properties
        v.properties = {}
        if ref.property then
          if not (type(ref.property[1]) == "table" and type(ref.property[2]) == "table") then
            ref.property = {ref.property}
          end
          
          for i, j in pairs(ref.property) do
            if j.type == "int" or j.type == "float" then
              v.properties[j.name] = tonumber(j.value)
            elseif j.type == "bool" then
              v.properties[j.name] = j.value == "true"
            else
              v.properties[j.name] = j.value
            end
          end
        end
      end
    end
    
    result.layer = table.merge({result.layer, result.objectgroup})
    result.objectgroup = nil
  end
  
  --print(inspect(result))
end

-- Loads a Tiled map from a tmx file.
function cartographer.load(path)
  if not path then error('No map path provided', 2) end
  finalXML2LuaTable(xml2lua:parse(love.filesystem.read(path)), path)
  local map = setmetatable(nil, Map)
  map:_init(path)
  return map
end

return cartographer