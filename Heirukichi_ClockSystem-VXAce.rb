#===============================================================================================
# HEIRUKICHI DAY/NIGHT SYSTEM - AKA VX ACE CLOCK
#===============================================================================================
# Version 1.0.5
# - Author: Heirukichi
# - Last update 06-26-2019 [MM-DD-YYYY]
#===============================================================================================
# TERMS OF USE
#-----------------------------------------------------------------------------------------------
# This script is under the GNU General Public License v3.0. This means that:
# - You are free to use this script in both commercial and non-commercial games as long as you
#   give proper credits to me (Heirukichi) and provide a link to my website;
# - You are free to modify this script as long as you do not pretend you wrote this and you
#   distribute it under the same license as the original.
#
# You can review the full license here: https://www.gnu.org/licenses/gpl-3.0.html
#
# In addition I'd like to keep track of games where my scripts are used so, even if this is not
# mandatory, I'd like you to inform me and send me a link when a game including my script is
# published. As I said, this is not mandatory but it really helps me and it is much appreciated.
#
# IMPORTANT NOTICE:
# If you want to distribute this code, feel free to do it, but provide a link to my website
# instead of pasting my script somewhere else.
#===============================================================================================
# DESCRIPTION
#-----------------------------------------------------------------------------------------------
# This script adds a day/night cycle. In addition to that it adds a clock sprite so players can
# get a grasp on game time.
#===============================================================================================
# INSTRUCTIONS
#-----------------------------------------------------------------------------------------------
# To set up this script you can change values inside HCK::CONFIG module. The purpose of each of
# those values is explained in detail there. If you just want your day/night cycle there are few
# default values you can use for a fast plug-and-play use of this script.
#
# This script is meant to work with two clock images. One is fixed (it is called clock support
# or just support in the script) while one can move (that is called just clock). The default
# path for those images is inside Graphics/Clock/ but feel free to change that when configuring
# the script.
#
# Those two images must have the same size and are displayed one above the other. Which one goes
# above and which one goes below is up to you. In the settings you have a value for that too.
# 
# NOTE: Since this script is meant as a night/day cycle, while it can still provide in-game time
# using $game_clock.to_s (it uses the format hh:mm AM/PM) the sprite moves over a cycle of 24
# hours (not 12). For this reason it is suited for something showing at which point of the cycle
# you are but you cannot use it to make a real clock (unless it is a digital one, in which case
# it works).
#
# While inside the engine you can use $game_clock.set_time(phase) in a script call to change
# your in-game time withuot having to wait that time actually passes by. You can use it to let
# the player rest in an inn or in any other situation that requires your time to flash-forward
# a bit. In this script call "phase" is the 30 minutes interval you want for your time.
#
# Examples:
#	$game_clock.set_time(45) <- This sets your time to be 22:30 (10:30 PM)
#	$game_clock.set_time(2)	 <- This sets your time to be 01:00 (01:00 AM)
#
# NOTE: the maximum value for phase is 47 while its minimum is 0. Any other value will have no
#		effect.
#
# If you decide to not initialize your clock at the beginning of the game and you want to set it
# up later using an event you can use $game_clock.setup(display). This will set up your clock
# and makes it ready to work. Its visibility depends on display value. It can be either true or
# false. If display is omitted then the default value (true) is used. Using setup automatically
# sets your time to HCK::CONFIG::STARTING_PHASE. No $game_clock.set_time needed after a setup.
#
# Once your clock has been set up you can access many different methods using script calls.
#-----------------------------------------------------------------------------------------------
# METHODS YOU CAN USE TO CONTROL YOUR CLOCK
#-----------------------------------------------------------------------------------------------
# - $game_clock.toggle makes your clock visible when invisible or hides it if visible.
# - $game_clock.show forces your clock to be visible. It has no effect when already visible.
# - $game_clock.hide forces your clock to disappear. If already invisible it has no effect.
# - $game_clock.stop stops your in-game time.
# - $game_clock.resume resumes your in-game time.
# - $game_clock.toggle_timeflow can either stop your clock or resume it depending on its status.
# - $game_clock.to_s returns a string containing your in-game time in the format hh:mm AM/PM.
# - $game_clock.visible? tells you if your clock is visible.
# - $game_clock.hour returns your in-game hour in 12h format.
# - $game_clock.hour24 returns your in-game hour in 24h format.
# - $game_clock.minute returns your in-game minutes.
# - $game_clock.phase returns the current 30 minutes interval.
# - $game_clock.force_refresh forces a sprite refresh for your clock.
# - $game_clock.set_indoor(value)	tells the engine if you are inside or outside. Value is true
#									when inside and false when outside. This is used to prevent
#									the engine from tinting your screen automatically. Clock
#									indoor flag is set to false when initializing $game_clock.
#									If you want it to be true do not forget to do it manually!
#									You can do it before setting up your clock so that the no
#									screen tone is accidentally applied.
# - $game_clock.toggle_indoor toggles indoor flag setting it to true if false or vice versa.
# - $game_clock.indoor? returns true if your indor flag is true, false otherwise.
# - $game_clock.day? $game_clock.night? $game_clock.dawn? $game_clock.dusk? return true if the
#	chosen phase is running, false otherwise.
#-----------------------------------------------------------------------------------------------
# GAME INTERPRETER CHANGES
#-----------------------------------------------------------------------------------------------
# This script changes how Tint Screen works and whenever you want to tint your screen back to
# normal it automatically detects the color of your current phase of the day and uses that one
# instead. For this reason I added a few methods to tint your screen to the normal (day) color
# using a script call even when it is using a different color.
#
# - tint_black(duration) tints your screen black (clock opacity goes to 0).
# - tint_white(duration) tints your screen white (clock opacity goes to 0).
# - tint_clear(duration) tints your screen to the normal tone (0, 0, 0, 0).
# - tint_normal(duration) tints your screen to the day phase color (clock opacity goes to 255).
#
# duration is the amount of frames your titn screen takes to complete. It can be omitted.
# Default value when omitted is 30 (same as Fadeout and Fadein).
#
# NOTE: Tint Screen is NOT Fadeout nor Fadein! Tint Screen does not let your message disappear
#		nor tints your pictures.
#
# NOTE: Game_Interpreter methods are not Game_Clock methods. You can use them in a script call
#		by just writing them as they are. Using $game_clock.tint_black because it DOES NOT WORK!
#===============================================================================================
# COMPATIBILITY
#-----------------------------------------------------------------------------------------------
# This script creates few new classes and create aliased methods for existing ones. Since there
# are no overwritten methods in this script it should (theoretically) be compatible with any
# other script overwriting one of those methods as long as this one is placed BELOW it.
#-----------------------------------------------------------------------------------------------
# Methods (* = aliased method, + = new method, ! = overwritten method)
#-----------------------------------------------------------------------------------------------
# DataManager
#	* make_save_contents
#	* extract_save_contents
#	* create_game_objects
#-----------------------------------------------------------------------------------------------
# Game_Interpreter
#	* command_223
#	+ set_clock_fading_speed
#	+ tint_clear
#	+ tint_normal
#	+ tint_black
#	+ tint_white
#-----------------------------------------------------------------------------------------------
# Scene_Map
#	* start
#-----------------------------------------------------------------------------------------------
# Spriteset_Map
#	* initialize
#	+ create_clock
#	+ create_clock_viewport
#	+ create_clock_sprite
#	* update
#	+ update_clock
#	+ update_clock_sprite
#	+ update_clock_viewport
#	* dispose
#	+ dispose_clock
#	+ dispose_clock_sprite
#	+ dispose_clock_viewport
#-----------------------------------------------------------------------------------------------
# Game_Screen
#	* initialize
#	+ allow_clock_tint
#	+ tint_manually
#	+ can_apply_clock_tint? 
#	* update
#	+ update_clockphase_tone
#-----------------------------------------------------------------------------------------------
# Sprite_Clock
#	+ initialize
#	+ create_clock
#	+ create_support
#	+ ox
#	+ oy
#	+ dispose
#	+ update
#	+ update_visibility
#	+ update_angle
#-----------------------------------------------------------------------------------------------
# Game_Clock
#	+ initialize
#	+ hour
#	+ hour24
#	+ minute
#	+ ampm
#	+ phase
#	+ to_s
#	+ visible?
#	+ angle
#	+ next_angle
#	+ toggle
#	+ show
#	+ hide
#	+ setup
#	+ set_up?
#	+ set_time
#	+ refresh
#	+ on_succesful_refresh
#	+ need_angle_refresh?
#	+ need_refresh?
#	+ tone_update?
#	+ on_succesful_tone_change
#	+ force_refresh
#	+ start_fading
#	+ stop_fading
#	+ fading?
#	+ set_fade_speed
#	+ stop
#	+ resume
#	+ working?
#	+ toggle_timeflow
#	+ set_indoor
#	+ indoor?
#	+ toggle_indoor
#	+ indoor_tint?
#	+ on_succesful_indoor_tint
#	+ night?
#	+ dawn?
#	+ dusk?
#	+ day?
#	+ update
#===============================================================================================
# CHANGE LOG
#-----------------------------------------------------------------------------------------------
# Version 1.0.2 [03-13-2019]
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# * It is now possible to configure your clock so that it only updates when $game_player is
#	moving. This was meant to stop time flow in turn based strategy games when the player is not
#	moving.
#-----------------------------------------------------------------------------------------------
# Version 1.0.3 [04-27-2019]
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# * Fixed a bug that caused screen tint to be applied regardless of TINT_ON_CHANGES value.
#-----------------------------------------------------------------------------------------------
# Version 1.0.4 [05-02-2019]
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# * $game_clock.set_time now has an internal check to convert numbers into the 0-47 range. It is
#	now possible to add extra phases to the current time using set_time, without having to worry
#	about the new value being less than 47.
#
#	Example:
#	$game_clock.phase # -> 36
#	$game_clock.set_time($game_clock.phase + 15) # -> new phase: 36 + 15 = 51
#	$game_clock.phase # -> 3
#-----------------------------------------------------------------------------------------------
# Version 1.0.5 [06-26-2019]
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# * Updated Terms of Use. The script is now under the GNU Genreal Public License v3.0. It does
#   not affect the way you can use the script, it only changes how you should credit me (a link
#   to my website page for this script is mandatory now). If you are using a previous version of
#   this script, you are not required to provide a link to my website, however, if you do, it is
#   much appreciated.
#===============================================================================================

$imported = {}if $imported.nil?
$imported["Heirukichi_DayNightSystem"] = true

module HCK

	#===========================================================================================
	# Use this module to configure your script.
	#===========================================================================================

	module CONFIG

		#=======================================================================================
		# Change the following value to be the distance between your clock and window border.
		# Default is 40.
		#=======================================================================================
	
		CLOCK_PADDING = 40
	
		#=======================================================================================
		# The following value is used to decide where your clock is displayed.
		# 0 - Upper right
		# 1 - Upper left
		# 2 - Bottom right
		# 3 - Bottom left
		# Default is 0 (Upper right corner).
		#=======================================================================================
		
		CLOCK_POSITION = 0
		
		#=======================================================================================
		# This one is your clock image resolution. Default is "48x48". You can create images
		# with different resolution. Just remember that the resolution must be the same for both
		# clock and support. Resolution must be in the "WidthxHeight" format.
		#=======================================================================================
		
		RESOLUTION = "48x48"
		
		#=======================================================================================
		# Your clock is made using two different images. CLOCK is the image rotating while
		# SUPPORT is the structure containing that image. PATH is your images directory path.
		# Default PATH is "Graphics/Clock/". While there is a default value for CLOCK and
		# SUPPORT feel free to change that as much as you want as long as it contains the file
		# you need. File extension can be omitted.
		#=======================================================================================
		
		CLOCK = "Clock"
		SUPPORT = "Clock_support"
		
		PATH = "Graphics/Clock/"
		
		#=======================================================================================
		# This flag is used to determine whether Clock is displayed above Support or vice versa.
		# -1 -> Clock image is displayed ABOVE Support image
		#  1 -> Clock image is displayed BELOW Support image
		# Default value is 1.
		#=======================================================================================
		
		SUPPORT_POSITION = 1
		
		#=======================================================================================
		# The following value tells the engine the minimum rotation (in degrees) needed to
		# refresh your clock. Default is 2.
		#=======================================================================================
		
		REFRESH_DEGREES = 2
		
		#=======================================================================================
		# Change the following value to be the amount of frames in a single in-game hour.
		# Default is 18000 (A full day/night cycle requires 2 hours of real time).
		#=======================================================================================
		
		HOUR_FRAMES = 18000
		
		#=======================================================================================
		# This flag is used to determine if your clock will be visible since the beginning of
		# the game. Default is true. If you want to display your clock starting from a certain
		# point of your game instead of displaying it at the beginning of the game just set it
		# to false and then setup your clock somewhere else in an event.
		# To set up your clock you can use the following script call:
		#
		# $game_clock.setup
		#
		# The clock will NOT let you set it up again once it has already been set up. If you
		# want to change your in-game time you can set its time later.
		#=======================================================================================
		
		CLOCK_ON_START = true
		
		#=======================================================================================
		# Change this to be the starting phase (30 minutes interval) for your game. Default is
		# 16 (8 AM).
		#=======================================================================================
		
		STARTING_PHASE = 16
		
		#=======================================================================================
		# This value can be either true or false. When true your screen is tinted according to
		# the phase of the day you are in (Night, Dawn, etc.). Default is true. If set to false
		# do not bother with the next two groups of values.
		#=======================================================================================
		
		TINT_ON_CHANGES = true
		
		#=======================================================================================
		# The following values define your screen tone. You can use them to tint your screen as
		# time passes during the day. Values are as follows:
		# DAY_PHASE = [Red, Green, Blue, Gray, StartingPhase, EndingPhase]
		# StartingPhase is the value of your clock phase when your screen start being tinted
		# with that color, Ending phase is the last one.
		#=======================================================================================
		
		DAY = [0, 0, 0, 0, 14, 35]
		DAWN = [30, -34, -34, 0, 12, 13]
		DUSK = [68, -34, -34, 0, 36, 37]
		NIGHT = [-68, -68, 0, 68, 38, 11]
		
		#=======================================================================================
		# Change this to be your phase transition length (in frames). Default is 300.
		# Every value higher than 300 will be 300 by default. This is not something I want but
		# it is something the library itself does not allow.
		#=======================================================================================
		
		PHASE_TRANSITION = 300
		
		#=======================================================================================
		# These parameters are used to determine if your clock can be update when moving or not.
		# Set either UPDATE_WHEN_MOVING or UPDATE_WHEN_MOVING_WITH_SWITCH to true it you want
		# your clock to update only when moving. The main difference between the two is that if
		# UPDATE_WHEN_MOVING_WITH_SWITCH is set to true and the switch is set to false the clock
		# updates normally. To reserve a switch set UPDATE_WHEN_MOVING_SWITCH to be your switch
		# ID. Default is 1.
		# If you do not want to reserve a switch for such purpose but you still want your clock
		# to only update when moving set UPDATE_WHEN_MOVING to true.
		# UPDATE_WHEN_MOVING and UPDATE_WHEN_MOVING_WITH_SWITCH are both false by default.
		#=======================================================================================
		
		UPDATE_WHEN_MOVING = false
		UPDATE_WHEN_MOVING_WITH_SWITCH = false
		UPDATE_WHEN_MOVING_SWITCH = 1
		
	end
	
	#===========================================================================================
	# The following module contains a few methods used to debug this script. Set ACTIVE to true
	# to check if you configured this script correctly. Set it to false otherwise.
	#===========================================================================================
	
	module DEBUG
		
		ACTIVE = false
		
		#=======================================================================================
		# WARNING!!
		#---------------------------------------------------------------------------------------
		# DO NOT MODIFY AFTER THIS POINT UNLESS YOU KNOW WHAT YOU ARE DOING!
		#=======================================================================================
		
		def self.hour_frames
			return 60
		end
		
	end
	
	#===========================================================================================
	# Get clock image width.
	#===========================================================================================
	
	def self.width
		return res[0].to_i
	end
	
	#===========================================================================================
	# Get clock image height.
	#===========================================================================================
	
	def self.height
		return res[1].to_i
	end
	
	#===========================================================================================
	# Get resolution as an array.
	#===========================================================================================
	
	def self.res
		return CONFIG::RESOLUTION.split("x")
	end
	
	#===========================================================================================
	# Get clock complete path.
	#===========================================================================================
	
	def self.clock_path
		return "#{CONFIG::PATH}#{CONFIG::CLOCK}"
	end
	
	#===========================================================================================
	# Get support complete path.
	#===========================================================================================
	
	def self.support_path
		return "#{CONFIG::PATH}#{CONFIG::SUPPORT}"
	end
	
	#===========================================================================================
	# Get frames length of each day phase (1 phase = 30 game minutes).
	#===========================================================================================
	
	def self.phase_length
		return (hour_frames / 2)
	end
	
	#===========================================================================================
	# Get amount of frames needed to perform a single degree rotation.
	#===========================================================================================
	
	def self.degree_frames
		return (hour_frames / 15)
	end
	
	#===========================================================================================
	# Get number of frames in one hour. It might be much shorter when DEBUG::ACTIVE is true.
	#===========================================================================================
	
	def self.hour_frames
		DEBUG::ACTIVE ? DEBUG.hour_frames : CONFIG::HOUR_FRAMES
	end
	
	#===========================================================================================
	# Get number of frames in one minute. It might be much shorter when DEBUG::ACTIVE is true.
	#===========================================================================================
	
	def self.minute_frames
		return (hour_frames / 60)
	end
	
	#===========================================================================================
	# Get viewport coordinates.
	#===========================================================================================
	
	def self.vpx
		x = CONFIG::CLOCK_PADDING
		x = Graphics.width - x - width if (CONFIG::CLOCK_POSITION % 2 == 0)
		return x
	end
	
	def self.vpy
		y = CONFIG::CLOCK_PADDING
		y = Graphics.height - y - height if (CONFIG::CLOCK_POSITION >= 2)
		return y
	end
	
	#===========================================================================================
	# Get phase color.
	#===========================================================================================
	
	def self.phase_color(phase)
		return [0, 0, 0, 0, 0, 59] unless CONFIG::TINT_ON_CHANGES
		return CONFIG::DAWN if ((phase >= CONFIG::DAWN[4]) && (phase <= CONFIG::DAWN[5]))
		return CONFIG::DAY	if ((phase >= CONFIG::DAY[4]) && (phase <= CONFIG::DAY[5]))
		return CONFIG::DUSK	if ((phase >= CONFIG::DUSK[4]) && (phase <= CONFIG::DUSK[5]))
		return CONFIG::NIGHT
	end
	
	#===========================================================================================
	# Get if phase color needs to change.
	#===========================================================================================
	
	def self.phase_change?(phase)
		return true if phase == CONFIG::DAWN[4]
		return true if phase == CONFIG::DUSK[4]
		return true if phase == CONFIG::NIGHT[4]
		return true if phase == CONFIG::DAY[4]
		return false
	end
	
	#===========================================================================================
	# Get tint screen lenfth for phase trantision.
	#===========================================================================================
	
	def self.phase_transition_length
		DEBUG::ACTIVE ? (hour_frames / 3) : CONFIG::PHASE_TRANSITION
	end
	
	#===========================================================================================
	# Compares two different tones.
	#===========================================================================================
	
	def self.same_tone?(a, b, tolerance = 0.1)
		same_red = (a.red > (b.red - tolerance)) && (a.red < (b.red + tolerance))
		same_blue = (a.blue > (b.blue - tolerance)) && (a.blue < (b.blue + tolerance))
		same_green = (a.green > (b.green - tolerance)) && (a.green < (b.green + tolerance))
		same_gray = (a.gray > (b.gray - tolerance)) && (a.gray < (b.gray + tolerance))
		return same_red && same_blue && same_green && same_gray
	end
	
	#===========================================================================================
	# Gets phase tone.
	#===========================================================================================
	
	def self.phase_tone
		r = ($game_clock.indoor? ? 0 : HCK.phase_color($game_clock.phase)[0])
		g = ($game_clock.indoor? ? 0 : HCK.phase_color($game_clock.phase)[1])
		b = ($game_clock.indoor? ? 0 : HCK.phase_color($game_clock.phase)[2])
		gray = ($game_clock.indoor? ? 0 : HCK.phase_color($game_clock.phase)[3])
		tone = Tone.new(r, g, b, gray)
		return tone
	end
	
	#===========================================================================================
	# Determine if clock can be updated
	#===========================================================================================
	
	def self.moving_switch
		$game_switches[CONFIG::UPDATE_WHEN_MOVING_SWITCH]
	end
	
	def self.moving_switch_on?
		return moving_switch if CONFIG::UPDATE_WHEN_MOVING_WITH_SWITCH
		return false
	end
	
	def self.can_update?
		return $game_player.moving? if (CONFIG::UPDATE_WHEN_MOVING || moving_switch_on?)
		return true
	end

end

module DataManager

	#===========================================================================================
	# This part is used to alias a few methods inside DataManager module. Those methods are used
	# to export $game_clock into save files and load it from saved games.
	#===========================================================================================
	
	class << DataManager
		
		alias hck_make_save_contents_old	make_save_contents
		def make_save_contents
			contents = hck_make_save_contents_old
			contents[:clock] = 		$game_clock
			contents
		end
		
		alias hck_extract_save_contents_old	extract_save_contents
		def extract_save_contents(contents)
			hck_extract_save_contents_old(contents)
			$game_clock	=		contents[:clock]
		end
		
		alias hck_create_game_objects_old	create_game_objects
		def create_game_objects
			hck_create_game_objects_old
			$game_clock =		Game_Clock.new
		end
		
	end
	
end

class Game_Interpreter
	
	alias hck_command_223_old	command_223
	def command_223
		tone = Tone.new
		if (HCK.same_tone?(tone, @params[0]) && HCK::CONFIG::TINT_ON_CHANGES)
			screen.start_tone_change(HCK.phase_tone, @params[1])
			screen.allow_clock_tint
			wait(@params[1]) if @params[2]
		else
			screen.tint_manually if HCK::CONFIG::TINT_ON_CHANGES
			hck_command_223_old
		end
	end
	
	def set_clock_fading_speed(d)
		speed = 255 / d
		$game_clock.set_fade_speed(speed)
	end
	
	def tint_clear(d = 30)
		set_clock_fading_speed(d)
		screen.allow_clock_tint
		screen.start_tone_change(Tone.new, d)
	end
	
	def tint_normal(d = 30)
		set_clock_fading_speed(d)
		screen.allow_clock_tint
		screen.start_tone_change(HCK.phase_tone, d)
	end
	
	def tint_black(d = 30)
		screen.tint_manually if HCK::CONFIG::TINT_ON_CHANGES
		set_clock_fading_speed(-d)
		$game_clock.start_fading
		screen.start_tone_change(Tone.new(-255, -255, -255, 0), d)
	end
	
	def tint_white(d = 30)
		screen.tint_manually if HCK::CONFIG::TINT_ON_CHANGES
		set_clock_fading_speed(-d)
		$game_clock.start_fading
		screen.start_tone_change(Tone.new(255, 255, 255, 0), d)
	end
	
end

class Scene_Map < Scene_Base
	
	alias hck_start_old	start
	def start
		hck_start_old
		$game_clock.setup if HCK::CONFIG::CLOCK_ON_START
	end
	
end

class Spriteset_Map
	
	alias hck_initialize_old	initialize
	def initialize
		create_clock
		hck_initialize_old
	end
	
	#===========================================================================================
	# Create clock related sprites and viewport
	#===========================================================================================
	
	def create_clock
		create_clock_viewport
		create_clock_sprite
	end
	
	def create_clock_viewport
		@clock_viewport = Viewport.new(HCK.vpx, HCK.vpy, HCK.width, HCK.height)
		@clock_viewport.z = 100
	end
	
	def create_clock_sprite
		@spr_clock = Sprite_Clock.new(@clock_viewport)
	end
	
	#===========================================================================================
	# Update $game_clock and every clock related sprite and viewport
	#===========================================================================================
	
	alias hck_update_old		update
	def update
		update_clock
		hck_update_old
	end
	
	def update_clock
		$game_clock.update
		update_clock_sprite if ($game_clock.need_sprite_refresh? || $game_clock.fading?)
		update_clock_viewport if $game_clock.need_sprite_refresh?
		$game_clock.on_succesful_refresh if $game_clock.need_sprite_refresh?
	end
	
	def update_clock_sprite
		@spr_clock.angle = $game_clock.angle
		@spr_clock.visible = $game_clock.visible?
		@spr_clock.update
	end
	
	def update_clock_viewport
		@clock_viewport.update
	end
	
	#===========================================================================================
	# Dispose clock related sprites and viewport.
	#===========================================================================================
	
	alias hck_dispose_old		dispose
	def dispose
		dispose_clock
		hck_dispose_old
	end
	
	def dispose_clock
		dispose_clock_sprite
		dispose_clock_viewport
	end
	
	def dispose_clock_sprite
		@spr_clock.dispose
	end
	
	def dispose_clock_viewport
		@clock_viewport.dispose
	end
	
end

class Game_Screen

	alias hck_initialize_old	initialize
	def initialize
		@manual_tint = false
		@indoor_tint = false
		hck_initialize_old
	end
	
	def allow_clock_tint
		@manual_tint = false
	end
	
	def tint_manually
		@manual_tint = true
	end
	
	def can_apply_clock_tint?
		a = !@manual_tint
		b = !$game_clock.indoor?
		return (a && b)
	end
	
	alias hck_update_old	update
	def update
		if HCK::CONFIG::TINT_ON_CHANGES
			if ($game_clock.tone_update? && (can_apply_clock_tint? || $game_clock.indoor_tint?))
				update_clockphase_tone
			end
			$game_clock.on_succesful_indoor_tint if $game_clock.indoor_tint?
			$game_clock.on_succesful_tone_change if $game_clock.tone_update?
		end
		hck_update_old
	end
	
	def update_clockphase_tone
		tone = HCK.phase_tone
		duration = HCK.phase_transition_length
		start_tone_change(tone, duration)
	end
	
end

class Sprite_Clock

	attr_accessor	:visible
	attr_accessor	:angle
	
	def initialize(vp)
		@viewport = vp
		@visible = $game_clock.visible?
		@angle = $game_clock.angle
		create_clock
		create_support
		@support.z = @clock.z + HCK::CONFIG::SUPPORT_POSITION
	end
	
	def  create_clock
		@clock = Sprite.new(@viewport)
		@clock.visible = visible
		@clock.angle = angle
		@clock.x = @clock.ox = ox
		@clock.y = @clock.oy = oy
		@clock.bitmap = Bitmap.new(HCK.clock_path)
	end
	
	def create_support
		@support = Sprite.new(@viewport)
		@support.visible = visible
		@support.x = @support.ox = ox
		@support.y = @support.oy = oy
		@support.bitmap = Bitmap.new(HCK.support_path)
	end
	
	def ox
		(HCK.width / 2)
	end
	
	def oy
		(HCK.height / 2)
	end
	
	def viewport
		@viewport
	end
	
	def dispose
		@clock.dispose
		@support.dispose
	end
	
	def update
		update_visibility
		update_angle
		@clock.update
		@support.update
	end
	
	def update_visibility
		fade($game_clock.fade_speed) if ($game_clock.visible? && $game_clock.fading?) # new
		@clock.visible = visible
		@support.visible = visible
	end
	
	def fade(value)
		$game_clock.opacity += value
		$game_clock.opacity = 0 if $game_clock.opacity <= 0
		$game_clock.opacity = 255 if $game_clock.opacity >= 255
		$game_clock.set_fade_speed(0) if ($game_clock.opacity == 0 || $game_clock.opacity == 255)
		@clock.opacity = $game_clock.opacity
		@support.opacity = $game_clock.opacity
		@clock.update
		@support.update
		$game_clock.stop_fading if ($game_clock.opacity == 255)
	end
	
	def update_angle
		@clock.angle = angle
	end
	
end

class Game_Clock

	attr_accessor	:opacity
	attr_reader		:fade_speed
	
	def initialize
		@time = 0
		@rotation = 0
		@fade_speed = 0
		@fading = false
		@working = false
		@indoor = false
		@opacity = 255
		@need_refresh = false
		@refresh_sprites = false
		@visible = false
		@set_up = false
	end
	
	#===========================================================================================
	# Get in-game hour.
	#===========================================================================================
	
	def hour
		return 0 if (HCK.hour_frames == 0)
		time = (@time / HCK.hour_frames)
		return 12 if time == 0
		return (time <= 12 ? time : (time - 12))
	end
	
	def hour24
		return 0 if (HCK.hour_frames == 0)
		time = (@time / HCK.hour_frames)
		return time
	end
	
	#===========================================================================================
	# Get in-game minutes.
	#===========================================================================================
	
	def minute
		return 0 if (HCK.minute_frames == 0)
		return ((@time - hour24 * HCK.hour_frames) / HCK.minute_frames)
	end
	
	#===========================================================================================
	# Determine if current time is AM or PM.
	#===========================================================================================
	
	def ampm
		hour24 < 12 ? "AM" : "PM"
	end
	
	#===========================================================================================
	# Determine phase. Each day has 48 phases (30 minutes interval). Used for purposes like
	# transition between bright and dark and similar stuff.
	#===========================================================================================
	
	def phase
		return (@time / HCK.phase_length)
	end
	
	#===========================================================================================
	# Transforms time into String.
	#===========================================================================================
	
	def to_s
		time = sprintf("%02d:%02d %s", hour, minute, ampm)
		return time
	end
	
	#===========================================================================================
	# Check visibility.
	#===========================================================================================
	
	def visible?
		@visible
	end
	
	#===========================================================================================
	# Check current rotation.
	#===========================================================================================
	
	def angle
		@rotation = 0 if @rotation == 360
		@rotation == 0 ? 360 : @rotation
	end
	
	#===========================================================================================
	# Get next angle.
	#===========================================================================================
	
	def next_angle
		return (360 - @time / HCK.degree_frames)
	end
	
	#===========================================================================================
	# Toggle visibility.
	#===========================================================================================
	
	def toggle
		visible? ? hide : show
	end
	
	def show
		@visible = true
		@need_refresh = true
	end
	
	def hide
		@visible = false
		@need_refresh = true
	end
	
	#===========================================================================================
	# Clock setup.
	#===========================================================================================
	
	def setup(display = true)
		return if set_up?
		@time = HCK::CONFIG::STARTING_PHASE * HCK.phase_length
		@visible = display
		@rotation = next_angle
		@phase_update = true
		@need_refresh = true
		@set_up = true
		@working = true
		refresh
	end
	
	#=======================================================================================
	# Check if clock has been already set up.
	#=======================================================================================
	
	def set_up?
		@set_up
	end
	
	#=======================================================================================
	# Set clock time.
	#=======================================================================================
	
	def set_time(time = HCK::CONFIG::STARTING_PHASE)
		return unless time.is_a?(Integer)
		return if (time < 0)
		@time = (time % 48) * HCK.phase_length
		@rotation = ((next_angle % 2 == 0) ? next_angle : next_angle - 1)
		force_refresh
	end
	
	#=======================================================================================
	# Refresh Clock and set up flag to refresh sprites.
	#=======================================================================================
	
	def refresh
		if need_angle_refresh?
			@rotation = next_angle
			@refresh_sprites = true
		end
		@refresh_sprites = true if @need_refresh
		@need_refresh = false
	end
	
	def on_succesful_refresh
		@refresh_sprites = false
	end
	
	def need_angle_refresh?
		return ((angle - next_angle) >= HCK::CONFIG::REFRESH_DEGREES)
	end
	
	def need_refresh?
		return true if need_angle_refresh?
		return true if @need_refresh
		return false
	end
	
	def need_sprite_refresh?
		@refresh_sprites
	end
	
	def tone_update?
		return @phase_update
	end
	
	def on_succesful_tone_change
		@phase_update = false
	end
	
	def force_refresh
		@need_refresh = true
		@phase_update = true
	end
	
	#=======================================================================================
	# This method is used when tinting screen or when fading out. It tells the engine to
	# change clock opacity while changing screen color.
	#=======================================================================================
	
	def start_fading
		@fading = true
	end
	
	def stop_fading
		@fading = false
	end
	
	def fading?
		return @fading
	end
	
	def set_fade_speed(value)
		@fade_speed = value
	end
	
	#=======================================================================================
	# Methods to stop and resume clock.
	#=======================================================================================
	
	def stop
		@working = false
	end
	
	def resume
		@working = true
	end
	
	def working?
		@working
	end
	
	def toggle_timeflow
		working? ? stop : resume
	end
	
	#=======================================================================================
	# Methods used to stop tinting your screen when indoor.
	#=======================================================================================
	
	def set_indoor(inside = true)
		@indoor = inside
		@phase_update = true
		@indoor_tint_refresh = true if indoor?
	end
	
	def indoor?
		return @indoor
	end
	
	def toggle_indoor
		set_indoor(indoor? ? false : true)
	end
	
	def indoor_tint?
		return @indoor_tint_refresh
	end
	
	def on_succesful_indoor_tint
		@indoor_tint_refresh = false
	end
	
	#=======================================================================================
	# Check day phases.
	#=======================================================================================
	
	def night?
		a = phase > HCK::CONFIG::NIGHT[4]
		b = phase < HCK::CONFIG::NIGHT[5]
		return a || b
	end
	
	def dawn?
		a = phase > HCK::CONFIG::DAWN[4]
		b = phase < HCK::CONFIG::DAWN[5]
		return a && b
	end
	
	def dusk?
		a = phase > HCK::CONFIG::DUSK[4]
		b = phase < HCK::CONFIG::DUSK[5]
		return a && b
	end
	
	def day?
		a = phase > HCK::CONFIG::DAY[4]
		b = phase < HCK::CONFIG::DAY[5]
		return a && b
	end
	
	#=======================================================================================
	# Update clock and check if refresh is needed.
	#=======================================================================================
	
	def update
		return unless HCK.can_update?
		old_phase = phase
		@time += 1 if working?
		unless HCK.phase_change?(old_phase)
			@phase_update = true if HCK.phase_change?(phase)
		end
		puts "Current in-game time: #{to_s}" if HCK::DEBUG::ACTIVE
		refresh if need_refresh?
		@time = 0 if (@time == HCK.hour_frames * 24)
	end
	
end