package com.unz47.labyrinth.tabs;

import com.unz47.labyrinth.main.Labyrinth;
import net.minecraft.core.registries.Registries;
import net.minecraft.network.chat.Component;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.world.item.CreativeModeTab;
import net.minecraft.world.item.CreativeModeTabs;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.RegistryObject;

public class LabyrinthDim2Tab {
    public static final DeferredRegister<CreativeModeTab> CREATIVE_MODE_TABS = 
            DeferredRegister.create(Registries.CREATIVE_MODE_TAB, Labyrinth.MOD_ID);

    public static final RegistryObject<CreativeModeTab> LABYRINTH_DIM2 = CREATIVE_MODE_TABS.register("labyrinth_dim2",
            () -> CreativeModeTab.builder()
                    .icon(() -> new ItemStack(Items.EMERALD))
                    .title(Component.translatable("creativetab.labyrinth_dim2"))
                    .withTabsBefore(ResourceLocation.fromNamespaceAndPath(Labyrinth.MOD_ID, "labyrinth_dim1"))
                    .displayItems((parameters, output) -> {
                        addItems(output);
                    })
                    .build());
    
    private static void addItems(CreativeModeTab.Output output) {
        output.accept(Items.STONE);
    }
}