/datum/config_entry/string/comms_key
	protection = CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/comms_key/ValidateAndSet(str_val)
	return str_val != "default_pwd" && length(str_val) > 6 && ..()

/datum/config_entry/keyed_list/cross_server
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_TEXT
	protection = CONFIG_ENTRY_LOCKED
	lowercase_key = FALSE // The names of the servers are proper nouns. Also required for the cross_comms_name config to work.

/datum/config_entry/keyed_list/cross_server/ValidateAndSet(str_val)
	. = ..()
	if(.)
		var/list/newv = list()
		for(var/I in config_entry_value)
			newv[replacetext(I, "+", " ")] = config_entry_value[I]
		config_entry_value = newv

/datum/config_entry/keyed_list/cross_server/ValidateListEntry(key_name, key_value)
	return key_value != "byond:\\address:port" && ..()

/datum/config_entry/string/cross_comms_name

/datum/config_entry/string/cross_comms_network
	protection = CONFIG_ENTRY_LOCKED


/******************/
/* Deprecated IRC */
/******************/

/datum/config_entry/flag/use_irc_bot

/datum/config_entry/flag/irc_bot_export

/datum/config_entry/flag/use_lib_nudge

/datum/config_entry/string/irc_bot_host

/datum/config_entry/string/main_irc

/datum/config_entry/string/admin_irc

/datum/config_entry/flag/announce_shuttle_dock_to_irc



/datum/config_entry/string/webhook_url
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/webhook_key
	protection = CONFIG_ENTRY_HIDDEN | CONFIG_ENTRY_LOCKED
