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
      self._spriteBatches[tileset] = spriteBatch(image)
    end
  end
end

function Layer.spritelayer:_setSprite(x, y, gid, offGrid)
  if self.useSpriteBatch then
    self:_batchSetSprite(x, y, gid, offGrid)
  else
    -- if the gid is 0 (empty), remove the sprite at (x, y)
    -- (if it exists)
    if offGrid then
      if gid == 0 then
        if self._sprites.offGridMap[y] and self._sprites.offGridMap[y][x] then
          self._sprites.offGridMap[y][x] = nil
        end
        if self._sprites.offGridQuads[y] and self._sprites.offGridQuads[y][x] then
          self._sprites.offGridQuads[y][x] = nil
        end
      end

      if not self._sprites.offGridMap[y] then
        self._sprites.offGridMap[y] = {}
      end
      self._sprites.offGridMap[y][x] = gid

      local tileset = self._map:getTileset(gid)

      if tileset.image then
        -- get the new quad
        local animation = self._animations[gid]
        local quad = self._map:_getTileQuad(gid, animation and animation.currentFrame)
        -- if the sprite doesn't have a quad, add one
        if not self._sprites.offGridQuads[y] then
          self._sprites.offGridQuads[y] = {}
        end
        self._sprites.offGridQuads[y][x] = quad
        --otherwise, if there's no image, remove any quad that may be there
      elseif self._sprites.offGridQuads[y] and self._sprites.offGridQuads[y][x] then
        self._sprites.offGridQuads[y][x] = nil
      end
    else
      if gid == 0 then
        if self._sprites.map[y] and self._sprites.map[y][x] then
          self._sprites.map[y][x] = nil
        end
        if self._sprites.quads[y] and self._sprites.quads[y][x] then
          self._sprites.quads[y][x] = nil
        end
        return
      end

      if not self._sprites.map[y] then
        self._sprites.map[y] = {}
      end
      self._sprites.map[y][x] = gid
      -- update the sprite's tile GID
      local tileset = self._map:getTileset(gid)
      -- if the sprite should have a quad...
      if tileset.image then
        -- get the new quad
        local animation = self._animations[gid]
        local quad = self._map:_getTileQuad(gid, animation and animation.currentFrame)
        -- if the sprite doesn't have a quad, add one
        if not self._sprites.quads[y] then
          self._sprites.quads[y] = {}
        end
        self._sprites.quads[y][x] = quad
        --otherwise, if there's no image, remove any quad that may be there
      elseif self._sprites.quads[y] and self._sprites.quads[y][x] then
        self._sprites.quads[y][x] = nil
      end
    end
  end
end

function Layer.spritelayer:_batchSetSprite(x, y, gid, offGrid)
  if not offGrid then
    x = x * self._map.tilewidth
    y = y * self._map.tileheight
  end
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
  
  self.useSpriteBatch = (not map.infinite and map.width * map.tilewidth <= view.w and map.height * map.tileheight <= view.h) or spriteBatchTileMaps
  self:_initAnimations()

  if self.useSpriteBatch then
    self:_createSpriteBatches()
    self._sprites = {
      exists = {},
      tileGid = {},
      x = {},
      y = {},
      id = {},
      spriteBatch = {},
    }
  else
    self._sprites = {
      map = {},
      quads = {},
      offGridMap = {},
      offGridQuads = {},
      drawRange = {x=0, y=0, w=self._map.width*self._map.tilewidth, h=self._map.height*self._map.tileheight}
    }
  end
end

function Layer.spritelayer:setDrawRange(x, y, w, h)
  if not self.useSpriteBatch then
    self._sprites.drawRange.x = x or self._sprites.drawRange.x
    self._sprites.drawRange.y = y or self._sprites.drawRange.y
    self._sprites.drawRange.w = w or self._sprites.drawRange.w
    self._sprites.drawRange.h = h or self._sprites.drawRange.h
  end
end

function Layer.spritelayer:_updateAnimations(dt)
  if self.useSpriteBatch then
    self:_batchUpdateAnimations(dt)
  else
    local vw, vh = view.w / 2, view.h / 2
    local ty = math.ceil(((self._sprites.drawRange.y-self.offsety-view.y-vh) + ((view.y+vh) * (self.parallaxy or 1)))/self._map.tileheight)-1
    local th = math.floor(self._sprites.drawRange.h/self._map.tileheight)+1
    local tx = math.ceil(((self._sprites.drawRange.x-self.offsetx-view.x-vw) + ((view.x+vw) * (self.parallaxx or 1)))/self._map.tilewidth)-1
    local tw = math.floor(self._sprites.drawRange.w/self._map.tilewidth)+1
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
          if #self._sprites.offGridQuads ~= 0 then
            for y, ytable in pairs(self._sprites.offGridQuads) do
              for x, _ in pairs(ytable) do
                if self._sprites.offGridMap[y] and self._sprites.offGridMap[y][x] then
                  local quad = self._map:_getTileQuad(self._sprites.offGridMap[y][x], animation.currentFrame)
                  self._sprites.offGridQuads[y][x] = quad
                end
              end
            end
          end
          for y=ty, ty+th do
            for x=tx, tx+tw do
              if self._sprites.map[y] and self._sprites.map[y][x] == gid and self._sprites.quads[y] and self._sprites.quads[y][x] then
                local quad = self._map:_getTileQuad(gid, animation.currentFrame)
                self._sprites.quads[y][x] = quad
              end
            end
          end
        end
      end
    end
  end
end

function Layer.spritelayer:_batchUpdateAnimations(dt)
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
  if self.useSpriteBatch then
    self:_batchDraw()
  else
    love.graphics.push()
    local sx, sy = (self.parallaxx or 1) * (self.parentParallaxX or 1), (self.parallaxy or 1) * (self.parentParallaxY or 1)
    local vw, vh = view.w / 2, view.h / 2
    if sx ~= 1 or sy ~= 1 then
      love.graphics.translate(view.x + vw, view.y + vh)
      love.graphics.translate((-view.x - vw) * sx, (-view.y - vh) * sy)
    end
    love.graphics.translate(self.offsetx, self.offsety)
    -- draw the tiles within the draw range
    local ty = math.ceil(((self._sprites.drawRange.y-self.offsety-view.y-vh) + ((view.y+vh) * sy))/self._map.tileheight)-1
    local th = math.floor(self._sprites.drawRange.h/self._map.tileheight)+1
    local tx = math.ceil(((self._sprites.drawRange.x-self.offsetx-view.x-vw) + ((view.x+vw) * sx))/self._map.tilewidth)-1
    local tw = math.floor(self._sprites.drawRange.w/self._map.tilewidth)+1
    local sprites_map = self._sprites.map
    local sprites_quad = self._sprites.quads
    local map_images = self._map._images
    local map_tilewidth = self._map.tilewidth
    local map_tileheight = self._map.tileheight

    for y=ty, ty+th do
      for x=tx, tx+tw do
        if sprites_map[y] and sprites_map[y][x] and sprites_quad[y] and sprites_quad[y][x] then
          local tileset = self._map:getTileset(sprites_map[y][x]).image
          if tileset then
            map_images[tileset]:draw(sprites_quad[y][x], x*map_tilewidth, y*map_tileheight)
          end
        end
      end
    end
    love.graphics.pop()
  end
end

function Layer.spritelayer:_batchDraw()
  love.graphics.push()
  if ((self.parallaxx or 1) ~= 1 or (self.parallaxy or 1) ~= 1) then
    local vx, vy = view.x + (view.w / 2), view.y + (view.h / 2)
    love.graphics.translate(vx, vy)
    love.graphics.translate(-vx * (self.parallaxx or 1), -vy * (self.parallaxy or 1))
  end
  love.graphics.translate(self.offsetx, self.offsety)
  -- draw the sprite batches
  for _, spriteBatch in pairs(self._spriteBatches) do
    spriteBatch:draw()
  end
  -- draw the unbatched sprites
  for i = 1, #self._sprites.exists do
    if not self._sprites.spriteBatch[i] then
      local animation = self._animations[self._sprites.tileGid[i]]
      local image = self._map:_getTileImage(self._sprites.tileGid[i], animation and animation.currentFrame)
      image:draw(self._sprites.x[i], self._sprites.y[i])
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
    --error("LuaJIT FFI is not allowed; use CSV instead.")

    assert(ffi, "Compressed maps require LuaJIT FFI.\nPlease Switch your interperator to LuaJIT or your Tile Layer Format to \"CSV\".")
    if self.chunks then
      for _, v in ipairs(self.chunks) do
        if v.data then
          local data = love.data.decode("string", "base64", v.data)
          if self.compression == "zstd" then
            error("Zstandard is not a supported compression type.")
          elseif self.compression == "gzip" then
            data = love.data.decompress("string", "gzip", data)
          elseif self.compression == "zlib" then
            data = love.data.decompress("string", "zlib", data)
          end
          v.data = self._map:getDecompressedData(data)
        end
      end
    else
      local data = love.data.decode("string", "base64", self.data)
      if self.compression == "zstd" then
        error("Zstandard is not a supported compression type.")
      elseif self.compression == "gzip" then
        data = love.data.decompress("string", "gzip", data)
      elseif self.compression == "zlib" then
        data = love.data.decompress("string", "zlib", data)
      end
      self.data = self._map:getDecompressedData(data)
    end
  end
  for _, gid, gridX, gridY, _, _ in self:getTiles() do
    self:_setSprite(gridX, gridY, gid)
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
        gid = chunk.data[self._map:coordinatesToIndex(x - chunk.x, y - chunk.y, chunk.width)]
      end
    end
  else
    gid = self.data[self._map:coordinatesToIndex(x, y, self.width)]
  end
  gid = gid and (gid - 1) or -1
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
        local index = self._map:coordinatesToIndex(x - chunk.x, y - chunk.y, chunk.width)
        chunk.data[index] = gid
      end
    end
  else
    self.data[self._map:coordinatesToIndex(x, y, self.width)] = gid
  end
  self:_setSprite(x, y, gid)
end

-- Returns the global ID of the tile at the given pixel position,
-- or false if the tile is empty.
function Layer.tilelayer:getTileAtPixelPosition(x, y)
  return self:getTileAtGridPosition(self:pixelToGrid(x, y))
end

-- Sets the tile at the given pixel position to the specified global ID.
function Layer.tilelayer:setTileAtPixelPosition(pixelX, pixelY, id, tileset)
  local gridX, gridY = self:pixelToGrid(pixelX, pixelY)
  return self:setTileAtGridPosition(gridX, gridY, id, tileset)
end

function Layer.tilelayer:_getTileAtIndex(index)
  -- for infinite maps, treat all the chunk data like one big array
  if self.chunks then
    for _, chunk in ipairs(self.chunks) do
      if index <= #chunk.data then
        local gid = chunk.data[index]
        local gridX, gridY = self._map:indexToCoordinates(index, chunk.width)
        gridX, gridY = gridX + chunk.x, gridY + chunk.y
        local pixelX, pixelY = self:gridToPixel(gridX, gridY)
        return gid, gridX, gridY, pixelX, pixelY
      else
        index = index - #chunk.data
      end
    end
  elseif self.data[index] then
    local gid = self.data[index]
    local gridX, gridY = self._map:indexToCoordinates(index, self.width)
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

--  for _, object in ipairs(self.objects) do
--    if object.gid and object.visible then
--      self:_setSprite(object.x, object.y - object.height, object.gid, true)
--    end
--  end
end

-- Represents an image layer in an exported Tiled map.
Layer.imagelayer = setmetatable({}, Layer.base)
Layer.imagelayer.__index = Layer.imagelayer

function Layer.imagelayer:draw()
  self._map._images[self.image]:draw(self.offsetx, self.offsety)
end

-- Represents a layer group in an exported Tiled map.
Layer.group = setmetatable({}, Layer.base)
Layer.group.__index = Layer.group

function Layer.group:_init(map)
  Layer.base._init(self, map)

  for _, layer in ipairs(self.layers) do
    setmetatable(layer, Layer[layer.type])
    layer:_init(self._map)
  end
  setmetatable(self.layers, getByNameMetatable)
end

Layer.group.getLayer = getLayer

function Layer.group:update(dt)
  for _, layer in ipairs(self.layers) do
    if layer.update then layer:update(dt) end
  end
end

function Layer.group:setDrawRange(x, y, w, h)
  for _, layer in ipairs(self.layers) do
    if layer.setDrawRange then layer:setDrawRange(x, y, w, h) end
  end
end

function Layer.group:draw()
  for _, layer in ipairs(self.layers) do
    layer.parentParallaxX = self.parallaxx * (self.parentParallaxX or 1)
    layer.parentParallaxY = self.parallaxy * (self.parentParallaxY or 1)
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

  local imagePath = self.dir .. relativeImagePath
  local npGen1, npGen2 = '[^SEP]+SEP%.%.SEP?', 'SEP+%.?SEP'
  local npPat1, npPat2 = npGen1:gsub('SEP', '/'), npGen2:gsub('SEP', '/')
  local k
  repeat imagePath, k = imagePath:gsub(npPat2, '/') until k == 0
  repeat imagePath, k = imagePath:gsub(npPat1, '') until k == 0
  if imagePath == '' then imagePath = '.' end

  self._images[relativeImagePath] = imageWrapper(imagePath)
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

  local function recursiveImageLayer(l)
    for _, layer in ipairs(l) do
      if layer.type == 'imagelayer' then
        self:_loadImage(layer.image)
      elseif layer.type == 'group' then
        recursiveImageLayer(layer.layers)
      end
    end
  end
  recursiveImageLayer(self.layers)
end

function Map:_initLayers()
  for _, layer in ipairs(self.layers) do
    setmetatable(layer, Layer[layer.type])
    layer:_init(self)
  end
  setmetatable(self.layers, getByNameMetatable)
end

function Map:_init(path)
  self.dir = path:match('(.-)([^\\/]-%.?([^%.\\/]*))$')
  self._quadCache = {}
  self.tilesetCache = {}
  self.tileCache = {}
  self.path = path
  if self.backgroundcolor then
    self.backgroundcolor[1] = self.backgroundcolor[1] / 255
    self.backgroundcolor[2] = self.backgroundcolor[2] / 255
    self.backgroundcolor[3] = self.backgroundcolor[3] / 255
  end
  self:_loadImages()
  setmetatable(self.tilesets, getByNameMetatable)
  self:_initLayers()
end

function Map:coordinatesToIndex(x, y, w)
  return x + w * y + 1
end

-- given a grid with w items per row, return the column and row of the nth item
-- (going from left to right, top to bottom)
-- https://stackoverflow.com/a/9816217
function Map:indexToCoordinates(n, w)
  return (n - 1) % w, math.floor((n - 1) / w)
end

-- Decompress tile layer data
-- https://github.com/karai17/Simple-Tiled-Implementation/blob/master/sti/utils.lua#L67
function Map:getDecompressedData(data)
  local d = {}
  local decoded = ffi.cast("uint32_t*", data)

  for i = 0, (data:len() / ffi.sizeof("uint32_t")) - 1 do
    table.insert(d, tonumber(decoded[i]))
  end

  return d
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
  local gridWidth = math.floor(tileset.imagewidth / (tileset.tilewidth + tileset.spacing))
  local x, y = self:indexToCoordinates(id + 1, tileset.columns)
  id = id + tileset.firstgid
  if not self._quadCache[id] then
    self._quadCache[id] = quad(
      tileset.margin + (x * (tileset.tilewidth + tileset.spacing)),
      tileset.margin + (y * (tileset.tileheight + tileset.spacing)),
      tileset.tilewidth, tileset.tileheight
    )
  end
  return self._quadCache[id]
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
  if self.tilesetCache[gid] then return self.tilesetCache[gid] end
  for i = #self.tilesets, 1, -1 do
    local tileset = self.tilesets[i]
    if tileset.firstgid <= gid then
      self.tilesetCache[gid] = tileset
      return tileset
    end
  end
end

-- Gets the data table for the tile with the given global ID, if it exists.
function Map:getTile(gid)
  if self.tileCache[gid] then return self.tileCache[gid] end
  local tileset = self:getTileset(gid)
  for _, tile in ipairs(tileset.tiles) do
    if tileset.firstgid + tile.id == gid then
      self.tileCache[gid] = tile
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
    love.graphics.setColor(self.backgroundcolor[1], self.backgroundcolor[2], self.backgroundcolor[3], 1)
    love.graphics.rectangle("fill", view.x-1, view.y-1, view.w+1, view.h+1)
  end
end

function Map:setDrawRange(x, y, w, h)
  for _, layer in ipairs(self.layers) do
    if layer.setDrawRange then layer:setDrawRange(x, y, w, h) end
  end
end

function Map:draw()
  self:drawBackground()
  love.graphics.setColor(1, 1, 1, 1)
  for _, layer in ipairs(self.layers) do
    if layer.visible and layer.draw then layer:draw() end
  end
end

function Map:release()
  for _, v in pairs(self._quadCache) do
    v:release()
  end
  self._quadCache = nil

  for _, v in pairs(self._images) do
    v:release()
  end
  self._images = nil
end

local function setProperties(pTable, path)
  pTable.properties = pTable.properties or {}
  local ref = pTable.properties
  pTable.properties = {}
  
  if ref.property then
    if not (type(ref.property[1]) == "table" and type(ref.property[2]) == "table") then
      ref.property = {ref.property}
    end
    for i, j in pairs(ref.property) do
      if j.type == "int" or j.type == "float" or j.type == "object" then
        pTable.properties[j.name] = tonumber(j.value)
      elseif j.type == "bool" then
        pTable.properties[j.name] = j.value == "true"
      elseif j.type == "file" then
        pTable.properties[j.name] = (j.value == "") and j.value or j.value:getAbsolutePath(path)
      else
        pTable.properties[j.name] = j.value
      end
    end
  end
end

local function loadTX(j, fcache, p, basePath)
  local tf = {}
  local usePath = p

  if j.template then
    usePath = j.template:getAbsolutePath(usePath)
    if not fcache[basePath .. j.template] then
      if not love.filesystem.getInfo(usePath) then
        error("No such template file '" .. j.template .. "'")
      end
      fcache[basePath .. j.template] = xml2lua:parse(love.filesystem.read(usePath)).template.object
    end
    usePath = usePath:getDirectory()
    tf = loadTX(table.clone(fcache[basePath .. j.template]), fcache, usePath, basePath)
  end

  j.type = j.type == nil and (tf.type == nil and "" or tf.type) or j.type
  j.name = j.name == nil and (tf.name == nil and "" or tf.name) or j.name
  j.width = tonumber(j.width) or tonumber(tf.width) or 0
  j.height = tonumber(j.height) or tonumber(tf.height) or 0
  j.x = tonumber(j.x) or tonumber(tf.x)
  j.y = tonumber(j.y) or tonumber(tf.y)
  j.rotation = tonumber(j.rotation) or tonumber(tf.rotation) or 0
  j.visible = j.visible == nil and (tf.visible ~= "0") or (j.visible ~= "0")
  j.id = tonumber(j.id) or tonumber(tf.id)
  j.gid = tonumber(j.gid) or tonumber(tf.gid)

  if not j.point and not j.ellipse and not j.polyline and not j.polygon and not j.text then
    j.point = tf.tmpPoint
    j.ellipse = tf.tmpEllipse
    j.polyline = tf.tmpPolyline
    j.polygon = tf.tmpPolygon
    j.text = tf.tmpText
  end

  if j.point then
    j.tmpPoint = j.point
    j.point = nil
    j.shape = "point"
  elseif j.ellipse then
    j.tmpEllipse = j.ellipse
    j.ellipse = nil
    j.shape = "ellipse"
  elseif j.polyline then
    j.tmpPolyline = j.polyline
    j.shape = "polyline"

    j.polyline = j.polyline.points:split(" ")
    local ptmp = {}
    for o, p in pairs(j.polyline) do
      ptmp[o] = p:split(",")
      for o2, p2 in pairs(ptmp[o]) do
        ptmp[o][o2] = tonumber(p2)
      end
    end
    j.polyline = ptmp          
  elseif j.polygon then
    j.tmpPolygon = j.polygon
    j.shape = "polygon"

    j.polygon = j.polygon.points:split(" ")
    local ptmp = {}
    for o, p in pairs(j.polygon) do
      ptmp[o] = p:split(",")
      for o2, p2 in pairs(ptmp[o]) do
        ptmp[o][o2] = tonumber(p2)
      end
    end
    j.polygon = ptmp  
  elseif j.text then
    j.tmpText = j.text
    j.shape = "text"
    j.wrap = j.text.wrap == "1"
    j.halign = j.text.halign
    j.valign = j.text.valign
    j.fontfamily = j.text.fontfamily
    if j.text.color then
      j.color = j.text.color:gsub("#","")
      j.color = {tonumber("0x"..j.color:sub(1,2)),
        tonumber("0x"..j.color:sub(3,4)), tonumber("0x"..j.color:sub(5,6))}
    end
    j.text = j.text[1]
  else
    j.shape = "rectangle"
    j.gid = tonumber(j.gid) or tonumber(tf.gid)
  end
  
  setProperties(j, usePath)

  if tf.properties then
    for o, p in pairs(tf.properties) do
      if j.properties[o] == nil then
        j.properties[o] = p
      end
    end
  end

  return j
end

local function loadTSX(map, path)
  local alreadyDone = not not map.tilesets
  if map.tileset or alreadyDone then
    if not alreadyDone then
      if not (type(map.tileset[1]) == "table" and type(map.tileset[2]) == "table") then
        map.tileset = {map.tileset}
      end
      map.tilesets = map.tilesets or map.tileset
    end
    map.tileset = nil

    for k, v in pairs(map.tilesets) do
      v.firstgid = tonumber(v.firstgid)
      local ts
      local usePath = path
      if v.source then
        usePath = v.source:getAbsolutePath(path)
        if not love.filesystem.getInfo(usePath) then
          error("No such tileset '" .. v.source .. "'")
        end
        ts = xml2lua:parse(love.filesystem.read(usePath)).tileset
        usePath = usePath:getDirectory()
      else
        ts = v
      end

      if not v.source then
        ts.filename = v.source
      end
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
        if v.source then
          tmp = ts.image
          local tmp2 = v.source:split("/")
          ts.image = (v.source:sub(0, -tmp2[#tmp2]:len()-1) .. tmp.source):getAbsolutePath(usePath)
          ts.imagewidth = tonumber(tmp.width)
          ts.imageheight = tonumber(tmp.height)
        else
          v.imagewidth = tonumber(v.image.width)
          v.imageheight = tonumber(v.image.height)
          v.image = v.image.source:getAbsolutePath(usePath)
        end
      end
      
      setProperties(ts, usePath)

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
          setProperties(p, usePath)
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
          
          setProperties(p, usePath)
          
          if p.terrain then
            p.terrain = p.terrain:split(",")
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
      else
        ts.tiles = {}
      end

      ts.firstgid = v.firstgid
      ts.version = nil
      ts.tiledversion = nil

      map.tilesets[k] = ts
    end
  end
end

local function layerGroupParenting(tab, map, path)
  if tab.layer then
    if not (type(tab.layer[1]) == "table" and type(tab.layer[2]) == "table") then
      tab.layer = {tab.layer}
    end
    for _, v in pairs(tab.layer) do
      if v.type == "tilelayer" then
        v.x = tonumber(v.x) or 0
        v.y = tonumber(v.y) or 0
        v.visible = v.visible ~= "0"
        v.opacity = tonumber(v.opacity) or 1
        v.offsetx = tonumber(v.offsetx) or 0
        v.offsety = tonumber(v.offsety) or 0
        v.parallaxx = tonumber(v.parallaxx) or 1
        v.parallaxy = tonumber(v.parallaxy) or 1
        v.width = tonumber(v.width) or 0
        v.height = tonumber(v.height) or 0
        v.id = tonumber(v.id)

        if v.data then
          if v.data.encoding then
            v.encoding = v.data.encoding
            v.data.encoding = nil
          end
          if v.data.compression then
            v.compression = v.data.compression
            v.data.compression = nil
          end

          if map.infinite then
            if v.data.chunk then
              if not (type(v.data.chunk[1]) == "table" and type(v.data.chunk[2]) == "table") then
                v.data.chunk = {v.data.chunk}
              end
              v.chunks = v.data.chunk

              for i, j in pairs(v.chunks) do
                j.data = j[1]
                j[1] = nil
              end

              v.data = nil

              for i, j in pairs(v.chunks) do
                j.width = tonumber(j.width)
                j.height = tonumber(j.height)
                j.x = tonumber(j.x)
                j.y = tonumber(j.y)
              end

              if v.encoding  == "csv" then
                for i, j in pairs(v.chunks) do
                  local full = j.data:split("\r\n")
                  j.data = ""
                  for o, p in ipairs(full) do
                    j.data = j.data .. p
                  end
                  j.data = j.data:split(",")
                  for o, p in ipairs(j.data) do
                    j.data[o] = tonumber(p)
                  end
                end
              end
            else
              v.data = nil
              v.chunks = {}
            end
          else
            if v.encoding == "csv" then
              local full = v.data[1]:split("\r\n")
              v.data[1] = ""
              for i, j in ipairs(full) do
                v.data[1] = v.data[1] .. j
              end
            end
            v.data = v.data[1]
            if v.encoding == "csv" then
              v.data = v.data:split(",")
              for i, j in ipairs(v.data) do
                v.data[i] = tonumber(j)
              end
            end
          end
        end
      elseif v.type == "objectgroup" then
        v.id = tonumber(v.id)
        v.visible = v.visible ~= "0"
        v.opacity = tonumber(v.opacity) or 1
        v.offsetx = tonumber(v.offsetx) or 0
        v.offsety = tonumber(v.offsety) or 0
        v.draworder = v.draworder or "topdown"
        if v.object then
          if not (type(v.object[1]) == "table" and type(v.object[2]) == "table") then
            v.object = {v.object}
          end
          v.objects = v.object
          v.object = nil
          local tcache = {}
          for i, j in pairs(v.objects) do
            j = loadTX(j, tcache, path, path)
            if j.gid then
              j.y = j.y - j.height
            end
          end
          for i, j in pairs(v.objects) do
            j.tmpPoint = nil
            j.tmpEllipse = nil
            j.tmpPolyline = nil
            j.tmpPolygon = nil
            j.tmpText = nil
          end
        else
          v.objects = {}
        end
      elseif v.type == "imagelayer" then
        v.id = tonumber(v.id)
        v.visible = v.visible ~= "0"
        v.opacity = tonumber(v.opacity) or 1
        v.offsetx = tonumber(v.offsetx) or 0
        v.offsety = tonumber(v.offsety) or 0
        v.image = v.image.source:getAbsolutePath(path)
      elseif v.type == "group" then
        v.id = tonumber(v.id)
        v.visible = v.visible ~= "0"
        v.opacity = tonumber(v.opacity) or 1
        v.offsetx = tonumber(v.offsetx) or 0
        v.offsety = tonumber(v.offsety) or 0
        v.parallaxx = tonumber(v.parallaxx) or 1
        v.parallaxy = tonumber(v.parallaxy) or 1

        layerGroupParenting(v, map, path)
      end
      
      setProperties(v, path)
    end
    tab.layers = tab.layer
    tab.layer = nil
  else
    tab.layers = {}
  end
end

local function finalXML2LuaTable(str, f)
  str = str:gsub("<layer", "<layer type=\"tilelayer\"")
  str = str:gsub("<objectgroup", "<layer type=\"objectgroup\"")
  str = str:gsub("<imagelayer", "<layer type=\"imagelayer\"")
  str = str:gsub("<group", "<layer type=\"group\"")
  str = str:gsub("</objectgroup", "</layer")
  str = str:gsub("</imagelayer", "</layer")
  str = str:gsub("</group", "</layer")

  local result = xml2lua:parse(str).map

  local tmp = f:split("/")
  tmp = tmp[#tmp]:len()
  local path = f:sub(0, -tmp-2)

  result.compressionLevel = nil
  result.height = tonumber(result.height)
  result.width = tonumber(result.width)
  result.editorsettings = nil
  result.nextlayerid = tonumber(result.nextlayerid)
  result.nextobjectid = tonumber(result.nextobjectid)
  result.luaversion = "5.1"
  result.tileheight = tonumber(result.tileheight)
  result.tilewidth = tonumber(result.tilewidth)
  result.infinite = result.infinite ~= "0"
  if result.backgroundcolor then
    result.backgroundcolor = result.backgroundcolor:gsub("#","")
    result.backgroundcolor = {tonumber("0x"..result.backgroundcolor:sub(1,2)),
      tonumber("0x"..result.backgroundcolor:sub(3,4)), tonumber("0x"..result.backgroundcolor:sub(5,6))}
  end
  
  setProperties(result, path)
  loadTSX(result, path)
  layerGroupParenting(result, result, path)

  collectgarbage()
  collectgarbage()

  return result
end

-- Loads a Tiled map from a tmx file.
function cartographer.load(path)
  if not path then error('No map path provided', 2) end
  if not love.filesystem.getInfo(path) then error('Map path "' .. path .. '" does not exist', 2) end

  local map

  if path:sub(path:len()-3, path:len()) == ".tmx" then
    map = setmetatable(finalXML2LuaTable(love.filesystem.read(path), path), Map)
  end

  map:_init(path)

  return map
end

return cartographer
