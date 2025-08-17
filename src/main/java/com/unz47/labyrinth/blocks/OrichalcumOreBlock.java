package com.unz47.labyrinth.blocks;

import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.DropExperienceBlock;
import net.minecraft.world.level.block.SoundType;
import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.util.valueproviders.UniformInt;

public class OrichalcumOreBlock extends DropExperienceBlock {
    
    public OrichalcumOreBlock() {
        super(UniformInt.of(3, 7), BlockBehaviour.Properties.of()
                .strength(3.0f, 3.0f)
                .requiresCorrectToolForDrops()
                .sound(SoundType.STONE));
    }
}