#!/bin/bash

# --- 配置区域 ---
# 单个用户限制为 32 核 (32 * 100%)
SINGLE_CPU_LIMIT="3200%"
# 单个用户内存上限
SINGLE_MEM_LIMIT="256G"
# ----------------

echo "正在应用 CPU + 内存 限制策略..."
echo "目标：普通用户 [32核 + 256GB 内存], 管理员 [无限制]"

# 1. 获取所有 UID >= 1000 的真实用户
for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do

    uid=$(id -u "$user")

    # 2. 检查是否是管理员 (在 sudo 或 wheel 组)
    if groups "$user" | grep -qE "(sudo|wheel)"; then
        echo "✅ 用户 [$user] (UID:$uid) 是管理员，跳过 CPU / 内存 限制。"

        # 如需取消管理员之前的限制，可取消注释
        # sudo systemctl set-property user-$uid.slice CPUQuota=
        # sudo systemctl set-property user-$uid.slice MemoryMax=
    else
        echo "🔒 用户 [$user] (UID:$uid) 是普通用户，限制为 32 核 + 256GB 内存..."

        sudo systemctl set-property user-$uid.slice \
            CPUQuota=${SINGLE_CPU_LIMIT} \
            MemoryMax=${SINGLE_MEM_LIMIT}
    fi
done

echo "设置完成！"

echo "验证示例："
echo "systemctl show user-\$(id -u 用户名).slice -p CPUQuota -p MemoryMax"
