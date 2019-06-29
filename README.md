# Day-Night_Cycle-VXAce
_Author: Heirukichi_

## DESCRIPTION
This script adds a day/night cycle. In addition to that it adds a clock sprite so players can get a grasp on game time.


## INSTALLATION
To set up this script you can change values inside `HCK::CONFIG` module. The purpose of each of those values is explained in detail there. If you just want your day/night cycle there are few default values you can use for a fast plug-and-play use of this script.

This script is meant to work with two clock images. One is fixed (it is called clock support or just support in the script) while one can move (that is called just clock). The default path for those images is inside Graphics/Clock/ but feel free to change that when configuring the script.

Those two images must have the same size and are displayed one above the other. Which one goes above and which one goes below is up to you. In the settings you have a value for that too.

#### _**NOTICE**_
Since this script is meant as a night/day cycle, while it can still provide in-game time using `$game_clock.to_s` (it uses the format hh:mm AM/PM) the sprite moves over a cycle of 24 hours (not 12). For this reason it is suited for something showing at which point of the cycle you are but you cannot use it to make a real clock (unless it is a digital one, in which case it works).

While inside the engine you can use `$game_clock.set_time(phase)` in a script call to change your in-game time withuot having to wait that time actually passes by. You can use it to let the player rest in an inn or in any other situation that requires your time to flash-forward a bit. In this script call "phase" is the 30 minutes interval you want for your time.

##### Examples:
`$game_clock.set_time(45)` <- This sets your time to be 22:30 (10:30 PM)
`$game_clock.set_time(2)`	 <- This sets your time to be 01:00 (01:00 AM)

If you decide not to initialize your clock at the beginning of the game and you want to set it up later using an event you can use $game_clock.setup(display). This will set up your clock and makes it ready to work. Its visibility depends on display value. It can be either true or false. If display is omitted then the default value (true) is used. Using setup automatically sets your time to `HCK::CONFIG::STARTING_PHASE`. No `$game_clock.set_time` needed after a setup.

Once your clock has been set up you can access many different methods using script calls.

## USAGE

### METHODS YOU CAN USE TO CONTROL YOUR CLOCK

- `$game_clock.toggle` makes your clock visible when invisible or hides it if visible.
- `$game_clock.show` forces your clock to be visible. It has no effect when already visible.
- `$game_clock.hide` forces your clock to disappear. If already invisible it has no effect.
- `$game_clock.stop` stops your in-game time.
- `$game_clock.resume` resumes your in-game time.
- `$game_clock.toggle_timeflow` can either stop your clock or resume it depending on its status.
- `$game_clock.to_s` returns a string containing your in-game time in the format hh:mm AM/PM.
- `$game_clock.visible?` tells you if your clock is visible.
- `$game_clock.hour` returns your in-game hour in 12h format.
- `$game_clock.hour24` returns your in-game hour in 24h format.
- `$game_clock.minute` returns your in-game minutes.
- `$game_clock.phase` returns the current 30 minutes interval.
- `$game_clock.force_refresh` forces a sprite refresh for your clock.
- `$game_clock.set_indoor(value)`	tells the engine if you are inside or outside. Value is true when inside and false when outside. This is used to prevent the engine from tinting your screen automatically. Clock indoor flag is set to false when initializing `$game_clock`. If you want it to be true do not forget to do it manually! You can do it before setting up your clock so that the no screen tone is accidentally applied.
- `$game_clock.toggle_indoor` toggles indoor flag setting it to true if false or vice versa.
- `$game_clock.indoor?` returns true if your indor flag is true, false otherwise.
- `$game_clock.day? $game_clock.night? $game_clock.dawn? $game_clock.dusk?` return true if the chosen phase is running, false otherwise.

### GAME INTERPRETER CHANGES
This script changes how Tint Screen works and whenever you want to tint your screen back to normal it automatically detects the color of your current phase of the day and uses that one instead. For this reason I added a few methods to tint your screen to the normal (day) color using a script call even when it is using a different color.
- `tint_black(duration)` tints your screen black (clock opacity goes to 0).
- `tint_white(duration)` tints your screen white (clock opacity goes to 0).
- `tint_clear(duration)` tints your screen to the normal tone (0, 0, 0, 0).
- `tint_normal(duration)` tints your screen to the day phase color (clock opacity goes to 255).

In all these methods, duration is the amount of frames your titn screen takes to complete. It can be omitted.
Default value when omitted is 30 (same as Fadeout and Fadein).

#### _**NOTICE**_
Tint Screen is NOT Fadeout nor Fadein! Tint Screen does not let your message disappear nor tints your pictures.

#### _**NOTICE**_
`Game_Interpreter` methods are not `Game_Clock methods`. You can use them in a script call by just writing them as they are. Using `$game_clock.tint_black` **DOES NOT WORK**!

### COMPATIBILITY

This script creates a few new classes and create aliased methods for existing ones. Since there are no overwritten methods in this script it should (theoretically) be compatible with any other script overwriting one of those methods as long as this one is placed BELOW it.

Symbol | Method
-------|-------
\* | aliased method
\+ | new method
\! | overwritten method

*DataManager*
- \* make_save_contents
- \* extract_save_contents
- \* create_game_objects

*Game_Interpreter*
-	\* command_223
-	\+ set_clock_fading_speed
- \+ tint_clear
- \+ tint_normal
- \+ tint_black
- \+ tint_white

*Scene_Map*
-	\* start

*Spriteset_Map*
- \* initialize
- \+ create_clock
- \+ create_clock_viewport
- \+ create_clock_sprite
- \* update
- \+ update_clock
- \+ update_clock_sprite
- \+ update_clock_viewport
- \* dispose
- \+ dispose_clock
- \+ dispose_clock_sprite
- \+ dispose_clock_viewport

*Game_Screen*
-	\* initialize
-	\+ allow_clock_tint
-	\+ tint_manually
-	\+ can_apply_clock_tint? 
-	\* update
- \+ update_clockphase_tone

*Sprite_Clock*
-	\+ initialize
-	\+ create_clock
-	\+ create_support
-	\+ ox
-	\+ oy
-	\+ dispose
-	\+ update
-	\+ update_visibility
-	\+ update_angle

*Game_Clock*
-	\+ initialize
-	\+ hour
-	\+ hour24
-	\+ minute
-	\+ ampm
-	\+ phase
-	\+ to_s
-	\+ visible?
-	\+ angle
-	\+ next_angle
- \+ toggle
-	\+ show
-	\+ hide
-	\+ setup
-	\+ set_up?
-	\+ set_time
-	\+ refresh
-	\+ on_succesful_refresh
-	\+ need_angle_refresh?
-	\+ need_refresh?
-	\+ tone_update?
-	\+ on_succesful_tone_change
-	\+ force_refresh
-	\+ start_fading
-	\+ stop_fading
-	\+ fading?
-	\+ set_fade_speed
-	\+ stop
-	\+ resume
-	\+ working?
-	\+ toggle_timeflow
-	\+ set_indoor
-	\+ indoor?
-	\+ toggle_indoor
-	\+ indoor_tint?
-	\+ on_succesful_indoor_tint
-	\+ night?
-	\+ dawn?
-	\+ dusk?
-	\+ day?
- \+ update

## LICENSE
All the images in this project are under the CC BY-SA 4.0 International license. You can review the full license [here](https://creativecommons.org/licenses/by-sa/4.0/legalcode).

The code is under the GNU General Public License v3.0. You can review the complete GNU General Public License v3.0 in the LICENSE file or at this [link](https://www.gnu.org/licenses/gpl-3.0.html).

To sum up things you are free to use this material in any commercial and non commercial project as long as:
- proper credit is given to me (Heirukichi);
- a link to my website is provided (I recommend adding it to a credits.txt file in your project, but any other mean is fine);
- if you modify anything, you still provide credit and properly mark the parts you have modified.

In addition, I would like to be notified if you use this in any project.
You can send me a message containing a link to the finished product using the contact form on my website (check my profile for the link).
The link is not supposed to contain a free copy of the finished product.
The sole purpose of the link is to help me keeping track of where my work is being used.

More information can be found in the script itself.
At the same time, the script contains detailed instructions on how to use it. Read them carefully.
