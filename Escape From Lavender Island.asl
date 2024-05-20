// Escape from Lavender Island Autosplitter and Load Remover Version 1.3.0 - May 20, 2024
// Autosplitter by TheDementedSalad
// Load Remover and Reset by SabulineHorizon
// Some additional splits for 100% found with help from wRadion

// This version was hastily thrown together to work with the most recent game update and hasn't been tested very much yet
// It probably needs more testing since some pointers might break

state("LavenderIsland-Win64-Shipping", "Steam 10/10/23")
{
	string88 Start		:	0x554AA40, 0x8, 0x50, 0x50, 0x148, 0x298, 0x0, 0x20, 0x0, 0x0, 0x0;
	string88 Objective	:	0x553B560, 0x40, 0x18, 0x238, 0x40, 0x8, 0x350, 0x328, 0x130, 0x38, 0x0;
	string42 Map		:	0x5B05370, 0x180, 0x30, 0xF8, 0x0; //Local filepath to current map
	int FrameCount		:	0x5A55C44;
	
	//The following 2 addresses should work most of the time, but haven't been fully stress-tested for reliability
	byte PreLoading		:	0x5A887B8, 0x58, 0x158; //0 not preloading, 1 preloading
	int LoadingScreen	:	0x5ADDD30, 0x90, 0x1B0, 0x90; //981668864 yes, other no - Only works during times when loading screen is visible 
}

init
{
	// print("ModuleSize: " + modules.First().ModuleMemorySize.ToString());
	switch (modules.First().ModuleMemorySize)
	{
		//This uses ModuleMemorySize to detect version
		case (100642816):
			version = "Steam 10/10/23";
			break;
		default:
			print("Unknown version detected");
        return false;
	}
}

startup
{
	vars.ASLVersion = "ASL Version 1.3.0 - May 20, 2024"; //Written to work with "Steam 10/10/23" game version
	
	vars.completedSplits = new List<string>();
	vars.canLoad = false;
	vars.colonyFlag = 0;
	
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
	
	settings.Add("Obj", false, "Any% Splits");
	settings.SetToolTip("Obj", "Splits that are used in the Any% route");
	settings.CurrentDefaultParent = "Obj";
	settings.Add("Go see the Warden/CEO/Dean upstairs to try a", true, "Talk to four legged creature");
	settings.Add("Climb to the top of that building and see if", true, "Escape the prison");
	settings.Add("That owl over there looks like he wants to t", true, "Free Everyone");
	settings.Add("Ask the Robot about your new ship.", true, "Get first ship");
	settings.Add("Follow the green markers on your map and wan", true, "Finish ship tutorial");
	settings.Add("Zoom in with RB or LB on your controller or ", true, "Get first mask");
	settings.Add("Follow the green markers in the alien colony", true, "Enter Extra Terrestial Colony");
	settings.Add("Deliver the Urn to the ocean.", true, "Sleep with Bone Leg");
	settings.Add("Go talk to Bone Leg about doing mushrooms in", true, "Urn delivered to ocean");
	settings.Add("Go to the park and take the drugs with Bone ", true, "Bought shrooms");	
	settings.Add("Practice using your ship with unlimited powe", true, "Get final ship");
	settings.Add("What is outside the bottle?", true, "High as a kite");
	settings.CurrentDefaultParent = null;

	settings.Add("Alt", false, "Additional Splits");
	settings.SetToolTip("Alt", "Splits that are used in the 100% route and other extended categories");
	settings.CurrentDefaultParent = "Alt";
	settings.Add("Welcome to your orientation to the Lavender ", true, "Map Tutorial");
	settings.Add("Continue exploring or you can leave the neig", true, "Finish pharmacy");
	settings.Add("Follow the green markers around the slums.", true, "Enter So-Tep Slums");
	settings.Add("Try out your new vape juice.", true, "Get vape");
	settings.Add("Practice using your new ship. See how high y", true, "Get second ship");
	settings.Add("Wash the scientist's dirty clothes.", true, "Reach scientist");
	settings.Add("Take the clean clothes back to the scientist", true, "Finish laundry");
	settings.Add("Practice using your scientist mask. Explore ", true, "Get second mask");
	settings.Add("Follow the green markers around  the renovat", true, "Enter Clown Crypt Renovation Zone");
	settings.Add("Complete all 3 Clown Town challenges.", true, "Trapped in Clown Town");
	settings.Add("Complete 2 more Clown Town challenges.", true, "First clown challenge");
	settings.Add("Find and complete the last Clown Town challe", true, "Second clown challenge");
	settings.Add("Learn new dances with your clown mask. Enter", true, "Get third mask");
	settings.Add("Follow the green markers in the disintegrati", true, "Enter Business Disintegration District");
	settings.Add("Collect social media followers by bumping in", true, "Get fourth mask");
	settings.Add("Get 10 LavCoins to visit the mall. Play game", true, "Followers collected");
	settings.Add("Investigate the LavCoin underground mall.", true, "Mall Door opened");
	settings.Add("Escape the Business Disintegration District", true, "Get fourth ship");
	settings.Add("Learn alien mask", true, "Get final mask", "Alt");
	settings.CurrentDefaultParent = null;
	
	settings.Add("End", true, "Final split (always active)");
		settings.SetToolTip("End", "Triggers when the end cutscene plays");
	
	settings.Add("ColonyPause", false, "Extra Terrestrial Colony Pause");
		settings.SetToolTip("ColonyPause", "Pause when entering the Extra Terrestrial Colony, unpauses after reload");
	
	settings.Add("Luck", false, "Luck");
		settings.SetToolTip("Luck", "This setting literally doesn't do anything. Feel free to check it if you think it might bring good luck");
}

onStart
{
	vars.completedSplits.Clear();
	vars.colonyFlag = 0;
}

update
{
	//Uncomment debug information in the event of an update.
	//print(modules.First().ModuleMemorySize.ToString());
	
	// if(timer.CurrentPhase == TimerPhase.NotRunning)
		// vars.completedSplits.Clear();
	
	//pause when entering Extra Terrestrial Colony
	if(settings["ColonyPause"] && vars.colonyFlag == 0 && current.Objective != null && current.Objective == "Follow the green markers in the alien colony")
		vars.colonyFlag = 1;
	//disable colonyFlag once loading starts
	if(current.PreLoading == 1 && vars.colonyFlag == 1)
		vars.colonyFlag = 2;
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
	return (current.PreLoading == 1) ||
			(current.LoadingScreen == 981668864) ||
			(vars.colonyFlag == 1);
}

reset
{
	return current.FrameCount < old.FrameCount && current.Map == "/Game/Maps/IntroLevel";
}
