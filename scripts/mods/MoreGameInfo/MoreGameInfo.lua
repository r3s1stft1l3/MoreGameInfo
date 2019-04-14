local mod = get_mod("MoreGameInfo")

mod.status = nil

-- world = Application:main_world()

_get_realm = function()
    local in_modded_realm = script_data["eac-untrusted"]
    if in_modded_realm then
        return "Modded Realm"
    else
        return "Official Realm"
    end
end

_get_career = function()
    local player_manager = Managers.player
	local player = player_manager:local_player()
	local profile_index = player:profile_index()
	local profile = SPProfiles[profile_index]
	local careers = profile.careers
	local career_index = player:career_index()
	local career = careers[career_index]
	local career_name = career.name
    return career_name
end

collect_status = function()
    local realm = _get_realm()
    local map_name = LevelHelper:current_level_settings().display_name
    local player_count = Managers.player:num_human_players()
    local career = _get_career()
    -- local mission_time = ??
    -- local difficulty = ??
    return string.format("%s - %s [%s/4] (%s)", Localize(career), Localize(map_name), player_count, realm)
end

update_status = function(source) 
    local status = collect_status()
    -- mod:echo("update status (%s): %s", source, status)
    local is_steam = Steam and Steam.connected()
    if not is_steam then
        mod:warning("Steam is not connected")
        return
    end
     -- don't update, unless it has changed
    if mod.status ~= status then
        Presence.set_presence("status", status)
        mod.status = status
        return true
    else
        return false
    end
end

enable_player_hooks = function()
    mod:debug("enabling player hooks")
    -- Update the status whenever a new player joins
    mod:hook_safe(Managers.player, "add_remote_player", function()
        update_status("add_remote_player")
    end)
    mod:hook_safe(Managers.player, "add_player", function()
        update_status("add_player")
    end)
    mod:hook_safe(Managers.player, "remove_player", function()
        update_status("remove_player")
    end)
end

-- register hooks once the playermanager was initialised
mod:hook_safe(Game, "_init_managers", function()
    mod:debug("game init")
    enable_player_hooks()
end)

-- if mod is intialised while the game is running
if Managers.player then
    mod:debug("mod reload")
    enable_player_hooks()
else
    mod:debug("Managers.player not yet initialised")
end

-- Update the status whenever a new map is loaded
mod.on_game_state_changed = function(status, state_name)
    if status == "enter" and state_name == "StateIngame" then
        update_status("game state")
    end
end

-- Manually trigger the update (for testing)
mod:command("set_status", "", function()
    if update_status("command") then
        mod:echo("setting status to '%s'", mod.status)
    else
        mod:echo("status is already '%s' or setting status failed", mod.status)
    end
end)