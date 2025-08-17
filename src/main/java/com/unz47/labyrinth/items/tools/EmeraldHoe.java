package com.unz47.labyrinth.items.tools;

import net.minecraft.world.item.HoeItem;
import net.minecraft.world.item.Item;

public class EmeraldHoe extends HoeItem {
    public EmeraldHoe() {
        super(EmeraldTier.EMERALD, new Item.Properties().fireResistant());
    }
}