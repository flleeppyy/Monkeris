/datum/log_category/debug
	category = LOG_CATEGORY_DEBUG

/datum/log_category/debug_tgui
	category = LOG_CATEGORY_DEBUG_TGUI
	master_category = /datum/log_category/debug

/datum/log_category/debug_sql
	category = LOG_CATEGORY_DEBUG_SQL
	master_category = /datum/log_category/debug

// #ifndef DISABLE_DREAMLUAU
// /datum/log_category/debug_lua
// 	category = LOG_CATEGORY_DEBUG_LUA
// 	master_category = /datum/log_category/debug
// #endif

/datum/log_category/debug_href
	category = LOG_CATEGORY_DEBUG_HREF
	master_category = /datum/log_category/debug

// This is not in the debug master category on purpose, do not add it
/datum/log_category/debug_runtime
	category = LOG_CATEGORY_RUNTIME
	internal_formatting = FALSE

/datum/log_category/debug_mapping
	category = LOG_CATEGORY_DEBUG_MAPPING
	master_category = /datum/log_category/debug

/datum/log_category/debug_mobtag
	category = LOG_CATEGORY_DEBUG_MOBTAG
	master_category = /datum/log_category/debug

/datum/log_category/debug_asset
	category = LOG_CATEGORY_DEBUG_ASSET
	config_flag = /datum/config_entry/flag/log_asset
	master_category = /datum/log_category/debug

/datum/log_category/debug_qdel
	category = LOG_CATEGORY_DEBUG_QDEL
	master_category = /datum/log_category/debug
