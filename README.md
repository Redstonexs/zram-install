# zram-install

这是一个轻量级、跨平台的 Shell 脚本，旨在为 Linux 服务器和物理机提供零配置的 **zram** (内存压缩技术) 启用方案。

本脚本会自动检测您的系统环境，动态提取物理内存大小，并以最完美的“甜点配置”为您开启 zram，极大缓解内存焦虑，提升系统流畅度。

## ✨ 核心特性

* 🐧 **跨平台智能识别**：无需手动指定系统，自动通过包管理器 (`apt` / `apk`) 识别 Debian、Ubuntu 或 Alpine Linux 并执行对应逻辑。
* 🧠 **动态内存嗅探**：自动读取 `/proc/meminfo`，动态分配物理内存的 **50%** 作为 zram 容量，避免硬编码导致的小内存机器 OOM 或大内存机器浪费。
* ⚡ **极速压缩算法**：默认配置采用 `zstd` 算法，提供极佳的压缩率与 CPU 开销平衡。
* 🛡️ **高容错设计**：即使系统存在失效的第三方软件源（如缺失 GPG key 导致的 `apt update` 报错），也能强制完成 zram 核心组件的安装。

## 🚀 快速开始

无需克隆整个仓库，您只需要在终端中使用 root 权限运行以下一行命令即可。

### 适用系统：Debian / Ubuntu
使用 `curl` 获取并直接执行：

```bash
curl -sSL https://raw.githubusercontent.com/Redstonexs/zram-install/main/install_zram.sh | sudo bash
