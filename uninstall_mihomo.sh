#!/bin/bash

# ==============================================================================
#
#          Mihomo Uninstaller - Mihomo 自动卸载脚本
#
#   本脚本将会：
#   1. 停止所有正在运行的 mihomo 进程。
#   2. 从 ~/.bashrc 文件中移除 mihomo 的配置行。
#   3. 删除 mihomo 的可执行文件和所有配置文件。
#   4. 在执行不可逆的删除操作前，会请求用户确认。
#
#   使用方法:
#   1. 保存此文件为 uninstall_mihomo.sh
#   2. 在终端中给予执行权限: chmod +x uninstall_mihomo.sh
#   3. 运行脚本: ./uninstall_mihomo.sh
#
# ==============================================================================

# 定义颜色常量，让输出更清晰
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_NC='\033[0m' # No Color

echo -e "${C_YELLOW}### Mihomo 卸载程序 ###${C_NC}"
echo ""

# --- 步骤一：停止正在运行的服务 ---
echo "[1/4] 正在停止所有 mihomo 进程..."
if pgrep -f mihomo > /dev/null; then
    pkill -9 -f mihomo
    echo -e "${C_GREEN}✅ 成功停止了 mihomo 进程。${C_NC}"
else
    echo -e "${C_GREEN}✅ 系统中没有正在运行的 mihomo 进程。${C_NC}"
fi
echo ""

# --- 步骤二：从 .bashrc 中移除配置 ---
BASHRC_FILE="$HOME/.bashrc"
echo "[2/4] 准备清理您的 .bashrc 配置文件..."

# 要删除的配置行
SOURCE_LINE="source $HOME/.config/mihomo/mihomo.sh"
ON_LINE="mihomo on"

if [ -f "$BASHRC_FILE" ]; then
    # 检查是否需要清理
    if grep -qF -- "$SOURCE_LINE" "$BASHRC_FILE" || grep -qF -- "$ON_LINE" "$BASHRC_FILE"; then
        echo "找到了以下需要从 $BASHRC_FILE 中移除的配置行:"
        echo -e "  - ${C_YELLOW}${SOURCE_LINE}${C_NC}"
        echo -e "  - ${C_YELLOW}${ON_LINE}${C_NC}"
        
        # 使用 sed 命令来删除指定的行。-i 表示直接修改文件。
        # sed -i '/pattern/d' file  的意思是删除 file 文件中匹配 pattern 的行。
        sed -i "/$(echo "$SOURCE_LINE" | sed 's/[[\.*^$/]/\\&/g')/d" "$BASHRC_FILE"
        sed -i "/$(echo "$ON_LINE" | sed 's/[[\.*^$/]/\\&/g')/d" "$BASHRC_FILE"
        
        echo -e "${C_GREEN}✅ 成功清理了 .bashrc 文件。${C_NC}"
    else
        echo -e "${C_GREEN}✅ .bashrc 文件中未找到 mihomo 相关配置，无需清理。${C_NC}"
    fi
else
    echo -e "${C_YELLOW}⚠️  未找到 .bashrc 文件，跳过清理。${C_NC}"
fi
echo ""


# --- 步骤三：删除文件和目录 ---
MIHOMO_EXECUTABLE="$HOME/bin/mihomo"
MIHOMO_CONFIG_DIR="$HOME/.config/mihomo"

echo "[3/4] 准备删除以下文件和目录:"
echo -e "  - 可执行文件: ${C_YELLOW}${MIHOMO_EXECUTABLE}${C_NC}"
echo -e "  - 配置文件目录: ${C_YELLOW}${MIHOMO_CONFIG_DIR}${C_NC}"
echo ""

# 关键操作前请求用户确认
read -p "您确定要永久删除这些文件吗？ (y/N): " choice
case "$choice" in 
  y|Y ) 
    echo "正在删除文件..."
    rm -f "$MIHOMO_EXECUTABLE"
    rm -rf "$MIHOMO_CONFIG_DIR"
    echo -e "${C_GREEN}✅ 文件和目录已成功删除。${C_NC}"
    ;;
  * ) 
    echo -e "${C_RED}❌ 操作已取消，未删除任何文件。${C_NC}"
    exit 1
    ;;
esac
echo ""

# --- 步骤四：完成 ---
echo "[4/4] 卸载完成！"
echo -e "${C_GREEN}🎉 Mihomo 已成功从您的系统中移除。${C_NC}"
echo "请执行 'source ~/.bashrc' 或重新打开一个新的终端窗口来让所有更改完全生效。"

exit 0