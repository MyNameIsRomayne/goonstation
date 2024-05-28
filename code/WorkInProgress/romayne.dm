

//ABSTRACT_TYPE(/obj/ore_patch)
/obj/ore_patch
	name = "The very conceptulization of free rocks"
	desc = "You shouldn't be seeing this! Report it to a coder."

/obj/item/coder_button
	name = "Var Detector 9000"
	desc = "Use this to sniff out variables on anything!!!"
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "button_comp_button_unpressed"

	var/list/var_list

	attack_self(mob/user)
		src.ui_interact(user)

	ui_data(mob/user)
		return list(
			"var_data" = src.var_list,
		)

	ui_act(action, params)
		if (action == "query")
			src.update_vars_by_origin(params["path"])
		tgui_process.try_update_ui(usr, src)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "VarReader")
			ui.open()

	// get parents of path from most primitive to most abstract. eg ["/obj", "/obj/item", "/obj/item/weldingtool"]
	proc/get_parents_of_path(var/typepath)
		var/list/parent_types = list()
		var/list/type_parts = splittext(typepath, "/")
		type_parts.Remove("")
		for (var/i in 1 to length(type_parts))
			var/work_in_partgress = ""
			for (var/parts_to_merge in 1 to i)
				work_in_partgress += "/[type_parts[parts_to_merge]]"

			parent_types += work_in_partgress
		return parent_types

	proc/values_differ(var/value1, var/value2)



	// update var_list with the new typepath we wish to investigate.
	proc/update_vars_by_origin(var/typepath)
		var/type_path = text2path(typepath)
		if (!type_path)
			return
		var/list/parent_types = src.get_parents_of_path(typepath)

		src.var_list = list()
		var/used_vars = list()

		for (var/parent_type in parent_types)
			var/datum/path = text2path(parent_type)
			var/datum/path_instantiated = new path
			var/path_vars = path_instantiated.vars
			for (var/key in path_vars)
				var/value = path_vars[key]
				if (key in used_vars)
					if (value == src.var_list[parent_type][key]["value"])
						continue
				else
					used_vars[key] = parent_type

				//var/output_data = list(list("name"=key, "value"=value, "islist"=islist(value), "istype" = istype(path_vars[key], /datum)))

			qdel(path_instantiated)

	proc/list_as_str_why_isnt_this_a_global_fuck(var/list/L)
		var/output = ""
		for (var/i in 1 to length(L))
			output += "[L[i]]"
			if (i != length(L))
				output += ", "
		return "\[[output]\]"
