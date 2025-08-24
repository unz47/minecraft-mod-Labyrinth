package com.unz47.labyrinth.dimension;

import com.unz47.labyrinth.main.Labyrinth;
import net.minecraft.core.registries.Registries;
import net.minecraft.resources.ResourceKey;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.dimension.DimensionType;

public class ModDimensions {
    
    public static final ResourceKey<Level> ORE_DIMENSION_KEY = ResourceKey.create(Registries.DIMENSION, 
            new ResourceLocation(Labyrinth.MOD_ID, "ore_dimension"));
    
    public static final ResourceKey<DimensionType> ORE_DIMENSION_TYPE = ResourceKey.create(Registries.DIMENSION_TYPE, 
            new ResourceLocation(Labyrinth.MOD_ID, "ore_dimension_type"));
    
    public static void register() {
        System.out.println("Registering Mod Dimensions for " + Labyrinth.MOD_ID);
    }
}