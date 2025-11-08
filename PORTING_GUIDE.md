# Hướng dẫn Port HyperOS ROM thủ công

## 📚 Mục lục
1. [Tổng quan quy trình](#tổng-quan-quy-trình)
2. [Công cụ cần thiết](#công-cụ-cần-thiết)
3. [Cấu trúc Super Partition](#cấu-trúc-super-partition)
4. [Các bước Port ROM chi tiết](#các-bước-port-rom-chi-tiết)
5. [Files quan trọng cần thay thế](#files-quan-trọng-cần-thay-thế)
6. [Các patch và fix cần thiết](#các-patch-và-fix-cần-thiết)

---

## 🎯 Tổng quan quy trình

### Khái niệm cơ bản
Port ROM = Lấy **giao diện/tính năng** từ ROM nguồn (PORTROM) + **driver/hardware** từ ROM gốc (BASEROM)

```
BASEROM (MUNCH)     +     PORTROM (FUXI/NUWA/ISHTAR)
├── vendor ──────────────> Giữ nguyên (drivers, hardware)
├── odm ─────────────────> Giữ nguyên
├── vendor_dlkm ─────────> Giữ nguyên
├── odm_dlkm ────────────> Giữ nguyên
├── system ──────────────> Thay thế (Android framework)
├── system_ext ──────────> Thay thế (Extensions)
├── product ─────────────> Thay thế (Apps, UI)
└── mi_ext ──────────────> Thay thế (MIUI/HyperOS specific)
```

---

## 🛠️ Công cụ cần thiết

### 1. Công cụ giải nén/nén
```bash
# Cài đặt trên Ubuntu/Debian
sudo apt install unzip zip 7zip p7zip-full zstd

# Tools chuyên dụng
- payload-dumper-go    # Giải nén payload.bin
- lpunpack             # Giải nén super.img
- lpmake               # Đóng gói super.img
```

### 2. Công cụ xử lý filesystem
```bash
- extract.erofs        # Giải nén EROFS
- mkfs.erofs          # Đóng gói EROFS
- make_ext4fs         # Đóng gói EXT4
- imgextractor.py     # Giải nén IMG
- simg2img            # Chuyển đổi sparse image
```

### 3. Công cụ patch/mod
```bash
- apktool             # Decompile/recompile APK
- baksmali/smali      # Decompile/recompile DEX
- zipalign            # Align APK
- fspatch.py          # Patch filesystem config
- contextpatch.py     # Patch SELinux contexts
```

---

## 📦 Cấu trúc Super Partition

### Super.img chứa các phân vùng con:

| Phân vùng | Nguồn | Mục đích | Kích thước ước tính |
|-----------|-------|----------|---------------------|
| **vendor** | BASEROM | Driver phần cứng, HAL, firmware | ~800MB |
| **odm** | BASEROM | Cấu hình OEM specific | ~200MB |
| **vendor_dlkm** | BASEROM | Vendor kernel modules | ~50MB |
| **odm_dlkm** | BASEROM | ODM kernel modules | ~10MB |
| **system** | PORTROM | Android framework core | ~1.5GB |
| **system_ext** | PORTROM | System extensions, VNDK | ~600MB |
| **product** | PORTROM | Apps, themes, fonts | ~1.2GB |
| **mi_ext** | PORTROM | MIUI/HyperOS extensions | ~100MB |

---

## 📋 Các bước Port ROM chi tiết

### **BƯỚC 1: Chuẩn bị ROM**

```bash
# Tải về 2 file ROM:
# - BASEROM: ROM chính thức cho MUNCH (máy đích)
# - PORTROM: ROM muốn port (FUXI/NUWA/ISHTAR)

# Ví dụ:
BASEROM="miui_MUNCH_V14.0.8.0.TKMCNXM.zip"
PORTROM="miui_FUXI_V14.0.24.0.TNGCNXM.zip"
```

### **BƯỚC 2: Giải nén payload.bin**

```bash
# Giải nén payload từ ZIP
unzip BASEROM payload.bin -d baserom/
unzip PORTROM payload.bin -d portrom/

# Giải nén payload.bin thành các IMG
payload-dumper-go -o baserom/images/ baserom/payload.bin
payload-dumper-go -o portrom/images/ portrom/payload.bin
```

**Kết quả:** Các file IMG trong `images/`:
- system.img, vendor.img, product.img, odm.img, v.v.

### **BƯỚC 3: Giải nén các IMG thành folder**

```bash
# Giải nén EROFS images
extract.erofs -x -i baserom/images/system.img
extract.erofs -x -i portrom/images/system.img
extract.erofs -x -i portrom/images/product.img
extract.erofs -x -i portrom/images/system_ext.img
extract.erofs -x -i portrom/images/mi_ext.img

# Di chuyển vào thư mục làm việc
mv system baserom/images/
mv product portrom/images/
# ... tương tự cho các partition khác
```

---

## 🔄 Files quan trọng cần thay thế

### **A. Files Overlay (từ BASEROM → PORTROM)**

#### 1. **Device-specific Overlays** (product/app hoặc product/overlay)
```bash
# Files cần copy từ BASEROM sang PORTROM:
product/app/AospFrameworkResOverlay.apk
product/app/DevicesAndroidOverlay.apk
product/app/DevicesOverlay.apk
product/app/SettingsRroDeviceHideStatusBarOverlay.apk
product/app/MiuiBiometricResOverlay.apk
```

**Lý do:** Chứa cấu hình màn hình, cảm biến, nút bấm cho MUNCH

#### 2. **Display Configuration**
```bash
# Copy toàn bộ thư mục
product/etc/displayconfig/display_id_*.xml
```

**Lý do:** Fix độ sáng màn hình, tần số quét

#### 3. **Device Features**
```bash
# Copy toàn bộ folder
product/etc/device_features/
```

**Lý do:** Định nghĩa tính năng phần cứng (camera, NFC, fingerprint)

#### 4. **MiuiBiometric** (Nhận diện khuôn mặt)
```bash
product/app/MiuiBiometric/
```

### **B. Files cần từ BASEROM (giữ nguyên)**

#### 1. **Vendor partition** (toàn bộ)
```bash
vendor/
├── bin/           # Hardware daemons
├── lib/           # Hardware libraries
├── lib64/
├── etc/           # Hardware configs
├── firmware/      # Firmware files
└── build.prop     # Vendor properties
```

#### 2. **ODM partition** (toàn bộ)
```bash
odm/
├── etc/
└── build.prop
```

#### 3. **boot.img**
```bash
# Kernel và ramdisk cho MUNCH
boot.img
```

---

## 🔧 Các patch và fix cần thiết

### **1. Fix Build.prop**

Cần sửa các file `build.prop` trong các partition:

#### **a. System build.prop**
```bash
# File: system/system/build.prop
# Sửa device code
ro.product.device=munch                    # Đổi từ fuxi → munch
ro.product.system.device=munch
ro.build.product=munch

# Sửa ngày build
ro.build.date=Thu Dec 05 10:30:00 UTC 2024
ro.build.date.utc=1733395800

# Thêm props
ro.crypto.state=encrypted
debug.game.video.support=true
```

#### **b. Product build.prop**
```bash
# File: product/etc/build.prop
ro.product.product.name=munch
ro.sf.lcd_density=440                      # Độ phân giải MUNCH
persist.miui.density_v2=440

# Millet netlink (quan trọng!)
ro.millet.netlink=29                       # Lấy từ BASEROM

# Animations
persist.sys.miui_animator_sched.sched_threads=2
```

#### **c. Vendor build.prop**
```bash
# File: vendor/build.prop
# Giữ nguyên từ BASEROM, nhưng update:
ro.vendor.build.date=Thu Dec 05 10:30:00 UTC 2024
ro.vendor.build.date.utc=1733395800

# Performance props
persist.vendor.mi_sf.optimize_for_refresh_rate.enable=1
ro.vendor.mi_sf.ultimate.perf.support=true
ro.surface_flinger.set_touch_timer_ms=200
```

### **2. Fix NFC**

NFC hardware khác nhau giữa các máy, cần copy từ BASEROM hoặc từ folder `devices/nfc/`:

```bash
vendor/bin/hw/vendor.nxp.hardware.nfc@2.0-service
vendor/etc/libnfc-*.conf
vendor/etc/init/vendor.nxp.hardware.nfc@2.0-service.rc
vendor/firmware/*nfc*.bin
vendor/lib/nfc_nci.nqx.default.hw.so
vendor/lib/modules/nfc_i2c.ko
```

### **3. Disable Signature Verification** (Quan trọng!)

#### Patch framework.jar
```bash
# Mục tiêu: Bypass Android signature check
# File: system/system/framework/framework.jar

# 1. Giải nén JAR
7z x framework.jar classes*.dex

# 2. Decompile DEX
baksmali d --api 34 classes.dex -o smali/

# 3. Tìm file: smali/android/os/Build.smali
# Sửa method isBuildConsistent():
.method public static isBuildConsistent()Z
    .registers 1
    const/4 v0, 0x1        # Luôn return true
    return v0
.end method

# 4. Recompile
smali a --api 34 smali/ -o classes.dex

# 5. Đóng gói lại
7z a -tzip framework.jar classes.dex
```

#### Patch services.jar
```bash
# File: system/system/framework/services.jar
# Target method: getMinimumSignatureSchemeVersionForTargetSdk

# Tìm dòng gọi method này và sửa thành:
const/4 v0, 0x0        # Return 0 thay vì version check
```

### **4. Fix Fingerprint/AOD**

```bash
# Sửa DevicesAndroidOverlay.apk
# File: res/values/config.xml

# Thay đổi:
<string name="config_dozeComponent">
    com.android.systemui/com.android.systemui.doze.DozeService
</string>

# Từ:
com.miui.aod/com.miui.aod.doze.DozeService
```

### **5. Disable AVB Verification**

```bash
# Sửa các file fstab trong vendor/etc/
# File: vendor/etc/fstab.qcom (hoặc fstab.default)

# Xóa các flags:
,avb
,avb=vbmeta
,avb=vbmeta_system
,avb=vbmeta_vendor
,avb_keys=/avb/...
```

### **6. Remove Data Encryption** (Tùy chọn)

```bash
# Trong cùng file fstab:
# Xóa các encryption flags:
,fileencryption=aes-256-xts
,metadata_encryption=aes-256-xts
,fileencryption=ice

# Hoặc thay bằng:
,encryptable=footer
```

### **7. Fix VNDK Version**

```bash
# File: system_ext/etc/vintf/manifest.xml
# Thêm vendor-ndk version từ BASEROM:

<vendor-ndk>
    <version>34</version>     <!-- Lấy từ vendor/build.prop -->
</vendor-ndk>
```

### **8. Screen Density**

```bash
# Xác định DPI của MUNCH
# Tìm trong BASEROM/product/etc/build.prop:
ro.sf.lcd_density=440

# Sửa tất cả build.prop trong PORTROM thành 440
```

### **9. Camera**

```bash
# Option 1: Dùng camera PORTROM (Leica)
product/priv-app/MiuiCamera/MiuiCamera.apk

# Option 2: Dùng camera BASEROM (stock)
# Copy từ BASEROM → PORTROM
```

---

## 📦 Đóng gói lại ROM

### **BƯỚC 1: Tạo filesystem configs**

```bash
# Python scripts tự động tạo:
python3 fspatch.py portrom/images/system portrom/config/system_fs_config
python3 contextpatch.py portrom/images/system portrom/config/system_file_contexts
```

### **BƯỚC 2: Đóng gói partitions**

#### Đóng gói EROFS (recommended):
```bash
mkfs.erofs -zlz4hc,1 \
    --mount-point=/system \
    --fs-config-file=portrom/config/system_fs_config \
    --file-contexts=portrom/config/system_file_contexts \
    portrom/images/system.img \
    portrom/images/system/
```

#### Đóng gói EXT4 (có thể mount rw):
```bash
make_ext4fs -J -T 1733395800 \
    -S portrom/config/system_file_contexts \
    -l 2147483648 \
    -C portrom/config/system_fs_config \
    -L system -a system \
    portrom/images/system.img \
    portrom/images/system/
```

Làm tương tự cho: **product, system_ext, mi_ext**

### **BƯỚC 3: Tạo super.img**

```bash
# Lấy kích thước super từ BASEROM
# Thường là: 9126805504 bytes (8.5GB)

# Tạo super.img cho V-AB devices (MUNCH):
lpmake \
    --virtual-ab \
    --metadata-size 65536 \
    --super-name super \
    --metadata-slots 3 \
    --device super:9126805504 \
    --group qti_dynamic_partitions_a:9126805504 \
    --group qti_dynamic_partitions_b:9126805504 \
    \
    --partition system_a:readonly:1500000000:qti_dynamic_partitions_a \
    --image system_a=portrom/images/system.img \
    --partition system_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition product_a:readonly:1200000000:qti_dynamic_partitions_a \
    --image product_a=portrom/images/product.img \
    --partition product_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition system_ext_a:readonly:600000000:qti_dynamic_partitions_a \
    --image system_ext_a=portrom/images/system_ext.img \
    --partition system_ext_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition vendor_a:readonly:800000000:qti_dynamic_partitions_a \
    --image vendor_a=baserom/images/vendor.img \
    --partition vendor_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition odm_a:readonly:200000000:qti_dynamic_partitions_a \
    --image odm_a=baserom/images/odm.img \
    --partition odm_b:readonly:0:qti_dynamic_partitions_b \
    \
    --partition mi_ext_a:readonly:100000000:qti_dynamic_partitions_a \
    --image mi_ext_a=portrom/images/mi_ext.img \
    --partition mi_ext_b:readonly:0:qti_dynamic_partitions_b \
    \
    --output portrom/images/super.img
```

### **BƯỚC 4: Nén và tạo flashable ZIP**

```bash
# Nén super.img
zstd --rm portrom/images/super.img -o super.zst

# Tạo cấu trúc ZIP
mkdir -p flash_package/images/
mkdir -p flash_package/META-INF/com/google/android/

# Copy files
cp super.zst flash_package/images/
cp boot.img flash_package/images/        # Từ BASEROM hoặc custom
cp update-binary flash_package/META-INF/com/google/android/
cp zstd flash_package/META-INF/          # Binary để giải nén

# Tạo ZIP
cd flash_package/
zip -r ../HyperOS_MUNCH_Port.zip ./*
```

---

## 📱 Flash ROM

### Qua Fastboot:
```bash
# Reboot to fastboot
fastboot reboot bootloader

# Flash super
fastboot flash super super.img

# Flash boot
fastboot flash boot boot.img

# Reboot
fastboot reboot
```

### Qua Recovery (TWRP):
```bash
# Flash ZIP file
adb sideload HyperOS_MUNCH_Port.zip

# Hoặc copy vào storage và flash trong TWRP
```

---

## ⚠️ Troubleshooting

### Bootloop:
1. Kiểm tra lại vendor/odm từ BASEROM
2. Kiểm tra AVB disabled
3. Kiểm tra vintf manifest
4. Flash lại boot.img

### Không nhận SIM/WiFi:
- Vendor partition bị lỗi, dùng lại vendor từ BASEROM

### Camera không hoạt động:
- Dùng camera từ BASEROM

### Fingerprint không hoạt động:
- Kiểm tra MiuiBiometric
- Kiểm tra device_features
- Copy MiuiBiometricResOverlay.apk từ BASEROM

### Độ sáng màn hình lỗi:
- Copy display_id_*.xml từ BASEROM
- Copy MiuiFrameworkResOverlay.apk

---

## 📚 Tài liệu tham khảo

- [Android Dynamic Partitions](https://source.android.com/docs/core/ota/dynamic_partitions)
- [EROFS Documentation](https://www.kernel.org/doc/html/latest/filesystems/erofs.html)
- [Xiaomi Partition Layout](https://xiaomi.eu/community/threads/partition-layout.61178/)

---

## ✅ Checklist trước khi flash

- [ ] Vendor từ BASEROM (đúng máy)
- [ ] ODM từ BASEROM
- [ ] System/Product/System_ext từ PORTROM
- [ ] Build.prop đã sửa device code
- [ ] NFC files copied
- [ ] Display config copied
- [ ] Device features copied
- [ ] AVB disabled trong fstab
- [ ] Signature check patched
- [ ] Super.img size đúng
- [ ] Boot.img compatible với kernel

---

**Lưu ý cuối:** Port ROM cần hiểu biết về Android architecture, filesystem, và debugging. Nên backup data và có plan B trước khi flash!
