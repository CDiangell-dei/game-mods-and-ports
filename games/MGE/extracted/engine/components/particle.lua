local particle = {}

local _image
local _position
local _velocity
local _acceleration
local _startColor
local _endColor
local _startSize
local _endSize
local _lifetime = 1.0
local _timer = 0

function particle.update(dt)
    _timer = _timer + dt
    if _timer > _lifetime then
        particle.source.destroy()
        return false
    end
    local progress = _timer / _lifetime
    _velocity.x = _velocity.x + (_acceleration.x * dt)
    _velocity.y = _velocity.y + (_acceleration.y * dt)
    _position.x = _position.x + (_velocity.x * dt)
    _position.y = _position.y + (_velocity.y * dt)
    local sx = _startSize.x + ((_endSize.x - _startSize.x) * progress)
    local sy = _startSize.y + ((_endSize.y - _startSize.y) * progress)
    particle.source.setPosition(_position.x, _position.y)
    particle.source.setSize(sx, sy)
    local r = _startColor.r + ((_endColor.r - _startColor.r) * progress)
    local g = _startColor.g + ((_endColor.g - _startColor.g) * progress)
    local b = _startColor.b + ((_endColor.b - _startColor.b) * progress)
    local a = _startColor.a + ((_endColor.a - _startColor.a) * progress)
    _image.setColor(r, g, b, a)
    return true
end

function particle.init(position, velocity, acceleration, startColor, endColor, lifetime, startSize, endSize)
    _image = particle.source.getComponent('image')
    if _image == nil then
        _lifetime = 1.0
        _timer = 1.1
        return
    end
    _position = position
    _velocity = velocity
    _acceleration = acceleration
    _startColor = startColor
    _endColor = endColor
    _lifetime = lifetime
    _startSize = startSize
    _endSize = endSize
    _timer = 0
end

return particle