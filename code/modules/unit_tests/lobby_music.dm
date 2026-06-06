// Checks if all lobby music is included at least once in one of the lobby screens
/datum/unit_test/lobby_music/Run()
	check_all_music_is_used()
	check_all_music_has_valid_properties()

/datum/unit_test/lobby_music/proc/check_all_music_has_valid_properties()
	var/list/types = list()
	for(var/datum/lobbyscreen_music/artist as anything in subtypesof(/datum/lobbyscreen_music))
		// example: /datum/lobbyscreen_music/duke_gneiss
		for(var/datum/lobbyscreen_music/track as anything in subtypesof(artist))
			// example: /datum/lobbyscreen_music/duke_gneiss/bluespace
			if(isnull(initial(track.title)))
				TEST_FAIL("Lobby track '[track]' has a bad/null author_url")
			if(isnull(initial(track.file)))
				TEST_FAIL("Lobby track '[track]' has a bad/null file")
			if(isnull(initial(track.artist)))
				TEST_FAIL("Lobby track '[track]' has a bad/null artist")
			if(isnull(initial(track.artist_url)))
				TEST_FAIL("Lobby track '[track]' has a bad/null artist_url")


/datum/unit_test/lobby_music/proc/check_all_music_is_used()
	for(var/datum/lobbyscreen_music/artist as anything in subtypesof(/datum/lobbyscreen_music))
		for(var/datum/lobbyscreen_music/track as anything in subtypesof(artist))
			if (!check_screens_for_track(track))
				TEST_FAIL("Lobby track '[track]' has no lobby screen parents!")

/datum/unit_test/lobby_music/proc/check_screens_for_track(datum/lobbyscreen_music/track)
	for(var/datum/lobbyscreen/artist as anything in subtypesof(/datum/lobbyscreen))
		for(var/datum/lobbyscreen/screen_type as anything in subtypesof(artist))
			var/datum/lobbyscreen/lobby_screen = new screen_type
			if(track in lobby_screen.possible_music)
				return TRUE
