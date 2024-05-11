vec4 effect(vec4 color, Image texture, vec2 uv, vec2 xy) {
    float width = xy.x / uv.x;
    int shiftAmount = 7;
    vec4 pixel = Texel(texture,uv);
    pixel.r = Texel(texture,vec2(max(0,xy.x-shiftAmount)/width,uv.y)).r;
    pixel.b = Texel(texture,vec2(min(width,xy.x+shiftAmount)/width,uv.y)).b;
    return pixel;

}