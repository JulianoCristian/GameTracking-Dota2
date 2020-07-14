LinkLuaModifier( "modifier_minor_ability_upgrades", "modifiers/modifier_minor_ability_upgrades", LUA_MODIFIER_MOTION_NONE )

_G.MINOR_ABILITY_UPGRADE_OP_ADD = 1
_G.MINOR_ABILITY_UPGRADE_OP_MUL = 2

_G.MINOR_ABILITY_UPGRADES =
{
   npc_dota_hero_magnataur = require( "minor_ability_upgrades/minor_ability_upgrades_magnataur" ),
   npc_dota_hero_phantom_assassin = require( "minor_ability_upgrades/minor_ability_upgrades_phantom_assassin" ),
   npc_dota_hero_snapfire = require( "minor_ability_upgrades/minor_ability_upgrades_snapfire" ),
   npc_dota_hero_disruptor = require( "minor_ability_upgrades/minor_ability_upgrades_disruptor" ),
   npc_dota_hero_winter_wyvern = require( "minor_ability_upgrades/minor_ability_upgrades_winter_wyvern" ),
   npc_dota_hero_tusk = require( "minor_ability_upgrades/minor_ability_upgrades_tusk" ),
   npc_dota_hero_ursa = require( "minor_ability_upgrades/minor_ability_upgrades_ursa" ),
   npc_dota_hero_sniper = require( "minor_ability_upgrades/minor_ability_upgrades_sniper" ),
   npc_dota_hero_mars = require( "minor_ability_upgrades/minor_ability_upgrades_mars" ),
   npc_dota_hero_viper = require( "minor_ability_upgrades/minor_ability_upgrades_viper" ),
   npc_dota_hero_weaver = require( "minor_ability_upgrades/minor_ability_upgrades_weaver" ),
   npc_dota_hero_omniknight = require( "minor_ability_upgrades/minor_ability_upgrades_omniknight" ),
   npc_dota_hero_witch_doctor = require( "minor_ability_upgrades/minor_ability_upgrades_witch_doctor" ),


   --non hero specific upgrades (bonus HP/mana/damage/etc.)
   base_stats_upgrades = require( "minor_ability_upgrades/base_minor_stats_upgrades" ),
}

_G.ULTIMATE_ABILITY_NAMES =
{
   npc_dota_hero_omniknight = "omniknight_guardian_angel",
   npc_dota_hero_magnataur = "magnataur_reverse_polarity_radius",
   npc_dota_hero_phantom_assassin = "phantom_assassin_coup_de_grace",
   npc_dota_hero_winter_wyvern = "winter_wyvern_winters_curse",
   npc_dota_hero_disruptor = "disruptor_static_storm",
   npc_dota_hero_snapfire = "snapfire_mortimer_kisses", 
   npc_dota_hero_tusk = "tusk_walrus_punch",
   npc_dota_hero_ursa = "ursa_enrage",
   npc_dota_hero_sniper = "sniper_assassinate",
   npc_dota_hero_mars = "mars_arena_of_blood",
   npc_dota_hero_viper = "viper_viper_strike",
   npc_dota_hero_weaver = "weaver_time_lapse",
   npc_dota_hero_witch_doctor = "witch_doctor_death_ward",
}

-- Lists for ability upgrades go here
_G.SPECIAL_ABILITY_UPGRADES = {}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_omniknight"] =
{
	"aghsfort_special_omniknight_purification_cast_radius",
	"aghsfort_special_omniknight_purification_charges",
	"aghsfort_special_omniknight_purification_cooldown_reduction",
	"aghsfort_special_omniknight_purification_multicast",

   "aghsfort_special_omniknight_repel_procs_purification",
   "aghsfort_special_omniknight_repel_outgoing_damage",
   --"aghsfort_special_omniknight_repel_applies_degen_aura", --needs some re-write to make it work in all cases and doesn't seem interesting anyway
   "aghsfort_special_omniknight_repel_damage_instance_refraction",
   "aghsfort_special_omniknight_repel_knockback_on_cast",

   "aghsfort_special_omniknight_degen_aura_toggle",
   "aghsfort_special_omniknight_degen_aura_damage",
   "aghsfort_special_omniknight_degen_aura_restoration",

   "aghsfort_special_omniknight_guardian_angel_purification",
   "aghsfort_special_omniknight_guardian_angel_immune_flight",
   --"aghsfort_special_omniknight_guardian_angel_single_target",
   "aghsfort_special_omniknight_guardian_angel_single_target_dummy",

}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_magnataur"] =
{
   "aghsfort_special_magnataur_shockwave_multishot",
	"aghsfort_special_magnataur_shockwave_damage_reduction",
   "aghsfort_special_magnataur_shockwave_boomerang",

	"aghsfort_special_magnataur_empower_all_allies",
   "aghsfort_special_magnataur_empower_lifesteal",
   "aghsfort_special_magnataur_empower_shockwave_on_attack",

   --"aghsfort_special_magnataur_skewer_original_scepter",
   --"aghsfort_special_magnataur_friendly_skewer",
   "aghsfort_special_magnataur_skewer_bonus_strength",
   "aghsfort_special_magnataur_skewer_heal",
   "aghsfort_special_magnataur_skewer_shockwave",

   --"aghsfort_special_magnataur_reverse_polarity_radius",
   "aghsfort_special_magnataur_reverse_polarity_polarity_dummy",
   "aghsfort_special_magnataur_reverse_polarity_allies_crit",
   "aghsfort_special_magnataur_reverse_polarity_steroid",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_phantom_assassin"] =
{
	"aghsfort_special_phantom_assassin_coup_de_grace_marks_target",
   "aghsfort_special_phantom_assassin_coup_de_grace_bloody_debuff",
   "aghsfort_special_phantom_assassin_coup_de_grace_kills_refresh",

	"aghsfort_special_phantom_assassin_stifling_dagger_no_secondary_dagger_restriction",
	"aghsfort_special_phantom_assassin_stifling_dagger_on_attack",
	"aghsfort_special_phantom_assassin_stifling_dagger_autodagger",

	"aghsfort_special_phantom_assassin_blur_regen_when_active",
	"aghsfort_special_phantom_assassin_blur_dagger_on_end",
	"aghsfort_special_phantom_assassin_blur_immediate",

	"aghsfort_special_phantom_assassin_phantom_strike_buff_allies",
	"aghsfort_special_phantom_assassin_phantom_strike_mastery",
	"aghsfort_special_phantom_assassin_phantom_strike_damage_reduction",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_luna"] =
{
	"omniknight_guardian_angel",
	"aghsfort_special_omniknight_purification_cast_radius",
	"omniknight_purification",
}


SPECIAL_ABILITY_UPGRADES["npc_dota_hero_winter_wyvern"] =
{
   "aghsfort_special_winter_wyvern_arctic_burn_splitshot",
   "aghsfort_special_winter_wyvern_arctic_burn_doubleattack",
   --"aghsfort_special_winter_wyvern_arctic_burn_nomana",
   "aghsfort_special_winter_wyvern_arctic_burn_splash_damage",

   "aghsfort_special_winter_wyvern_splinter_blast_main_target_hit",
   "aghsfort_special_winter_wyvern_splinter_blast_vacuum",
   "aghsfort_special_winter_wyvern_splinter_blast_heal",

   "aghsfort_special_winter_wyvern_cold_embrace_charges",
   "aghsfort_special_winter_wyvern_cold_embrace_blast_on_end",
   "aghsfort_special_winter_wyvern_cold_embrace_magic_damage_block",

   "aghsfort_special_winter_wyvern_winters_curse_transfer",
   "aghsfort_special_winter_wyvern_winters_curse_damage_amp",
   "aghsfort_special_winter_wyvern_winters_curse_heal_on_death",
}


SPECIAL_ABILITY_UPGRADES["npc_dota_hero_disruptor"] =
{
	"aghsfort_special_disruptor_thunder_strike_interval_upgrade",
	"aghsfort_special_disruptor_thunder_strike_mana_restore",
	"aghsfort_special_disruptor_thunder_strike_crit_chance",
	"aghsfort_special_disruptor_thunder_strike_on_attack",

--	"aghsfort_special_disruptor_glimpse_cast_aoe",
	"aghsfort_special_disruptor_glimpse_hit_on_arrival",
	"aghsfort_special_disruptor_glimpse_travel_damage",

	--"aghsfort_special_disruptor_kinetic_field_instant_setup",
	"aghsfort_special_disruptor_kinetic_field_damage",
	"aghsfort_special_disruptor_kinetic_field_allied_heal",
	"aghsfort_special_disruptor_kinetic_field_allied_attack_buff",
   "aghsfort_special_disruptor_kinetic_field_double_ring",

	"aghsfort_special_disruptor_static_storm_kinetic_field_on_cast",
	"aghsfort_special_disruptor_static_storm_crits_on_attacks",
	"aghsfort_special_disruptor_static_storm_damage_reduction",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_snapfire"] =
{
   "aghsfort_special_snapfire_scatterblast_double_barrel",
   "aghsfort_special_snapfire_scatterblast_knockback",
   "aghsfort_special_snapfire_scatterblast_fullrange_pointblank",
   "aghsfort_special_snapfire_scatterblast_barrage",

   "aghsfort_special_snapfire_firesnap_cookie_multicookie",
   "aghsfort_special_snapfire_firesnap_cookie_enemytarget",
   "aghsfort_special_snapfire_firesnap_cookie_allied_buff",

   "aghsfort_special_snapfire_lil_shredder_explosives",
   "aghsfort_special_snapfire_lil_shredder_ally_cast",
   "aghsfort_special_snapfire_lil_shredder_bouncing_bullets",

   "aghsfort_special_snapfire_mortimer_kisses_fragmentation",
--   "aghsfort_special_snapfire_mortimer_kisses_fire_trail",
   "aghsfort_special_snapfire_mortimer_kisses_autoattack",
   "aghsfort_special_snapfire_mortimer_kisses_incoming_damage_reduction",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_tusk"] =
{
   --"aghsfort_special_tusk_ice_shards_circle",
   "aghsfort_special_tusk_ice_shards_secondary",
   "aghsfort_special_tusk_ice_shards_explode",
   "aghsfort_special_tusk_ice_shards_stun",

   "aghsfort_special_tusk_snowball_heal",
   "aghsfort_special_tusk_snowball_end_damage",
   "aghsfort_special_tusk_snowball_global",

   "aghsfort_special_tusk_tag_team_lifesteal",
   "aghsfort_special_tusk_tag_team_toggle",
   "aghsfort_special_tusk_tag_team_global",

   "aghsfort_special_tusk_walrus_punch_reset",
   "aghsfort_special_tusk_walrus_punch_land_damage",
   "aghsfort_special_tusk_walrus_punch_wallop",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_ursa"] =
{
   "aghsfort_special_ursa_earthshock_invis",
   "aghsfort_special_ursa_earthshock_knockback",
   "aghsfort_special_ursa_earthshock_miss_chance",
   --"aghsfort_special_ursa_earthshock_apply_fury_swipes", -- bugged

   "aghsfort_special_ursa_overpower_crit",
   "aghsfort_special_ursa_overpower_evasion",
   "aghsfort_special_ursa_overpower_cleave",
   "aghsfort_special_ursa_overpower_taunt",

   "aghsfort_special_ursa_fury_swipes_armor_reduction",

   "aghsfort_special_ursa_enrage_magic_immunity",
   "aghsfort_special_ursa_enrage_fear",
   "aghsfort_special_ursa_enrage_armor",
   "aghsfort_special_ursa_enrage_attack_speed",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_sniper"] =
{
   "aghsfort_special_sniper_shrapnel_bombs",
   "aghsfort_special_sniper_shrapnel_attack_speed",
   "aghsfort_special_sniper_shrapnel_miss_chance",
   "aghsfort_special_sniper_shrapnel_move_speed",

   "aghsfort_special_sniper_headshot_crits",
   "aghsfort_special_sniper_headshot_stuns",

   "aghsfort_special_sniper_take_aim_self_purge",
   --"aghsfort_special_sniper_take_aim_aoe", -- bugged
   "aghsfort_special_sniper_take_aim_hop_backwards",
   "aghsfort_special_sniper_take_aim_armor_reduction",
   "aghsfort_special_sniper_take_aim_rapid_fire",

   "aghsfort_special_sniper_assassinate_buckshot",
   "aghsfort_special_sniper_assassinate_original_scepter",
   "aghsfort_special_sniper_assassinate_killshot_buff",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_mars"] = 
{
   "aghsfort_special_mars_spear_multiskewer",
   "aghsfort_special_mars_spear_impale_explosion",
   "aghsfort_special_mars_spear_burning_trail",

   "aghsfort_special_mars_gods_rebuke_full_circle",
   "aghsfort_special_mars_gods_rebuke_stun",
   "aghsfort_special_mars_gods_rebuke_strength_buff",

   --"aghsfort_special_mars_bulwark_counter_rebuke",
   --"aghsfort_special_mars_bulwark_healing",
   "aghsfort_special_mars_bulwark_return",
   "aghsfort_special_mars_bulwark_spears",
   "aghsfort_special_mars_bulwark_soldiers",

   "aghsfort_special_mars_arena_of_blood_outside_perimeter",
   --"aghsfort_special_mars_arena_of_blood_fear",
   "aghsfort_special_mars_arena_of_blood_global",
   "aghsfort_special_mars_arena_of_blood_attack_buff",
}
SPECIAL_ABILITY_UPGRADES["npc_dota_hero_viper"] = 
{
   "aghsfort_special_viper_poison_attack_spread",
   "aghsfort_special_viper_poison_attack_explode",
   "aghsfort_special_viper_poison_snap",

   "aghsfort_special_viper_nethertoxin_lifesteal",
   "aghsfort_special_viper_nethertoxin_charges",
   "aghsfort_special_viper_nethertoxin_persist",

   "aghsfort_special_viper_corrosive_skin_speed_steal",
   "aghsfort_special_viper_corrosive_skin_flying",
   "aghsfort_special_viper_corrosive_skin_aura",

   "aghsfort_special_viper_viper_strike_allies",
   --"aghsfort_special_viper_channeled_viper_strike",
   "aghsfort_special_viper_periodic_strike",
   "aghsfort_special_viper_chain_viper_strike",
}


SPECIAL_ABILITY_UPGRADES["npc_dota_hero_weaver"] = 
{
   "aghsfort_special_weaver_swarm_allies",
   "aghsfort_special_weaver_swarm_explosion",
   "aghsfort_special_weaver_swarm_damage_transfer",

   "aghsfort_special_weaver_geminate_attack_splitshot",
   "aghsfort_special_weaver_geminate_attack_applies_swarm",  
   "aghsfort_special_weaver_geminate_attack_lifesteal",
   "aghsfort_special_weaver_geminate_attack_knockback",



  -- "aghsfort_special_weaver_shukuchi_pull",
  "aghsfort_special_weaver_shukuchi_trail",
  "aghsfort_special_weaver_shukuchi_heal",
  "aghsfort_special_weaver_shukuchi_attack_on_completion",
  "aghsfort_special_weaver_shukuchi_swarm",
  "aghsfort_special_weaver_shukuchi_greater_invisibility",

  "aghsfort_special_weaver_time_lapse_allies",
  "aghsfort_special_weaver_time_lapse_restoration",
  "aghsfort_special_weaver_time_lapse_explosion",
}

SPECIAL_ABILITY_UPGRADES["npc_dota_hero_witch_doctor"] = 
{

   "aghsfort_special_witch_doctor_paralyzing_cask_multicask",
   "aghsfort_special_witch_doctor_paralyzing_cask_applies_maledict",
   "aghsfort_special_witch_doctor_paralyzing_cask_aoe_damage",
   "aghsfort_special_witch_doctor_paralyzing_cask_attack_procs",
   
   --"aghsfort_special_witch_doctor_maledict_ground_curse",
   "aghsfort_special_witch_doctor_maledict_aoe_procs",
   "aghsfort_special_witch_doctor_maledict_death_restoration",
   "aghsfort_special_witch_doctor_maledict_affects_allies",
   "aghsfort_special_witch_doctor_maledict_infectious",
   
   "aghsfort_special_witch_doctor_voodoo_restoration_enemy_damage",
   "aghsfort_special_witch_doctor_voodoo_restoration_lifesteal",
   "aghsfort_special_witch_doctor_voodoo_restoration_damage_amp",
   "aghsfort_special_witch_doctor_voodoo_restoration_mana_restore",
   
   "aghsfort_special_witch_doctor_death_ward_no_channel",
   "aghsfort_special_witch_doctor_death_ward_splitshot",
   "aghsfort_special_witch_doctor_death_ward_damage_resist",
   --"aghsfort_special_witch_doctor_death_ward_bounce",
}