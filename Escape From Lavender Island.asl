// Escape from Lavender Island Autosplitter and Load Remover Version 1.0.1 - Sept 14, 2023
// Autosplitter by TheDementedSalad
// Load Remover and Reset by SabulineHorizon


state("LavenderIsland-Win64-Shipping")
{
	string88 Start		:	0x55499F0, 0x8, 0x60, 0x50, 0x0, 0x78, 0x258, 0x10, 0x10, 0x0;
	string88 Objective	:	0x553A510, 0x40, 0x18, 0x238, 0x238, 0x350, 0x328, 0x128, 0x28, 0x0;
	string42 Map		:	0x5B042F0, 0x180, 0x30, 0xF8, 0x0; //Local filepath to current map
	int Loading		:	0x5B009D8, 0xA88, 0x1B0, 0x90; //981668864 yes, other no
	int FrameCount		:	0x5A54BC4; //I think it's a frame count, not really certain
}

init
{

}

startup
{
	vars.ASLVersion = "ASL Version 1.0.1 - Sept 14 2023";
	
	vars.completedSplits = new List<string>();
	
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
	settings.CurrentDefaultParent = "Obj";
	settings.Add("Go see the Warden/CEO/Dean upstairs to try a", false, "Talk to four legged creature");
	settings.Add("Climb to the top of that building and see if", false, "Escape the prison");
	settings.Add("That owl over there looks like he wants to t", false, "Free Everyone");
	settings.Add("Ask the Robot about your new ship.", false, "Get first ship");
	settings.Add("Follow the green markers on your map and wan", false, "Finish ship tutorial");
	settings.Add("You can visit the pharmacy with your new mas", false, "Get first mask");
	settings.Add("Continue exploring or you can leave the neig", false, "Finish pharmacy");
	settings.Add("Follow the green markers around the slums.", false, "Enter So-Tep Slums");
	settings.Add("Try out your new vape juice.", false, "Get vape");
	settings.Add("Practice using your new ship. See how high y", false, "Get second ship");
	settings.Add("Wash the scientist's dirty clothes.", false, "Reach scientist");
	settings.Add("Take the clean clothes back to the scientist", false, "Finish laundry");
	settings.Add("Practice using your scientist mask. Explore ", false, "Get second mask");
	settings.Add("Follow the green markers in the alien colony", false, "Enter Extra Terrestial Colony");
	settings.Add("Deliver the Urn to the ocean.", false, "Sleep with Bone Leg");
	settings.Add("Go talk to Bone Leg about doing mushrooms in", false, "Urn delivered to ocean");
	settings.Add("Go to the park and take the drugs with Bone ", false, "Bought shrooms");	
	settings.Add("Practice using your ship with unlimited powe", false, "Get final ship");
	settings.Add("What is outside the bottle?", false, "High as a kite");
	settings.CurrentDefaultParent = null;

	settings.Add("End", true, "Final split (always active)");
	
	
}

update
{
	//Uncomment debug information in the event of an update.
	//print(modules.First().ModuleMemorySize.ToString());
	
	if(timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.completedSplits.Clear();
	}
}

start
{
	return current.Start == "Welcome to Lavender Corporate University Pri" && old.Start != "Welcome to Lavender Corporate University Pri";
}

split
{
	if(settings["" + current.Objective] && !vars.completedSplits.Contains(current.Objective) && current.Objective != old.Objective){
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
	return current.Loading == 981668864;
}

reset
{
	return current.FrameCount < old.FrameCount && current.Map == "/Game/Maps/IntroLevel";
}
