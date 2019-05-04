extern Image pal;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
  {
    color = floor(Texel(texture, tc) * 31);
    return texture2D(pal, vec2(((color.r * 32) + color.g)/1024, color.b/32));
  }