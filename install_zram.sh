#!/bin/sh

echo "========================================="
echo "  🚀 全自动 zram 优化脚本"
echo "========================================="

# 1. 权限检查
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ 请使用 root 权限运行此脚本！"
  exit 1
fi

# 2. 内存计算 (读取 /proc/meminfo)
TOTAL_MEM_MB=$(awk '/MemTotal/ { printf "%d", $2/1024 }' /proc/meminfo)
ZRAM_SIZE_MB=$((TOTAL_MEM_MB / 2))

echo "📊 检测到物理内存: ${TOTAL_MEM_MB} MB"
echo "🎯 计划分配 zram 容量: ${ZRAM_SIZE_MB} MB (50%)"
echo "-----------------------------------------"

# 3. Debian / Ubuntu 逻辑 (通过 apt 检测)
if command -v apt-get >/dev/null 2>&1; then
    echo "🐧 检测到系统类型: Debian / Ubuntu (apt)"
    echo "[1/3] 正在安装 zram-tools..."
    
    # 忽略 update 报错，并设置无交互模式避免弹窗卡住脚本
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y || true
    apt-get install -y zram-tools
    
    echo "[2/3] 写入配置 (ALGO=zstd, PERCENT=50)..."
    cat > /etc/default/zramswap <<EOF
ALGO=zstd
PERCENT=50
EOF
    
    echo "[3/3] 启动 systemd 服务..."
    systemctl restart zramswap
    systemctl enable zramswap
    
    echo "-----------------------------------------"
    echo "✅ zram 配置完成！当前状态："
    zramctl

# 4. Alpine Linux 逻辑 (通过 apk 检测)
elif command -v apk >/dev/null 2>&1; then
    echo "⛰️ 检测到系统类型: Alpine Linux (apk)"
    echo "[1/3] 正在安装 zram-init..."
    apk update && apk add zram-init
    
    echo "[2/3] 写入配置 (算法: zstd, 大小: ${ZRAM_SIZE_MB}M)..."
    cat > /etc/conf.d/zram-init <<EOF
load_on_start="yes"
unload_on_stop="yes"
num_devices="1"
type0="swap"
comp_algorithm0="zstd"
size0="${ZRAM_SIZE_MB}M"
EOF
    
    echo "[3/3] 启动 OpenRC 服务..."
    rc-service zram-init restart
    rc-update add zram-init default
    
    echo "-----------------------------------------"
    echo "✅ zram 配置完成！当前 Swap 状态："
    cat /proc/swaps

# 5. 其他未适配系统
else
    echo "❌ 失败：无法识别当前系统的包管理器 (未找到 apt 或 apk)。"
    exit 1
fi
