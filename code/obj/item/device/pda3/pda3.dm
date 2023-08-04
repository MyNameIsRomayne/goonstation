// Ohhh im in for it now

/obj/item/device/pda3
	name = "Advanced PDA"
	desc = "An experimental prototype PDA with what reviewers have claimed to be a \"Fancy as FUCK GUI\". Whatever that means."
	icon = 'icons/obj/items/pda.dmi'
	icon_state = "pda"
	item_state = "pda"
	w_class = W_CLASS_SMALL
	rand_pos = 0
	flags = FPRINT | TABLEPASS
	c_flags = ONBELT
	wear_layer = MOB_BELT_LAYER
	var/obj/item/card/id/ID_card = null // slap an ID card into that thang
	var/obj/item/pen = null // slap a pen into that thang
	var/registered = null // so we don't need to replace all the dang checks for ID cards
	var/assignment = null
	var/access = list()
	var/image/ID_image = null
	var/owner = null
	var/ownerAssignment = null
	var/obj/item/disk/data/cartridge/cartridge = null //current cartridge
	var/ejectable_cartridge = 1
	var/datum/computer/file/pda_program/active_program = null
	var/datum/computer/file/pda_program/os/main_os/host_program = null
	var/datum/computer/file/pda_program/scan/scan_program = null
	var/datum/computer/file/pda_program/fileshare/fileshare_program = null
	var/obj/item/disk/data/fixed_disk/hd = null
	var/closed = 1 //Can we insert a module now?
	var/obj/item/uplink/integrated/pda/uplink = null
	var/obj/item/device/pda_module/module = null
	var/frequency = FREQ_PDA
	var/beacon_freq = FREQ_NAVBEACON //Beacon frequency for locating beacons (I love beacons)
	var/net_id = null //Hello dude intercepting our radio transmissions, here is a number that is not just \ref
	var/scannable = TRUE // Whether this PDA is picked up when scanning for PDAs on the messenger

	var/tmp/list/pdasay_autocomplete = list()

	var/tmp/list/image/overlay_images = null
	var/tmp/current_overlay = "idle"

	var/bg_color = "#6F7961"
	var/link_color = "#000000"
	var/linkbg_color = "#565D4B"
	var/graphic_mode = 0

	var/setup_default_pen = /obj/item/pen //PDAs can contain writing implements by default
	var/setup_default_cartridge = null //Cartridge contains job-specific programs
	var/setup_drive_size = 32 //PDAs don't have much work room at all, really.
	// 2020 zamu update: 24 -> 32
	var/setup_system_os_path = /datum/computer/file/pda_program/os/main_os //Needs an operating system to...operate!!
	var/setup_scanner_on = 1 //Do we search the cart for a scanprog to start loaded?
	var/setup_default_module = /obj/item/device/pda_module/flashlight //Module to have installed on spawn.
	var/mailgroups = list(MGO_STAFF,MGD_PARTY) //What default mail groups the PDA is part of.
	var/default_muted_mailgroups = list() //What mail groups should the PDA ignore by default
	var/reserved_mailgroups = list( // Job-specific mailgroups that cannot be joined or left
		// Departments
		MGD_COMMAND, MGD_SECURITY, MGD_MEDBAY, MGD_MEDRESEACH, MGD_SCIENCE, MGD_CARGO, MGD_STATIONREPAIR, MGD_BOTANY, MGD_MINING, MGD_KITCHEN, MGD_SPIRITUALAFFAIRS,
		// Other
		MGO_STAFF, MGO_AI, MGO_SILICON, MGO_JANITOR, MGO_ENGINEER,
		// Alerts
		MGA_MAIL, MGA_RADIO, MGA_CHECKPOINT, MGA_ARREST, MGA_DEATH, MGA_MEDCRIT, MGA_CLONER, MGA_ENGINE, MGA_RKIT, MGA_SALES, MGA_SHIPPING, MGA_CARGOREQUEST, MGA_CRISIS, MGA_TRACKING,
	)
	var/alertgroups = list(MGA_MAIL, MGA_RADIO) // What mail groups that we're not a member of should we be able to mute?
	var/bombproof = 0 // can't be destroyed with detomatix
	var/exploding = 0
	/// Syndie sound programs can blow out the speakers and render it forever *silent*
	var/speaker_busted = 0

	/// The PDA's currently loaded ringtone set
	var/datum/ringtone/r_tone = /datum/ringtone
	/// A temporary ringtone set for preview purposed
	var/datum/ringtone/r_tone_temp
	/// A list of ringtones tied to an alert -- Overrides whatever settings set for their mailgroup. Typically remains static in length
	var/list/alert_ringtones = list(MGA_MAIL = null,\
																	MGA_CHECKPOINT = null,\
																	MGA_ARREST = null,\
																	MGA_DEATH = null,\
																	MGA_MEDCRIT = null,\
																	MGA_CLONER = null,\
																	MGA_ENGINE = null,\
																	MGA_RKIT = null,\
																	MGA_SALES = null,\
																	MGA_SHIPPING = null,\
																	MGA_CARGOREQUEST = null,\
																	MGA_CRISIS = null,\
																	MGA_RADIO = null)

	/// mailgroup-specific ringtones, added on the fly!
	var/list/mailgroup_ringtones = list()

	registered_owner()
		.= registered
