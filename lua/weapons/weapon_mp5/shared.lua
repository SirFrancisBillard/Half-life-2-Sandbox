--========== Copyleft © 2010, Team Sandbox, Some rights reserved. ===========--
--
-- Purpose: Initialize the base scripted weapon.
--
--===========================================================================--

SWEP.printname				= "SMG"
SWEP.viewmodel				= "models/weapons/v_5mg2.mdl"
SWEP.playermodel			= "models/weapons/w_smg3.mdl"
SWEP.anim_prefix			= "smg"
SWEP.bucket					= 2
SWEP.bucket_position		= 1

SWEP.clip_size				= 30
SWEP.clip2_size				= -1
SWEP.default_clip			= 30
SWEP.default_clip2			= -1
SWEP.primary_ammo			= "smg1"
SWEP.secondary_ammo			= "None"

SWEP.weight					= 7
SWEP.item_flags				= 0

SWEP.damage					= 20

SWEP.SoundData				=
{
	empty					= "weapons/1alyxgun/alyxgun_empty.wav",
	single_shot				= "weapons/1smg2/npc_smg2_fire1.wav",
	burst					= "weapons/1smg2/44k/smg2_fireburst1.wav",
	reload					= "weapons/smg1/smg1_reload.wav",
	special1				= "weapons/1smg2/switch_burst.wav",
	special2				= "weapons/1smg2/switch_single.wav"
}

SWEP.showusagehint			= 0
SWEP.autoswitchto			= 1
SWEP.autoswitchfrom			= 1
SWEP.BuiltRightHanded		= 1
SWEP.AllowFlipping			= 1
SWEP.MeleeWeapon			= 0

-- TODO; implement Activity enum library!!
SWEP.m_acttable				=
{
	{ 1048, 977, false },
	{ 1049, 979, false },

	{ 1058, 978, false },
	{ 1061, 980, false },

	{ 1073, 981, false },
	{ 1077, 981, false },

	{ 1090, 982, false },
	{ 1093, 982, false },

	{ 1064, 983, false },
};

function SWEP:Initialize()
	self.m_bReloadsSingly	= false;
	self.m_bFiresUnderwater	= false;
	self.m_bBurstEnabled	= false;
	self.m_flBurstTimer		= 0;
end

function SWEP:Precache()
end

function SWEP:PrimaryAttack()
	-- Only the player fires this way so we can cast
	local pPlayer = self:GetOwner();

	if ( ToBaseEntity( pPlayer ) == NULL ) then
		return;
	end

	if ( self.m_iClip1 <= 0 ) then
		if ( not self.m_bFireOnEmpty ) then
			self:Reload();
		else
			self:WeaponSound( 0 );
			self.m_flNextPrimaryAttack = 0.15;
		end

		return;
	end

	pPlayer:DoMuzzleFlash();

	self:SendWeaponAnim( 180 );
	pPlayer:SetAnimation( 5 );
	ToHL2MPPlayer(pPlayer):DoAnimationEvent( 0 );

	local vecSrc		= pPlayer:Weapon_ShootPosition();
	local vecAiming		= pPlayer:GetAutoaimVector( 0.08715574274766 );

	local info = { m_iShots = 1, m_vecSrc = vecSrc, m_vecDirShooting = vecAiming, m_vecSpread = vec3_origin, m_flDistance = MAX_TRACE_LENGTH, m_iAmmoType = self.m_iPrimaryAmmoType };

	if ( self.m_bBurstEnabled ) then

		self:WeaponSound( 5 );

		self.m_flNextPrimaryAttack = gpGlobals.curtime() + 0.3;

		local burst = 3

		if ( self.m_iClip1 < 3 ) then

			burst = self.m_iClip1;

		end

		self.m_iClip1 = self.m_iClip1 - burst;

		info.m_iShots = burst;

	else

		self:WeaponSound( 1 );

		self.m_flNextPrimaryAttack = gpGlobals.curtime() + 0.1;

		self.m_iClip1 = self.m_iClip1 - 1;

	end

	self.m_flNextSecondaryAttack = gpGlobals.curtime() + 0.1;

	info.m_pAttacker = pPlayer;

	-- Fire the bullets, and force the first shot to be perfectly accuracy
	pPlayer:FireBullets( info );

	pPlayer:ViewPunch( QAngle( -0.2, random.RandomFloat( -0.1, 0.1 ), 0 ) );

	if ( self.m_iClip1 == 0 and pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) <= 0 ) then
		-- HEV suit - indicate out of ammo condition
		pPlayer:SetSuitUpdate( "!HEV_AMO0", 0, 0 );
	end
end

function SWEP:SecondaryAttack()
	if ( gpGlobals.curtime() > self.m_flBurstTimer ) then

		self.m_flBurstTimer = gpGlobals.curtime() + 0.5;

		if ( self.m_bBurstEnabled ) then

			self.m_bBurstEnabled = false;

			self:WeaponSound( 12 );

		else

			self.m_bBurstEnabled = true;

			self:WeaponSound( 11 );

		end

	end
end

function SWEP:Reload()
	local fRet = self:DefaultReload( self:GetMaxClip1(), self:GetMaxClip2(), 182 );
	if ( fRet ) then
		self:WeaponSound( 6 );
		ToHL2MPPlayer(self:GetOwner()):DoAnimationEvent( 3 );
	end
	return fRet;
end

function SWEP:Think()
end

function SWEP:CanHolster()
end

function SWEP:Deploy()
end

function SWEP:GetDrawActivity()
	return 171;
end

function SWEP:Holster( pSwitchingTo )
end

function SWEP:ItemPostFrame()
end

function SWEP:ItemBusyFrame()
end

function SWEP:DoImpactEffect()
end
