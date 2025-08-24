package com.unz47.labyrinth.events;

import com.unz47.labyrinth.blocks.GlowstonePortalBlock;
import net.minecraft.core.BlockPos;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.item.FlintAndSteelItem;
import net.minecraft.world.level.Level;
import net.minecraftforge.event.entity.player.PlayerInteractEvent;
import net.minecraftforge.eventbus.api.EventPriority;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;

@Mod.EventBusSubscriber(modid = "labyrinth")
public class PortalIgnitionHandler {
    
    @SubscribeEvent(priority = EventPriority.HIGH)
    public static void onRightClickBlock(PlayerInteractEvent.RightClickBlock event) {
        if (event.getItemStack().getItem() instanceof FlintAndSteelItem) {
            Level level = event.getLevel();
            BlockPos pos = event.getPos();
            
            System.out.println("Flint and steel used at: " + pos);
            System.out.println("Block at position: " + level.getBlockState(pos).getBlock());
            
            // ポータル作成を試行
            boolean portalCreated = GlowstonePortalBlock.trySpawnPortal(level, pos, event.getEntity());
            
            if (portalCreated) {
                System.out.println("Portal created successfully!");
                if (!level.isClientSide) {
                    level.playSound(null, pos, SoundEvents.FLINTANDSTEEL_USE, SoundSource.BLOCKS, 1.0F, 
                            level.random.nextFloat() * 0.4F + 0.8F);
                    
                    if (!event.getEntity().getAbilities().instabuild) {
                        event.getItemStack().hurtAndBreak(1, event.getEntity(), 
                            event.getHand() == net.minecraft.world.InteractionHand.MAIN_HAND ? 
                            net.minecraft.world.entity.EquipmentSlot.MAINHAND : 
                            net.minecraft.world.entity.EquipmentSlot.OFFHAND);
                    }
                }
                event.setCancellationResult(InteractionResult.sidedSuccess(level.isClientSide));
                event.setCanceled(true);
            } else {
                System.out.println("Portal creation failed!");
            }
        }
    }
}