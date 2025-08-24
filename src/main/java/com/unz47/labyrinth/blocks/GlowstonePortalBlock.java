package com.unz47.labyrinth.blocks;

import com.unz47.labyrinth.dimension.ModDimensions;
import com.unz47.labyrinth.portal.PortalLinkManager;
import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.LevelAccessor;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.material.MapColor;
import net.minecraftforge.common.util.ITeleporter;
import net.minecraftforge.server.ServerLifecycleHooks;
import java.util.function.Function;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class GlowstonePortalBlock extends Block {
    
    private static final Map<UUID, Long> lastTeleport = new HashMap<>();
    private static final long TELEPORT_COOLDOWN = 3000; // 3秒のクールダウン
    
    public GlowstonePortalBlock() {
        super(BlockBehaviour.Properties.of()
                .mapColor(MapColor.COLOR_YELLOW)
                .noCollission()
                .randomTicks()
                .strength(-1.0F)
                .sound(net.minecraft.world.level.block.SoundType.GLASS)
                .lightLevel((state) -> 11));
    }
    
    @Override
    public void entityInside(BlockState state, Level level, BlockPos pos, Entity entity) {
        if (!level.isClientSide && !entity.isPassenger() && !entity.isVehicle() && entity.canChangeDimensions()) {
            // クールダウンチェック
            UUID entityId = entity.getUUID();
            long currentTime = System.currentTimeMillis();
            
            if (lastTeleport.containsKey(entityId)) {
                long lastTime = lastTeleport.get(entityId);
                if (currentTime - lastTime < TELEPORT_COOLDOWN) {
                    return; // クールダウン中
                }
            }
            
            lastTeleport.put(entityId, currentTime);
            handlePortalTeleport(entity, pos);
        }
    }
    
    @Override
    public void neighborChanged(BlockState state, Level level, BlockPos pos, Block block, BlockPos fromPos, boolean isMoving) {
        if (!level.isClientSide) {
            // ポータル枠が壊れたかチェック
            if (!isPortalFrameValid(level, pos)) {
                System.out.println("Portal frame broken at: " + pos + ", destroying portal");
                destroyPortal(level, pos);
            }
        }
    }
    
    private void handlePortalTeleport(Entity entity, BlockPos pos) {
        ServerLevel serverLevel = (ServerLevel) entity.level();
        ServerLevel destinationLevel;
        boolean isFromOverworld = serverLevel.dimension() == Level.OVERWORLD;
        
        if (isFromOverworld) {
            destinationLevel = ServerLifecycleHooks.getCurrentServer().getLevel(ModDimensions.ORE_DIMENSION_KEY);
        } else {
            destinationLevel = ServerLifecycleHooks.getCurrentServer().getLevel(Level.OVERWORLD);
        }
        
        if (destinationLevel != null) {
            entity.changeDimension(destinationLevel, new ITeleporter() {
                @Override
                public Entity placeEntity(Entity entity, ServerLevel currentWorld, ServerLevel destWorld, float yaw, Function<Boolean, Entity> repositionEntity) {
                    Entity repositionedEntity = repositionEntity.apply(false);
                    
                    // シンプルなポータルシステム：各ディメンションに1つのポータル
                    BlockPos destinationPos = findOrCreateSinglePortal(destWorld, isFromOverworld, pos);
                    // ポータル周辺の安全な場所にテレポート
                    BlockPos safeSpawnPos = findSafeSpawnLocation(destWorld, destinationPos);
                    repositionedEntity.setPos(safeSpawnPos.getX() + 0.5, safeSpawnPos.getY(), safeSpawnPos.getZ() + 0.5);
                    
                    // プレイヤーにポータル位置を知らせる
                    if (repositionedEntity instanceof ServerPlayer serverPlayer) {
                        serverPlayer.sendSystemMessage(Component.literal("ポータルが " + destinationPos + " に作成されました"));
                    }
                    
                    return repositionedEntity;
                }
            });
        }
    }
    
    private static BlockPos findOrCreateSinglePortal(ServerLevel destWorld, boolean goingToOreDimension, BlockPos sourcePortalPos) {
        System.out.println("Finding or creating single portal in " + destWorld.dimension());
        
        // 目的地ディメンションの既存ポータルを確認
        BlockPos existingPortal = goingToOreDimension ? 
            PortalLinkManager.getOreDimensionPortal() : 
            PortalLinkManager.getOverworldPortal();
            
        if (existingPortal != null) {
            System.out.println("Found existing portal at: " + existingPortal);
            return existingPortal;
        }
        
        // 既存ポータルがない場合は新しく作成（元のポータル位置を参考にする）
        System.out.println("No existing portal found, creating new portal near source position");
        BlockPos referencePos = new BlockPos(sourcePortalPos.getX(), 70, sourcePortalPos.getZ());
        BlockPos newPortalPos = createNewPortal(destWorld, referencePos);
        
        // ポータル位置を登録
        if (goingToOreDimension) {
            PortalLinkManager.setOreDimensionPortal(newPortalPos);
        } else {
            PortalLinkManager.setOverworldPortal(newPortalPos);
        }
        
        System.out.println("New portal created and registered at: " + newPortalPos);
        return newPortalPos;
    }
    
    private static BlockPos findSafeSpawnLocation(ServerLevel level, BlockPos portalPos) {
        // ポータル周辺3マスの範囲で安全な場所を探す
        for (int x = -3; x <= 3; x++) {
            for (int z = -3; z <= 3; z++) {
                for (int y = -1; y <= 2; y++) {
                    BlockPos checkPos = portalPos.offset(x, y, z);
                    
                    // 空気ブロックで、足場があり、頭上も空いている場所を探す
                    if (level.getBlockState(checkPos).isAir() && 
                        level.getBlockState(checkPos.above()).isAir() && 
                        !level.getBlockState(checkPos.below()).isAir() && 
                        level.getBlockState(checkPos.below()).isSolid()) {
                        
                        System.out.println("Safe spawn location found at: " + checkPos);
                        return checkPos;
                    }
                }
            }
        }
        
        // 安全な場所が見つからない場合はポータル位置をそのまま使用
        System.out.println("No safe spawn location found, using portal position: " + portalPos);
        return portalPos;
    }
    
    private static boolean isPortalFrameValid(Level level, BlockPos portalPos) {
        // ポータルブロックの周囲でフレームの完全性をチェック
        // X軸方向のポータルをチェック
        if (checkPortalFrame(level, portalPos, Direction.Axis.X)) {
            return true;
        }
        // Z軸方向のポータルをチェック
        if (checkPortalFrame(level, portalPos, Direction.Axis.Z)) {
            return true;
        }
        return false;
    }
    
    private static boolean checkPortalFrame(Level level, BlockPos portalPos, Direction.Axis axis) {
        // ポータルサイズを再計算してフレームを検証
        PortalSize portalSize = new PortalSize(level, portalPos, axis);
        return portalSize.isValid();
    }
    
    private static void destroyPortal(Level level, BlockPos startPos) {
        // ポータルブロックを検索して全て破壊
        for (int x = -10; x <= 10; x++) {
            for (int y = -10; y <= 10; y++) {
                for (int z = -10; z <= 10; z++) {
                    BlockPos checkPos = startPos.offset(x, y, z);
                    if (level.getBlockState(checkPos).getBlock() instanceof GlowstonePortalBlock) {
                        level.setBlock(checkPos, Blocks.AIR.defaultBlockState(), 3);
                    }
                }
            }
        }
        
        // ポータルマネージャーからも削除
        if (level instanceof ServerLevel serverLevel) {
            PortalLinkManager.removePortal(serverLevel);
        }
        
        System.out.println("Portal destroyed at: " + startPos);
    }
    
    public static boolean trySpawnPortal(Level level, BlockPos pos, Player player) {
        System.out.println("Attempting to create portal at: " + pos);
        System.out.println("Block clicked: " + level.getBlockState(pos).getBlock());
        
        // クライアント側では処理しない
        if (level.isClientSide) {
            return false;
        }
        
        // そのディメンションに既にポータルが存在するかチェック
        if (level instanceof ServerLevel serverLevel && PortalLinkManager.hasPortal(serverLevel)) {
            System.out.println("Portal already exists in this dimension!");
            
            // プレイヤーにメッセージを送信
            if (player instanceof ServerPlayer serverPlayer) {
                serverPlayer.sendSystemMessage(Component.literal("ポータルはこの世界に１つで十分だ"));
            }
            return false;
        }
        
        // 複数の位置でポータル作成を試行
        BlockPos[] tryPositions = {
            pos,                    // クリックした位置
            pos.above(),           // クリックした位置の上
            pos.offset(1, 0, 0),   // 周囲の位置
            pos.offset(-1, 0, 0),
            pos.offset(0, 0, 1),
            pos.offset(0, 0, -1),
            pos.offset(0, 1, 0),
            pos.offset(0, -1, 0)
        };
        
        for (BlockPos tryPos : tryPositions) {
            // ネザーゲート風：縦と横両方向でポータルサイズを試行
            PortalSize portalX = new PortalSize(level, tryPos, Direction.Axis.X);
            if (portalX.isValid() && portalX.portalBlockCount == 0) {
                portalX.createPortalBlocks();
                registerNewPortal(level, portalX.getPortalCenter());
                return true;
            }
            
            PortalSize portalZ = new PortalSize(level, tryPos, Direction.Axis.Z);
            if (portalZ.isValid() && portalZ.portalBlockCount == 0) {
                portalZ.createPortalBlocks();
                registerNewPortal(level, portalZ.getPortalCenter());
                return true;
            }
        }
        
        return false;
    }
    
    private static void registerNewPortal(Level level, BlockPos portalCenter) {
        if (level instanceof ServerLevel serverLevel && !level.isClientSide) {
            boolean isOverworld = level.dimension() == Level.OVERWORLD;
            if (isOverworld) {
                PortalLinkManager.setOverworldPortal(portalCenter);
            } else {
                PortalLinkManager.setOreDimensionPortal(portalCenter);
            }
            System.out.println("Portal registered at: " + portalCenter + " in " + level.dimension());
        }
    }
    
    
    private static BlockPos createNewPortal(ServerLevel level, BlockPos originalPos) {
        // 安全な場所を見つける
        BlockPos safePos = findSafeSpot(level, originalPos);
        
        // 4x5ポータルを作成
        createPortalStructure(level, safePos);
        
        return safePos.offset(1, 1, 0); // ポータル内部の位置を返す
    }
    
    private static BlockPos findSafeSpot(ServerLevel level, BlockPos preferredPos) {
        // 地面の高さを見つける
        BlockPos.MutableBlockPos mutablePos = preferredPos.mutable();
        
        // 地表を探す
        for (int y = level.getMaxBuildHeight() - 1; y >= level.getMinBuildHeight(); y--) {
            mutablePos.setY(y);
            if (!level.getBlockState(mutablePos).isAir() && level.getBlockState(mutablePos.above()).isAir()) {
                return mutablePos.above().immutable();
            }
        }
        
        // 地表が見つからない場合はY=70に設定
        return new BlockPos(preferredPos.getX(), 70, preferredPos.getZ());
    }
    
    private static void createPortalStructure(ServerLevel level, BlockPos basePos) {
        System.out.println("Creating portal structure at: " + basePos);
        
        // 4x5ポータル構造を作成
        // 底辺
        for (int x = 0; x < 4; x++) {
            level.setBlock(basePos.offset(x, 0, 0), Blocks.GLOWSTONE.defaultBlockState(), 3);
            level.setBlock(basePos.offset(x, 4, 0), Blocks.GLOWSTONE.defaultBlockState(), 3);
        }
        
        // 側面
        for (int y = 1; y < 4; y++) {
            level.setBlock(basePos.offset(0, y, 0), Blocks.GLOWSTONE.defaultBlockState(), 3);
            level.setBlock(basePos.offset(3, y, 0), Blocks.GLOWSTONE.defaultBlockState(), 3);
        }
        
        // 内部をポータルブロックで埋める
        BlockState portalState = com.unz47.labyrinth.regi.ModBlocks.GLOWSTONE_PORTAL.get().defaultBlockState();
        for (int x = 1; x < 3; x++) {
            for (int y = 1; y < 4; y++) {
                level.setBlock(basePos.offset(x, y, 0), portalState, 3);
            }
        }
        
        System.out.println("Portal structure created successfully");
    }
    
    public static class PortalSize {
        private final Level level;
        private final Direction.Axis axis;
        private final Direction rightDir;
        private final Direction leftDir;
        private int portalBlockCount;
        private BlockPos bottomLeft;
        private int height;
        private int width;
        
        public PortalSize(Level level, BlockPos pos, Direction.Axis axis) {
            this.level = level;
            this.axis = axis;
            this.rightDir = axis == Direction.Axis.X ? Direction.WEST : Direction.SOUTH;
            this.leftDir = this.rightDir.getOpposite();
            
            // 底面を探す
            for (BlockPos bottomPos = pos; pos.getY() > bottomPos.getY() - 21 && pos.getY() > level.getMinBuildHeight() && this.isEmpty(level.getBlockState(pos.below())); pos = pos.below()) {
            }
            
            int leftEdge = this.getDistanceUntilEdge(pos, this.leftDir) - 1;
            if (leftEdge >= 0) {
                this.bottomLeft = pos.relative(this.leftDir, leftEdge);
                this.width = this.getDistanceUntilEdge(this.bottomLeft, this.rightDir);
                if (this.width < 2 || this.width > 21) {
                    this.bottomLeft = null;
                    this.width = 0;
                } else {
                    this.height = this.calculatePortalHeight();
                }
            } else {
                this.width = 0;
            }
        }
        
        protected int getDistanceUntilEdge(BlockPos pos, Direction direction) {
            int distance;
            for (distance = 0; distance < 22; ++distance) {
                BlockPos edgePos = pos.relative(direction, distance);
                if (!this.isEmpty(this.level.getBlockState(edgePos)) || !this.level.getBlockState(edgePos.below()).is(Blocks.GLOWSTONE)) {
                    break;
                }
            }
            
            BlockPos framePos = pos.relative(direction, distance);
            return this.level.getBlockState(framePos).is(Blocks.GLOWSTONE) ? distance : 0;
        }
        
        public int calculatePortalHeight() {
            label24:
            for (this.height = 0; this.height < 21; ++this.height) {
                for (int i = 0; i < this.width; ++i) {
                    BlockPos portalPos = this.bottomLeft.relative(this.rightDir, i).above(this.height);
                    BlockState state = this.level.getBlockState(portalPos);
                    if (!this.isEmpty(state)) {
                        break label24;
                    }
                    
                    if (state.getBlock() instanceof GlowstonePortalBlock) {
                        ++this.portalBlockCount;
                    }
                    
                    if (i == 0) {
                        if (!this.level.getBlockState(portalPos.relative(this.leftDir)).is(Blocks.GLOWSTONE)) {
                            break label24;
                        }
                    } else if (i == this.width - 1) {
                        if (!this.level.getBlockState(portalPos.relative(this.rightDir)).is(Blocks.GLOWSTONE)) {
                            break label24;
                        }
                    }
                }
            }
            
            // 上辺フレームチェック
            for (int j = 0; j < this.width; ++j) {
                if (!this.level.getBlockState(this.bottomLeft.relative(this.rightDir, j).above(this.height)).is(Blocks.GLOWSTONE)) {
                    this.height = 0;
                    break;
                }
            }
            
            if (this.height <= 21 && this.height >= 3) {
                return this.height;
            } else {
                this.bottomLeft = null;
                this.width = 0;
                this.height = 0;
                return 0;
            }
        }
        
        protected boolean isEmpty(BlockState state) {
            return state.isAir() || state.getBlock() instanceof GlowstonePortalBlock;
        }
        
        public boolean isValid() {
            return this.bottomLeft != null && this.width >= 2 && this.width <= 21 && this.height >= 3 && this.height <= 21;
        }
        
        public void createPortalBlocks() {
            BlockState portalState = com.unz47.labyrinth.regi.ModBlocks.GLOWSTONE_PORTAL.get().defaultBlockState();
            BlockPos.betweenClosed(this.bottomLeft, this.bottomLeft.relative(Direction.UP, this.height - 1).relative(this.rightDir, this.width - 1)).forEach((pos) -> {
                this.level.setBlock(pos, portalState, 18);
            });
            System.out.println("Portal created! Size: " + this.width + "x" + this.height);
        }
        
        public BlockPos getPortalCenter() {
            if (this.bottomLeft == null) {
                return null;
            }
            // ポータルの中心位置を計算
            int centerX = this.width / 2;
            int centerY = this.height / 2;
            return this.bottomLeft.relative(this.rightDir, centerX).above(centerY);
        }
    }
}