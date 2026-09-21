state("noita") {
	uint gameCompleted : "fmodstudio.dll", 0x107238, 0x24, 0xC, 0xE4, 0x54, 0x30, 0xC, 0xE4, 0x7C, 0x1C;
	uint loadingAnimation : 0xE04B94;
	int sampoUsed : 0xE249F0, 0x28, 0x4C, 0x0, 0x10;
	int isPolymorphed : 0xE2491C, 0x28, 0x98;
	int isDead : 0xE08784;
}

startup {
	settings.Add("startOnCursor", true, "Start when player spawns (Cursor appears)");

	settings.Add("split", true, "Split on:");
		settings.Add("gameCompleted", true, "Game Completed screen", "split");
		settings.Add("deathSplit", false, "Death", "split");

	settings.Add("reset", true, "Reset on:");
		settings.Add("newGame", true, "Starting game", "reset");
		settings.SetToolTip("newGame", "NOTE: Will also reset when restarting the game");
		settings.Add("deathReset", false, "Death", "reset");
}

init {
	var size = modules.First().ModuleMemorySize;
	print("MEMORY SIZE: " + size);

	vars.startTime = -1;
	vars.creditsPrimed = false;
}

onStart {
	print("STARTED");
}

onReset {
	vars.creditsPrimed = false;
	print("RESET");
}

update {
	// Flag to prevent Reset/Split on Death after the Sampo has been used.
	// Since we couldn't find a fully stable "Sampo Used" address, use a workaround to make sure the flag is ONLY set when you ACTUALLY use the Sampo.
	if (current.sampoUsed > 0 && current.isDead == 0 && current.isPolymorphed == 0 && !vars.creditsPrimed) {
		vars.creditsPrimed = true;
		print("CREDITS PRIMED!");
	}
}

start {
	// Start the timer when the Cursor appears
    if (current.loadingAnimation == 0 && current.loadingAnimation != old.loadingAnimation) {	
		// A little faster than I expected, so add a delay
        if (vars.startTime < 0) {
            vars.startTime = Environment.TickCount + 90;
		}
    }

    if (vars.startTime > 0 && Environment.TickCount >= vars.startTime) {
        vars.startTime = -1;
        return settings["startOnCursor"];
    }
}

reset {
	// Reset when you press New Game. Important to note that it also resets if you restart the game
	if (current.loadingAnimation != 0 && current.loadingAnimation != old.loadingAnimation) {	
		return settings["newGame"];
    }

	// Reset on Death
	if (current.isDead == 1 && current.isDead != old.isDead && !vars.creditsPrimed) {
		return settings["deathReset"];
	}
}

split {	
	// Split on game completed screen
	if (current.gameCompleted != null) {
		if (current.gameCompleted > 0 && old.gameCompleted == 0) {
			print("SPLIT: Game Complete!");
			return settings["gameCompleted"];
		}
	}

	// Split on Death
	if (current.isDead == 1 && current.isDead != old.isDead && !vars.creditsPrimed) {
		if (settings["deathSplit"]) {
			print("SPLIT: Death");
			return true;
		}
	}
}
