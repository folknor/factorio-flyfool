local MASK_PLAYER = "player"
local TYPE_CHARACTER = "character"

script.on_event(defines.events.on_player_changed_position, function(ev)
	---@cast ev OnPlayerChangedPosition
	local pIndex = ev.player_index
	local p = game.players[pIndex]
	if not p or not p.valid or not p.connected or not p.position or not p.surface then return end

	local collides = p.surface.find_entities_filtered({
		position = p.position,
		collision_mask = MASK_PLAYER,
	})[1]
	if collides and collides.valid then
		if collides.type ~= TYPE_CHARACTER then
			if not storage.flying[pIndex] then
				storage.flying[pIndex] = true
				-- We've taken off, now we need to modify the speed to match the storage speed

				-- character_running_speed_modifier
				-- is a percentage modifier of the base running speed
				-- I'm not sure what modifies it in the base game, but certainly tiles do not modify it

				-- character_running_speed
				-- Is the actual current speed of the character, before _modifier is applied
				-- This is changed by tiles, exoskeletons, etc
				-- We need to figure out the percentage difference between the old and new speed

				local old = storage.speed[pIndex]
				local new = p.character_running_speed

				local diff = math.abs((new - old) / ((new + old) / 2))

				p.character_running_speed_modifier = storage.modifier[pIndex] + diff
			end
		else
			if storage.flying[pIndex] then
				-- We've landed, we need to reset character_running_speed_modifier
				p.character_running_speed_modifier = storage.modifier[pIndex]
			end

			-- We're just walking along, lets save the current speed
			storage.modifier[pIndex] = p.character_running_speed_modifier
			storage.speed[pIndex] = p.character_running_speed
			storage.flying[pIndex] = false
		end
	end
end)

local function setup()
	storage.flying = {}
	storage.modifier = {}
	storage.speed = {}
end

script.on_init(setup)
script.on_configuration_changed(setup)
