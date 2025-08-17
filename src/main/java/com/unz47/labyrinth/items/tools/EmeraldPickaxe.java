package com.unz47.labyrinth.items.tools;

import net.minecraft.world.item.PickaxeItem;
import net.minecraft.world.item.Item;

public class EmeraldPickaxe extends PickaxeItem {
    public EmeraldPickaxe() {
        super(EmeraldTier.EMERALD, new Item.Properties().fireResistant());
    }
}