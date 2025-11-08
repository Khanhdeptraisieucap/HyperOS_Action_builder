#!/bin/bash

# ============================================================================
# HyperOS ROM Manual Porting Script - Example
# Ví dụ port ROM thủ công (FUXI → MUNCH)
# ============================================================================

set -e  # Exit on error

echo "================================"
echo "HyperOS Manual Port Example"
echo "================================"

# ============================================================================
# BƯỚC 1: CẤU HÌNH
# ============================================================================

BASEROM="miui_MUNCH_V14.0.8.0.TKMCNXM.zip"      # ROM gốc (máy đích)
PORTROM="miui_FUXI_V14.0.24.0.TNGCNXM.zip"      # ROM nguồn (muốn port)

WORK_DIR="$(pwd)/manual_port"
BASE_DIR="$WORK_DIR/baserom"
PORT_DIR="$WORK_DIR/portrom"
OUT_DIR="$WORK_DIR/output"

mkdir -p "$BASE_DIR" "$PORT_DIR" "$OUT_DIR"

# ============================================================================
# BƯỚC 2: GIẢI NÉN PAYLOAD.BIN
# ============================================================================

echo ""
echo "[1/10] Extracting payload.bin from ROMs..."

# Giải nén payload từ ZIP files
unzip -q "$BASEROM" payload.bin -d "$BASE_DIR/"
unzip -q "$PORTROM" payload.bin -d "$PORT_DIR/"

echo "✓ Payload extracted"

# ============================================================================
# BƯỚC 3: DUMP PAYLOAD → IMG FILES
# ============================================================================

echo ""
echo "[2/10] Dumping payload.bin to image files..."

# Cần công cụ: payload-dumper-go
payload-dumper-go -o "$BASE_DIR/images/" "$BASE_DIR/payload.bin"
payload-dumper-go -o "$PORT_DIR/images/" "$PORT_DIR/payload.bin"

echo "✓ Images dumped"

# ============================================================================
# BƯỚC 4: EXTRACT IMG → FOLDERS
# ============================================================================

echo ""
echo "[3/10] Extracting image files to folders..."

cd "$BASE_DIR/images/"

# Extract BASEROM partitions
for part in vendor odm; do
    echo "  - Extracting $part from BASEROM..."
    extract.erofs -x -i "${part}.img"
    rm "${part}.img"  # Xóa img để tiết kiệm dung lượng
done

cd "$PORT_DIR/images/"

# Extract PORTROM partitions
for part in system product system_ext mi_ext; do
    echo "  - Extracting $part from PORTROM..."
    extract.erofs -x -i "${part}.img"
    rm "${part}.img"
done

cd "$WORK_DIR"

echo "✓ All partitions extracted"

# ============================================================================
# BƯỚC 5: COPY HARDWARE-SPECIFIC FILES (BASEROM → PORTROM)
# ============================================================================

echo ""
echo "[4/10] Copying device-specific files..."

# Display configs (fix độ sáng)
echo "  - Display configs..."
cp -rf "$BASE_DIR/images/product/etc/displayconfig/"* \
       "$PORT_DIR/images/product/etc/displayconfig/"

# Device features (định nghĩa phần cứng)
echo "  - Device features..."
cp -rf "$BASE_DIR/images/product/etc/device_features/"* \
       "$PORT_DIR/images/product/etc/device_features/"

# Overlay APKs
echo "  - Overlay APKs..."
overlays=(
    "AospFrameworkResOverlay.apk"
    "DevicesAndroidOverlay.apk"
    "DevicesOverlay.apk"
    "MiuiBiometricResOverlay.apk"
    "SettingsRroDeviceHideStatusBarOverlay.apk"
)

for overlay in "${overlays[@]}"; do
    base_apk=$(find "$BASE_DIR/images/product" -name "$overlay" -type f)
    port_apk=$(find "$PORT_DIR/images/product" -name "$overlay" -type f)

    if [[ -f "$base_apk" && -f "$port_apk" ]]; then
        echo "    • $overlay"
        cp -f "$base_apk" "$port_apk"
    fi
done

# MiuiBiometric (Face unlock)
if [[ -d "$BASE_DIR/images/product/app/MiuiBiometric" ]]; then
    echo "  - MiuiBiometric..."
    rm -rf "$PORT_DIR/images/product/app/MiuiBiometric"
    cp -rf "$BASE_DIR/images/product/app/MiuiBiometric" \
           "$PORT_DIR/images/product/app/"
fi

echo "✓ Device files copied"

# ============================================================================
# BƯỚC 6: SỬA BUILD.PROP
# ============================================================================

echo ""
echo "[5/10] Modifying build.prop files..."

# Lấy device code từ BASEROM
BASE_DEVICE=$(grep "ro.product.vendor.device" \
              "$BASE_DIR/images/vendor/build.prop" | cut -d'=' -f2)

# Lấy screen density
BASE_DENSITY=$(grep "ro.sf.lcd_density" \
               "$BASE_DIR/images/product/etc/build.prop" | cut -d'=' -f2)

# Lấy millet netlink version
MILLET_NETLINK=$(grep "ro.millet.netlink" \
                 "$BASE_DIR/images/product/etc/build.prop" | cut -d'=' -f2)

echo "  - Device: $BASE_DEVICE"
echo "  - Density: $BASE_DENSITY"
echo "  - Millet: $MILLET_NETLINK"

# Ngày build mới
BUILD_DATE=$(date -u +"%a %b %d %H:%M:%S UTC %Y")
BUILD_UTC=$(date +%s)

# Sửa tất cả build.prop
for prop in $(find "$PORT_DIR/images" -name "build.prop"); do
    echo "  - Patching $(basename $(dirname $prop))/build.prop"

    # Device code
    sed -i "s/ro.product.device=.*/ro.product.device=$BASE_DEVICE/g" "$prop"
    sed -i "s/ro.product.vendor.device=.*/ro.product.vendor.device=$BASE_DEVICE/g" "$prop"
    sed -i "s/ro.product.system.device=.*/ro.product.system.device=$BASE_DEVICE/g" "$prop"
    sed -i "s/ro.product.product.name=.*/ro.product.product.name=$BASE_DEVICE/g" "$prop"

    # Screen density
    sed -i "s/ro.sf.lcd_density=.*/ro.sf.lcd_density=$BASE_DENSITY/g" "$prop"
    sed -i "s/persist.miui.density_v2=.*/persist.miui.density_v2=$BASE_DENSITY/g" "$prop"

    # Build date
    sed -i "s/ro.build.date=.*/ro.build.date=$BUILD_DATE/g" "$prop"
    sed -i "s/ro.build.date.utc=.*/ro.build.date.utc=$BUILD_UTC/g" "$prop"
done

# Thêm props đặc biệt vào product/etc/build.prop
cat >> "$PORT_DIR/images/product/etc/build.prop" << EOF

# Manual port additions
ro.millet.netlink=$MILLET_NETLINK
persist.sys.miui_animator_sched.sched_threads=2
EOF

# Thêm props vào system/system/build.prop
cat >> "$PORT_DIR/images/system/system/build.prop" << EOF

# System additions
ro.crypto.state=encrypted
debug.game.video.support=true
debug.game.video.speed=true
EOF

echo "✓ Build.prop modified"

# ============================================================================
# BƯỚC 7: FIX NFC
# ============================================================================

echo ""
echo "[6/10] Fixing NFC..."

# Copy NFC files từ vendor BASEROM
cp -f "$BASE_DIR/images/vendor/bin/hw/vendor.nxp.hardware.nfc@2.0-service" \
      "$PORT_DIR/images/vendor/bin/hw/" 2>/dev/null || true

cp -f "$BASE_DIR/images/vendor/etc/libnfc-"*.conf \
      "$PORT_DIR/images/vendor/etc/" 2>/dev/null || true

cp -f "$BASE_DIR/images/vendor/lib/nfc_nci.nqx.default.hw.so" \
      "$PORT_DIR/images/vendor/lib/" 2>/dev/null || true

echo "✓ NFC fixed"

# ============================================================================
# BƯỚC 8: DISABLE AVB & ENCRYPTION
# ============================================================================

echo ""
echo "[7/10] Disabling AVB and encryption..."

for fstab in $(find "$PORT_DIR/images/vendor/etc" -name "fstab.*"); do
    echo "  - $(basename $fstab)"

    # Remove AVB
    sed -i 's/,avb_keys=.*avbpubkey//g' "$fstab"
    sed -i 's/,avb=vbmeta_system//g' "$fstab"
    sed -i 's/,avb=vbmeta_vendor//g' "$fstab"
    sed -i 's/,avb=vbmeta//g' "$fstab"
    sed -i 's/,avb//g' "$fstab"

    # Remove encryption (optional)
    sed -i 's/,fileencryption=[^,]*//g' "$fstab"
    sed -i 's/,metadata_encryption=[^,]*//g' "$fstab"
done

echo "✓ AVB & encryption disabled"

# ============================================================================
# BƯỚC 9: PATCH SIGNATURE CHECK
# ============================================================================

echo ""
echo "[8/10] Patching signature verification..."

# Patch framework.jar (simplified version)
# Note: Thực tế cần smali/baksmali, ở đây chỉ là placeholder

echo "  ⚠ MANUAL STEP REQUIRED:"
echo "    You need to manually patch:"
echo "    - system/system/framework/framework.jar"
echo "    - system/system/framework/services.jar"
echo "    See PORTING_GUIDE.md for details"

# ============================================================================
# BƯỚC 10: TẠO FILESYSTEM CONFIGS
# ============================================================================

echo ""
echo "[9/10] Generating filesystem configs..."

mkdir -p "$PORT_DIR/config"

for part in system product system_ext mi_ext; do
    echo "  - $part configs..."
    python3 bin/fspatch.py \
        "$PORT_DIR/images/$part" \
        "$PORT_DIR/config/${part}_fs_config"

    python3 bin/contextpatch.py \
        "$PORT_DIR/images/$part" \
        "$PORT_DIR/config/${part}_file_contexts"
done

echo "✓ Configs generated"

# ============================================================================
# BƯỚC 11: ĐÓNG GÓI PARTITIONS
# ============================================================================

echo ""
echo "[10/10] Packing partitions..."

cd "$PORT_DIR/images"

# Pack với EROFS
for part in system product system_ext mi_ext; do
    echo "  - Packing $part.img (EROFS)..."

    mkfs.erofs -zlz4hc,1 \
        --mount-point=/$part \
        --fs-config-file=../config/${part}_fs_config \
        --file-contexts=../config/${part}_file_contexts \
        ${part}.img \
        $part/

    # Xóa folder để tiết kiệm dung lượng
    rm -rf $part/
done

echo "✓ Partitions packed"

# ============================================================================
# BƯỚC 12: TẠO SUPER.IMG
# ============================================================================

echo ""
echo "[11/10] Creating super.img..."

# Lấy size của các partition
SYSTEM_SIZE=$(stat -c%s system.img)
PRODUCT_SIZE=$(stat -c%s product.img)
SYSTEM_EXT_SIZE=$(stat -c%s system_ext.img)
MI_EXT_SIZE=$(stat -c%s mi_ext.img)
VENDOR_SIZE=$(stat -c%s "$BASE_DIR/images/vendor.img")
ODM_SIZE=$(stat -c%s "$BASE_DIR/images/odm.img")

SUPER_SIZE=9126805504  # 8.5GB

echo "  Partition sizes:"
echo "    system:     $SYSTEM_SIZE"
echo "    product:    $PRODUCT_SIZE"
echo "    system_ext: $SYSTEM_EXT_SIZE"
echo "    mi_ext:     $MI_EXT_SIZE"
echo "    vendor:     $VENDOR_SIZE"
echo "    odm:        $ODM_SIZE"

# Tạo super.img cho V-AB device
lpmake \
    --virtual-ab \
    --metadata-size 65536 \
    --super-name super \
    --metadata-slots 3 \
    --device super:$SUPER_SIZE \
    --group qti_dynamic_partitions_a:$SUPER_SIZE \
    --group qti_dynamic_partitions_b:$SUPER_SIZE \
    \
    --partition system_a:readonly:$SYSTEM_SIZE:qti_dynamic_partitions_a \
    --image system_a=system.img \
    --partition system_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition product_a:readonly:$PRODUCT_SIZE:qti_dynamic_partitions_a \
    --image product_a=product.img \
    --partition product_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition system_ext_a:readonly:$SYSTEM_EXT_SIZE:qti_dynamic_partitions_a \
    --image system_ext_a=system_ext.img \
    --partition system_ext_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition mi_ext_a:readonly:$MI_EXT_SIZE:qti_dynamic_partitions_a \
    --image mi_ext_a=mi_ext.img \
    --partition mi_ext_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition vendor_a:readonly:$VENDOR_SIZE:qti_dynamic_partitions_a \
    --image vendor_a="$BASE_DIR/images/vendor.img" \
    --partition vendor_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition odm_a:readonly:$ODM_SIZE:qti_dynamic_partitions_a \
    --image odm_a="$BASE_DIR/images/odm.img" \
    --partition odm_b:readonly:0:qti_dynamic_partitions_b \
    \
    --output "$OUT_DIR/super.img"

echo "✓ Super.img created: $(stat -c%s $OUT_DIR/super.img) bytes"

# ============================================================================
# BƯỚC 13: NÉN VÀ TẠO FLASHABLE ZIP
# ============================================================================

echo ""
echo "[12/10] Creating flashable package..."

cd "$OUT_DIR"

# Nén super.img
echo "  - Compressing super.img..."
zstd --rm super.img -o super.zst

# Tạo cấu trúc
mkdir -p images/
mkdir -p META-INF/com/google/android/

mv super.zst images/

# Copy boot.img từ BASEROM
cp "$BASE_DIR/images/boot.img" images/

# Copy update-binary script (cần chuẩn bị sẵn)
# cp /path/to/update-binary META-INF/com/google/android/
# cp /path/to/zstd META-INF/

# Tạo ZIP
echo "  - Creating ZIP..."
zip -r HyperOS_MUNCH_Manual_Port.zip ./*

echo ""
echo "================================"
echo "✓ PORT COMPLETED!"
echo "================================"
echo ""
echo "Output: $OUT_DIR/HyperOS_MUNCH_Manual_Port.zip"
echo ""
echo "⚠ IMPORTANT:"
echo "1. You still need to manually patch framework.jar and services.jar"
echo "2. Copy update-binary and zstd to META-INF/"
echo "3. Test on your device (backup first!)"
echo ""
