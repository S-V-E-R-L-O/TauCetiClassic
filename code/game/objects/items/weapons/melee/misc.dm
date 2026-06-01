/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 10
	hitsound = list('sound/weapons/captainwhip.ogg')
	throwforce = 7
	w_class = SIZE_SMALL
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")

/obj/item/weapon/melee/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b></span>")
	return (OXYLOSS)

/obj/item/weapon/melee/chainofcommand/afterattack(atom/target, mob/living/user, proximity, params)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!isloyal(user))
		to_chat(user, "<span class='danger'[bicon(src)] SPECIAL FUNCTION DISABLED. LOYALTY IMPLANT NOT FOUND.</span>")
		return
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	user.visible_message("<span class='notice'>[user] flails their [src] at [H]</span>")
	if(locate(/obj/item/weapon/implant/fake/obedience) in H.implants)
		//like clumsy
		explosion(user.loc, 0, 0, 1, 7)
		to_chat(user, "<span class='danger'>[src] blows up in your face.</span>")
		if(isliving(user))
			var/mob/living/living_user = user
			living_user.Sleeping(15 SECONDS)
			if(ishuman(user))
				var/mob/living/carbon/human/user_human = living_user
				var/obj/item/organ/external/BP = user_human.get_bodypart(BP_ACTIVE_ARM)
				if(BP)
					BP.droplimb(FALSE, FALSE, DROPLIMB_BLUNT)
		to_chat(target, "<span class='userdanger'>COVER BLOWN!!! THEY KNOW ABOUT US!!!</span>")
		qdel(src)
		return
	if(!isimplantedobedience(H))
		return
	H.Stun(5)
	H.apply_effect(5, WEAKEN)
	H.apply_effect(20, AGONY)
	to_chat(H, "<span class='danger'You feel something beep inside of you and a wave of electricity pierces your body!</span>")
	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
	sparks.set_up(3, 0, get_turf(H))
	sparks.start()

/obj/item/weapon/melee/icepick
	name = "ice pick"
	desc = "Used for chopping ice. Also excellent for mafia esque murders."
	icon_state = "ice_pick"
	item_state = "ice_pick"
	force = 15
	throwforce = 10
	w_class = SIZE_TINY
	attack_verb = list("stabbed", "jabbed", "iced,")

/obj/item/weapon/melee/improvised_smasher
	name = "Кустарный разрубатель"
	cases = list("Кустарный разрубатель", "Кустарного разрубателя", "Кустарному разрубателю", "Кустарный разрубатель", "Кустарным разрубателем", "Кустарном разрубателе")
	desc = "Грубо сваренная из мусора железка, способная крушить всё подряд. Выглядит так, будто вот-вот развалится, но в умелых руках творит чудеса."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sorda"
	item_state = "sorda"
	force = 10
	throwforce = 10
	w_class = 4
	slot_flags = SLOT_FLAGS_BELT
	attack_verb = list("крушит", "разрубает", "вгрызается")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 1
	can_embed = FALSE

	var/dash_ready = TRUE
	var/dash_cooldown = 10 SECONDS
	var/dash_distance = 3

/obj/item/weapon/melee/improvised_smasher/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity || user.get_active_hand() != src)
		return ..()

	if(!dash_ready)
		to_chat(user, "<span class='warning'>[src] ещё не готов к рывку!</span>")
		return

	if(user.incapacitated())
		return

	var/dir_to_target = get_dir(user, target)
	if(dir_to_target == 0)
		return

	walk(user, 0)

	var/turf/start = get_turf(user)
	var/turf/current = start
	var/list/crossed_mobs = list()
	for(var/i in 1 to dash_distance)
		var/turf/next = get_step(current, dir_to_target)
		if(!next || next.density)
			break
		var/blocked = FALSE
		for(var/atom/movable/AM in next)
			if(AM == user)
				continue
			if(AM.density && !ismob(AM))
				blocked = TRUE
				break
		if(blocked)
			break
		current = next
		for(var/mob/living/L in current)
			if(L != user && !(L in crossed_mobs))
				crossed_mobs += L

	user.visible_message("<span class='danger'>[user] совершает рывок с [src]!</span>")
	playsound(user, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)

	dash_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_dash)), dash_cooldown)

	// Блокируем действия на время анимации
	user.SetNextMove(world.time + 3)

	var/dx = 0, dy = 0
	if(dir_to_target == NORTH)
		dy = (current.y - start.y) * 32
	else if(dir_to_target == SOUTH)
		dy = (current.y - start.y) * 32
	else if(dir_to_target == EAST)
		dx = (current.x - start.x) * 32
	else if(dir_to_target == WEST)
		dx = (current.x - start.x) * 32
	else if(dir_to_target == NORTHEAST)
		dx = (current.x - start.x) * 32; dy = (current.y - start.y) * 32
	else if(dir_to_target == NORTHWEST)
		dx = (current.x - start.x) * 32; dy = (current.y - start.y) * 32
	else if(dir_to_target == SOUTHEAST)
		dx = (current.x - start.x) * 32; dy = (current.y - start.y) * 32
	else if(dir_to_target == SOUTHWEST)
		dx = (current.x - start.x) * 32; dy = (current.y - start.y) * 32

	var/anim_time = 2
	var/matrix/stretch = matrix()
	if(abs(dx) > abs(dy))
		stretch.Scale(1.5, 0.8)
	else if(abs(dy) > abs(dx))
		stretch.Scale(0.8, 1.5)
	else
		stretch.Scale(1.3, 1.3)

	animate(user, pixel_x = dx, pixel_y = dy, transform = stretch, time = 0, easing = LINEAR_EASING)
	animate(transform = null, time = anim_time, easing = LINEAR_EASING)

	addtimer(CALLBACK(src, PROC_REF(finish_dash), user, current, crossed_mobs, start), anim_time)

/obj/item/weapon/melee/improvised_smasher/proc/finish_dash(mob/living/user, turf/target_turf, list/crossed_mobs, turf/start)
	if(QDELETED(user))
		return
	if(get_turf(user) != start)
		animate(user, pixel_x = 0, pixel_y = 0, transform = null, time = 0)
		to_chat(user, "<span class='warning'>Рывок прерван!</span>")
		return
	if(!target_turf || target_turf.density)
		animate(user, pixel_x = 0, pixel_y = 0, transform = null, time = 0)
		to_chat(user, "<span class='warning'>Рывок заблокирован!</span>")
		return

	user.forceMove(target_turf)
	animate(user, pixel_x = 0, pixel_y = 0, transform = null, time = 0)

	user.next_move = world.time

	if(crossed_mobs.len)
		for(var/mob/living/L in crossed_mobs)
			if(L != user)
				L.take_bodypart_damage(force / 2)
				L.visible_message("<span class='danger'>[user] проносится сквозь [L], нанося урон [src]!</span>")
		playsound(target_turf, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/melee/improvised_smasher/proc/reset_dash()
	dash_ready = TRUE
	if(ismob(loc))
		to_chat(loc, "<span class='notice'>[src] снова готов к рывку.</span>")

/obj/item/weapon/melee/syndicate_spear
	name = "Копьё синдиката"
	cases = list("Копьё синдиката", "Копья синдиката", "Копью синдиката", "Копьё синдиката", "Копьём синдиката", "Копье синдиката")
	desc = "Зазубренное копьё из тёмного металла с инкрустированной рукоятью. Кажется, оно жаждет крови."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sper"
	item_state = "sper"
	force = 15
	throwforce = 15
	w_class = 4
	slot_flags = SLOT_FLAGS_BACK
	attack_verb = list("пронзает", "вонзает", "протыкает")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 1
	can_embed = FALSE

	var/dash_ready = TRUE
	var/dash_cooldown = 7 SECONDS
	var/dash_distance = 3

	var/kills = 0
	var/max_force = 45
	var/base_force = 15

	var/dash_mode = TRUE

	// Отслеживание врагов: WEAKREF -> list(mob, world.time)
	var/list/tracked_targets = list()

/obj/item/weapon/melee/syndicate_spear/atom_init(mapload)
	. = ..()
	update_force()

/obj/item/weapon/melee/syndicate_spear/proc/update_force()
	force = min(base_force + kills * 2, max_force)

/obj/item/weapon/melee/syndicate_spear/attack_self(mob/user)
	..()
	dash_mode = !dash_mode
	if(dash_mode)
		to_chat(user, "<span class='notice'>Копьё переведено в режим рывка.</span>")
		playsound(src, 'sound/weapons/saberon.ogg', VOL_EFFECTS_MASTER)
	else
		to_chat(user, "<span class='notice'>Копьё переведено в боевой режим.</span>")
		playsound(src, 'sound/weapons/saberoff.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/melee/syndicate_spear/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(QDELETED(M) || M.stat == DEAD)
		return

	// Следим только за игроками, у которых есть key
	if(M.key)
		var/datum/weakref/ref = WEAKREF(M)
		if(!(ref in tracked_targets))
			RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(on_target_death))
		tracked_targets[ref] = list("mob" = M, "time" = world.time)

/obj/item/weapon/melee/syndicate_spear/proc/on_target_death(mob/living/target)
	SIGNAL_HANDLER
	var/datum/weakref/ref = WEAKREF(target)
	if(ref in tracked_targets)
		var/list/data = tracked_targets[ref]
		var/last_hit = data["time"]
		tracked_targets -= ref
		UnregisterSignal(target, COMSIG_MOB_DEATH)

		// Смерть в течение 30 секунд после последнего удара = засчитываем
		if(world.time - last_hit <= 30 SECONDS && force < max_force)
			kills++
			update_force()
			var/mob/holder = loc
			if(ismob(holder))
				to_chat(holder, "<span class='notice'>Копьё насыщается кровью поверженного врага! Текущий урон: [force]. Убийств: [kills].</span>")
				if(force >= max_force)
					to_chat(holder, "<span class='warning'>Копьё достигло максимальной остроты.</span>")

/obj/item/weapon/melee/syndicate_spear/Destroy()
	// Очищаем все отслеживаемые сигналы
	for(var/ref in tracked_targets)
		var/mob/M = tracked_targets[ref]["mob"]
		if(!QDELETED(M))
			UnregisterSignal(M, COMSIG_MOB_DEATH)
	tracked_targets = null
	return ..()

/obj/item/weapon/melee/syndicate_spear/afterattack(atom/target, mob/living/user, proximity, params)
	if(!dash_mode)
		return ..()

	if(!proximity || user.get_active_hand() != src)
		return ..()

	if(!dash_ready)
		to_chat(user, "<span class='warning'>Копьё ещё не готово к рывку!</span>")
		return

	if(user.incapacitated())
		return

	var/dir_to_target = get_dir(user, target)
	if(dir_to_target == 0)
		return

	walk(user, 0)

	var/turf/start = get_turf(user)
	var/turf/current = start
	var/list/crossed_mobs = list()
	for(var/i in 1 to dash_distance)
		var/turf/next = get_step(current, dir_to_target)
		if(!next || next.density)
			break
		var/blocked = FALSE
		for(var/atom/movable/AM in next)
			if(AM == user)
				continue
			if(AM.density && !ismob(AM))
				blocked = TRUE
				break
		if(blocked)
			break
		current = next
		for(var/mob/living/L in current)
			if(L != user && !(L in crossed_mobs))
				crossed_mobs += L

	user.visible_message("<span class='danger'>[user] совершает рывок с [src]!</span>")
	playsound(user, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)

	dash_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_dash)), dash_cooldown)

	user.SetNextMove(world.time + 3)

	var/dx = 0, dy = 0
	if(dir_to_target == NORTH)
		dy = (current.y - start.y) * 32
	else if(dir_to_target == SOUTH)
		dy = (current.y - start.y) * 32
	else if(dir_to_target == EAST)
		dx = (current.x - start.x) * 32
	else if(dir_to_target == WEST)
		dx = (current.x - start.x) * 32
	else if(dir_to_target == NORTHEAST)
		dx = (current.x - start.x) * 32; dy = (current.y - start.y) * 32
	else if(dir_to_target == NORTHWEST)
		dx = (current.x - start.x) * 32; dy = (current.y - start.y) * 32
	else if(dir_to_target == SOUTHEAST)
		dx = (current.x - start.x) * 32; dy = (current.y - start.y) * 32
	else if(dir_to_target == SOUTHWEST)
		dx = (current.x - start.x) * 32; dy = (current.y - start.y) * 32

	var/anim_time = 2
	var/matrix/stretch = matrix()
	if(abs(dx) > abs(dy))
		stretch.Scale(1.5, 0.8)
	else if(abs(dy) > abs(dx))
		stretch.Scale(0.8, 1.5)
	else
		stretch.Scale(1.3, 1.3)

	animate(user, pixel_x = dx, pixel_y = dy, transform = stretch, time = 0, easing = LINEAR_EASING)
	animate(transform = null, time = anim_time, easing = LINEAR_EASING)

	addtimer(CALLBACK(src, PROC_REF(finish_dash), user, current, crossed_mobs, start), anim_time)

/obj/item/weapon/melee/syndicate_spear/proc/finish_dash(mob/living/user, turf/target_turf, list/crossed_mobs, turf/start)
	if(QDELETED(user))
		return
	if(get_turf(user) != start)
		animate(user, pixel_x = 0, pixel_y = 0, transform = null, time = 0)
		to_chat(user, "<span class='warning'>Рывок прерван!</span>")
		return
	if(!target_turf || target_turf.density)
		animate(user, pixel_x = 0, pixel_y = 0, transform = null, time = 0)
		to_chat(user, "<span class='warning'>Рывок заблокирован!</span>")
		return

	user.forceMove(target_turf)
	animate(user, pixel_x = 0, pixel_y = 0, transform = null, time = 0)
	user.next_move = world.time

	if(crossed_mobs.len)
		for(var/mob/living/L in crossed_mobs)
			if(L != user)
				L.take_bodypart_damage(force / 2)
				L.visible_message("<span class='danger'>[user] пронзает [L] копьём, проносясь сквозь!</span>")
		playsound(target_turf, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/melee/syndicate_spear/proc/reset_dash()
	dash_ready = TRUE
	if(ismob(loc))
		to_chat(loc, "<span class='notice'>Копьё снова готово к рывку.</span>")