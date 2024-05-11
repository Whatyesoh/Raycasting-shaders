

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 xy) {
    
    vec4 pixel = Texel(texture,uv);

    float totalColor = pixel.r + pixel.g + pixel.b;

    float oldColor = totalColor/3;

    float indexX = mod(xy.x,4);
    float indexY = mod(xy.y,4);

    float index = indexX + indexY;

    float threshold = 5;

    if (index == 0) {
        threshold = 0;
    }
    else if (index == 1) {
        threshold = 8;
    }
    else if (index == 2) {
        threshold = 2;
    }
    else if (index == 3) {
        threshold = 10;
    }
    else if (index == 4) {
        threshold = 12;
    }
    else if (index == 5) {
        threshold = 4;
    }
    else if (index == 6) {
        threshold = 14;
    }
    else if (index == 7) {
        threshold = 6;
    }
    else if (index == 8) {
        threshold = 3;
    }
    else if (index == 9) {
        threshold = 11;
    }
    else if (index == 10) {
        threshold = 1;
    }
    else if (index == 11) {
        threshold = 9;
    }
    else if (index == 12) {
        threshold = 15;
    }
    else if (index == 13) {
        threshold = 17;
    }
    else if (index == 14) {
        threshold = 13;
    } 

    if (oldColor >= threshold/16) {
        return vec4(1,1,1,1);
    }
    return vec4(0,0,0,1);

}