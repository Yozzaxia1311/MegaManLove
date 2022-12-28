extern Image palette;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
   color = floor(Texel(texture, tc) * 31.0);
   return texture2D(palette, vec2(((color.r * 32.0) + color.g)/1024.0, color.b/32.0));
}
