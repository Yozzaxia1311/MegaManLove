#ifdef GL_ES
uniform Image pal;
#else
extern Image pal;
#endif

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
  {
    color = floor(Texel(texture, tc) * 32.0);
    return texture2D(pal, vec2(((color.r * 32.0) + color.g)/1024.0, color.b/32.0));
  }