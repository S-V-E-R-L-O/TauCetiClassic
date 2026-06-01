#ifndef COMSIG_MOB_DEATH
#define COMSIG_MOB_DEATH "mob_death"
#endif

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

    var/turf/target_turf = get_turf(target)
    if(!target_turf)
        return

    // Проверяем дистанцию
    if(get_dist(user, target_turf) > dash_distance)
        to_chat(user, "<span class='warning'>Слишком далеко!</span>")
        return

    // Проверяем видимость
    if(!(target_turf in view(user)))
        to_chat(user, "<span class='warning'>Вы не видите это место!</span>")
        return

    // Проверяем, что это не стена
    if(target_turf.density)
        to_chat(user, "<span class='warning'>Невозможно совершить рывок в препятствие!</span>")
        return

    // Останавливаем бег
    walk(user, 0)
    user.move_dir = 0

    // Собираем мобов на линии
    var/list/crossed_mobs = list()
    for(var/turf/T in get_line(user, target_turf))
        if(T == get_turf(user))
            continue
        for(var/mob/living/L in T)
            if(L != user && !(L in crossed_mobs))
                crossed_mobs += L

    user.visible_message("<span class='danger'>[user] совершает рывок с [src]!</span>")
    playsound(user, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)

    dash_ready = FALSE
    addtimer(CALLBACK(src, PROC_REF(reset_dash)), dash_cooldown)

    user.SetNextMove(world.time + 3)

    var/turf/start = get_turf(user)
    var/dx = (target_turf.x - start.x) * 32
    var/dy = (target_turf.y - start.y) * 32
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

    addtimer(CALLBACK(src, PROC_REF(finish_dash), user, target_turf, crossed_mobs, start), anim_time)

/obj/item/weapon/melee/improvised_smasher/proc/finish_dash(mob/living/user, turf/target_turf, list/crossed_mobs, turf/start)
    if(!QDELETED(user))
        user.next_move = world.time
        user.move_dir = 0
        walk(user, 0)
        animate(user, pixel_x = 0, pixel_y = 0, transform = null, time = 0)

    if(QDELETED(user) || !target_turf || target_turf.density)
        if(!QDELETED(user))
            to_chat(user, "<span class='warning'>Рывок не удался!</span>")
        return

    user.forceMove(target_turf)

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
    var/dash_distance = 4   // копьё бьёт дальше

    var/kills = 0
    var/max_force = 45
    var/base_force = 15

    var/dash_mode = TRUE

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
    if(!QDELETED(M) && M.stat == DEAD && M.key && force < max_force)
        kills++
        update_force()
        to_chat(user, "<span class='notice'>Копьё насыщается кровью! Текущий урон: [force]. Убийств: [kills].</span>")
        if(force >= max_force)
            to_chat(user, "<span class='warning'>Копьё достигло максимальной остроты.</span>")

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

    var/turf/target_turf = get_turf(target)
    if(!target_turf)
        return

    // Проверяем дистанцию
    if(get_dist(user, target_turf) > dash_distance)
        to_chat(user, "<span class='warning'>Слишком далеко!</span>")
        return

    // Проверяем видимость
    if(!(target_turf in view(user)))
        to_chat(user, "<span class='warning'>Вы не видите это место!</span>")
        return

    // Проверяем, что это не стена
    if(target_turf.density)
        to_chat(user, "<span class='warning'>Невозможно совершить рывок в препятствие!</span>")
        return

    // Останавливаем бег
    walk(user, 0)
    user.move_dir = 0

    // Собираем мобов на линии
    var/list/crossed_mobs = list()
    for(var/turf/T in get_line(user, target_turf))
        if(T == get_turf(user))
            continue
        for(var/mob/living/L in T)
            if(L != user && !(L in crossed_mobs))
                crossed_mobs += L

    user.visible_message("<span class='danger'>[user] совершает рывок с [src]!</span>")
    playsound(user, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)

    dash_ready = FALSE
    addtimer(CALLBACK(src, PROC_REF(reset_dash)), dash_cooldown)

    user.SetNextMove(world.time + 3)

    var/turf/start = get_turf(user)
    var/dx = (target_turf.x - start.x) * 32
    var/dy = (target_turf.y - start.y) * 32
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

    addtimer(CALLBACK(src, PROC_REF(finish_dash), user, target_turf, crossed_mobs, start), anim_time)

/obj/item/weapon/melee/syndicate_spear/proc/finish_dash(mob/living/user, turf/target_turf, list/crossed_mobs, turf/start)
    if(!QDELETED(user))
        user.next_move = world.time
        user.move_dir = 0
        walk(user, 0)
        animate(user, pixel_x = 0, pixel_y = 0, transform = null, time = 0)

    if(QDELETED(user) || !target_turf || target_turf.density)
        if(!QDELETED(user))
            to_chat(user, "<span class='warning'>Рывок не удался!</span>")
        return

    user.forceMove(target_turf)

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