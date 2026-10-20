local translator = {}

local _language = 'en_us'
local _languages = {}
local _text = {}

local function _addTranslationToText(path)
    local csv = engine.fileSystem.loadCsv(path)
    if csv == nil then
        return
    end
    for i=2, #csv do
        local line = csv[i]
        local key = line[1]
        local translation = line[2]
		if type(translation) == 'string' then
			translation = string.gsub(translation, '\\n', '\n')
		end
        _text[key] = translation
    end
end

local function _refresh()
    local fallback = _languages['en_us']
    local data = _languages[_language]
    if fallback == nil and data == nil then
        _text = {}
        return
    end
    _text = {}
    if fallback ~= nil then
        for _, path in ipairs(fallback) do
            _addTranslationToText(path)
        end
    end
    if data ~= nil and _language ~= 'en_us' then
        for _, path in ipairs(data) do
            _addTranslationToText(path)
        end
    end
    if data ~= nil or fallback ~= nil then
        engine.events.invoke('refreshLanguage')
    end
end

function translator.addTranslation(language, path)
    if type(language) ~= 'string' or type(path) ~= 'string' then
        return
    end
    local data = _languages[language]
    if data == nil then
        data = {}
        _languages[language] = data
    end
    table.insert(data, path)
    if language == _language then
        _refresh()
    end
end

function translator.clearTranslations()
    _languages = {}
    _text = {}
    _language = 'en_us'
end

function translator.getLanguage()
    return _language
end

function translator.setLanguage(language)
    if type(language) ~= 'string' then
        return
    end
    _language = language
    _refresh()
end

function translator.getText(key)
    if key == nil then
        return nil
    end
    return _text[key] or key
end

return translator