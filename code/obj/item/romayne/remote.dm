/obj/item/remote/coderunner
	name = "The Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "Pressing this may have untold consequences."
	icon_state = "locator"
	item_state = "electronic"
	density = 0
	anchored = UNANCHORED
	w_class = W_CLASS_SMALL

	attack_self(mob/user as mob)
		for(var/i = 0, i < 100, i++)
			test_mix(user,215,1385)
			sleep(10)
/*
	attack_self(mob/user as mob)
		text2file("oxygen,plasma,power","ttvs.txt")
		for(var/oxyTemp = 100, oxyTemp <= 300, oxyTemp++)
			for(var/plasmaTemp= 500, plasmaTemp <= 2500, plasmaTemp ++)
				test_mix(user,oxyTemp,plasmaTemp)
				if(world.tick_usage > 90)
					sleep(10)
		boutput(user,"Wait a half minute for remaining TTVs..")
		sleep(300)
		boutput(user,"Should be done.")
*/
	proc/test_mix(mob/user as mob,var/oxy,var/pla)
		var/obj/item/device/transfer_valve/ttv = new()
		var/obj/item/tank/PT = new() // Replace with /test/tank to remove exploding and have CSV output
		var/obj/item/tank/OT = new()
		OT.air_contents.temperature = oxy
		OT.air_contents.oxygen = (1013.25 * OT.air_contents.volume) / (8.314 * OT.air_contents.temperature) // n = PV/RT
		PT.air_contents.temperature = pla
		PT.air_contents.toxins = (1013.25 * PT.air_contents.volume) / (8.314 * PT.air_contents.temperature)
		ttv.tank_one = PT
		PT.set_loc(ttv)
		ttv.tank_two = OT
		OT.set_loc(ttv)
		ttv.loc = user.loc
		ttv.UpdateIcon()
		ttv.toggle_valve()
		/*
		SPAWN(100)
			var/i = 100
			while(i-->0)
				if(PT.power > 0)
					break
				sleep(1)
			//boutput(world,"[oxy],[pla],[PT.power]")
			text2file("[oxy],[pla],[PT.power]","ttvs.txt")
			qdel(ttv)
		*/ // Uncomment with testing TTVs


/obj/item/tank/test
	name = "Testing tank"
	desc = "A tank made for testing the would-be explosions of TTVs. It appears to have a weak inner shell similar to that of a regular tank, with a pressure sensure to measure the power."
	/// The power of the explosion.
	var/power = 0

	check_status()
		// Get aforementioned power
		if(!air_contents)
			power = max(0,power)
			return
		var/pressure = MIXTURE_PRESSURE(air_contents)
		if(pressure > TANK_FRAGMENT_PRESSURE) // 50 atmospheres, or: 5066.25 kpa under current _setup.dm conditions
			//Give the gas a chance to build up more pressure through reacting
			playsound(src.loc, 'sound/machines/hiss.ogg', 50, TRUE)
			air_contents.react()
			air_contents.react()
			air_contents.react()
			pressure = MIXTURE_PRESSURE(air_contents)
			var/range = (pressure - TANK_FRAGMENT_PRESSURE) / TANK_FRAGMENT_SCALE
			power = min(range, 12)
			boutput(world,"[power]")
			air_contents = null
		else if(pressure > TANK_RUPTURE_PRESSURE)
			if(integrity <= 0)
				power = max(0,power)
				air_contents = null
				src.visible_message("<span class='alert'>[src] violently ruptures!</span>")
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 60, TRUE)
			else
				integrity--
		else if(pressure > TANK_LEAK_PRESSURE)
			if(integrity <= 0)
				playsound(src.loc, 'sound/effects/spray.ogg', 50, TRUE)
				power = max(0,power)
				air_contents = null
			else
				integrity--
		else if(integrity < 3)
			integrity++
