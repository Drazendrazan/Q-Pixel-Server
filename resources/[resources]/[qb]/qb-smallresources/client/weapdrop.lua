local disabledPickups = {
  `PICKUP_WEAPON_ADVANCEDRIFLE`,
  `PICKUP_WEAPON_APPISTOL`,
  `PICKUP_WEAPON_ASSAULTRIFLE`,
  `PICKUP_WEAPON_MINISMG2`,
  `PICKUP_WEAPON_ASSAULTRIFLE_MK2`,
  `PICKUP_WEAPON_ASSAULTSHOTGUN`,
  `PICKUP_WEAPON_ASSAULTSMG`,
  `PICKUP_WEAPON_AUTOSHOTGUN`,
  `PICKUP_WEAPON_BAT`,
  `PICKUP_WEAPON_BATTLEAXE`,
  `PICKUP_WEAPON_BOTTLE`,
  `PICKUP_WEAPON_BULLPUPRIFLE`,
  `PICKUP_WEAPON_BULLPUPRIFLE_MK2`,
  `PICKUP_WEAPON_BULLPUPSHOTGUN`,
  `PICKUP_WEAPON_CARBINERIFLE`,
  `PICKUP_WEAPON_CARBINERIFLE_MK2`,
  `PICKUP_WEAPON_COMBATMG`,
  `PICKUP_WEAPON_COMBATMG_MK2`,
  `PICKUP_WEAPON_COMBATPDW`,
  `PICKUP_WEAPON_COMBATPISTOL`,
  `PICKUP_WEAPON_COMPACTLAUNCHER`,
  `PICKUP_WEAPON_COMPACTRIFLE`,
  `PICKUP_WEAPON_CROWBAR`,
  `PICKUP_WEAPON_DAGGER`,
  `PICKUP_WEAPON_DBSHOTGUN`,
  `PICKUP_WEAPON_DOUBLEACTION`,
  `PICKUP_WEAPON_FIREWORK`,
  `PICKUP_WEAPON_FLAREGUN`,
  `PICKUP_WEAPON_FLASHLIGHT`,
  `PICKUP_WEAPON_GRENADE`,
  `PICKUP_WEAPON_GRENADELAUNCHER`,
  `PICKUP_WEAPON_GUSENBERG`,
  `PICKUP_WEAPON_GolfClub`,
  `PICKUP_WEAPON_HAMMER`,
  `PICKUP_WEAPON_HATCHET`,
  `PICKUP_WEAPON_HEAVYPISTOL`,
  `PICKUP_WEAPON_HEAVYSHOTGUN`,
  `PICKUP_WEAPON_HEAVYSNIPER`,
  `PICKUP_WEAPON_HEAVYSNIPER_MK2`,
  `PICKUP_WEAPON_HOMINGLAUNCHER`,
  `PICKUP_WEAPON_KNIFE`,
  `PICKUP_WEAPON_KNUCKLE`,
  `PICKUP_WEAPON_MACHETE`,
  `PICKUP_WEAPON_MACHINEPISTOL`,
  `PICKUP_WEAPON_MARKSMANPISTOL`,
  `PICKUP_WEAPON_MARKSMANRIFLE`,
  `PICKUP_WEAPON_MARKSMANRIFLE_MK2`,
  `PICKUP_WEAPON_MG`,
  `PICKUP_WEAPON_MICROSMG`,
  `PICKUP_WEAPON_MINIGUN`,
  `PICKUP_WEAPON_MINISMG`,
  `PICKUP_WEAPON_MOLOTOV`,
  `PICKUP_WEAPON_MUSKET`,
  `PICKUP_WEAPON_NIGHTSTICK`,
  `PICKUP_WEAPON_PETROLCAN`,
  `PICKUP_WEAPON_PIPEBOMB`,
  `PICKUP_WEAPON_PISTOL`,
  `PICKUP_WEAPON_PISTOL50`,
  `PICKUP_WEAPON_PISTOL_MK2`,
  `PICKUP_WEAPON_POOLCUE`,
  `PICKUP_WEAPON_PROXMINE`,
  `PICKUP_WEAPON_PUMPSHOTGUN`,
  `PICKUP_WEAPON_PUMPSHOTGUN_MK2`,
  `PICKUP_WEAPON_RAILGUN`,
  `PICKUP_WEAPON_RAYCARBINE`,
  `PICKUP_WEAPON_RAYMINIGUN`,
  `PICKUP_WEAPON_RAYPISTOL`,
  `PICKUP_WEAPON_REVOLVER`,
  `PICKUP_WEAPON_REVOLVER_MK2`,
  `PICKUP_WEAPON_RPG`,
  `PICKUP_WEAPON_SAWNOFFSHOTGUN`,
  `PICKUP_WEAPON_SMG`,
  `PICKUP_WEAPON_SMG_MK2`,
  `PICKUP_WEAPON_SMOKEGRENADE`,
  `PICKUP_WEAPON_SNIPERRIFLE`,
  `PICKUP_WEAPON_SNSPISTOL`,
  `PICKUP_WEAPON_SNSPISTOL_MK2`,
  `PICKUP_WEAPON_SPECIALCARBINE`,
  `PICKUP_WEAPON_SPECIALCARBINE_MK2`,
  `PICKUP_WEAPON_STICKYBOMB`,
  `PICKUP_WEAPON_STONE_HATCHET`,
  `PICKUP_WEAPON_STUNGUN`,
  `PICKUP_WEAPON_SWITCHBLADE`,
  `PICKUP_WEAPON_VINTAGEPISTOL`,
  `PICKUP_WEAPON_WRENCH`
}

CreateThread(function()
  for _, hash in pairs(disabledPickups) do
    ToggleUsePickupsForPlayer(PlayerId(), hash, false)
  end
end)

-- tranq stuff
local ped = nil
local isDead = false

RegisterCommand("spawnped", function()
  ped = CreatePed(4, `mp_m_freemode_01`, vector4(-1104.39, -3081.89, 13.95, 247.22), 1, 1)
  GiveWeaponToPed(ped, 727643628, 9999, 0, 1)
  SetCurrentPedWeapon(ped, 727643628, 1)
end, false)

RegisterCommand("shootme", function()
  TaskShootAtEntity(ped, PlayerPedId(), 5000, `FIRING_PATTERN_FULL_AUTO`)
end)

local minorAnim = "cpr_pumpchest_idle"
local minorDict = "mini@cpr@char_b@cpr_def"
local tranqed = false
function loadAnimDict(dict)
  RequestAnimDict(dict)
  while(not HasAnimDictLoaded(dict)) do
      Wait(0)
  end
end
AddEventHandler("DamageEvents:EntityDamaged", function(victim, attacker, pWeapon, isMelee)
  local playerPed = PlayerPedId()
  if victim ~= playerPed then return end
  if pWeapon ~= 727643628 then return end
  if tranqed then return end
  tranqed = true
  SetPedToRagdoll(playerPed, 1000, 10000, 0, false, false, false)
  TriggerEvent("qb-voice:setTransmissionDisabled", { 
    ["phone"] = true,
    ["proximity"] = true,
    ["radio"] = true,
  })
  Wait(500)
  DoScreenFadeOut(500)
  Wait(500)
  CreateThread(function()
    local waitTime = 500
    local loopCount = 0
    loadAnimDict(minorDict)
    while loopCount < 600 do
      loopCount = loopCount + 1
      if not IsEntityPlayingAnim(playerPed, minorDict, minorAnim, 3) then
        ClearPedTasksImmediately(playerPed)
        TaskPlayAnim(playerPed, minorDict, minorAnim, 8.0, -8, -1, 1, 0, 0, 0, 0)
      end
      Wait(waitTime)
    end
    exports['qb-ui']:hideInteraction("Tranquilized", "error")
    tranqed = false
    StopScreenEffect("DrugsMichaelAliensFight")
    ClearPedTasks(playerPed)
    TriggerEvent("qb-voice:setTransmissionDisabled", {
      ["phone"] = false,
      ["proximity"] = false,
      ["radio"] = isDead,
    })
  end)
  CreateThread(function()
    Wait(5000)
    exports['qb-ui']:showInteraction("Tranquilized", "error")
    DoScreenFadeIn(5000)
    StartScreenEffect("DrugsMichaelAliensFight", 3.0, 0)
  end)
end)