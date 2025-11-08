# 📁 Danh sách Files quan trọng khi Port ROM

## 🎯 TÓM TẮT NHANH

### Files GIỮ NGUYÊN từ BASEROM (MUNCH):
```
✓ vendor/          (toàn bộ partition)
✓ odm/             (toàn bộ partition)
✓ boot.img         (kernel + ramdisk)
✓ vbmeta.img       (nếu cần)
```

### Files THAY THẾ từ PORTROM (FUXI/NUWA/ISHTAR):
```
✓ system/          (toàn bộ partition)
✓ system_ext/      (toàn bộ partition)
✓ product/         (toàn bộ partition - với exceptions)
✓ mi_ext/          (toàn bộ partition)
```

### Files MERGE (BASEROM → PORTROM):
```
⚠ Overlay APKs
⚠ Display configs
⚠ Device features
⚠ Biometric files
⚠ NFC configs
⚠ Camera (optional)
```

---

## 📂 CHI TIẾT CÁC FILES CẦN XỬ LÝ

### 1️⃣ OVERLAY APKs (product partition)

**Vị trí:** `product/app/` hoặc `product/overlay/`

#### ✅ Files cần COPY từ BASEROM → PORTROM:

```bash
# Framework Overlays
product/app/AospFrameworkResOverlay/AospFrameworkResOverlay.apk
product/app/MiuiFrameworkResOverlay/MiuiFrameworkResOverlay.apk

# Device Overlays
product/app/DevicesAndroidOverlay/DevicesAndroidOverlay.apk
product/app/DevicesOverlay/DevicesOverlay.apk

# Settings Overlays
product/app/SettingsRroDeviceHideStatusBarOverlay/SettingsRroDeviceHideStatusBarOverlay.apk

# Biometric Overlays
product/app/MiuiBiometricResOverlay/MiuiBiometricResOverlay.apk
```

**Mục đích:**
- Cấu hình màn hình (cutout, corners)
- Cấu hình nút vật lý
- Cấu hình cảm biến
- Cấu hình fingerprint position

---

### 2️⃣ DISPLAY CONFIGURATION

**Vị trí:** `product/etc/displayconfig/`

#### ✅ Files cần xử lý:

```bash
# Copy TẤT CẢ từ BASEROM
product/etc/displayconfig/display_id_0.xml
product/etc/displayconfig/display_id_4630946736638489730.xml
product/etc/displayconfig/display_id_[other_numbers].xml
```

**Nội dung quan trọng:**
```xml
<!-- Brightness curve -->
<displayBrightnessMapping>
    <displayBrightnessPoint>
        <nits>2.0</nits>
        <backlight>0.0</backlight>
    </displayBrightnessPoint>
    ...
</displayBrightnessMapping>

<!-- Refresh rate -->
<refreshRate>
    <zone id="default">
        <refreshRateRange>
            <minimum>60</minimum>
            <maximum>120</maximum>
        </refreshRateRange>
    </zone>
</refreshRate>
```

**Fix lỗi:** Độ sáng màn hình, tần số quét

---

### 3️⃣ DEVICE FEATURES

**Vị trí:** `product/etc/device_features/`

#### ✅ Files cần COPY từ BASEROM:

```bash
product/etc/device_features/munch.xml          # Tên file = device code
product/etc/device_features/munch_global.xml   # Nếu có
```

**Nội dung:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<features>
    <!-- Camera -->
    <bool name="support_camera_60fps_video">true</bool>
    <integer name="support_camera_burst_shoot">100</integer>

    <!-- Fingerprint -->
    <bool name="support_fingerprint">true</bool>
    <integer name="fingerprint_pos_x">540</integer>
    <integer name="fingerprint_pos_y">1870</integer>

    <!-- Face unlock -->
    <bool name="support_face_unlock">true</bool>

    <!-- NFC -->
    <bool name="support_nfc">true</bool>

    <!-- Display -->
    <integer name="screen_refresh_rate">120</integer>
    <bool name="support_aod">true</bool>

    <!-- Hardware -->
    <string name="device_cpu">Snapdragon 870</string>
    <integer name="ram_size">8192</integer>
</features>
```

**Fix lỗi:** Tính năng bị ẩn, camera setting không đúng

---

### 4️⃣ BUILD.PROP FILES

#### 📍 Các file build.prop cần sửa:

```
system/system/build.prop
system_ext/etc/build.prop
product/etc/build.prop
vendor/build.prop           (từ BASEROM - update date only)
odm/etc/build.prop          (từ BASEROM - update date only)
mi_ext/etc/build.prop
```

#### 🔧 Properties quan trọng cần sửa:

##### **A. Device Identification:**
```properties
# ===== SỬA TRONG TẤT CẢ BUILD.PROP =====
ro.product.device=munch
ro.product.vendor.device=munch
ro.product.system.device=munch
ro.product.odm.device=munch
ro.product.product.name=munch
ro.product.system_ext.device=munch
ro.product.board=munch
ro.product.mod_device=munch
ro.build.product=munch
```

##### **B. Display Properties:**
```properties
# ===== product/etc/build.prop =====
ro.sf.lcd_density=440                    # MUNCH density
persist.miui.density_v2=440
```

##### **C. Build Date:**
```properties
# ===== TẤT CẢ BUILD.PROP =====
ro.build.date=Thu Dec 05 10:30:00 UTC 2024
ro.build.date.utc=1733395800
ro.vendor.build.date=Thu Dec 05 10:30:00 UTC 2024
ro.vendor.build.date.utc=1733395800
# ... tương tự cho odm, system, product
```

##### **D. Millet (MIUI Battery Optimization):**
```properties
# ===== product/etc/build.prop =====
ro.millet.netlink=29                     # Lấy từ BASEROM!
```

**⚠️ QUAN TRỌNG:** Nếu sai `ro.millet.netlink` → Battery drain!

##### **E. Performance Props:**
```properties
# ===== vendor/build.prop =====
persist.vendor.mi_sf.optimize_for_refresh_rate.enable=1
ro.vendor.mi_sf.ultimate.perf.support=true
ro.surface_flinger.set_touch_timer_ms=200
ro.surface_flinger.set_idle_timer_ms=1100
debug.sf.set_idle_timer_ms=1100

# ===== vendor/default.prop =====
ro.surface_flinger.use_content_detection_for_refresh_rate=true
ro.surface_flinger.set_display_power_timer_ms=2147483647
```

##### **F. System Props:**
```properties
# ===== system/system/build.prop =====
ro.crypto.state=encrypted
debug.game.video.support=true
debug.game.video.speed=true

# ===== product/etc/build.prop =====
persist.sys.miui_animator_sched.sched_threads=2
ro.miui.cust_erofs=0
```

---

### 5️⃣ BIOMETRIC FILES

#### ✅ MiuiBiometric APP:

```bash
# Copy TOÀN BỘ folder từ BASEROM
product/app/MiuiBiometric/
├── MiuiBiometric.apk
├── oat/
│   └── arm64/
│       └── MiuiBiometric.odex
```

**Fix lỗi:** Face unlock không hoạt động

---

### 6️⃣ NFC FILES

**Từ BASEROM hoặc devices/nfc/:**

```bash
# Binaries
vendor/bin/hw/vendor.nxp.hardware.nfc@2.0-service
vendor/bin/nqnfcinfo

# Configs
vendor/etc/libnfc-nci.conf
vendor/etc/libnfc-nxp.conf
vendor/etc/libnfc-nxp_RF.conf
vendor/etc/sn100u_nfcon.pnscr

# Init scripts
vendor/etc/init/vendor.nxp.hardware.nfc@2.0-service.rc

# Libraries
vendor/lib/nfc_nci.nqx.default.hw.so
vendor/lib/vendor.nxp.hardware.nfc@2.0.so
vendor/lib64/nfc_nci.nqx.default.hw.so
vendor/lib64/vendor.nxp.hardware.nfc@2.0.so

# Kernel modules
vendor/lib/modules/nfc_i2c.ko
vendor/lib/modules/5.4-gki/nfc_i2c.ko

# Firmware
vendor/firmware/96_nfcCard_RTP.bin
vendor/firmware/98_nfcCardSlow_RTP.bin

# Permissions
vendor/etc/permissions/android.hardware.nfc.xml
vendor/etc/permissions/android.hardware.nfc.hce.xml
vendor/etc/permissions/android.hardware.nfc.hcef.xml
```

---

### 7️⃣ FSTAB FILES (Disable AVB & Encryption)

**Vị trí:** `vendor/etc/fstab.*`

```bash
vendor/etc/fstab.qcom          # Snapdragon
vendor/etc/fstab.default
```

#### ✂️ Cần XÓA các flags sau:

```diff
# BEFORE:
system  /dev/block/.../system  ext4  ro,barrier=1,avb=vbmeta_system  wait,slotselect
userdata  /dev/block/.../userdata  f2fs  noatime,nosuid,nodev,fileencryption=aes-256-xts,metadata_encryption=aes-256-xts  latemount,wait

# AFTER:
system  /dev/block/.../system  ext4  ro,barrier=1  wait,slotselect
userdata  /dev/block/.../userdata  f2fs  noatime,nosuid,nodev  latemount,wait
```

**Xóa:**
- `,avb`
- `,avb=vbmeta`
- `,avb=vbmeta_system`
- `,avb=vbmeta_vendor`
- `,avb_keys=/avb/...`
- `,fileencryption=...`
- `,metadata_encryption=...`

---

### 8️⃣ VINTF MANIFEST

**Vị trí:** `system_ext/etc/vintf/manifest.xml`

#### ➕ Cần THÊM:

```xml
<manifest version="1.0" type="framework">
    <!-- ... existing content ... -->

    <vendor-ndk>
        <version>34</version>     <!-- Lấy từ vendor/build.prop: ro.vndk.version -->
    </vendor-ndk>

</manifest>
```

**Fix lỗi:** Bootloop do VNDK mismatch

---

### 9️⃣ FRAMEWORK FILES (Cần patch)

#### 🔨 Files cần patch smali:

##### **A. framework.jar**
**Vị trí:** `system/system/framework/framework.jar`

**Target class:** `android/os/Build.smali`

**Method cần patch:** `isBuildConsistent()`

```smali
# BEFORE:
.method public static isBuildConsistent()Z
    .registers 5
    # ... complex logic ...
    return v0
.end method

# AFTER:
.method public static isBuildConsistent()Z
    .registers 1
    const/4 v0, 0x1        # Always return true
    return v0
.end method
```

##### **B. services.jar**
**Vị trí:** `system/system/framework/services.jar`

**Target class:** `com/android/server/pm/PackageManagerServiceUtils.smali`

**Method:** `getMinimumSignatureSchemeVersionForTargetSdk()`

```smali
# Tìm dòng invoke method này và thay return value = 0
const/4 v0, 0x0
```

##### **C. miui-services.jar** (Nếu dùng xiaomi.eu)
**Vị trí:** `system/system/framework/miui-services.jar`

**Patch:** SystemServerImpl constructor

---

### 🔟 CAMERA FILES (Optional)

#### Option 1: Dùng Camera PORTROM (Leica):
```bash
# Giữ nguyên từ PORTROM
product/priv-app/MiuiCamera/
```

#### Option 2: Dùng Camera BASEROM (Stock):
```bash
# Copy từ BASEROM
cp -rf baserom/product/priv-app/MiuiCamera/ \
       portrom/product/priv-app/
```

#### Option 3: Dùng Camera custom:
```bash
# Thay bằng devices/MiuiCamera.apk
rm -rf product/priv-app/MiuiCamera
mkdir product/priv-app/MiuiCamera
cp devices/MiuiCamera.apk product/priv-app/MiuiCamera/
```

---

## 📊 CHECKLIST KHI PORT

### ✅ Pre-Port Checklist:

- [ ] Có BASEROM cho MUNCH (chính xác version)
- [ ] Có PORTROM muốn port
- [ ] Đã cài đủ tools (payload-dumper-go, lpunpack, lpmake, erofs-utils)
- [ ] Đã backup device (nếu flash thật)

### ✅ During-Port Checklist:

**Partitions:**
- [ ] Vendor từ BASEROM
- [ ] ODM từ BASEROM
- [ ] System từ PORTROM
- [ ] Product từ PORTROM (đã merge files)
- [ ] System_ext từ PORTROM
- [ ] Mi_ext từ PORTROM

**Overlays & Configs:**
- [ ] Display configs copied
- [ ] Device features copied
- [ ] All overlay APKs replaced
- [ ] MiuiBiometric copied

**Build Props:**
- [ ] Device code = munch (tất cả props)
- [ ] Screen density = 440
- [ ] Millet netlink đúng
- [ ] Build date updated

**Security:**
- [ ] AVB disabled trong fstab
- [ ] framework.jar patched
- [ ] services.jar patched

**Hardware:**
- [ ] NFC files copied
- [ ] Boot.img từ BASEROM

**VINTF:**
- [ ] VNDK version added to manifest.xml

### ✅ Post-Port Checklist:

- [ ] Super.img size hợp lý (< 8.5GB)
- [ ] Tất cả partitions có trong super
- [ ] ZIP structure đúng
- [ ] Update-binary script có
- [ ] Zstd binary có

---

## 🔍 DEBUG BOOTLOOP

### Logs cần check:

```bash
# Via ADB (nếu bootloop nhẹ)
adb logcat | grep -i "crash\|error\|fatal"

# Các lỗi thường gặp:
```

### 1. **VINTF mismatch:**
```
ERROR: VINTF: Cannot find VNDK version 34
```
**Fix:** Thêm `<version>34</version>` vào `system_ext/etc/vintf/manifest.xml`

### 2. **Millet crash:**
```
FATAL: MiuiBoosterService crashed - netlink version mismatch
```
**Fix:** Sửa `ro.millet.netlink` trong product/etc/build.prop

### 3. **Display HAL crash:**
```
ERROR: Display HAL failed to initialize
```
**Fix:** Copy display_id_*.xml từ BASEROM

### 4. **Fingerprint HAL:**
```
ERROR: Fingerprint service died
```
**Fix:** Copy MiuiBiometricResOverlay.apk từ BASEROM

---

## 📞 XỬ LÝ LỖI THƯỜNG GẶP

| Lỗi | Nguyên nhân | Cách fix |
|-----|-------------|----------|
| **Bootloop** | VNDK mismatch | Add VNDK version to manifest.xml |
| **No WiFi** | Vendor partition sai | Dùng vendor từ BASEROM |
| **No SIM** | Vendor/ODM sai | Dùng vendor/odm từ BASEROM |
| **Screen dim** | Display config sai | Copy display_id_*.xml từ BASEROM |
| **FP not work** | Biometric overlay sai | Copy overlays + MiuiBiometric từ BASEROM |
| **Camera crash** | Camera incompatible | Dùng camera từ BASEROM |
| **NFC not work** | NFC files missing | Copy NFC files từ BASEROM |
| **Battery drain** | Millet netlink sai | Fix ro.millet.netlink |
| **Signature error** | Framework not patched | Patch framework.jar & services.jar |

---

## 🎓 KẾT LUẬN

### Files TUYỆT ĐỐI KHÔNG ĐỘNG TỪ BASEROM:
1. **vendor/** - Toàn bộ partition
2. **odm/** - Toàn bộ partition
3. **boot.img** - Kernel

### Files CẦN MERGE (BASEROM → PORTROM):
1. Overlay APKs (6-10 files)
2. Display configs (2-5 files)
3. Device features (1-2 files)
4. MiuiBiometric (1 folder)
5. NFC files (15-20 files)

### Files CẦN PATCH:
1. Tất cả build.prop (8-10 files)
2. Tất cả fstab (2-3 files)
3. framework.jar (1 file)
4. services.jar (1 file)
5. vintf/manifest.xml (1 file)

### Tổng số files cần can thiệp: **~50-80 files**

**Thời gian ước tính:** 2-4 giờ (thủ công) vs 15-30 phút (script tự động)

---

**🔗 Tham khảo thêm:**
- [PORTING_GUIDE.md](PORTING_GUIDE.md) - Hướng dẫn chi tiết từng bước
- [manual_port_example.sh](manual_port_example.sh) - Script example
- [port.sh](port.sh) - Script tự động hoàn chỉnh
