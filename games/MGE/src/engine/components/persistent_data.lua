local persistent = {
    activeReceivers = {},
    cleared = false,
    activeInputCount = 0,
    maskShader = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 col = Texel(texture, texture_coords);
        if (col.a * color.a < 0.01) {
            discard;
        }
        return vec4(1.0);
    }]],
    maskCount = 0,
}

local _defaultTexture = love.image.newImageData(4, 4)
for x=0, 3 do
    for y=0, 3 do
        _defaultTexture:setPixel(x, y, 1.0, 1.0, 1.0, 1.0)
    end
end
persistent.defaultSprite = love.graphics.newImage(_defaultTexture)
persistent.defaultSprite:setWrap('repeat', 'repeat')

return persistent