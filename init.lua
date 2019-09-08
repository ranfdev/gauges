-- gauges: Adds health/breath bars above players
--
-- Copyright © 2014-2019 4aiman, Hugo Locurcio and contributors - MIT License
-- See `LICENSE.md` included in the source distribution for details.

local hp_bar = {
	physical = false,
	collisionbox = {x = 0, y = 0, z = 0},
	visual = "sprite",
	textures = {"health_20.png"}, -- The texture is changed later in the code
	visual_size = {x = 1.5, y = 0.09375, z = 1.5}, -- Y value is (1 / 16) * 1.5
	wielder = nil,
}

function vector.sqdist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return dx * dx + dy * dy + dz * dz
end

function hp_bar:on_hpchange()
	local wielder = self.wielder and minetest.get_player_by_name(self.wielder)

	if
		wielder == nil or
		vector.sqdist(wielder:get_pos(), self.object:get_pos()) > 3
	then
		self.object:remove()
		return
	end

	local hp = wielder:get_hp()
	local breath = wielder:get_breath()

	self.object:set_properties({
		textures = {
			"health_" .. tostring(hp) .. ".png",
		},
	})
end

minetest.register_entity("gauges:hp_bar", hp_bar)

local gauge_list = {}

local function add_HP_gauge(name)
	local player = minetest.get_player_by_name(name)
	local pos = player:get_pos()
	local ent = minetest.add_entity(pos, "gauges:hp_bar")

	if ent ~= nil then
		ent:set_attach(player, "", {x = 0, y = 19, z = 0}, {x = 0, y = 0, z = 0})
		ent = ent:get_luaentity()
		ent.wielder = name
    gauge_list[name] = ent
	end
end

if
	minetest.settings:get_bool("enable_damage") and
	minetest.settings:get_bool("health_bars") ~= false
then
	minetest.register_on_joinplayer(function(player)
		minetest.after(1, add_HP_gauge, player:get_player_name())
	end)
  minetest.register_on_player_hpchange(function (player)
    gauge_list[player:get_player_name()]:on_hpchange()
  end)
  minetest.register_on_leaveplayer(function(player)
    gauge_list[player:get_player_name()].object:remove()
  end)
end
