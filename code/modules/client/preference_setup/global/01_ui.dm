/datum/preferences
	//var/clientfps = 0
		//game-preferences
	var/ooccolor			//Whatever this is set to acts as 'reset' color and is thus unusable as an actual custom color
	var/asaycolor			//Whatever this is set to acts as 'reset' color and is thus unusable as an actual custom color
	var/UI_style = "ErisStyle"
	var/UI_useborder = 0
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255
	var/UI_compact_style = 0

/datum/category_item/player_setup_item/player_global/ui
	name = "UI"
	sort_order = 1

/datum/category_item/player_setup_item/player_global/ui/load_preferences(var/savefile/S)
	S["UI_style"]		>> pref.UI_style
	S["UI_style_color"]	>> pref.UI_style_color
	S["UI_style_alpha"]	>> pref.UI_style_alpha
	S["ooccolor"]		>> pref.ooccolor
	S["asaycolor"]		>> pref.asaycolor
	//S["clientfps"]		>> pref.clientfps

/datum/category_item/player_setup_item/player_global/ui/save_preferences(var/savefile/S)
	S["UI_style"]		<< pref.UI_style
	S["UI_style_color"]	<< pref.UI_style_color
	S["UI_style_alpha"]	<< pref.UI_style_alpha
	S["ooccolor"]		<< pref.ooccolor
	S["asaycolor"]		<< pref.asaycolor
	//S["clientfps"]		<< pref.clientfps

/datum/category_item/player_setup_item/player_global/ui/sanitize_preferences()
	pref.UI_style		= sanitize_inlist(pref.UI_style, all_ui_styles, initial(pref.UI_style))
	pref.UI_style_color	= sanitize_hexcolor(pref.UI_style_color, initial(pref.UI_style_color))
	pref.UI_style_alpha	= sanitize_integer(pref.UI_style_alpha, 0, 255, initial(pref.UI_style_alpha))
	pref.ooccolor		= sanitize_hexcolor(pref.ooccolor, GLOB.OOC_COLOR)
	pref.asaycolor		= sanitize_hexcolor(pref.asaycolor, DEFAULT_ASAY_COLOR)
	//pref.clientfps	    = sanitize_integer(pref.clientfps, CLIENT_MIN_FPS, CLIENT_MAX_FPS, initial(pref.clientfps))

/datum/category_item/player_setup_item/player_global/ui/content(var/mob/user)
	. += "<b>UI Settings</b><br>"
	. += "<b>UI Style:</b> <a href='byond://?src=\ref[src];select_style=1'><b>[pref.UI_style]</b></a><br>"
	. += "<b>Custom UI</b> (recommended for White UI):<br>"
	. += "-Color: <a href='byond://?src=\ref[src];select_color=1'><b>[pref.UI_style_color]</b></a> <table style='display:inline;' bgcolor='[pref.UI_style_color]'><tr><td>__</td></tr></table> <a href='byond://?src=\ref[src];reset=ui'>reset</a><br>"
	. += "-Alpha(transparency): <a href='byond://?src=\ref[src];select_alpha=1'><b>[pref.UI_style_alpha]</b></a> <a href='byond://?src=\ref[src];reset=alpha'>reset</a><br>"
	if(can_select_ooc_color(user))
		. += "<b>OOC Color:</b>"
		if(pref.ooccolor == GLOB.OOC_COLOR)
			. += "<a href='byond://?src=\ref[src];select_ooc_color=1'><b>Using Default</b></a><br>"
		else
			. += "<a href='byond://?src=\ref[src];select_ooc_color=1'><b>[pref.ooccolor]</b></a> <table style='display:inline;' bgcolor='[pref.ooccolor]'><tr><td>__</td></tr></table> <a href='byond://?src=\ref[src];reset=ooc'>reset</a><br>"
	// Just use the same check
	if(can_select_ooc_color(user))
		. += "<b>ASAY Color:</b>"
		if(pref.asaycolor == DEFAULT_ASAY_COLOR)
			. += "<a href='byond://?src=\ref[src];select_asay_color=1'><b>Using Default</b></a><br>"
		else
			. += "<a href='byond://?src=\ref[src];select_asay_color=1'><b>[pref.asaycolor]</b></a> <table style='display:inline;' bgcolor='[pref.asaycolor]'><tr><td>__</td></tr></table> <a href='byond://?src=\ref[src];reset=asay'>reset</a><br>"
	//. += "<b>Client FPS:</b> <a href='byond://?src=\ref[src];select_fps=1'><b>[pref.clientfps]</b></a><br>"


/datum/category_item/player_setup_item/player_global/ui/OnTopic(var/href,var/list/href_list, var/mob/user)
	if(href_list["select_style"])
		var/UI_style_new = input(user, "Choose UI style.", CHARACTER_PREFERENCE_INPUT_TITLE, pref.UI_style) as null|anything in all_ui_styles
		if(!UI_style_new || !CanUseTopic(user)) return TOPIC_NOACTION
		pref.UI_style = UI_style_new
		pref.client.create_UI()
		return TOPIC_REFRESH

	else if(href_list["select_color"])
		var/UI_style_color_new = input(user, "Choose UI color, dark colors are not recommended!", "Global Preference", pref.UI_style_color) as color|null
		if(isnull(UI_style_color_new) || !CanUseTopic(user)) return TOPIC_NOACTION
		pref.UI_style_color = UI_style_color_new
		pref.client.create_UI()
		return TOPIC_REFRESH

	else if(href_list["select_alpha"])
		var/UI_style_alpha_new = input(user, "Select UI alpha (transparency) level, between 50 and 255.", "Global Preference", pref.UI_style_alpha) as num|null
		if(isnull(UI_style_alpha_new) || (UI_style_alpha_new < 50 || UI_style_alpha_new > 255) || !CanUseTopic(user)) return TOPIC_NOACTION
		pref.UI_style_alpha = UI_style_alpha_new
		pref.client.create_UI()
		return TOPIC_REFRESH

	else if(href_list["select_ooc_color"])
		var/new_ooccolor = input(user, "Choose OOC color:", "Global Preference") as color|null
		if(new_ooccolor && can_select_ooc_color(user) && CanUseTopic(user))
			pref.ooccolor = new_ooccolor
			return TOPIC_REFRESH

	else if(href_list["select_asay_color"])
		var/new_asaycolor = input(user, "Choose ASAY color:", "Global Preference") as color|null
		if(new_asaycolor && can_select_asay_color(user) && CanUseTopic(user))
			pref.asaycolor = new_asaycolor
			return TOPIC_REFRESH

	/*
	else if(href_list["select_fps"])
		var/version_message
		if (user.client && user.client.byond_version < 511)
			version_message = "\nYou need to be using byond version 511 or later to take advantage of this feature, your version of [user.client.byond_version] is too low"
		if (world.byond_version < 511)
			version_message += "\nThis server does not currently support client side fps. You can set now for when it does."
		var/new_fps = input(user, "Choose your desired fps.[version_message]\n(0 = synced with server tick rate (currently:[world.fps]))", "Global Preference") as num|null
		if (isnum(new_fps) && CanUseTopic(user))
			pref.clientfps = CLAMP(new_fps, CLIENT_MIN_FPS, CLIENT_MAX_FPS)

			var/mob/target_mob = preference_mob()
			if(target_mob && target_mob.client)
				target_mob.client.apply_fps(pref.clientfps)
			return TOPIC_REFRESH
	*/
	else if(href_list["reset"])
		switch(href_list["reset"])
			if("ui")
				pref.UI_style_color = initial(pref.UI_style_color)
			if("alpha")
				pref.UI_style_alpha = initial(pref.UI_style_alpha)
			if("ooc")
				pref.ooccolor = GLOB.OOC_COLOR
			if("asay")
				pref.ooccolor = DEFAULT_ASAY_COLOR
		pref.client.create_UI()
		return TOPIC_REFRESH

	return ..()

/proc/can_select_ooc_color(var/mob/user)
	return CONFIG_GET(flag/allow_admin_ooccolor) && check_rights(R_ADMIN, 0, user)

/proc/can_select_asay_color(var/mob/user)
	return CONFIG_GET(flag/allow_admin_asaycolor) && check_rights(R_ADMIN, 0, user)
