// Escape from Lavender Island Autosplitter and Load Remover Version 1.2.3 - Sept 28, 2023
// Autosplitter by TheDementedSalad
// Load Remover and Reset by SabulineHorizon
// Some memory pointers found with help from cactus

state("LavenderIsland-Win64-Shipping", "28/9/23")
{
    string88 Start        :    0x554AA40, 0x8, 0x60, 0x50, 0x0, 0x78, 0x258, 0x10, 0x10, 0x0;
    string88 Objective    :    0x5B05330, 0x180, 0x38, 0x0, 0x30, 0x250, 0x630, 0x8, 0x0, 0x0;
    string42 Map        :    0x5B05330, 0x180, 0x30, 0xF8, 0x0; //Local filepath to current map
    int FrameCount        :    0x5A55C04;
	byte LevelLoaded		:	0x5B05330, 0x180, 0x38, 0x0, 0x30, 0x250, 0x824; //False positives in intro, sleep cutscene, end, and main menu
	int IntroLoaded		:	0x5B05330, 0x180, 0x38, 0x0, 0x30, 0x5C8, 0x0; //Used to tell the difference between 0 and null for AdvanceIntro
	int AdvanceIntro		:	0x5B05330, 0x180, 0x38, 0x0, 0x30, 0x588; //Used to detect false positives in intro and end
	float PlayerZ	:	0x55DDDF0, 0x8, 0x38, 0x0, 0xC0, 0x1D8; //Used to detect false positives in sleep with bone leg cutscene
	
	byte PreLoading	: 0x5AB5C30, 0x0, 0x18, 0x48, 0x3B1; //0 not preloading, 1 preloading - this is an updated address that hasn't been tried yet, seems extremely reliable
	// byte LoadingScreenOn	: 0x5B05330, 0x120, 0x228, 0x3B0; //Only works when loading screen is on, doesn't remove loading before the screen
}

init
{
	switch (modules.First().ModuleMemorySize)
	{
		case (100638720):
			version = "SteamRelease";
			break;
		default:
			print("Unknown version detected");
        return false;
	}
}

startup
{
	vars.ASLVersion = "ASL Version 1.2.3 - Sept 28 2023";
	
	vars.completedSplits = new List<string>();
	vars.canLoad = false;
	
	if (timer.CurrentTimingMethod == TimingMethod.RealTime){ // stolen from dude simulator 3, basically asks the runner to set their livesplit to game time
		var timingMessage = MessageBox.Show (
			"This game uses Time without Loads (Game Time) as the main timing method.\n"+
			"LiveSplit is currently set to show Real Time (RTA).\n"+
			"Would you like to set the timing method to Game Time? This will make verification easier",
			"LiveSplit | Escape From Lavender Island",
		MessageBoxButtons.YesNo,MessageBoxIcon.Question);
		
		if (timingMessage == DialogResult.Yes){
			timer.CurrentTimingMethod = TimingMethod.GameTime;
		}
	}
	
	settings.Add("Obj", false, "Objectives");
		settings.SetToolTip("Obj", "Splits that are used in the more recent routes");
	settings.CurrentDefaultParent = "Obj";
	settings.Add("Go see the Warden/CEO/Dean upstairs to try a", false, "Talk to four legged creature");
	settings.Add("Climb to the top of that building and see if", false, "Escape the prison");
	settings.Add("That owl over there looks like he wants to t", false, "Free Everyone");
	settings.Add("Ask the Robot about your new ship.", false, "Get first ship");
	settings.Add("Follow the green markers on your map and wan", false, "Finish ship tutorial");
	settings.Add("Zoom in with RB or LB on your controller or ", false, "Get first mask (current version)");
		settings.SetToolTip("Zoom in with RB or LB on your controller or ", "Updated version, used when reloading to skip mask tutorial");
	settings.Add("Follow the green markers in the alien colony", false, "Enter Extra Terrestial Colony");
	settings.Add("Deliver the Urn to the ocean.", false, "Sleep with Bone Leg");
	settings.Add("Go talk to Bone Leg about doing mushrooms in", false, "Urn delivered to ocean");
	settings.Add("Go to the park and take the drugs with Bone ", false, "Bought shrooms");	
	settings.Add("Practice using your ship with unlimited powe", false, "Get final ship");
	settings.Add("What is outside the bottle?", false, "High as a kite");
	settings.CurrentDefaultParent = null;

	settings.Add("End", true, "Final split (always active)");
	
	settings.Add("Alt", false, "Obsolete Splits");
		settings.SetToolTip("Alt", "Obsolete splits that were only part of the old route");
	settings.Add("You can visit the pharmacy with your new mas", false, "Get first mask (old version)", "Alt");
		settings.SetToolTip("You can visit the pharmacy with your new mas", "Old version, doesn't split until mask tutorial is complete");
	settings.Add("Continue exploring or you can leave the neig", false, "Finish pharmacy", "Alt");
	settings.Add("Follow the green markers around the slums.", false, "Enter So-Tep Slums", "Alt");
	settings.Add("Try out your new vape juice.", false, "Get vape", "Alt");
	settings.Add("Practice using your new ship. See how high y", false, "Get second ship", "Alt");
	settings.Add("Wash the scientist's dirty clothes.", false, "Reach scientist", "Alt");
	settings.Add("Take the clean clothes back to the scientist", false, "Finish laundry", "Alt");
	settings.Add("Practice using your scientist mask. Explore ", false, "Get second mask", "Alt");
	
	settings.Add("Luck", false, "Luck");
		settings.SetToolTip("Luck", "This setting literally doesn't do anything. Feel free to check it if you think it might bring good luck");
}

update
{
	//Uncomment debug information in the event of an update.
	//print(modules.First().ModuleMemorySize.ToString());
	
	if(timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.completedSplits.Clear();
	}
	
	// if player doesn't exist, loading is allowed
	if (current.PlayerZ == 0)
		vars.canLoad = true;
	
	// if loading ended, disable flag
	if (old.LevelLoaded != 1 && current.LevelLoaded == 1)
		vars.canLoad = false;
}

start
{
	return current.Start == "Welcome to Lavender Corporate University Pri" && old.Start != "Welcome to Lavender Corporate University Pri";
}

split
{
	if(current.Objective != null && settings["" + current.Objective] && !vars.completedSplits.Contains(current.Objective) && current.Objective != old.Objective){
		vars.completedSplits.Add(current.Objective);
		return true;
	}
		
	if(current.Objective != old.Objective && old.Objective == "Go see the credits and go back to Lavender C" && !vars.completedSplits.Contains(old.Objective)){
		vars.completedSplits.Add(old.Objective);
		return true;
	}
}

isLoading
{
	return ((current.PreLoading == 1) ||
			((current.LevelLoaded != 1) &&
			!(current.AdvanceIntro >= 0 && current.AdvanceIntro < 7 && current.IntroLoaded != 0) &&
			(vars.canLoad == true) &&
			(current.Map != "/Game/Maps/MainMenu")));
}

reset
{
	return current.FrameCount < old.FrameCount && current.Map == "/Game/Maps/IntroLevel";
}
