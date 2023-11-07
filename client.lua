
local debug = false

local function playAnimation(ped, animDict, animName, flag, async)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, flag, 0, false, false, false)
    while async and IsEntityPlayingAnim(ped, animDict, animName, 3) do Citizen.Wait(0) end
end

local function randomWeapon()
    local weaponlist = { "WEAPON_PISTOL" }
    if debug then
        for i = 1, #weaponlist do
            print(weaponlist[i])
        end
    end
    return weaponlist[math.random(1, #weaponlist)]
end

local function getRandomPed()
    local pedlist = { "s_m_y_casino_01", "s_m_y_marine_03", "s_m_y_doorman_01",
        "s_m_y_blackops_01", "s_m_m_highsec_02", "s_m_m_fiboffice_02", "s_m_m_chemsec_01", "mp_m_bogdangoon",
        "g_m_m_chicold_01", "csb_tomcasino", "csb_brucie2", "csb_ramp_marine", "csb_mweather", "u_m_m_streetart_01",
        "g_m_m_cartelguards_01" }
    if debug then
        for i = 1, #pedlist do
            print(pedlist[i])
        end
    end
    return pedlist[math.random(1, #pedlist)]
end

local function registerVehPed(vehicle, model, seat, type)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    local modalSpawn = CreatePedInsideVehicle(vehicle, 4, model, seat, true, false)
    GiveWeaponToPed(modalSpawn, GetHashKey(randomWeapon()), 255, false, false)
    SetPedShootRate(modalSpawn, 1000)

    for i = 1, 91 do
        SetPedCombatAttributes(modalSpawn, i, true)
    end
    SetPedCombatAbility(modalSpawn, 100)
    SetPedFleeAttributes(modalSpawn, 0, false)
    return modalSpawn
end

local function registerPed(model, coords, type)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    local modalSpawn = CreatePed(4, model, coords.x, coords.y, coords.z, 0.0, true, false)
    GiveWeaponToPed(modalSpawn, GetHashKey(randomWeapon()), 255, false, false)
    SetPedShootRate(modalSpawn, 1000)

    for i = 1, 91 do
        SetPedCombatAttributes(modalSpawn, i, true)
    end

    SetPedCombatAbility(modalSpawn, 100)
    SetPedFleeAttributes(modalSpawn, 0, false)
    return modalSpawn
end

local function playPlaneSequence(ped)
    local plane = GetHashKey("miljet")
    RequestModel(plane)

    while not HasModelLoaded(plane) do Citizen.Wait(0) end

    local planeSpawn = CreateVehicle(plane, -3633.6077, -2336.1934, 906.4427, 71.7856, true, false)
    local pilot = registerVehPed(planeSpawn, getRandomPed(), -1, "driver")
    local passenger = registerVehPed(planeSpawn, getRandomPed(), 0, "passenger")

    SetPedIntoVehicle(pilot, planeSpawn, -1)
    SetPedIntoVehicle(passenger, planeSpawn, 0)
    SetVehicleLandingGear(planeSpawn, 3)

    TaskVehicleDriveToCoord(pilot, planeSpawn, -963.5541, -2728.2590, 777.7566, 100.0, 0, plane, 1074528293, 5.0, 1.0)
    SetVehicleForwardSpeed(planeSpawn, 100.0)

    Citizen.Wait(4000)
    DoScreenFadeIn(2000)

    SetEntityInvincible(ped, true)
    SetEntityHasGravity(ped, false)
    SetEntityCollision(ped, false, false)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            SetFollowPedCamViewMode(4)
            if not IsPedInVehicle(ped, planeSpawn, false) then
                SetPedIntoVehicle(ped, planeSpawn, 5)
            end
        end
    end)

    Citizen.Wait(10000)
    TriggerServerEvent("kidnap:endedAbschiebung")
end


local function playEndSequence(ped, vehicleSpawn)
    DetachEntity(ped, false, false)
    local driver = GetPedInVehicleSeat(vehicleSpawn, -1)
    TaskVehicleDriveWander(driver, vehicleSpawn, 100.0, 1074528293)

    DoScreenFadeOut(1000)
    SetEntityNoCollisionEntity(ped, vehicleSpawn, false)
    playPlaneSequence(ped)
end


RegisterNetEvent('kidnap:startAbschiebung', function(data)
    --TriggerEvent("scully_emotemenu:toggleLimitation", true) Only if you have scully_emotemenu else you can delete this line or replace it with your own event
    TriggerEvent("scully_emotemenu:toggleLimitation", true)
    local coords = vector3(-963.5541, -2728.2590, 13.7566)
    local ped = GetPlayerPed(-1)

    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        TaskLeaveVehicle(ped, vehicle, 0)
        while IsPedInAnyVehicle(ped, false) do Citizen.Wait(0) end
        Citizen.Wait(1000)
        DeleteVehicle(vehicle)
    end

    if IsPedFalling(ped) or IsPedFatallyInjured(ped) or IsPedDeadOrDying(ped, true) or IsPedRagdoll(ped) or IsPedJumpingOutOfVehicle(ped) or IsPedClimbing(ped) or IsPedVaulting(ped) then
        return
    end

    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)
    local positionOffset = pedCoords - (GetEntityForwardVector(ped) * 7.0)
    local headingOffset = pedHeading - 180.0
    local vehicle = GetHashKey("burrito")
    RequestModel(vehicle)
    while not HasModelLoaded(vehicle) do Citizen.Wait(0) end

    local spawnArea = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
    local vehicleList = GetGamePool("CVehicle")
    for i = 1, #vehicleList do
        local vehicleCoords = GetEntityCoords(vehicleList[i])
        if GetDistanceBetweenCoords(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, spawnArea.x, spawnArea.y, spawnArea.z, true) < 5.0 then
            DeleteVehicle(vehicleList[i])
        end
    end

    local vehicleSpawn = CreateVehicle(vehicle, positionOffset.x, positionOffset.y, positionOffset.z, headingOffset, true,
        false)
    SetVehicleOnGroundProperly(vehicleSpawn)

    local driver = registerVehPed(vehicleSpawn, getRandomPed(), -1, "driver")
    SetPedKeepTask(driver, true)

    SetVehicleDoorOpen(vehicleSpawn, 2, false, false)
    SetVehicleDoorOpen(vehicleSpawn, 3, false, false)

    local passenger = registerPed(getRandomPed(),
        GetOffsetFromEntityInWorldCoords(vehicleSpawn, 0.0, 0.0, 0.0), "passenger")
    SetEntityHeading(passenger, pedHeading - 100.0)
    local ped_animDist, ped_animName = "random@kidnap_girl", "ig_1_girl_drag_into_van"
    local passenger_animDist, passenger_animName = "random@kidnap_girl", "ig_1_guy2_drag_into_van"

    local vehicleCoords = GetEntityCoords(vehicleSpawn)
    local vehicleRot = GetEntityRotation(vehicleSpawn)

    SetEntityNoCollisionEntity(ped, vehicleSpawn, false)
    SetEntityNoCollisionEntity(passenger, vehicleSpawn, false)

    local playerHeading = GetEntityHeading(ped) - 180.0
    local scene = NetworkCreateSynchronisedScene(vehicleCoords.x, vehicleCoords.y + 0.1, vehicleCoords.z + 0.1,
        vehicleRot.x, vehicleRot.y, playerHeading, 2, false, false, 1065353216, 0, 1065353216)

    NetworkAddPedToSynchronisedScene(passenger, scene, passenger_animDist, passenger_animName, 2.0, -2.0, 13, 16,
        1148846080, 0)
    NetworkAddPedToSynchronisedScene(ped, scene, ped_animDist, ped_animName, 2.0, -2.0, 13, 16, 1148846080, 0)

    NetworkStartSynchronisedScene(scene)
    isSceneActive = true
    Citizen.Wait(10500)
    isSceneActive = false
    NetworkStopSynchronisedScene(scene)

    SetVehicleDoorShut(vehicleSpawn, 2, false)
    SetVehicleDoorShut(vehicleSpawn, 3, false)
    SetPedIntoVehicle(passenger, vehicleSpawn, 2)
    AttachEntityToEntity(ped, vehicleSpawn, 0, -0.3, -1.2, 0.2, 0.0, 0.0, 0.0, false, false, false, false, 0, false)
    TaskVehicleDriveToCoord(driver, vehicleSpawn, coords.x, coords.y, coords.z, 100.0, 0, vehicle, 1074528293, 5.0,
        1.0)
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        DoScreenFadeOut(5000)
        Citizen.Wait(6000)
        local nodetype, p6, p7 = 1, 3.0, 0
        local found, nodeCoords, nodeHeading = GetClosestVehicleNodeWithHeading(coords.x + 50.0, coords.y + 50.0,
            coords.z, nodetype, p6, p7)
        if found then
            SetEntityCoords(vehicleSpawn, nodeCoords.x, nodeCoords.y, nodeCoords.z, false, false, false, false)
            SetEntityHeading(vehicleSpawn, nodeHeading)
        end
        DoScreenFadeIn(3000)
    end)

    local lastCheck, checkCoords = GetGameTimer(), GetEntityCoords(ped)
    local maxTry = 3
    while true do
        Citizen.Wait(0)
        local vehicleCoords = GetEntityCoords(vehicleSpawn)
        if GetGameTimer() - lastCheck > 5000 then
            if GetDistanceBetweenCoords(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, checkCoords.x, checkCoords.y, checkCoords.z, true) < 3.0 then
                local nodetype, p6, p7 = 1, 3.0, 0
                local found, nodeCoords, nodeHeading = GetClosestVehicleNodeWithHeading(vehicleCoords.x, vehicleCoords.y,
                    vehicleCoords.z, nodetype, p6, p7)
                if found then
                    SetEntityCoords(vehicleSpawn, nodeCoords.x, nodeCoords.y, nodeCoords.z, false, false, false, false)
                    SetEntityHeading(vehicleSpawn, nodeHeading)
                end
                maxTry = maxTry - 1
            end
            lastCheck = GetGameTimer()
            checkCoords = GetEntityCoords(ped)
        end

        if maxTry <= 0 then
            local nodetype, p6, p7 = 1, 3.0, 0
            local found, nodeCoords, nodeHeading = GetClosestVehicleNodeWithHeading(coords.x + 50.0, coords.y + 50.0,
                coords.z, nodetype, p6, p7)
            if found then
                SetEntityCoords(vehicleSpawn, nodeCoords.x, nodeCoords.y, nodeCoords.z, false, false, false, false)
                SetEntityHeading(vehicleSpawn, nodeHeading)
            end
        end

        if IsPedDeadOrDying(driver, true) or GetPedInVehicleSeat(vehicleSpawn, -1) ~= driver or GetVehicleEngineHealth(vehicleSpawn) < 0.0 then
            break
        end

        if GetDistanceBetweenCoords(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, coords.x, coords.y, coords.z, true) < 15.0 then
            break
        end
        local ped_van_animDist, ped_van_animName = "random@kidnap_girl", "ig_1_alt1_girl_in_van_loop"
        playAnimation(ped, ped_van_animDist, ped_van_animName, 0, false)
    end

    playEndSequence(ped, vehicleSpawn)
end)
