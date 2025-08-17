package com.unz47.labyrinth.items.tools;

import net.minecraft.world.item.ShovelItem;
import net.minecraft.world.item.Item;

public class EmeraldShovel extends ShovelItem {
    public EmeraldShovel() {
        super(EmeraldTier.EMERALD, new Item.Properties().fireResistant());
    }
}