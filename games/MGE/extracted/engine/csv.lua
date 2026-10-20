local csv = {}

local function _parse(data)
	local parsedCsv = {}
	local row = {}
	local field = ''
	local inQuotes = false
	local position = 1

	local function finishField()
		table.insert(row, field)
		field = ''
	end

	local function finishRow()
		if #row > 0 then
			table.insert(parsedCsv, row)
			row = {}
		end
	end

	while position <= #data do
		local character = string.sub(data, position, position)
		if inQuotes then
			if character == '"' then
				if string.sub(data, position + 1, position + 1) == '"' then
					field = field .. '"'
					position = position + 1
				else
					inQuotes = false
				end
			else
				field = field .. character
			end
		elseif character == '"' and field == '' then
			inQuotes = true
		elseif character == ',' then
			finishField()
		elseif character == '\r' then
			finishField()
			finishRow()
			if string.sub(data, position + 1, position + 1) == '\n' then
				position = position + 1
			end
		elseif character == '\n' then
			finishField()
			finishRow()
		else
			field = field .. character
		end
		position = position + 1
	end

	if inQuotes then
		error('Unclosed quoted field.')
	end
	if field ~= '' or #row > 0 then
		finishField()
		finishRow()
	end
	return parsedCsv
end

function csv.parse(data)
	local success, parsedCsv = pcall(_parse, data)
	if not success then
		engine.debug.logError('Failed to parse csv data: ' .. tostring(parsedCsv))
		return nil
	end
	return parsedCsv
end

return csv