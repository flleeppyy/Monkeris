/datum/extension/multitool
	var/window_x = 370
	var/window_y = 470

/datum/extension/multitool/proc/interact(var/obj/item/tool/multitool/M, var/mob/user)
	if(extension_status(user) != STATUS_INTERACTIVE)
		return

	var/html = get_interact_window(M, user)
	if(html)
		var/datum/browser/popup = new(usr, "multitool", "Multitool Menu", window_x, window_y)
		popup.set_content(html)
		popup.open()
	else
		close_window(usr)

/datum/extension/multitool/proc/get_interact_window(var/obj/item/tool/multitool/M, var/mob/user)
	return

/datum/extension/multitool/proc/close_window(var/mob/user)
	user << browse(null, "window=multitool")

/datum/extension/multitool/proc/buffer(var/obj/item/tool/multitool/multitool)
	. += "<b>Buffer Memory:</b><br>"
	var/buffer_name = multitool.get_buffer_name()
	if(buffer_name)
		. += "[buffer_name] <a href='byond://?src=\ref[src];send=\ref[multitool.buffer_object]'>Send</a> <a href='byond://?src=\ref[src];purge=1'>Purge</a><br>"
	else
		. += "No connection stored in the buffer."

/datum/extension/multitool/extension_status(var/mob/user)
	if(!user.get_multitool())
		return STATUS_CLOSE
	. = ..()

/datum/extension/multitool/extension_act(href, href_list, var/mob/user)
	if(..())
		close_window(usr)
		return TRUE

	var/obj/item/tool/multitool/M = user.get_multitool()
	if(href_list["send"])
		var/atom/buffer = locate(href_list["send"])
		. = send_buffer(M, buffer, user)
	else if(href_list["purge"])
		M.set_buffer(null)
		. = MT_REFRESH
	else
		. = on_topic(href, href_list, user)

	switch(.)
		if(MT_REFRESH)
			interact(M, user)
		if(MT_CLOSE)
			close_window(user)
	return MT_NOACTION ? FALSE : TRUE

/datum/extension/multitool/proc/on_topic(href, href_list, user)
	return MT_NOACTION

/datum/extension/multitool/proc/send_buffer(var/obj/item/tool/multitool/M, var/atom/buffer, var/mob/user)
	if(M.get_buffer() == buffer && buffer)
		receive_buffer(M, buffer, user)
	else if(!buffer)
		to_chat(user, span_warning("Unable to acquire data from the buffered object. Purging from memory."))
	return MT_REFRESH

/datum/extension/multitool/proc/receive_buffer(var/obj/item/tool/multitool/M, var/atom/buffer, var/mob/user)
	return
