local creditsScreen = {}

function creditsScreen.init(onComplete)
    local root = engine.objectManager.getRoot().find('root')
    local object = engine.objectManager.instantiate('data/scenes/credits.json', root)

    local function complete()
        object.destroy()
        if onComplete ~= nil then
            onComplete()
        end
    end

    local continueButtonComponent = object.find('background/continueButton/button').getComponent('button')
    continueButtonComponent.onClick.subscribe(complete)
    local continueButtonScript = engine.sandbox.dofile('data/scripts/ui/default_text_button.lua')
    continueButtonScript.init(object.find('background/continueButton'))
end

return creditsScreen
