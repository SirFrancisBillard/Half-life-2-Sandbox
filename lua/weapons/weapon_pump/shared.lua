--========== Copyleft © 2010, Team Sandbox, Some rights reserved. ===========--
--
-- Purpose: Initialize the base scripted weapon.
--
--===========================================================================--

SWEP.printname				= "Pump Shotgun"
SWEP.viewmodel				= "models/weapons/v_shotgun_old.mdl"
SWEP.playermodel			= "models/weapons/w_shotgun.mdl" -- will have to do
SWEP.anim_prefix			= "shotgun"
SWEP.bucket					= 3
SWEP.bucket_position		= 1

SWEP.clip_size				= 8
SWEP.clip2_size				= -1
SWEP.default_clip			= 8
SWEP.default_clip2			= -1
SWEP.primary_ammo			= "buckshot"
SWEP.secondary_ammo			= "None"

SWEP.weight					= 7
SWEP.item_flags				= 0

SWEP.damage					= 12

SWEP.SoundData				=
{
	empty					= "weapons/1alyxgun/alyxgun_empty.wav",
	single_shot				= "weapons/1shotgun1/Shotgun_Fire1.wav",
	double_shot				= "weapons/1shotgun1/Shotgun_secondaryfire_DoubleBlast.wav", -- KABLAM
	reload					= "weapons/1shotgun1/Shotgun_Reload1.wav",
	special1				= "weapons/1shotgun1/Shotgun_Cock.wav" -- xddd cock get it
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
	self.m_bReloadsSingly	= true;
	self.m_bFiresUnderwater	= false;
	self.m_bInReload		= false;
	self.m_bNeedPump		= false;
	self.m_bDelayedFire1	= false;
	self.m_bDelayedFire2	= false;
end

function SWEP:Precache()
end

function SWEP:PrimaryAttack()
	if ( self.m_bInReload ) then
		self.m_bDelayedFire1 = ( not self.m_bDelayedFire2 );
		return;
	end

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

	self:WeaponSound( 1 );
	pPlayer:DoMuzzleFlash();

	self:SendWeaponAnim( 180 );
	pPlayer:SetAnimation( 5 );
	ToHL2MPPlayer(pPlayer):DoAnimationEvent( 0 );

	self.m_flNextPrimaryAttack = gpGlobals.curtime() + 0.75;
	self.m_flNextSecondaryAttack = gpGlobals.curtime() + 0.75;

	self.m_iClip1 = self.m_iClip1 - 1;

	local vecSrc		= pPlayer:Weapon_ShootPosition();
	local vecAiming		= pPlayer:GetAutoaimVector( 0.08715574274766 );

	local info = { m_iShots = 6, m_vecSrc = vecSrc, m_vecDirShooting = vecAiming, m_vecSpread = vec3_origin, m_flDistance = MAX_TRACE_LENGTH, m_iAmmoType = self.m_iPrimaryAmmoType };
	info.m_pAttacker = pPlayer;

	-- Fire the bullets, and force the first shot to be perfectly accuracy
	pPlayer:FireBullets( info );

	--Disorient the player
	local angles = pPlayer:GetLocalAngles();

	angles.x = angles.x + random.RandomInt( -1, 1 );
	angles.y = angles.y + random.RandomInt( -1, 1 );
	angles.z = 0;

if not _CLIENT then
	pPlayer:SnapEyeAngles( angles );
end

	pPlayer:ViewPunch( QAngle( -8, random.RandomFloat( -2, 2 ), 0 ) );

	if ( self.m_iClip1 == 0 and pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) <= 0 ) then
		-- HEV suit - indicate out of ammo condition
		pPlayer:SetSuitUpdate( "!HEV_AMO0", 0, 0 );
	end

	if ( self.m_iClip1 > 0 ) then

		self.m_bNeedPump = true;

	end
end

function SWEP:SecondaryAttack()
	if ( self.m_bInReload ) then
		self.m_bDelayedFire2 = ( not self.m_bDelayedFire1 );
		return;
	end

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

	if ( self.m_iClip1 < 2 ) then

		return;

	end

	self:WeaponSound( 3 );
	pPlayer:DoMuzzleFlash();

	self:SendWeaponAnim( 181 );
	pPlayer:SetAnimation( 5 );
	ToHL2MPPlayer(pPlayer):DoAnimationEvent( 0 );

	self.m_flNextPrimaryAttack = gpGlobals.curtime() + 1;
	self.m_flNextSecondaryAttack = gpGlobals.curtime() + 1;

	self.m_iClip1 = self.m_iClip1 - 2;

	local vecSrc		= pPlayer:Weapon_ShootPosition();
	local vecAiming		= pPlayer:GetAutoaimVector( 0.08715574274766 );

	local info = { m_iShots = 12, m_vecSrc = vecSrc, m_vecDirShooting = vecAiming, m_vecSpread = vec3_origin, m_flDistance = MAX_TRACE_LENGTH, m_iAmmoType = self.m_iPrimaryAmmoType };
	info.m_pAttacker = pPlayer;

	-- Fire the bullets, and force the first shot to be perfectly accuracy
	pPlayer:FireBullets( info );

	--Disorient the player
	local angles = pPlayer:GetLocalAngles();

	angles.x = angles.x + random.RandomInt( -1, 1 );
	angles.y = angles.y + random.RandomInt( -1, 1 );
	angles.z = 0;

if not _CLIENT then
	pPlayer:SnapEyeAngles( angles );
end

	pPlayer:ViewPunch( QAngle( -8 * 2, random.RandomFloat( -2, 2 ) * 2, 0 ) );

	if ( self.m_iClip1 == 0 and pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) <= 0 ) then
		-- HEV suit - indicate out of ammo condition
		pPlayer:SetSuitUpdate( "!HEV_AMO0", 0, 0 );
	end

	if ( self.m_iClip1 > 0 ) then

		self.m_bNeedPump = true;

	end
end

function SWEP:StartReload()

	print("StartReload")

	local pPlayer = self:GetOwner();

	if ( ToBaseEntity( pPlayer ) == NULL ) then
		return false;
	end

	if ( pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) <= 0 ) then
		return false
	end

	if ( self.m_iClip1 >= self.clip_size ) then
		return false;
	end

	if ( pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) <= 0 ) then
		return false
	end

	if ( self.m_iClip1 <= 0 ) then
		self.m_bNeedPump = true;
	end

	local j = math.min( 1, pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) )

	if ( j <= 0 ) then
		return false;
	end

	self:SendWeaponAnim( 267 );

	self.m_flNextPrimaryAttack = gpGlobals.curtime() + self:SequenceDuration();
	self.m_flNextSecondaryAttack = gpGlobals.curtime() + self:SequenceDuration();

	self.m_bInReload = true;
	return true;
end

function SWEP:Reload()

	print("Reload")

	local pPlayer = self:GetOwner();

	if ( ToBaseEntity( pPlayer ) == NULL ) then
		return false;
	end

	if ( pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) <= 0 ) then
		return false;
	end

	if ( self.m_iClip1 >= self.clip_size ) then
		return false;
	end

	if ( pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) <= 0 ) then
		return false
	end

	if ( self.m_iClip1 <= 0 ) then
		self.m_bNeedPump = true;
	end

	local j = math.min( 1, pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) )

	if ( j <= 0 ) then
		return false;
	end

	if ( not m_bInReload ) then
		self:StartReload();
		return;
	end

	self:FillClip();

	self:WeaponSound( 6 );
	self:SendWeaponAnim( 183 );

	self.m_flNextPrimaryAttack = gpGlobals.curtime() + self:SequenceDuration();
	self.m_flNextSecondaryAttack = gpGlobals.curtime() + self:SequenceDuration();

	return true;
end

function SWEP:FinishReload()

	print("FinishReload")

	local pPlayer = self:GetOwner();

	if ( ToBaseEntity( pPlayer ) == NULL ) then
		return false;
	end

	self.m_bInReload = false;

	self:SendWeaponAnim( 268 );

	if ( self.m_bNeedPump ) then
		self:Pump();
	end
	
	self.m_flNextPrimaryAttack = gpGlobals.curtime() + self:SequenceDuration();
	self.m_flNextSecondaryAttack = gpGlobals.curtime() + self:SequenceDuration();
end

function SWEP:FillClip()

	print("FillClip")

	local pPlayer = self:GetOwner();

	if ( ToBaseEntity( pPlayer ) == NULL ) then
		return false;
	end

	if ( pPlayer:GetAmmoCount( self.m_iPrimaryAmmoType ) > 0 ) then
		if ( self.m_iClip1 > self.clip_size ) then
			self.m_iClip1 = self.m_iClip1 + 1;
			pPlayer:RemoveAmmo( 1, self.m_iPrimaryAmmoType );
			
			if ( self.m_iClip1 >= self.clip_size ) then
				self:FinishReload();
			end
		end
	end
end

function SWEP:Pump()

	print("Pump")

	local pPlayer = self:GetOwner();

	if ( ToBaseEntity( pPlayer ) == NULL ) then
		return false;
	end

	self.m_bNeedPump = false;

	self:WeaponSound( 11 );
	self:SendWeaponAnim( 269 );

	self.m_flNextPrimaryAttack = gpGlobals.curtime() + self:SequenceDuration();
	self.m_flNextSecondaryAttack = gpGlobals.curtime() + self:SequenceDuration();
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
