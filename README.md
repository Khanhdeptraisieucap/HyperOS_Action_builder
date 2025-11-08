<div align="center">

# HyperOS Action build Proj.
### 基于 https://github.com/ljc-fight/miui_port

</div>

## 简介
- HyperOS 一键自动移植打包 (FUXI/NUWA/ISHTAR -> MUNCH)
- 目标设备: POCO F4 / K40s (MUNCH)
- Github Action 无服务器运行

## 📚 Tài liệu học tập
- **[PORTING_GUIDE.md](PORTING_GUIDE.md)** - Hướng dẫn chi tiết port ROM thủ công (từng bước)
- **[CRITICAL_FILES.md](CRITICAL_FILES.md)** - Danh sách files quan trọng cần thay thế/sửa đổi
- **[manual_port_example.sh](manual_port_example.sh)** - Script mẫu port ROM thủ công

### Nội dung tài liệu:
- ✅ Tổng quan quy trình port ROM
- ✅ Công cụ cần thiết và cách sử dụng
- ✅ Cấu trúc Super partition
- ✅ Files quan trọng cần xử lý (50+ files)
- ✅ Cách patch framework/services để bypass signature check
- ✅ Cách fix NFC, fingerprint, camera, display
- ✅ Troubleshooting và debug
- ✅ Script example đầy đủ

## 感谢
> 本项目使用了以下开源项目的部分或全部内容，感谢这些项目的开发者（排名顺序不分先后）

- [「BypassSignCheck」by Weverses](https://github.com/Weverses/BypassSignCheck)
- [「contextpatch」 by ColdWindScholar](https://github.com/ColdWindScholar/TIK)
- [「fspatch」by affggh](https://github.com/affggh/fspatch)
- [「gettype」by affggh](https://github.com/affggh/gettype)
- [「lpunpack」by unix3dgforce](https://github.com/unix3dgforce/lpunpack)
- [「miui_port」by ljc-fight](https://github.com/ljc-fight/miui_port)
