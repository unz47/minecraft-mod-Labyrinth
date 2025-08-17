package com.unz47.labyrinth.items.tools;

import net.minecraft.tags.BlockTags;
import net.minecraft.world.item.Tier;
import net.minecraft.world.item.crafting.Ingredient;
import net.minecraft.world.item.Items;
import net.minecraft.tags.TagKey;
import net.minecraft.world.level.block.Block;

public enum EmeraldTier implements Tier {
    EMERALD;

    @Override
    public int getUses() {
        return 250; // 鉄と同等
    }

    @Override
    public float getSpeed() {
        return 6.0f; // 鉄と同等
    }

    @Override
    public float getAttackDamageBonus() {
        return 2.0f; // 鉄と同等
    }

    public int getLevel() {
        return 2; // 鉄と同等
    }

    @Override
    public int getEnchantmentValue() {
        return 14; // 鉄と同等
    }

    @Override
    public Ingredient getRepairIngredient() {
        return Ingredient.of(Items.EMERALD);
    }

    @Override
    public TagKey<Block> getIncorrectBlocksForDrops() {
        return BlockTags.INCORRECT_FOR_IRON_TOOL;
    }
}