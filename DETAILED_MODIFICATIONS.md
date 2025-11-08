# 📝 Hướng dẫn Chi Tiết Từng File Cần Sửa

## 📌 Mục lục nhanh
- [Files Thay Thế Nguyên Cả Folder](#files-thay-thế-nguyên-cả-folder)
- [Files Thay Thế Nguyên (Copy & Replace)](#files-thay-thế-nguyên-copy--replace)
- [Files Cần Sửa Nội Dung](#files-cần-sửa-nội-dung)
- [Files Cần Patch Binary/DEX](#files-cần-patch-binarydex)
- [Bảng Tóm Tắt Tất Cả Files](#bảng-tóm-tắt-tất-cả-files)

---

## 🗂️ Files Thay Thế Nguyên Cả Folder

### ✅ Thay thế TOÀN BỘ folder - không cần sửa gì

| Folder | Nguồn | Đích | Lý do |
|--------|-------|------|-------|
| `vendor/` | BASEROM | PORTROM | Driver phần cứng cho MUNCH |
| `odm/` | BASEROM | PORTROM | Config OEM cho MUNCH |
| `vendor_dlkm/` | BASEROM | PORTROM | Kernel modules vendor |
| `odm_dlkm/` | BASEROM | PORTROM | Kernel modules ODM |

**Lệnh:**
```bash
# Copy toàn bộ không cần sửa
cp -rf baserom/images/vendor portrom/images/
cp -rf baserom/images/odm portrom/images/
cp -rf baserom/images/vendor_dlkm portrom/images/
cp -rf baserom/images/odm_dlkm portrom/images/
```

---

## 📄 Files Thay Thế Nguyên (Copy & Replace)

### 1️⃣ Overlay APKs

#### 📍 Path: `product/app/*/`

| File | Path đầy đủ | Nguồn | Mục đích |
|------|------------|-------|----------|
| AospFrameworkResOverlay.apk | `product/app/AospFrameworkResOverlay/AospFrameworkResOverlay.apk` | BASEROM | Config notch, corners, navbar |
| DevicesAndroidOverlay.apk | `product/app/DevicesAndroidOverlay/DevicesAndroidOverlay.apk` | BASEROM | Config cảm biến, fingerprint |
| DevicesOverlay.apk | `product/app/DevicesOverlay/DevicesOverlay.apk` | BASEROM | Config thiết bị tổng quát |
| MiuiBiometricResOverlay.apk | `product/app/MiuiBiometricResOverlay/MiuiBiometricResOverlay.apk` | BASEROM | Vị trí fingerprint |
| SettingsRroDeviceHideStatusBarOverlay.apk | `product/app/SettingsRroDeviceHideStatusBarOverlay/SettingsRroDeviceHideStatusBarOverlay.apk` | BASEROM | Config status bar |
| MiuiFrameworkResOverlay.apk | `product/app/MiuiFrameworkResOverlay/MiuiFrameworkResOverlay.apk` | BASEROM | MIUI framework resources |

**Script:**
```bash
#!/bin/bash
# Copy overlay APKs from BASEROM to PORTROM

overlays=(
    "AospFrameworkResOverlay"
    "DevicesAndroidOverlay"
    "DevicesOverlay"
    "MiuiBiometricResOverlay"
    "SettingsRroDeviceHideStatusBarOverlay"
    "MiuiFrameworkResOverlay"
)

for overlay in "${overlays[@]}"; do
    base_apk=$(find baserom/images/product -name "${overlay}.apk" -type f)
    port_apk=$(find portrom/images/product -name "${overlay}.apk" -type f)

    if [[ -f "$base_apk" && -f "$port_apk" ]]; then
        echo "Copying $overlay..."
        cp -f "$base_apk" "$port_apk"
    fi
done
```

---

### 2️⃣ Display Configuration

#### 📍 Path: `product/etc/displayconfig/`

| File | Path đầy đủ | Nguồn | Nội dung |
|------|------------|-------|----------|
| display_id_0.xml | `product/etc/displayconfig/display_id_0.xml` | BASEROM | Brightness curve, refresh rate |
| display_id_*.xml | `product/etc/displayconfig/display_id_[số].xml` | BASEROM | Multiple display profiles |

**Nội dung file (ví dụ):**
```xml
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<displayConfiguration>
    <screenBrightnessMap>
        <point>
            <value>0.0</value>
            <nits>2.0</nits>
        </point>
        <point>
            <value>0.62</value>
            <nits>500.0</nits>
        </point>
        <point>
            <value>1.0</value>
            <nits>800.0</nits>
        </point>
    </screenBrightnessMap>

    <refreshRate>
        <lowerBlockingZoneConfigs>
            <defaultRefreshRate>60</defaultRefreshRate>
            <blockingZoneThreshold>
                <displayBrightnessPoint>
                    <lux>0</lux>
                    <nits>0</nits>
                </displayBrightnessPoint>
            </blockingZoneThreshold>
        </lowerBlockingZoneConfigs>
        <higherBlockingZoneConfigs>
            <defaultRefreshRate>120</defaultRefreshRate>
        </higherBlockingZoneConfigs>
    </refreshRate>
</displayConfiguration>
```

**Script:**
```bash
# Copy tất cả display config
cp -rf baserom/images/product/etc/displayconfig/*.xml \
       portrom/images/product/etc/displayconfig/
```

---

### 3️⃣ Device Features

#### 📍 Path: `product/etc/device_features/`

| File | Path đầy đủ | Nguồn | Nội dung |
|------|------------|-------|----------|
| munch.xml | `product/etc/device_features/munch.xml` | BASEROM | Features của MUNCH |

**Nội dung file munch.xml:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<features>
    <!-- Camera -->
    <bool name="support_camera_60fps_video">true</bool>
    <bool name="support_camera_8k_video">false</bool>
    <bool name="support_camera_asd_night">true</bool>
    <integer name="support_camera_burst_shoot">100</integer>
    <bool name="support_front_bokeh">true</bool>

    <!-- Display -->
    <integer name="screen_refresh_rate">120</integer>
    <bool name="support_aod">true</bool>
    <bool name="support_aod_color">false</bool>
    <integer name="aod_pos_x">540</integer>
    <integer name="aod_pos_y">1870</integer>

    <!-- Biometric -->
    <bool name="support_fingerprint">true</bool>
    <string name="fingerprint_type">side</string>
    <integer name="fingerprint_pos_x">540</integer>
    <integer name="fingerprint_pos_y">1870</integer>
    <bool name="support_face_unlock">true</bool>

    <!-- Hardware -->
    <string name="device_cpu">Snapdragon 870</string>
    <integer name="ram_size">8192</integer>
    <bool name="support_nfc">true</bool>
    <bool name="support_ir_blaster">true</bool>
    <bool name="support_wireless_charging">false</bool>

    <!-- Audio -->
    <bool name="support_audio_hires">true</bool>
    <bool name="support_dolby_atmos">true</bool>

    <!-- Connectivity -->
    <bool name="support_5g">true</bool>
    <bool name="support_wifi6">true</bool>
</features>
```

**Script:**
```bash
# Copy device features
cp -rf baserom/images/product/etc/device_features/* \
       portrom/images/product/etc/device_features/
```

---

### 4️⃣ MiuiBiometric

#### 📍 Path: `product/app/MiuiBiometric/`

| Item | Path | Nguồn |
|------|------|-------|
| Toàn bộ folder | `product/app/MiuiBiometric/` | BASEROM |

**Script:**
```bash
# Remove old và copy new
rm -rf portrom/images/product/app/MiuiBiometric
cp -rf baserom/images/product/app/MiuiBiometric \
       portrom/images/product/app/
```

---

### 5️⃣ NFC Files

#### 📍 Nhiều paths trong vendor/

| File | Path đầy đủ | Nguồn |
|------|------------|-------|
| vendor.nxp.hardware.nfc@2.0-service | `vendor/bin/hw/vendor.nxp.hardware.nfc@2.0-service` | BASEROM |
| nqnfcinfo | `vendor/bin/nqnfcinfo` | BASEROM |
| libnfc-nci.conf | `vendor/etc/libnfc-nci.conf` | BASEROM |
| libnfc-nxp.conf | `vendor/etc/libnfc-nxp.conf` | BASEROM |
| libnfc-nxp_RF.conf | `vendor/etc/libnfc-nxp_RF.conf` | BASEROM |
| vendor.nxp.hardware.nfc@2.0-service.rc | `vendor/etc/init/vendor.nxp.hardware.nfc@2.0-service.rc` | BASEROM |
| nfc_nci.nqx.default.hw.so | `vendor/lib/nfc_nci.nqx.default.hw.so` | BASEROM |
| nfc_nci.nqx.default.hw.so | `vendor/lib64/nfc_nci.nqx.default.hw.so` | BASEROM |
| nfc_i2c.ko | `vendor/lib/modules/nfc_i2c.ko` | BASEROM |
| *.bin | `vendor/firmware/*nfc*.bin` | BASEROM |
| android.hardware.nfc*.xml | `vendor/etc/permissions/android.hardware.nfc*.xml` | BASEROM |

**Script tự động:**
```bash
#!/bin/bash
# Copy NFC files

NFC_FILES=(
    "vendor/bin/hw/vendor.nxp.hardware.nfc@2.0-service"
    "vendor/bin/nqnfcinfo"
    "vendor/etc/libnfc-nci.conf"
    "vendor/etc/libnfc-nxp.conf"
    "vendor/etc/libnfc-nxp_RF.conf"
    "vendor/etc/sn100u_nfcon.pnscr"
    "vendor/etc/init/vendor.nxp.hardware.nfc@2.0-service.rc"
    "vendor/lib/nfc_nci.nqx.default.hw.so"
    "vendor/lib/vendor.nxp.hardware.nfc@2.0.so"
    "vendor/lib64/nfc_nci.nqx.default.hw.so"
    "vendor/lib64/vendor.nxp.hardware.nfc@2.0.so"
    "vendor/lib/modules/nfc_i2c.ko"
    "vendor/lib/modules/5.4-gki/nfc_i2c.ko"
)

for file in "${NFC_FILES[@]}"; do
    if [[ -f "baserom/images/$file" ]]; then
        cp -f "baserom/images/$file" "portrom/images/$file"
    fi
done

# Copy firmware
cp -f baserom/images/vendor/firmware/*nfc*.bin portrom/images/vendor/firmware/ 2>/dev/null

# Copy permissions
cp -f baserom/images/vendor/etc/permissions/android.hardware.nfc*.xml \
      portrom/images/vendor/etc/permissions/ 2>/dev/null
```

---

## ✏️ Files Cần Sửa Nội Dung

### 1️⃣ system/system/build.prop

#### 📍 Path: `system/system/build.prop`

**Các dòng cần sửa:**

```properties
# ========================================
# 1. DEVICE IDENTIFICATION
# ========================================
# BEFORE: ro.product.device=fuxi
# AFTER:
ro.product.device=munch

# BEFORE: ro.product.system.device=fuxi
# AFTER:
ro.product.system.device=munch

# BEFORE: ro.build.product=fuxi
# AFTER:
ro.build.product=munch

# ========================================
# 2. BUILD DATE (Update to current)
# ========================================
# BEFORE: ro.build.date=Tue Nov 12 15:30:45 CST 2024
# AFTER: (current date)
ro.build.date=Thu Dec 05 10:30:00 UTC 2024

# BEFORE: ro.build.date.utc=1731395445
# AFTER: (current timestamp)
ro.build.date.utc=1733395800

# BEFORE: ro.system.build.date=Tue Nov 12 15:30:45 CST 2024
# AFTER:
ro.system.build.date=Thu Dec 05 10:30:00 UTC 2024

# BEFORE: ro.system.build.date.utc=1731395445
# AFTER:
ro.system.build.date.utc=1733395800

# ========================================
# 3. ADDITIONS (Add at end of file)
# ========================================
# Add these lines:
ro.crypto.state=encrypted
debug.game.video.support=true
debug.game.video.speed=true
```

**Script sed:**
```bash
PROP_FILE="portrom/images/system/system/build.prop"

# Device code
sed -i "s/ro.product.device=.*/ro.product.device=munch/g" "$PROP_FILE"
sed -i "s/ro.product.system.device=.*/ro.product.system.device=munch/g" "$PROP_FILE"
sed -i "s/ro.build.product=.*/ro.build.product=munch/g" "$PROP_FILE"

# Build date
BUILD_DATE=$(date -u +"%a %b %d %H:%M:%S UTC %Y")
BUILD_UTC=$(date +%s)
sed -i "s/ro.build.date=.*/ro.build.date=$BUILD_DATE/g" "$PROP_FILE"
sed -i "s/ro.build.date.utc=.*/ro.build.date.utc=$BUILD_UTC/g" "$PROP_FILE"
sed -i "s/ro.system.build.date=.*/ro.system.build.date=$BUILD_DATE/g" "$PROP_FILE"
sed -i "s/ro.system.build.date.utc=.*/ro.system.build.date.utc=$BUILD_UTC/g" "$PROP_FILE"

# Additions
cat >> "$PROP_FILE" << 'EOF'

# Manual port additions
ro.crypto.state=encrypted
debug.game.video.support=true
debug.game.video.speed=true
EOF
```

---

### 2️⃣ product/etc/build.prop

#### 📍 Path: `product/etc/build.prop`

**Các dòng cần sửa:**

```properties
# ========================================
# 1. DEVICE IDENTIFICATION
# ========================================
# BEFORE: ro.product.product.name=fuxi
# AFTER:
ro.product.product.name=munch

# ========================================
# 2. SCREEN DENSITY
# ========================================
# BEFORE: ro.sf.lcd_density=480
# AFTER: (MUNCH = 440)
ro.sf.lcd_density=440

# BEFORE: persist.miui.density_v2=480
# AFTER:
persist.miui.density_v2=440

# ========================================
# 3. MILLET NETLINK (CRITICAL!)
# ========================================
# Tìm dòng này trong BASEROM product/etc/build.prop
# Ví dụ: ro.millet.netlink=29

# BEFORE: ro.millet.netlink=31  (hoặc không có)
# AFTER: (lấy từ BASEROM)
ro.millet.netlink=29

# ========================================
# 4. BUILD DATE
# ========================================
ro.product.build.date=Thu Dec 05 10:30:00 UTC 2024
ro.product.build.date.utc=1733395800

# ========================================
# 5. ADDITIONS
# ========================================
persist.sys.miui_animator_sched.sched_threads=2
ro.miui.cust_erofs=0
```

**Script:**
```bash
PROP_FILE="portrom/images/product/etc/build.prop"
BASE_PROP="baserom/images/product/etc/build.prop"

# Get millet netlink from BASEROM
MILLET_NETLINK=$(grep "ro.millet.netlink" "$BASE_PROP" | cut -d'=' -f2)
[[ -z "$MILLET_NETLINK" ]] && MILLET_NETLINK=29  # Default

# Device code
sed -i "s/ro.product.product.name=.*/ro.product.product.name=munch/g" "$PROP_FILE"

# Density
sed -i "s/ro.sf.lcd_density=.*/ro.sf.lcd_density=440/g" "$PROP_FILE"
sed -i "s/persist.miui.density_v2=.*/persist.miui.density_v2=440/g" "$PROP_FILE"

# Millet
if grep -q "ro.millet.netlink" "$PROP_FILE"; then
    sed -i "s/ro.millet.netlink=.*/ro.millet.netlink=$MILLET_NETLINK/g" "$PROP_FILE"
else
    echo "ro.millet.netlink=$MILLET_NETLINK" >> "$PROP_FILE"
fi

# Build date
BUILD_DATE=$(date -u +"%a %b %d %H:%M:%S UTC %Y")
BUILD_UTC=$(date +%s)
sed -i "s/ro.product.build.date=.*/ro.product.build.date=$BUILD_DATE/g" "$PROP_FILE"
sed -i "s/ro.product.build.date.utc=.*/ro.product.build.date.utc=$BUILD_UTC/g" "$PROP_FILE"

# Additions
cat >> "$PROP_FILE" << 'EOF'

# Performance
persist.sys.miui_animator_sched.sched_threads=2
ro.miui.cust_erofs=0
EOF
```

---

### 3️⃣ vendor/build.prop

#### 📍 Path: `vendor/build.prop`

**⚠️ Giữ nguyên từ BASEROM, chỉ sửa:**

```properties
# ========================================
# BUILD DATE (Update only)
# ========================================
ro.vendor.build.date=Thu Dec 05 10:30:00 UTC 2024
ro.vendor.build.date.utc=1733395800

# ========================================
# ADDITIONS (Add at end)
# ========================================
# K60 Performance props
persist.vendor.mi_sf.optimize_for_refresh_rate.enable=1
ro.vendor.mi_sf.ultimate.perf.support=true
ro.surface_flinger.set_touch_timer_ms=200
ro.surface_flinger.set_idle_timer_ms=1100
debug.sf.set_idle_timer_ms=1100

# Millet (comment out if exists)
# persist.sys.millet.cgroup1=...
```

**Script:**
```bash
PROP_FILE="portrom/images/vendor/build.prop"

# Update build date only
BUILD_DATE=$(date -u +"%a %b %d %H:%M:%S UTC %Y")
BUILD_UTC=$(date +%s)
sed -i "s/ro.vendor.build.date=.*/ro.vendor.build.date=$BUILD_DATE/g" "$PROP_FILE"
sed -i "s/ro.vendor.build.date.utc=.*/ro.vendor.build.date.utc=$BUILD_UTC/g" "$PROP_FILE"

# Comment out millet cgroup
sed -i "s/persist\.sys\.millet\.cgroup1/#persist\.sys\.millet\.cgroup1/" "$PROP_FILE"

# Add performance props
cat >> "$PROP_FILE" << 'EOF'

# K60 Performance optimizations
persist.vendor.mi_sf.optimize_for_refresh_rate.enable=1
ro.vendor.mi_sf.ultimate.perf.support=true
ro.surface_flinger.set_touch_timer_ms=200
ro.surface_flinger.set_idle_timer_ms=1100
debug.sf.set_idle_timer_ms=1100
ro.vendor.media.video.frc.support=true
EOF
```

---

### 4️⃣ vendor/default.prop

#### 📍 Path: `vendor/default.prop`

**Thêm vào cuối file:**

```properties
# ========================================
# GPU & TOUCH OPTIMIZATIONS
# ========================================
ro.surface_flinger.use_content_detection_for_refresh_rate=true
ro.surface_flinger.set_idle_timer_ms=2147483647
ro.surface_flinger.set_touch_timer_ms=2147483647
ro.surface_flinger.set_display_power_timer_ms=2147483647
```

**Script:**
```bash
PROP_FILE="portrom/images/vendor/default.prop"

cat >> "$PROP_FILE" << 'EOF'

# Touch and GPU optimizations
ro.surface_flinger.use_content_detection_for_refresh_rate=true
ro.surface_flinger.set_idle_timer_ms=2147483647
ro.surface_flinger.set_touch_timer_ms=2147483647
ro.surface_flinger.set_display_power_timer_ms=2147483647
EOF
```

---

### 5️⃣ system_ext/etc/build.prop

#### 📍 Path: `system_ext/etc/build.prop`

**Sửa:**

```properties
# DEVICE CODE
ro.product.system_ext.device=munch

# BUILD DATE
ro.system_ext.build.date=Thu Dec 05 10:30:00 UTC 2024
ro.system_ext.build.date.utc=1733395800
```

**Script:**
```bash
PROP_FILE="portrom/images/system_ext/etc/build.prop"

sed -i "s/ro.product.system_ext.device=.*/ro.product.system_ext.device=munch/g" "$PROP_FILE"

BUILD_DATE=$(date -u +"%a %b %d %H:%M:%S UTC %Y")
BUILD_UTC=$(date +%s)
sed -i "s/ro.system_ext.build.date=.*/ro.system_ext.build.date=$BUILD_DATE/g" "$PROP_FILE"
sed -i "s/ro.system_ext.build.date.utc=.*/ro.system_ext.build.date.utc=$BUILD_UTC/g" "$PROP_FILE"
```

---

### 6️⃣ mi_ext/etc/build.prop

#### 📍 Path: `mi_ext/etc/build.prop`

**Sửa device code trong version string:**

```properties
# BEFORE: ro.mi.os.version.incremental=V14.0.24.0.TNGCNXM  (FUXI)
# AFTER:  ro.mi.os.version.incremental=V14.0.24.0.TKMCNXM  (MUNCH)

# Thay TNGCNXM → TKMCNXM (hoặc version code tương ứng)
```

**⚠️ Lưu ý:** Script port.sh tự động replace device code trong tất cả version strings

---

### 7️⃣ fstab files (Disable AVB & Encryption)

#### 📍 Path: `vendor/etc/fstab.*`

**Files cần sửa:**
- `vendor/etc/fstab.qcom`
- `vendor/etc/fstab.default`

**Cần XÓA các flags sau trong TỪNG DÒNG:**

```fstab
# BEFORE:
system    /dev/block/.../system    ext4    ro,barrier=1,avb=vbmeta_system    wait,slotselect,avb_keys=/avb/key.pub
vendor    /dev/block/.../vendor    ext4    ro,barrier=1,avb=vbmeta_vendor    wait,slotselect
userdata  /dev/block/.../userdata  f2fs    noatime,nosuid,nodev,fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0,metadata_encryption=aes-256-xts:wrappedkey_v0    latemount,wait

# AFTER:
system    /dev/block/.../system    ext4    ro,barrier=1    wait,slotselect
vendor    /dev/block/.../vendor    ext4    ro,barrier=1    wait,slotselect
userdata  /dev/block/.../userdata  f2fs    noatime,nosuid,nodev    latemount,wait
```

**Flags cần xóa:**
- `,avb`
- `,avb=vbmeta`
- `,avb=vbmeta_system`
- `,avb=vbmeta_vendor`
- `,avb_keys=/avb/...`
- `,fileencryption=...`
- `,metadata_encryption=...`

**Script:**
```bash
for fstab in portrom/images/vendor/etc/fstab.*; do
    echo "Processing $fstab..."

    # Remove AVB
    sed -i 's/,avb_keys=[^,]*//g' "$fstab"
    sed -i 's/,avb=vbmeta_system//g' "$fstab"
    sed -i 's/,avb=vbmeta_vendor//g' "$fstab"
    sed -i 's/,avb=vbmeta//g' "$fstab"
    sed -i 's/,avb//g' "$fstab"

    # Remove encryption (optional)
    sed -i 's/,fileencryption=[^,]*//g' "$fstab"
    sed -i 's/,metadata_encryption=[^,]*//g' "$fstab"
done
```

---

### 8️⃣ system_ext/etc/vintf/manifest.xml

#### 📍 Path: `system_ext/etc/vintf/manifest.xml`

**Cần THÊM VNDK version:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest version="1.0" type="framework">

    <!-- ... existing HAL declarations ... -->

    <!-- ==================== ADD THIS ==================== -->
    <vendor-ndk>
        <version>34</version>     <!-- Lấy từ vendor/build.prop: ro.vndk.version -->
    </vendor-ndk>
    <!-- ================================================== -->

</manifest>
```

**Cách lấy VNDK version:**
```bash
# Tìm trong BASEROM vendor/build.prop
grep "ro.vndk.version" baserom/images/vendor/build.prop

# Output example: ro.vndk.version=34
```

**Script:**
```bash
VINTF_FILE="portrom/images/system_ext/etc/vintf/manifest.xml"
VENDOR_PROP="baserom/images/vendor/build.prop"

# Get VNDK version
VNDK_VERSION=$(grep "ro.vndk.version" "$VENDOR_PROP" | head -1 | cut -d'=' -f2)

# Check if already exists
if ! grep -q "<version>$VNDK_VERSION</version>" "$VINTF_FILE"; then
    # Add before </manifest>
    sed -i "s|</manifest>|    <vendor-ndk>\n        <version>$VNDK_VERSION</version>\n    </vendor-ndk>\n</manifest>|" "$VINTF_FILE"
    echo "Added VNDK version $VNDK_VERSION"
else
    echo "VNDK version already exists"
fi
```

---

### 9️⃣ system/system/etc/init/hw/init.rc

#### 📍 Path: `system/system/etc/init/hw/init.rc`

**Thêm theme protection:**

```rc
# Tìm dòng:
on boot
    # ... existing commands ...

# Thêm NGAY SAU dòng "on boot":
on boot
    chmod 0731 /data/system/theme    # <- ADD THIS LINE
    # ... existing commands continue ...
```

**Script:**
```bash
INIT_RC="portrom/images/system/system/etc/init/hw/init.rc"

if [[ -f "$INIT_RC" ]]; then
    # Add after "on boot" line
    sed -i '/^on boot/a\    chmod 0731 /data/system/theme' "$INIT_RC"
fi
```

---

## 🔨 Files Cần Patch Binary/DEX

### 1️⃣ framework.jar

#### 📍 Path: `system/system/framework/framework.jar`

**Target Class:** `android/os/Build.smali`

**Method:** `isBuildConsistent()`

**Location trong JAR:**
```
framework.jar
├── classes.dex
├── classes2.dex
├── classes3.dex  <- Build.smali thường ở đây
└── classes4.dex
```

**Chi tiết patch:**

**BEFORE (Original):**
```smali
.method public static isBuildConsistent()Z
    .registers 5

    # Long validation logic here
    invoke-static {}, Landroid/os/Build;->getSerial()Ljava/lang/String;
    move-result-object v0
    # ... many lines ...
    if-eqz v0, :cond_1
    # ... validation continues ...
    const/4 v0, 0x0
    return v0

    :cond_1
    const/4 v0, 0x1
    return v0
.end method
```

**AFTER (Patched - Always return true):**
```smali
.method public static isBuildConsistent()Z
    .registers 1

    const/4 v0, 0x1        # Set v0 = 1 (true)
    return v0              # Return true
.end method
```

**Bước patch:**

```bash
#!/bin/bash
# Step-by-step framework.jar patch

FRAMEWORK_JAR="portrom/images/system/system/framework/framework.jar"
WORK_DIR="tmp/framework"
API_LEVEL=34  # Android 14

# 1. Setup
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cp "$FRAMEWORK_JAR" "$WORK_DIR/"
cd "$WORK_DIR"

# 2. Extract DEX files
7z x -y framework.jar *.dex

# 3. Decompile all DEX files
for dex in *.dex; do
    base_name="${dex%.dex}"
    echo "Decompiling $dex..."
    baksmali d --api $API_LEVEL "$dex" -o "$base_name"
done

# 4. Find and patch Build.smali
BUILD_SMALI=$(find . -path "*/android/os/Build.smali" -type f)

if [[ -f "$BUILD_SMALI" ]]; then
    echo "Found: $BUILD_SMALI"

    # Backup
    cp "$BUILD_SMALI" "${BUILD_SMALI}.bak"

    # Find method location
    METHOD_START=$(grep -n "\.method public static isBuildConsistent()Z" "$BUILD_SMALI" | cut -d: -f1)
    METHOD_END=$(tail -n +$METHOD_START "$BUILD_SMALI" | grep -n "\.end method" | head -1 | cut -d: -f1)
    METHOD_END=$((METHOD_START + METHOD_END - 1))

    echo "Method at lines $METHOD_START to $METHOD_END"

    # Replace method content
    {
        head -n $METHOD_START "$BUILD_SMALI"
        cat << 'SMALI'
    .registers 1

    const/4 v0, 0x1
    return v0
.end method
SMALI
        tail -n +$((METHOD_END + 1)) "$BUILD_SMALI"
    } > "${BUILD_SMALI}.new"

    mv "${BUILD_SMALI}.new" "$BUILD_SMALI"
    echo "✓ Patched!"
fi

# 5. Recompile DEX files
for smali_dir in classes*; do
    if [[ -d "$smali_dir" ]]; then
        echo "Recompiling $smali_dir..."
        smali a --api $API_LEVEL "$smali_dir" -o "${smali_dir}.dex"
    fi
done

# 6. Repack JAR
zip -u framework.jar classes*.dex

# 7. Copy back
cp framework.jar "$FRAMEWORK_JAR"

echo "✓ framework.jar patched successfully!"
```

---

### 2️⃣ services.jar

#### 📍 Path: `system/system/framework/services.jar`

**Target Class:** `com/android/server/pm/PackageManagerServiceUtils.smali`

**Method:** `getMinimumSignatureSchemeVersionForTargetSdk(I)I`

**Location:**
```
services.jar
├── classes.dex
├── classes2.dex  <- PackageManagerServiceUtils thường ở đây
└── classes3.dex
```

**Chi tiết patch:**

**BEFORE:**
```smali
.method public static getMinimumSignatureSchemeVersionForTargetSdk(I)I
    .registers 3
    .param p0, "targetSdk"    # I

    const/16 v0, 0x1e        # v0 = 30 (Android 11)
    if-lt p0, v0, :cond_0    # if targetSdk >= 30

    const/4 v1, 0x2          # return 2 (v2 signature)
    return v1

    :cond_0
    const/4 v1, 0x1          # return 1 (v1 signature)
    return v1
.end method
```

**AFTER:**
```smali
.method public static getMinimumSignatureSchemeVersionForTargetSdk(I)I
    .registers 1
    .param p0, "targetSdk"    # I

    const/4 v0, 0x0          # return 0 (disable check)
    return v0
.end method
```

**Bước patch:**

```bash
#!/bin/bash
# services.jar patch script

SERVICES_JAR="portrom/images/system/system/framework/services.jar"
WORK_DIR="tmp/services"
API_LEVEL=34

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cp "$SERVICES_JAR" "$WORK_DIR/"
cd "$WORK_DIR"

# Extract & Decompile
7z x -y services.jar *.dex

for dex in *.dex; do
    base_name="${dex%.dex}"
    baksmali d --api $API_LEVEL "$dex" -o "$base_name"
done

# Find target file
TARGET_SMALI=$(find . -path "*/com/android/server/pm/PackageManagerServiceUtils.smali" -type f)

if [[ -f "$TARGET_SMALI" ]]; then
    echo "Found: $TARGET_SMALI"

    # Target method
    TARGET_METHOD='getMinimumSignatureSchemeVersionForTargetSdk'

    # Find method and get register number for move-result
    METHOD_LINE=$(grep -n "$TARGET_METHOD" "$TARGET_SMALI" | head -1 | cut -d: -f1)

    # Get register number from move-result instruction
    REGISTER_NUM=$(tail -n +$METHOD_LINE "$TARGET_SMALI" | grep -m 1 "move-result" | grep -oP 'v\K[0-9]+')

    if [[ -n "$REGISTER_NUM" ]]; then
        echo "Found register: v$REGISTER_NUM"

        # Find move-result line number
        MOVE_RESULT_LINE=$(tail -n +$METHOD_LINE "$TARGET_SMALI" | grep -n -m 1 "move-result" | cut -d: -f1)
        MOVE_RESULT_LINE=$((METHOD_LINE + MOVE_RESULT_LINE - 1))

        # Replace invoke + move-result with const/4 v[reg], 0x0
        sed -i "${METHOD_LINE},${MOVE_RESULT_LINE}d" "$TARGET_SMALI"
        sed -i "${METHOD_LINE}i\\    const/4 v${REGISTER_NUM}, 0x0" "$TARGET_SMALI"

        echo "✓ Patched!"
    fi
fi

# Recompile
for smali_dir in classes*; do
    if [[ -d "$smali_dir" ]]; then
        smali a --api $API_LEVEL "$smali_dir" -o "${smali_dir}.dex"
    fi
done

# Repack
zip -u services.jar classes*.dex
cp services.jar "$SERVICES_JAR"

echo "✓ services.jar patched!"
```

---

## 📊 Bảng Tóm Tắt Tất Cả Files

### Bảng đầy đủ với Actions

| # | File/Folder | Path | Action | Nguồn | Tool | Lý do |
|---|-------------|------|--------|-------|------|-------|
| 1 | vendor/ | vendor/ | COPY ENTIRE | BASEROM | cp -rf | Hardware drivers |
| 2 | odm/ | odm/ | COPY ENTIRE | BASEROM | cp -rf | OEM config |
| 3 | vendor_dlkm/ | vendor_dlkm/ | COPY ENTIRE | BASEROM | cp -rf | Kernel modules |
| 4 | odm_dlkm/ | odm_dlkm/ | COPY ENTIRE | BASEROM | cp -rf | Kernel modules |
| 5 | boot.img | boot.img | COPY FILE | BASEROM | cp | Kernel |
| 6 | AospFrameworkResOverlay.apk | product/app/.../AospFrameworkResOverlay.apk | REPLACE | BASEROM | cp | UI config |
| 7 | DevicesAndroidOverlay.apk | product/app/.../DevicesAndroidOverlay.apk | REPLACE | BASEROM | cp | Device config |
| 8 | DevicesOverlay.apk | product/app/.../DevicesOverlay.apk | REPLACE | BASEROM | cp | Device config |
| 9 | MiuiBiometricResOverlay.apk | product/app/.../MiuiBiometricResOverlay.apk | REPLACE | BASEROM | cp | FP position |
| 10 | SettingsRroDeviceHideStatusBarOverlay.apk | product/app/.../SettingsRroDeviceHideStatusBarOverlay.apk | REPLACE | BASEROM | cp | Status bar |
| 11 | MiuiFrameworkResOverlay.apk | product/app/.../MiuiFrameworkResOverlay.apk | REPLACE | BASEROM | cp | Framework |
| 12 | display_id_*.xml | product/etc/displayconfig/display_id_*.xml | COPY ALL | BASEROM | cp | Brightness |
| 13 | device_features/ | product/etc/device_features/ | COPY FOLDER | BASEROM | cp -rf | Features |
| 14 | MiuiBiometric/ | product/app/MiuiBiometric/ | COPY FOLDER | BASEROM | cp -rf | Face unlock |
| 15 | NFC files (20+) | vendor/bin/, vendor/lib/, vendor/etc/ | COPY FILES | BASEROM | cp | NFC support |
| 16 | system/system/build.prop | system/system/build.prop | MODIFY | PORTROM | sed | Device code |
| 17 | product/etc/build.prop | product/etc/build.prop | MODIFY | PORTROM | sed | Density, millet |
| 18 | vendor/build.prop | vendor/build.prop | MODIFY | BASEROM | sed | Date only |
| 19 | vendor/default.prop | vendor/default.prop | MODIFY | BASEROM | echo >> | GPU opt |
| 20 | system_ext/etc/build.prop | system_ext/etc/build.prop | MODIFY | PORTROM | sed | Device code |
| 21 | mi_ext/etc/build.prop | mi_ext/etc/build.prop | MODIFY | PORTROM | sed | Version code |
| 22 | fstab.* | vendor/etc/fstab.* | MODIFY | PORTROM | sed | Remove AVB |
| 23 | manifest.xml | system_ext/etc/vintf/manifest.xml | MODIFY | PORTROM | sed | Add VNDK |
| 24 | init.rc | system/system/etc/init/hw/init.rc | MODIFY | PORTROM | sed | Theme protect |
| 25 | framework.jar | system/system/framework/framework.jar | PATCH | PORTROM | baksmali/smali | Signature |
| 26 | services.jar | system/system/framework/services.jar | PATCH | PORTROM | baksmali/smali | Signature |

**Tổng cộng:** 26 items chính, ~70-80 files riêng lẻ

---

## ✅ Quy trình Hoàn Chỉnh

### Script tổng hợp tất cả

```bash
#!/bin/bash
# Complete ROM porting script

set -e

BASE="baserom/images"
PORT="portrom/images"

echo "=== STEP 1: Copy entire partitions ==="
cp -rf "$BASE/vendor" "$PORT/"
cp -rf "$BASE/odm" "$PORT/"
[[ -d "$BASE/vendor_dlkm" ]] && cp -rf "$BASE/vendor_dlkm" "$PORT/"
[[ -d "$BASE/odm_dlkm" ]] && cp -rf "$BASE/odm_dlkm" "$PORT/"

echo "=== STEP 2: Copy overlay APKs ==="
for overlay in AospFrameworkResOverlay DevicesAndroidOverlay DevicesOverlay \
               MiuiBiometricResOverlay SettingsRroDeviceHideStatusBarOverlay \
               MiuiFrameworkResOverlay; do
    base_apk=$(find "$BASE/product" -name "${overlay}.apk" -type f)
    port_apk=$(find "$PORT/product" -name "${overlay}.apk" -type f)
    [[ -f "$base_apk" && -f "$port_apk" ]] && cp -f "$base_apk" "$port_apk"
done

echo "=== STEP 3: Copy configs ==="
cp -rf "$BASE/product/etc/displayconfig/"* "$PORT/product/etc/displayconfig/"
cp -rf "$BASE/product/etc/device_features/"* "$PORT/product/etc/device_features/"

echo "=== STEP 4: Copy MiuiBiometric ==="
[[ -d "$BASE/product/app/MiuiBiometric" ]] && {
    rm -rf "$PORT/product/app/MiuiBiometric"
    cp -rf "$BASE/product/app/MiuiBiometric" "$PORT/product/app/"
}

echo "=== STEP 5: Copy NFC files ==="
# (see NFC script above)

echo "=== STEP 6: Modify build.prop files ==="
# Get values from BASEROM
MILLET=$(grep "ro.millet.netlink" "$BASE/product/etc/build.prop" | cut -d'=' -f2)
[[ -z "$MILLET" ]] && MILLET=29
BUILD_DATE=$(date -u +"%a %b %d %H:%M:%S UTC %Y")
BUILD_UTC=$(date +%s)

# Modify all build.prop files
for prop in $(find "$PORT" -name "build.prop"); do
    sed -i "s/ro.product.*device=.*/ro.product.device=munch/g" "$prop"
    sed -i "s/ro.sf.lcd_density=.*/ro.sf.lcd_density=440/g" "$prop"
    sed -i "s/ro.build.date=.*/ro.build.date=$BUILD_DATE/g" "$prop"
    sed -i "s/ro.build.date.utc=.*/ro.build.date.utc=$BUILD_UTC/g" "$prop"
done

# Product specific
sed -i "s/ro.millet.netlink=.*/ro.millet.netlink=$MILLET/" "$PORT/product/etc/build.prop"

echo "=== STEP 7: Disable AVB & Encryption ==="
for fstab in "$PORT/vendor/etc/fstab."*; do
    sed -i 's/,avb[^,]*//g; s/,fileencryption=[^,]*//g; s/,metadata_encryption=[^,]*//g' "$fstab"
done

echo "=== STEP 8: Fix VINTF ==="
VNDK=$(grep "ro.vndk.version" "$BASE/vendor/build.prop" | cut -d'=' -f2)
sed -i "s|</manifest>|    <vendor-ndk>\n        <version>$VNDK</version>\n    </vendor-ndk>\n</manifest>|" \
    "$PORT/system_ext/etc/vintf/manifest.xml"

echo "=== STEP 9: Patch framework & services ==="
# (Use scripts above)

echo "✓ All modifications completed!"
```

---

**Với tài liệu này, bạn có:**
- ✅ Path chính xác từng file
- ✅ Nội dung cụ thể cần sửa
- ✅ Script sẵn sàng chạy
- ✅ Hiểu rõ tại sao phải sửa
- ✅ Tools cần dùng cho từng loại file
