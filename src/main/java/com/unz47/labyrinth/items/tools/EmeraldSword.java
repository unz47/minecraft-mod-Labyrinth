package com.unz47.labyrinth.items.tools;

import net.minecraft.world.item.SwordItem;
import net.minecraft.world.item.Item;

public class EmeraldSword extends SwordItem {
    public EmeraldSword() {
        super(EmeraldTier.EMERALD, new Item.Properties().fireResistant());
    }
}