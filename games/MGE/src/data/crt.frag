uniform float scale;
uniform float strength;
uniform float chromatic_aberration;
uniform float noise;
uniform float fade;
uniform float time;

vec4 colorBleed (vec2 uv, vec4 col, Image tex, vec2 screen_coords)
{
    float uv_per_pixel = (1.0 / 1920.0);
    vec2 r_offset_uv = vec2(uv.x - uv_per_pixel, uv.y);
    vec2 b_offset_uv = vec2(uv.x + uv_per_pixel, uv.y);
    vec4 r_tex = Texel(tex, r_offset_uv);
    vec4 b_tex = Texel(tex, b_offset_uv);

    float ca_adjustment = 2.0 - (0.3 * scale);
    ca_adjustment = min(1.4, ca_adjustment);
    ca_adjustment = max(1.0, ca_adjustment);
    
    float red = col.r + (r_tex.r - col.r) * chromatic_aberration * ca_adjustment;
    float blue = col.b + (b_tex.b - col.b) * chromatic_aberration * ca_adjustment; 

    return vec4(red, col.g, blue, col.a);
}

vec4 saltAndPepper(vec2 uv)
{
    float x_pixel = floor(uv.x * 1920.0);
    float y_pixel = floor(uv.y * 1080.0);
    x_pixel /= 1920.0;
    y_pixel /= 1080.0;
    vec2 random_input = vec2(x_pixel * time, y_pixel * time);
    float value = fract(sin(dot(random_input, vec2(12.9898, 78.233)))*43758.5453);
    value = (1.0 - (value * 2.0)) * noise;
    return vec4(value, value, value, 0.0);
}

vec4 addScanlines(vec4 col, vec2 screen_coords)
{
    float magnitude = (col.r + col.g + col.b) * 0.333333;
    magnitude = min(magnitude, 0.95); //Show slightly on pure white

    float y_multiplier = mod(screen_coords.y / (scale * 0.5), 2.0);
    y_multiplier = floor(y_multiplier);

    float scanline; //only show horizontal scanline, or vertical scanline and don't add together
    if (y_multiplier > 0.5) {
        scanline = y_multiplier;
    } else {
        float x_multiplier = mod(screen_coords.x / (scale * 0.5), 2.0);
        x_multiplier = floor(x_multiplier);
        scanline = x_multiplier * 0.5;
    }

    float reduction = scanline * strength * (1.0 - magnitude) * 0.5;
    float increase = (1.0 - scanline) * strength * (1.0 - magnitude) * 1.0; //increase to maintain overall brightness
    float multiplier = 1.0 + (increase - reduction);
    return vec4(col.r * multiplier, col.g * multiplier, col.b * multiplier, col.a * multiplier);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 col = Texel(tex, texture_coords) * color;
    vec4 fadedCol = vec4(col.r + fade, col.g + fade, col.b + fade, col.a + fade);
    col = colorBleed(texture_coords, col, tex, screen_coords);
    col = addScanlines(col, screen_coords);
    col = col + saltAndPepper(texture_coords);
    vec4 adjustment = fadedCol - col;
    float absoluteFade = abs(fade);
    adjustment = vec4(adjustment.r * absoluteFade, adjustment.g * absoluteFade, adjustment.b * absoluteFade, adjustment.a * absoluteFade);
    return col + adjustment;
}
