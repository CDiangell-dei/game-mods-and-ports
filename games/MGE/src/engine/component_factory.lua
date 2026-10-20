local componentFactory = {}

local _components = {
    image = 'engine/components/image.lua',
    mask = 'engine/components/mask.lua',
    button = 'engine/components/button.lua',
    text = 'engine/components/text.lua',
    animator = 'engine/components/animator.lua',
    slider = 'engine/components/slider.lua',
    scrollbar = 'engine/components/scrollbar.lua',
    scrollView = 'engine/components/scroll_view.lua',
    input = 'engine/components/input.lua',
    gridLayoutGroup = 'engine/components/grid_layout_group.lua',
    horizontalLayoutGroup = 'engine/components/horizontal_layout_group.lua',
    verticalLayoutGroup = 'engine/components/vertical_layout_group.lua',
    particleSource = 'engine/components/particle_source.lua',
}

function componentFactory.instantiate(type, object)
    if _components[type] == nil then
        return nil
    end
    local component = engine.dofile(_components[type])
    component.object = object
    return component
end

function componentFactory.addCustom(type, component)
    _components[type] = component
end

return componentFactory