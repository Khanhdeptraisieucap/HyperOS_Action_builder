# ✅ Checklist Files Cần Thay Thế Khi Port ROM

## 📋 Checklist Nhanh - Sử Dụng Khi Port

### ✅ BƯỚC 1: COPY TOÀN BỘ PARTITION (Không động gì)

- [ ] **vendor/** (toàn bộ folder từ BASEROM)
- [ ] **odm/** (toàn bộ folder từ BASEROM)
- [ ] **vendor_dlkm/** (nếu có - từ BASEROM)
- [ ] **odm_dlkm/** (nếu có - từ BASEROM)
- [ ] **boot.img** (file từ BASEROM)

**Lệnh:**
```bash
cp -rf baserom/images/vendor portrom/images/
cp -rf baserom/images/odm portrom/images/
cp -rf baserom/images/vendor_dlkm portrom/images/ 2>/dev/null || true
cp -rf baserom/images/odm_dlkm portrom/images/ 2>/dev/null || true
```

---

### ✅ BƯỚC 2: COPY FILES OVERLAY (BASEROM → PORTROM)

#### A. Overlay APKs (6 files)

- [ ] **AospFrameworkResOverlay.apk**
  - Path: `product/app/AospFrameworkResOverlay/AospFrameworkResOverlay.apk`
  - Từ: BASEROM
  - Fix: Notch, corners, navigation bar

- [ ] **DevicesAndroidOverlay.apk**
  - Path: `product/app/DevicesAndroidOverlay/DevicesAndroidOverlay.apk`
  - Từ: BASEROM
  - Fix: Sensors, fingerprint, AOD

- [ ] **DevicesOverlay.apk**
  - Path: `product/app/DevicesOverlay/DevicesOverlay.apk`
  - Từ: BASEROM
  - Fix: Device general config

- [ ] **MiuiBiometricResOverlay.apk**
  - Path: `product/app/MiuiBiometricResOverlay/MiuiBiometricResOverlay.apk`
  - Từ: BASEROM
  - Fix: Fingerprint position

- [ ] **SettingsRroDeviceHideStatusBarOverlay.apk**
  - Path: `product/app/SettingsRroDeviceHideStatusBarOverlay/SettingsRroDeviceHideStatusBarOverlay.apk`
  - Từ: BASEROM
  - Fix: Status bar

- [ ] **MiuiFrameworkResOverlay.apk** (optional)
  - Path: `product/app/MiuiFrameworkResOverlay/MiuiFrameworkResOverlay.apk`
  - Từ: BASEROM
  - Fix: Framework resources

**Script:**
```bash
for overlay in AospFrameworkResOverlay DevicesAndroidOverlay DevicesOverlay \
               MiuiBiometricResOverlay SettingsRroDeviceHideStatusBarOverlay; do
    find baserom/images/product -name "${overlay}.apk" -exec cp {} \
         $(find portrom/images/product -name "${overlay}.apk") \; 2>/dev/null
done
```

---

#### B. Display Configuration

- [ ] **Tất cả display_id_*.xml**
  - Path: `product/etc/displayconfig/`
  - Từ: BASEROM
  - Fix: Brightness curve, refresh rate

**Script:**
```bash
cp -rf baserom/images/product/etc/displayconfig/*.xml \
       portrom/images/product/etc/displayconfig/
```

---

#### C. Device Features

- [ ] **device_features/munch.xml** (hoặc tên device tương ứng)
  - Path: `product/etc/device_features/`
  - Từ: BASEROM
  - Fix: Hardware capabilities

**Script:**
```bash
cp -rf baserom/images/product/etc/device_features/* \
       portrom/images/product/etc/device_features/
```

---

#### D. Biometric

- [ ] **MiuiBiometric/** (toàn bộ folder)
  - Path: `product/app/MiuiBiometric/`
  - Từ: BASEROM
  - Fix: Face unlock

**Script:**
```bash
rm -rf portrom/images/product/app/MiuiBiometric
cp -rf baserom/images/product/app/MiuiBiometric \
       portrom/images/product/app/
```

---

#### E. NFC Files (20+ files)

Từ `vendor/` partition của BASEROM:

**Binaries:**
- [ ] `vendor/bin/hw/vendor.nxp.hardware.nfc@2.0-service`
- [ ] `vendor/bin/nqnfcinfo`

**Configs:**
- [ ] `vendor/etc/libnfc-nci.conf`
- [ ] `vendor/etc/libnfc-nxp.conf`
- [ ] `vendor/etc/libnfc-nxp_RF.conf`
- [ ] `vendor/etc/sn100u_nfcon.pnscr`

**Init Scripts:**
- [ ] `vendor/etc/init/vendor.nxp.hardware.nfc@2.0-service.rc`

**Libraries:**
- [ ] `vendor/lib/nfc_nci.nqx.default.hw.so`
- [ ] `vendor/lib/vendor.nxp.hardware.nfc@2.0.so`
- [ ] `vendor/lib64/nfc_nci.nqx.default.hw.so`
- [ ] `vendor/lib64/vendor.nxp.hardware.nfc@2.0.so`

**Kernel Modules:**
- [ ] `vendor/lib/modules/nfc_i2c.ko`
- [ ] `vendor/lib/modules/5.4-gki/nfc_i2c.ko`

**Firmware:**
- [ ] `vendor/firmware/96_nfcCard_RTP.bin`
- [ ] `vendor/firmware/98_nfcCardSlow_RTP.bin`

**Permissions:**
- [ ] `vendor/etc/permissions/android.hardware.nfc.xml`
- [ ] `vendor/etc/permissions/android.hardware.nfc.hce.xml`
- [ ] `vendor/etc/permissions/android.hardware.nfc.hcef.xml`

**Script nhanh:**
```bash
# Từ devices/nfc/ hoặc BASEROM vendor/
cp -rf devices/nfc/bin/* portrom/images/vendor/bin/ 2>/dev/null
cp -rf devices/nfc/etc/* portrom/images/vendor/etc/ 2>/dev/null
cp -rf devices/nfc/lib/* portrom/images/vendor/lib/ 2>/dev/null
cp -rf devices/nfc/lib64/* portrom/images/vendor/lib64/ 2>/dev/null
cp -rf devices/nfc/firmware/* portrom/images/vendor/firmware/ 2>/dev/null
```

---

### ✅ BƯỚC 3: SỬA BUILD.PROP FILES

#### A. system/system/build.prop

**Sửa các dòng sau:**

- [ ] `ro.product.device=munch`
- [ ] `ro.product.system.device=munch`
- [ ] `ro.build.product=munch`
- [ ] `ro.build.date=<current_date>`
- [ ] `ro.build.date.utc=<current_timestamp>`
- [ ] `ro.system.build.date=<current_date>`
- [ ] `ro.system.build.date.utc=<current_timestamp>`

**Thêm vào cuối file:**

- [ ] `ro.crypto.state=encrypted`
- [ ] `debug.game.video.support=true`
- [ ] `debug.game.video.speed=true`

---

#### B. product/etc/build.prop

**Sửa các dòng:**

- [ ] `ro.product.product.name=munch`
- [ ] `ro.sf.lcd_density=440` (MUNCH density)
- [ ] `persist.miui.density_v2=440`
- [ ] `ro.product.build.date=<current_date>`
- [ ] `ro.product.build.date.utc=<current_timestamp>`

**⚠️ QUAN TRỌNG - Lấy từ BASEROM:**

- [ ] `ro.millet.netlink=<value_from_baserom>` (tìm trong BASEROM product/etc/build.prop)

**Thêm vào cuối:**

- [ ] `persist.sys.miui_animator_sched.sched_threads=2`
- [ ] `ro.miui.cust_erofs=0`

---

#### C. vendor/build.prop

**Chỉ sửa build date:**

- [ ] `ro.vendor.build.date=<current_date>`
- [ ] `ro.vendor.build.date.utc=<current_timestamp>`

**Comment out (nếu có):**

- [ ] `#persist.sys.millet.cgroup1=...`

**Thêm vào cuối:**

- [ ] `persist.vendor.mi_sf.optimize_for_refresh_rate.enable=1`
- [ ] `ro.vendor.mi_sf.ultimate.perf.support=true`
- [ ] `ro.surface_flinger.set_touch_timer_ms=200`
- [ ] `ro.surface_flinger.set_idle_timer_ms=1100`
- [ ] `debug.sf.set_idle_timer_ms=1100`
- [ ] `ro.vendor.media.video.frc.support=true`

---

#### D. vendor/default.prop

**Thêm vào cuối:**

- [ ] `ro.surface_flinger.use_content_detection_for_refresh_rate=true`
- [ ] `ro.surface_flinger.set_idle_timer_ms=2147483647`
- [ ] `ro.surface_flinger.set_touch_timer_ms=2147483647`
- [ ] `ro.surface_flinger.set_display_power_timer_ms=2147483647`

---

#### E. system_ext/etc/build.prop

**Sửa:**

- [ ] `ro.product.system_ext.device=munch`
- [ ] `ro.system_ext.build.date=<current_date>`
- [ ] `ro.system_ext.build.date.utc=<current_timestamp>`

---

#### F. odm/etc/build.prop (nếu có)

**Chỉ update date:**

- [ ] `ro.odm.build.date=<current_date>`
- [ ] `ro.odm.build.date.utc=<current_timestamp>`

---

### ✅ BƯỚC 4: SỬA FSTAB FILES

**Files:** `vendor/etc/fstab.*` (fstab.qcom, fstab.default)

**Xóa các flags sau trong TỪNG DÒNG:**

- [ ] `,avb`
- [ ] `,avb=vbmeta`
- [ ] `,avb=vbmeta_system`
- [ ] `,avb=vbmeta_vendor`
- [ ] `,avb_keys=/avb/...`

**Optional - Xóa encryption:**

- [ ] `,fileencryption=...`
- [ ] `,metadata_encryption=...`

**Script:**
```bash
for fstab in portrom/images/vendor/etc/fstab.*; do
    sed -i 's/,avb[^,]*//g' "$fstab"
    sed -i 's/,fileencryption=[^,]*//g' "$fstab"
    sed -i 's/,metadata_encryption=[^,]*//g' "$fstab"
done
```

---

### ✅ BƯỚC 5: SỬA VINTF MANIFEST

**File:** `system_ext/etc/vintf/manifest.xml`

**Thêm VNDK version:**

- [ ] Lấy VNDK version từ BASEROM `vendor/build.prop`: `ro.vndk.version`
- [ ] Thêm block XML:
```xml
<vendor-ndk>
    <version>34</version>     <!-- số version lấy được -->
</vendor-ndk>
```

**Script:**
```bash
VNDK=$(grep "ro.vndk.version" baserom/images/vendor/build.prop | cut -d'=' -f2)
sed -i "s|</manifest>|    <vendor-ndk>\n        <version>$VNDK</version>\n    </vendor-ndk>\n</manifest>|" \
    portrom/images/system_ext/etc/vintf/manifest.xml
```

---

### ✅ BƯỚC 6: SỬA INIT.RC (Optional)

**File:** `system/system/etc/init/hw/init.rc`

**Thêm sau dòng "on boot":**

- [ ] `chmod 0731 /data/system/theme`

---

### ✅ BƯỚC 7: PATCH JAR FILES (Advanced)

#### A. framework.jar

**File:** `system/system/framework/framework.jar`

**Target:** `android/os/Build.smali` → method `isBuildConsistent()`

**Action:**
- [ ] Decompile JAR
- [ ] Tìm Build.smali
- [ ] Sửa method return true
- [ ] Recompile

**Status:** ⬜ Chưa patch / ✅ Đã patch

---

#### B. services.jar

**File:** `system/system/framework/services.jar`

**Target:** `com/android/server/pm/PackageManagerServiceUtils.smali` → method `getMinimumSignatureSchemeVersionForTargetSdk`

**Action:**
- [ ] Decompile JAR
- [ ] Tìm PackageManagerServiceUtils.smali
- [ ] Sửa method return 0
- [ ] Recompile

**Status:** ⬜ Chưa patch / ✅ Đã patch

---

### ✅ BƯỚC 8: XÓA FILES KHÔNG CẦN THIẾT

**Optional - Debloat:**

- [ ] `product/etc/auto-install*`
- [ ] `product/data-app/*GalleryLockscreen*`
- [ ] `product/priv-app/MIUIBrowser`
- [ ] `product/priv-app/MIUIVideo`
- [ ] `product/priv-app/MIUIMusicT`
- [ ] `product/app/Updater`
- [ ] `system_ext/apex/com.android.vndk.v31.apex`
- [ ] `system_ext/apex/com.android.vndk.v32.apex`
- [ ] `system_ext/apex/com.android.vndk.v33.apex`

---

### ✅ BƯỚC 9: TẠO FILESYSTEM CONFIGS

**Cho mỗi partition cần đóng gói:**

- [ ] system → `fspatch.py` + `contextpatch.py`
- [ ] product → `fspatch.py` + `contextpatch.py`
- [ ] system_ext → `fspatch.py` + `contextpatch.py`
- [ ] mi_ext → `fspatch.py` + `contextpatch.py`

**Script:**
```bash
for part in system product system_ext mi_ext; do
    python3 bin/fspatch.py portrom/images/$part portrom/config/${part}_fs_config
    python3 bin/contextpatch.py portrom/images/$part portrom/config/${part}_file_contexts
done
```

---

### ✅ BƯỚC 10: ĐÓNG GÓI PARTITIONS

**Pack mỗi partition thành IMG:**

- [ ] system.img (EROFS hoặc EXT4)
- [ ] product.img (EROFS hoặc EXT4)
- [ ] system_ext.img (EROFS hoặc EXT4)
- [ ] mi_ext.img (EROFS hoặc EXT4)

**EROFS:**
```bash
mkfs.erofs -zlz4hc,1 \
    --mount-point=/system \
    --fs-config-file=portrom/config/system_fs_config \
    --file-contexts=portrom/config/system_file_contexts \
    portrom/images/system.img \
    portrom/images/system/
```

**EXT4:**
```bash
make_ext4fs -J -T $(date +%s) \
    -S portrom/config/system_file_contexts \
    -l 2147483648 \
    -C portrom/config/system_fs_config \
    -L system -a system \
    portrom/images/system.img \
    portrom/images/system/
```

---

### ✅ BƯỚC 11: TẠO SUPER.IMG

**Tạo super.img với lpmake:**

- [ ] Tính size của từng partition IMG
- [ ] Xác định super size (thường 9126805504 bytes)
- [ ] Run lpmake với tất cả partitions

**Check sizes:**
```bash
du -b portrom/images/system.img
du -b portrom/images/product.img
du -b portrom/images/system_ext.img
du -b portrom/images/mi_ext.img
du -b baserom/images/vendor.img
du -b baserom/images/odm.img
```

---

### ✅ BƯỚC 12: TẠO FLASHABLE ZIP

**Cấu trúc ZIP:**

- [ ] `images/super.zst` (nén từ super.img)
- [ ] `images/boot.img` (từ BASEROM hoặc custom)
- [ ] `META-INF/com/google/android/update-binary`
- [ ] `META-INF/zstd` (binary)

**Nén super.img:**
```bash
zstd --rm super.img -o super.zst
```

**Tạo ZIP:**
```bash
cd flash_package/
zip -r ../HyperOS_MUNCH_Port.zip ./*
```

---

## 📊 TỔNG KẾT

### Files PHẢI COPY (BASEROM → PORTROM):

| Loại | Số lượng | Từ BASEROM |
|------|----------|------------|
| Partitions | 4 folders | vendor/, odm/, vendor_dlkm/, odm_dlkm/ |
| Overlay APKs | 6 files | product/app/*/  |
| Display configs | 2-5 files | product/etc/displayconfig/ |
| Device features | 1-2 files | product/etc/device_features/ |
| MiuiBiometric | 1 folder | product/app/MiuiBiometric/ |
| NFC files | 20+ files | vendor/* |
| boot.img | 1 file | boot.img |

**Tổng:** ~35-45 files/folders

---

### Files PHẢI SỬA:

| File | Số dòng sửa | Thao tác |
|------|-------------|----------|
| system/system/build.prop | ~10 dòng | sed |
| product/etc/build.prop | ~8 dòng | sed |
| vendor/build.prop | ~10 dòng | sed, thêm |
| vendor/default.prop | ~4 dòng | thêm |
| system_ext/etc/build.prop | ~3 dòng | sed |
| fstab files (2-3 files) | ~5-10 dòng | sed |
| manifest.xml | 1 block | sed |
| init.rc | 1 dòng | sed |

**Tổng:** 8-10 files

---

### Files PHẢI PATCH (Binary):

| File | Method | Độ khó |
|------|--------|--------|
| framework.jar | Build.isBuildConsistent() | Medium |
| services.jar | PackageManagerServiceUtils.getMinimumSignature...() | Medium |

**Tổng:** 2 files (cần smali/baksmali)

---

## ✅ CHECKLIST CUỐI CÙNG TRƯỚC KHI FLASH

- [ ] Đã backup device
- [ ] Tất cả partitions có trong super.img
- [ ] Super.img size < 8.5GB
- [ ] Build.prop đã sửa device code
- [ ] Millet netlink đúng giá trị
- [ ] VNDK version đã thêm
- [ ] AVB đã disable
- [ ] Signature check đã patch (nếu cần)
- [ ] ZIP structure đúng format
- [ ] Update-binary và zstd có trong ZIP

---

## 🎯 TIPS

### Lệnh kiểm tra nhanh:

```bash
# Check device code trong build.prop
grep "ro.product.device" portrom/images/*/build.prop portrom/images/*/*/build.prop

# Check millet netlink
grep "ro.millet.netlink" portrom/images/product/etc/build.prop

# Check VNDK
grep "<version>" portrom/images/system_ext/etc/vintf/manifest.xml

# Check AVB trong fstab
grep "avb" portrom/images/vendor/etc/fstab.*

# Check super.img size
du -h out/super.img
```

### Lỗi thường gặp:

| Lỗi | Nguyên nhân | File cần check |
|-----|-------------|----------------|
| Bootloop | VNDK mismatch | manifest.xml |
| No WiFi/SIM | Vendor sai | vendor/ partition |
| Screen dim | Display config | displayconfig/*.xml |
| FP not work | Overlay sai | MiuiBiometricResOverlay.apk |
| Battery drain | Millet sai | ro.millet.netlink |
| Signature error | Framework chưa patch | framework.jar, services.jar |

---

**🎉 Hoàn thành checklist = ROM sẵn sàng flash!**
