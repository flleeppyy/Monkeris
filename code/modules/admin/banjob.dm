//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

var/jobban_runonce			// Updates legacy bans with new info
var/jobban_keylist[0]		//to store the keys & ranks

/proc/jobban_fullban(mob/M, rank, reason)
	if (!M || !M.key) return
	jobban_keylist.Add(text("[M.ckey] - [rank] ## [reason]"))
	jobban_savebanfile()

/proc/jobban_client_fullban(ckey, rank)
	if (!ckey || !rank) return
	jobban_keylist.Add(text("[ckey] - [rank]"))
	jobban_savebanfile()

//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(M && rank)
		/*
		if(_jobban_isbanned(M, rank)) return "Reason Unspecified"	//for old jobban
		*/

		for (var/s in jobban_keylist)
			if( findtext(s,"[M.ckey] - [rank]") == 1 )
				var/startpos = findtext(s, "## ")+3
				if(startpos && startpos<length(s))
					var/text = copytext(s, startpos, 0)
					if(text)
						return text
				return "Reason Unspecified"
	return 0

/*
DEBUG
/mob/verb/list_all_jobbans()
	set name = "list all jobbans"

	for(var/s in jobban_keylist)
		world << s

/mob/verb/reload_jobbans()
	set name = "reload jobbans"

	jobban_loadbanfile()
*/


/hook/startup/proc/loadJobBans()
	jobban_loadbanfile()
	return 1

/proc/jobban_loadbanfile()
	if(CONFIG_GET(flag/ban_legacy_system))
		var/savefile/S=new("data/job_full.ban")
		S["keys[0]"] >> jobban_keylist
		log_admin("Loading jobban_rank")
		S["runonce"] >> jobban_runonce

		if (!length(jobban_keylist))
			jobban_keylist=list()
			log_admin("jobban_keylist was empty")
	else
		if(!establish_db_connection())
			log_runtime("Database connection failed. Reverting to the legacy ban system.")
			CONFIG_SET(flag/ban_legacy_system, 1)
			jobban_loadbanfile()
			return

		//Job permabans
		var/DBQuery/perma_query = dbcon.NewQuery("SELECT target_id, job FROM bans WHERE type = 'JOB_PERMABAN' AND isnull(unbanned)")
		perma_query.Execute()

		while(perma_query.NextRow())
			var/id = perma_query.item[1]
			var/job = perma_query.item[2]
			var/DBQuery/get_ckey = dbcon.NewQuery("SELECT ckey from players WHERE id = '[id]'")
			get_ckey.Execute()
			if(get_ckey.NextRow())
				var/ckey = get_ckey.item[1]
				jobban_keylist.Add("[ckey] - [job]")



		//Job tempbans
		var/DBQuery/query = dbcon.NewQuery("SELECT target_id, job FROM bans WHERE type = 'JOB_TEMPBAN' AND isnull(unbanned) AND expiration_time > Now()")
		query.Execute()

		while(query.NextRow())
			var/id = query.item[1]
			var/job = query.item[2]
			var/DBQuery/get_ckey = dbcon.NewQuery("SELECT ckey from players WHERE id = '[id]'")
			get_ckey.Execute()
			if(get_ckey.NextRow())
				var/ckey = get_ckey.item[1]
				jobban_keylist.Add("[ckey] - [job]")



/proc/jobban_savebanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] << jobban_keylist

/proc/jobban_unban(mob/M, rank)
	jobban_remove("[M.ckey] - [rank]")
	jobban_savebanfile()


/proc/ban_unban_log_save(var/formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")


/proc/jobban_remove(X)
	for (var/i = 1; i <= length(jobban_keylist); i++)
		if( findtext(jobban_keylist[i], "[X]") )
			jobban_keylist.Remove(jobban_keylist[i])
			jobban_savebanfile()
			return 1
	return 0
