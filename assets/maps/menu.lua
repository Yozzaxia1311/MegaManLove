return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.3.2",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 32,
  height = 28,
  tilewidth = 8,
  tileheight = 8,
  nextlayerid = 7,
  nextobjectid = 33,
  properties = {},
  tilesets = {
    {
      name = "menu_tiled",
      firstgid = 1,
      filename = "tilesets/menu_tiled.tsx",
      tilewidth = 8,
      tileheight = 8,
      spacing = 0,
      margin = 0,
      columns = 16,
      image = "tilesets/menu_tiled.png",
      imagewidth = 128,
      imageheight = 120,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 8,
        height = 8
      },
      properties = {},
      terrains = {},
      tilecount = 240,
      tiles = {
        {
          id = 1,
          animation = {
            {
              tileid = 82,
              duration = 100
            },
            {
              tileid = 162,
              duration = 100
            }
          }
        },
        {
          id = 130,
          animation = {
            {
              tileid = 161,
              duration = 100
            },
            {
              tileid = 97,
              duration = 100
            },
            {
              tileid = 105,
              duration = 100
            }
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      id = 1,
      name = "bg",
      x = 0,
      y = 0,
      width = 32,
      height = 28,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      chunks = {
        {
          x = 0, y = 0, width = 16, height = 16,
          data = "eAFjYWBgYBnFo2EwmgZGZBoAAAx4BAE="
        },
        {
          x = 16, y = 0, width = 16, height = 16,
          data = "eAFjYWBgYBnFo2EwmgZGZBoAAAx4BAE="
        },
        {
          x = 0, y = 16, width = 16, height = 16,
          data = "eAFjYWBgYBnFo2EwQtMA0NsjGgAAimkDAQ=="
        },
        {
          x = 16, y = 16, width = 16, height = 16,
          data = "eAFjYWBgYBnFo2EwQtMA0NsjGgAAimkDAQ=="
        }
      }
    },
    {
      type = "group",
      id = 6,
      name = "Group 1",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["dfdf"] = false
      },
      layers = {
        {
          type = "imagelayer",
          id = 5,
          name = "Image Layer 1",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          image = "tilesets/menu_tiled.png",
          properties = {}
        }
      }
    },
    {
      type = "tilelayer",
      id = 2,
      name = "bg2",
      x = 0,
      y = 0,
      width = 32,
      height = 28,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["fff"] = false
      },
      encoding = "base64",
      compression = "zlib",
      chunks = {
        {
          x = 0, y = 0, width = 16, height = 16,
          data = "eAHtkrENgEAMA1M+sAA8Czyw/36cO5ckHdJbuiaKJcdKi4gFVthAavB1trN7QIcTpMxssH/BDQ9ImVkls99Wyez3VjL7vZmuPbd6kjfTteeWX95M155bfnln///+/xd2eRPm"
        },
        {
          x = 16, y = 0, width = 16, height = 16,
          data = "eAHlkLsJwFAMA13mJQvks0A+++8XqTCoMDiqY7hG2HDyiIgZLIAzgQG+Zht2d3AAzgqc7ML+DR7AOYGT8cZ11m68d521L+9dZ+3r/Fq9s7Pza/XOzs6v1Ts7s3+6VH5dxvt0qfy6jPfpUvl12d///wJALhNC"
        },
        {
          x = 0, y = 16, width = 16, height = 16,
          data = "eAHlkMsJwDAMQ3PsZ4G2WaCf/ferHukhGApReqxBGIRly8qp1KK2CpuQC5VauOuZ3dUP4RQcbtD8KEzCLFAO1+KRnW9zvb7ZibbHc/2vkzU34x9O1ujjv07WtW92oY1+4B0u+kHvcF/z596f6wbP6Q+L"
        },
        {
          x = 16, y = 16, width = 16, height = 16,
          data = "eAFjYGBgkABiSSCWAmJpIAYBYsVAajWAWBOItYBYG4hBgFgxTqBaLiDmBmkCAg4gJkWMXHfD/Eeuu2H+I8fNyP4F6Ye5ZTT8iU831Ax/UByMVAAAF5IO7w=="
        }
      }
    },
    {
      type = "objectgroup",
      id = 4,
      name = "Object Layer 1",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 32,
          name = "",
          type = "",
          shape = "polygon",
          x = 224,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -32, y = 40 },
            { x = 16, y = 48 }
          },
          properties = {}
        }
      }
    },
    {
      type = "tilelayer",
      id = 3,
      name = "graphics",
      x = 0,
      y = 0,
      width = 32,
      height = 28,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      chunks = {
        {
          x = 0, y = 0, width = 16, height = 16,
          data = "eAFjYBgFhEKAEaiACQcmpBckLwjEQmg4DsgPA2JigCJQkRIOTIx+aqjBFQbEmo0eBilAjanEagaqQ9cPC09ijUDXHw7UmEasZhrYnww0k9j4BzkT3f2U+j8WaGYCEAMAUH8HbA=="
        },
        {
          x = 16, y = 0, width = 16, height = 16,
          data = "eAFjYBjZgAnofWyYmchgiQeqSwNiITQsTKR+JaA6bFiZSP2UKqPE7yC7g4A4GYhTgRgWBsT6HagFrgemF0SToj8WqB6EydWPrA/GJsX+YKDdUUAMSgehUHeQoh9mJzJNiv4gJHthZpCiHwCzdQg9"
        },
        {
          x = 0, y = 16, width = 16, height = 16,
          data = "eAFjYCAOCAKVCWHBxOlmYEDXnwLUGESsZqA6dP0wtxBrBLr+RKDGWGI108D+YKCZpPhfEaheCQsGCo2C0RAgOwQA634E+w=="
        },
        {
          x = 16, y = 16, width = 16, height = 16,
          data = "eAETYmBgEELDwkA+sSAdqDAMiJHNIEU/sj4YmxT9QUC7s6BuSIa6gxT9MDuRaVL0hwDtjIHaCzODFP1KQL3oWBkoNgpGQ4AeIQAACnYFrg=="
        }
      }
    }
  }
}
