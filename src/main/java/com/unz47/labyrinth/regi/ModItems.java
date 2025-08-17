package com.unz47.labyrinth.regi;

import com.unz47.labyrinth.items.dim1.ingot.Ingots;
import com.unz47.labyrinth.main.Labyrinth;
import net.minecraft.world.item.Item;
import com.unz47.labyrinth.items.tools.*;
import net.minecraftforge.eventbus.api.IEventBus;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

public class ModItems {
    public static final DeferredRegister<Item> ITEMS = 
            DeferredRegister.create(ForgeRegistries.ITEMS, Labyrinth.MOD_ID);
    
    // Dim1 Ingots
    public static final RegistryObject<Item> BASIC_INGOT = ITEMS.register("basic_ingot",
            Ingots.BasicIngot::new);

    // Emerald Tools
    public static final RegistryObject<Item> EMERALD_PICKAXE = ITEMS.register("emerald_pickaxe",
            EmeraldPickaxe::new);
    public static final RegistryObject<Item> EMERALD_AXE = ITEMS.register("emerald_axe",
            EmeraldAxe::new);
    public static final RegistryObject<Item> EMERALD_HOE = ITEMS.register("emerald_hoe",
            EmeraldHoe::new);
    public static final RegistryObject<Item> EMERALD_SWORD = ITEMS.register("emerald_sword",
            EmeraldSword::new);
    public static final RegistryObject<Item> EMERALD_SHOVEL = ITEMS.register("emerald_shovel",
            EmeraldShovel::new);
    
    public static void register(IEventBus eventBus) {
        ITEMS.register(eventBus);
    }
}