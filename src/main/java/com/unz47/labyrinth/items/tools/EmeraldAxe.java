package com.unz47.labyrinth.items.tools;

import net.minecraft.world.item.AxeItem;
import net.minecraft.world.item.Item;

public class EmeraldAxe extends AxeItem {
    public EmeraldAxe() {
        super(EmeraldTier.EMERALD, new Item.Properties().fireResistant());
    }
}