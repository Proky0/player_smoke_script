local pedSmokePtfx = nil
local isSmokeEnabled = false
local smokeColorIndex = 1

local PTFX_ASSET = "scr_ar_planes"
local PTFX_EFFECT = "scr_ar_trail_smoke"

local BONE_ID = 0xE175

function UpdateSmokeEffect()
	local playerPed = PlayerPedId()

	local color = Shared.Colors[smokeColorIndex]
	if not color then return end

	if DoesParticleFxLoopedExist( pedSmokePtfx ) then
		StopParticleFxLooped( pedSmokePtfx, false )
		pedSmokePtfx = nil
	end

	if isSmokeEnabled then
		local boneIndex = GetPedBoneIndex( playerPed, BONE_ID )

		UseParticleFxAssetNextCall( PTFX_ASSET )
		pedSmokePtfx = StartNetworkedParticleFxLoopedOnEntityBone(
			PTFX_EFFECT,
			playerPed,
			0.0, 0.0, 0.0,
			0.0, 0.0, 0.0,
			boneIndex,
			0.2,
			false, false, false
		)

		SetParticleFxLoopedColour( pedSmokePtfx, color.r / 255, color.g / 255, color.b / 255, false )
		SetParticleFxLoopedScale( pedSmokePtfx, 0.2 )
	end
end

function ClearPedSmoke()
	if DoesParticleFxLoopedExist( pedSmokePtfx ) then
		StopParticleFxLooped( pedSmokePtfx, false )
		RemoveParticleFx( pedSmokePtfx, false )
	end

	pedSmokePtfx = nil
	isSmokeEnabled = false
end

function ChangeSmokeColor( direction )
	smokeColorIndex = smokeColorIndex + direction

	if smokeColorIndex > #Shared.Colors then
		smokeColorIndex = 1
	elseif smokeColorIndex < 1 then
		smokeColorIndex = #Shared.Colors
	end

	if isSmokeEnabled then
		UpdateSmokeEffect()
	end
end

CreateThread( function ()
	RequestNamedPtfxAsset( PTFX_ASSET )
	while not HasNamedPtfxAssetLoaded( PTFX_ASSET ) do
		Wait( 10 )
	end

	while true do
		local playerPed = PlayerPedId()
		local parachuteState = GetPedParachuteState( playerPed )

		if parachuteState == 1 or parachuteState == 2 then
			if IsControlJustPressed( 0, 174 ) then ChangeSmokeColor( -1 ) end
			if IsControlJustPressed( 0, 175 ) then ChangeSmokeColor( 1 ) end

			if IsControlJustPressed( 0, 51 ) then
				isSmokeEnabled = not isSmokeEnabled

				if isSmokeEnabled then
					UpdateSmokeEffect()
				else
					ClearPedSmoke()
				end
			end

			Wait( 0 )
		else
			if isSmokeEnabled or pedSmokePtfx then
				ClearPedSmoke()
			end

			Wait( 150 )
		end
	end
end )