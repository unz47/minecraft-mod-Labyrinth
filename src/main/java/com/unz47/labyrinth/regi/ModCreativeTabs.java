package com.unz47.labyrinth.regi;

import com.unz47.labyrinth.tabs.LabyrinthDim1Tab;
import com.unz47.labyrinth.tabs.LabyrinthDim2Tab;
import net.minecraftforge.eventbus.api.IEventBus;

public class ModCreativeTabs {
    
    public static void register(IEventBus eventBus) {
        LabyrinthDim1Tab.CREATIVE_MODE_TABS.register(eventBus);
        LabyrinthDim2Tab.CREATIVE_MODE_TABS.register(eventBus);
    }
}