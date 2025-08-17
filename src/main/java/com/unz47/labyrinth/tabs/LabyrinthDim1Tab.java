package com.unz47.labyrinth.tabs;

import com.unz47.labyrinth.main.Labyrinth;
import com.unz47.labyrinth.regi.ModItems;
import net.minecraft.core.registries.Registries;
import net.minecraft.network.chat.Component;
import net.minecraft.world.item.CreativeModeTab;
import net.minecraft.world.item.CreativeModeTabs;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.RegistryObject;

public class LabyrinthDim1Tab {
    public static final DeferredRegister<CreativeModeTab> CREATIVE_MODE_TABS = 
            DeferredRegister.create(Registries.CREATIVE_MODE_TAB, Labyrinth.MOD_ID);

    public static final RegistryObject<CreativeModeTab> LABYRINTH_DIM1 = CREATIVE_MODE_TABS.register("labyrinth_dim1",
            () -> CreativeModeTab.builder()
                    .icon(() -> new ItemStack(Items.DIAMOND))
                    .title(Component.translatable("creativetab.labyrinth_dim1"))
                    .withTabsBefore(CreativeModeTabs.SPAWN_EGGS)
                    .displayItems((parameters, output) -> {
                        addItems(output);
                    })
                    .build());
    
    private static void addItems(CreativeModeTab.Output output) {
        output.accept(Items.STONE);
        output.accept(com.unz47.labyrinth.regi.ModBlocks.ORICHALCUM_ORE.get());
        output.accept(com.unz47.labyrinth.regi.ModItems.BASIC_INGOT.get());

        // Emerald Tools
        output.accept(ModItems.EMERALD_PICKAXE.get());
        output.accept(ModItems.EMERALD_AXE.get());
        output.accept(ModItems.EMERALD_HOE.get());
        output.accept(ModItems.EMERALD_SWORD.get());
        output.accept(ModItems.EMERALD_SHOVEL.get());
    }
}