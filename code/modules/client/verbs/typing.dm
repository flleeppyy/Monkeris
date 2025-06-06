#define IC_VERBS list("say", "me", "whisper")

/client/var/commandbar_thinking = FALSE
/client/var/commandbar_typing = FALSE

/client/proc/initialize_commandbar_spy()
	src << output('html/typing_indicator.html', "commandbar_spy")

/client/proc/handle_commandbar_typing(href_list)
	if (get_preference_value(/datum/client_preference/show_typing_indicator) == GLOB.PREF_HIDE) //check pref
		return
	if (length(href_list["verb"]) < 1 || !(LOWER_TEXT(href_list["verb"]) in IC_VERBS) || text2num(href_list["argument_length"]) < 1)
		if (commandbar_typing)
			commandbar_typing = FALSE
			stop_typing()

		if (commandbar_thinking)
			commandbar_thinking = FALSE
			stop_thinking()
		return

	if (!commandbar_thinking)
		commandbar_thinking = TRUE
		start_thinking()

	if (!commandbar_typing)
		commandbar_typing = TRUE
		start_typing()


/** Sets the mob as "thinking" - with indicator and the TRAIT_THINKING_IN_CHARACTER trait */
/client/proc/start_thinking()
	if(get_preference_value(/datum/client_preference/show_typing_indicator) == GLOB.PREF_HIDE)
		return FALSE
	// ADD_TRAIT(mob, TRAIT_THINKING_IN_CHARACTER, CURRENTLY_TYPING_TRAIT)
	mob?.set_typing_indicator(TRUE)

/** Removes typing/thinking indicators and flags the mob as not thinking */
/client/proc/stop_thinking()
	mob?.set_typing_indicator(FALSE)

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/client/proc/start_typing()
	var/mob/client_mob = mob
	client_mob.set_typing_indicator(FALSE)
	if(get_preference_value(/datum/client_preference/show_typing_indicator) == GLOB.PREF_HIDE)
		return FALSE
	client_mob.set_typing_indicator(TRUE)
	addtimer(CALLBACK(src, PROC_REF(stop_typing)), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/**
 * Callback to remove the typing indicator after a brief period of inactivity.
 * If the user was typing IC, the thinking indicator is shown.
 */
/client/proc/stop_typing()
	if(isnull(mob))
		return FALSE
	var/mob/client_mob = mob
	client_mob.set_typing_indicator(FALSE)
	if(get_preference_value(/datum/client_preference/show_typing_indicator) == GLOB.PREF_HIDE)
		return FALSE
	client_mob.set_typing_indicator(TRUE)

#undef IC_VERBS
