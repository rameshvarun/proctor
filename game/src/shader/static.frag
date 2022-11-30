float PHI = 1.61803398874989484820459 * 00000.1;
float PI  = 3.14159265358979323846264 * 00000.1;
float SQ2 = 1.41421356237309504880169 * 10000.0;

extern float time;

float gold_noise(in vec2 coordinate, in float seed){
    return fract(sin(dot(coordinate*(seed+PHI), vec2(PHI, PI)))*SQ2);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    float noise = gold_noise(screen_coords, time);

    // White lines.
    float y_bin = screen_coords.y;
    if(gold_noise(vec2(y_bin, y_bin), time) < 0.01) {
      noise = 1.0;
    }

    return color * vec4(noise, noise, noise, 1.0);
}
