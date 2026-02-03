-- OBS Lua Script: Force Fullscreen Projector for a Specific Source
local obs = obslua

local default_source_name = "Elgato 4K X" 
local default_monitor_index = 0 

local hotkey_id = obs.OBS_INVALID_HOTKEY_ID
local source_name = default_source_name
local monitor_index = default_monitor_index

function script_description()
    return [[
    <center><h2>Source Projector (Retina Fix)</h2></center>
    <p>Opens a Source Projector in true fullscreen mode.</p>
    <hr/>
    <p><b>Usage:</b> Assign a hotkey to "Open Fullscreen Projector (Source)".</p>
    ]]
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source_name", "Source Name (Exact spelling):", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int(props, "monitor_index", "Monitor Index (0 = Main):", 0, 10, 1)
    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "source_name", default_source_name)
    obs.obs_data_set_default_int(settings, "monitor_index", default_monitor_index)
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
    if source_name == "" then source_name = default_source_name end
    monitor_index = obs.obs_data_get_int(settings, "monitor_index")
end

function script_load(settings)
    hotkey_id = obs.obs_hotkey_register_frontend(
        "open_source_projector",
        "Open Fullscreen Projector (Source)",
        on_hotkey
    )
    
    local hotkey_save_array = obs.obs_data_get_array(settings, "open_source_projector")
    obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
    
    script_update(settings)
end

function script_save(settings)
    local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
    obs.obs_data_set_array(settings, "open_source_projector", hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end

function on_hotkey(pressed)
    if not pressed then return end
    open_projector()
end

function open_projector()
    local source = obs.obs_get_source_by_name(source_name)
    
    if source then
        -- Try using "Source" as string type instead of enum
        obs.obs_frontend_open_projector("Source", monitor_index, nil, source_name)
        obs.obs_source_release(source)
    else
        obs.script_log(obs.LOG_WARNING, "[Source Projector] Error: Source '" .. source_name .. "' not found!")
    end
end