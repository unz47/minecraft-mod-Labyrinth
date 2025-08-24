package com.unz47.labyrinth.portal;

import com.unz47.labyrinth.dimension.ModDimensions;
import net.minecraft.core.BlockPos;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.level.Level;

public class PortalLinkManager {
    // 各ディメンションに1つのポータルのみ
    private static BlockPos overworldPortal = null;
    private static BlockPos oreDimensionPortal = null;
    
    static {
        System.out.println("PortalLinkManager initialized");
    }
    
    /**
     * オーバーワールドのポータル位置を設定
     */
    public static void setOverworldPortal(BlockPos pos) {
        overworldPortal = pos;
        System.out.println("Overworld portal set at: " + pos);
    }
    
    /**
     * 新ディメンションのポータル位置を設定
     */
    public static void setOreDimensionPortal(BlockPos pos) {
        oreDimensionPortal = pos;
        System.out.println("Ore dimension portal set at: " + pos);
    }
    
    /**
     * オーバーワールドのポータル位置を取得
     */
    public static BlockPos getOverworldPortal() {
        return overworldPortal;
    }
    
    /**
     * 新ディメンションのポータル位置を取得
     */
    public static BlockPos getOreDimensionPortal() {
        return oreDimensionPortal;
    }
    
    /**
     * 指定されたディメンションにポータルが既に存在するかチェック
     */
    public static boolean hasPortal(ServerLevel level) {
        if (level == null) {
            System.out.println("Warning: hasPortal called with null level");
            return false;
        }
        
        boolean isOverworld = level.dimension() == Level.OVERWORLD;
        boolean isOreDimension = level.dimension() == ModDimensions.ORE_DIMENSION_KEY;
        
        System.out.println("=== Portal Check ===");
        System.out.println("Checking dimension: " + level.dimension().location());
        System.out.println("Is overworld: " + isOverworld);
        System.out.println("Is ore dimension: " + isOreDimension);
        System.out.println("Current overworld portal: " + overworldPortal);
        System.out.println("Current ore dimension portal: " + oreDimensionPortal);
        
        boolean result;
        if (isOverworld) {
            result = (overworldPortal != null);
        } else if (isOreDimension) {
            result = (oreDimensionPortal != null);
        } else {
            // 未知のディメンションでは常にfalse
            System.out.println("Unknown dimension, returning false");
            result = false;
        }
        
        System.out.println("hasPortal result: " + result);
        System.out.println("===================");
        return result;
    }
    
    /**
     * ポータルを削除
     */
    public static void removePortal(ServerLevel level) {
        boolean isOverworld = level.dimension() == Level.OVERWORLD;
        boolean isOreDimension = level.dimension() == ModDimensions.ORE_DIMENSION_KEY;
        
        if (isOverworld) {
            System.out.println("Removing overworld portal at: " + overworldPortal);
            overworldPortal = null;
        } else if (isOreDimension) {
            System.out.println("Removing ore dimension portal at: " + oreDimensionPortal);
            oreDimensionPortal = null;
        }
    }
    
    /**
     * すべてのポータルをクリア
     */
    public static void clearAllPortals() {
        overworldPortal = null;
        oreDimensionPortal = null;
        System.out.println("All portals cleared");
    }
}