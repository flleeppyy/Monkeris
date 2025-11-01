//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in SSmobs.mob_list | SShumans.mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Context: Only administrators may use this command.</font>")
		return
	if(!ismob(M) || !M.client)
		return
	cmd_admin_pm(M.client,null)

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(isnewplayer(T.mob))
				targets["(New Player) - [T]"] = T
			else if(isghost(T.mob))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) as null|anything in sortList(targets)
	cmd_admin_pm(targets[target],null)

//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_admin_pm(client/C, msg = null, type = "PM")
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, span_danger("Error: Admin-PM: You are unable to use admin PM-s (muted)."))
		return

	if(!isclient(C))
		if(holder)
			to_chat(src, "<font color='red'>Error: Private-Message: Client not found.</font>")
		else
			to_chat(src, "<font color='red'>Error: Private-Message: Client not found. They may have lost connection, so try using an adminhelp!</font>")
		return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message to [key_name(C, 0, holder ? 1 : 0)]") as text|null

		if(!msg)
			return
		if(!C)
			if(holder)
				to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
			else
				to_chat(src, "<font color='red'>Error: Private-Message: Client not found. They may have lost connection, so try using an adminhelp!</font>")
			return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	msg = sanitize(msg)
	if(!msg)	return

	var/recieve_pm_type = "Player"
	if(holder)
		msg = emoji_parse(msg)
		//mod PMs are maroon
		//PMs sent from admins and mods display their rank
		if(holder)
			if(!C.holder && holder && holder.fakekey)
				recieve_pm_type = "Admin"
			else
				recieve_pm_type = holder.rank_names()

	else if(!C.holder)
		to_chat(src, "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>")
		return

	var/recieve_message

	if(holder && !C.holder)
		recieve_message = "[span_pm("<span class='howto'><b>-- Click the [recieve_pm_type]'s name to reply --</b>")]</span>\n"
		if(C.adminhelped)
			to_chat(C, recieve_message)
			C.adminhelped = 0

		//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
		if(CONFIG_GET(flag/popup_admin_pm))
			spawn(0)	//so we don't hold the requester proc up
				var/sender = src
				var/sendername = key
				var/reply = sanitize(input(C, msg,"[recieve_pm_type] PM from [sendername]", "") as text|null)		//show message and await a reply
				if(C && reply)
					if(sender)
						C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
					else
						adminhelp(reply)													//sender has left, adminhelp instead
				return

	to_chat(C, "[span_pm("<span class='in'>" + create_text_tag("pm_in", "", C) + " <b>\[[recieve_pm_type] PM\]</b> <span class='name'>[key_name(src, TRUE, C.holder ? 1 : 0)]")]: <span class='message linkify'>[msg]</span></span></span>")
	to_chat(src, "[span_pm("<span class='out'>" + create_text_tag("pm_out_alt", "PM", src) + " to <span class='name'>[ADMIN_FULLMONTY(src)]")]: <span class='message linkify'>[msg]</span></span></span>")

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins shouldn't be able to disable this
	if(C.get_preference_value(/datum/client_preference/staff/play_adminhelp_ping) == GLOB.PREF_HEAR)
		sound_to(C, 'sound/effects/adminhelp.ogg')

	send_adminalert2adminchat(message = "PM: [key_name(src)]->[key_name(C)]: [msg]")

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")


	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in GLOB.admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == src)
			continue
		if(X.key != key && X.key != C.key && (X.holder.rank_flags() & R_ADMIN|R_MENTOR))
			to_chat(X, "[span_pm("<span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'>[key_name(src, X, 0)]")] to [span_name("[key_name(C, X, 0)]")]: <span class='message linkify'>[msg]</span></span></span>")

	//Check if the mob being PM'd has any open admin tickets.
	var/tickets = list()
	if(type == "Mentorhelp")
		tickets = SSmentor_tickets.checkForTicket(C)
	else
		tickets = SStickets.checkForTicket(C)
	if(tickets)
		for(var/datum/ticket/i in tickets)
			i.addResponse(src, msg) // Add this response to their open tickets.
		return
	if(type == "Mentorhelp")
		if(check_rights(R_ADMIN|R_MENTOR, 0, C.mob)) //Is the person being pm'd an admin? If so we check if the pm'er has open tickets
			tickets = SSmentor_tickets.checkForTicket(src)
	else // Ahelp
		if(check_rights(R_ADMIN, 0, C.mob)) //Is the person being pm'd an admin? If so we check if the pm'er has open tickets
			tickets = SStickets.checkForTicket(src)

	if(tickets)
		for(var/datum/ticket/i in tickets)
			i.addResponse(src, msg)
		return


/client/proc/cmd_admin_irc_pm(sender)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>")
		return

	var/msg = input(src,"Message:", "Reply private message to [sender] on IRC / 400 character limit") as text|null

	if(!msg)
		return

	sanitize(msg)

	// Handled on Bot32's end, unsure about other bots
//	if(length(msg) > 400) // TODO: if message length is over 400, divide it up into seperate messages, the message length restriction is based on IRC limitations.  Probably easier to do this on the bots ends.
//		src << span_warning("Your message was not sent because it was more then 400 characters find your message below for ease of copy/pasting")
//		src << span_notice("[msg]")
//		return



	to_chat(src, "[span_pm("<span class='out'>" + create_text_tag("pm_out_alt", "", src) + " to <span class='name'>IRC-[sender]")]: [span_message("[msg]")]</span></span>")

	log_admin("PM: [key_name(src)]->IRC-[sender]: [msg]")
	for(var/client/X in GLOB.admins)
		if(X == src)
			continue
		if(X.holder.rank_flags() & R_ADMIN)
			to_chat(X, "[span_pm("<span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'>[key_name(src, X, 0)]")] to [span_name("IRC-[sender]")]: [span_message("[msg]")]</span></span>")
