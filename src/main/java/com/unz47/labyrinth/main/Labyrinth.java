package com.unz47.labyrinth.main;

import com.unz47.labyrinth.regi.ModBlocks;
import com.unz47.labyrinth.regi.ModCreativeTabs;
import com.unz47.labyrinth.regi.ModItems;
import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.eventbus.api.IEventBus;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;

@Mod("labyrinth")
public class Labyrinth {

    public static final String MOD_ID = "labyrinth";

    public Labyrinth() {
        IEventBus modEventBus = FMLJavaModLoadingContext.get().getModEventBus();
        
        ModBlocks.register(modEventBus);
        ModItems.register(modEventBus);
        ModCreativeTabs.register(modEventBus);
        
        MinecraftForge.EVENT_BUS.register(this);
    }
}