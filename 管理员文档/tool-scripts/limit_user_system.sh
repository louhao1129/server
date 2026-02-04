#!/bin/bash

# ================= 配置区域 =================

# 普通用户限制
SINGLE_CPU_LIMIT="3200%"      # 32 核
SINGLE_MEM_LIMIT="256G"       # 每用户 256GB

# system.slice 兜底限制（建议 < 物理内存）
SYSTEM_MEM_LIMIT="960G"       # 根据你机器内存自行调整
# SYSTEM_CPU_LIMIT="6400%"    # 可选，不建议轻易限制

# ============================================

echo "应用 systemd 资源限制策略"
echo "普通用户：32 核 + 256GB"
echo "system.slice：内存兜底 ${SYSTEM_MEM_LIMIT}"

# ---------- 1. system.slice 兜底 ----------
echo "🛡️  设置 system.slice 内存上限..."

sudo systemctl set-property system.slice \
    MemoryMax=${SYSTEM_MEM_LIMIT}

# 如确实需要限制 system CPU，可取消注释
# sudo systemctl set-property system.slice CPUQuota=${SYSTEM_CPU_LIMIT}

# ---------- 2. per-user 限制 ----------
echo "🔒 设置普通用户资源限制..."

for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do

    uid=$(id -u "$user")

    if groups "$user" | grep -qE "(sudo|wheel)"; then
        echo "✅ [$user] (UID:$uid) 管理员，跳过限制"
    else
        echo "🔒 [$user] (UID:$uid) → 32 核 + 256GB"

        sudo systemctl set-property user-$uid.slice \
            CPUQuota=${SINGLE_CPU_LIMIT} \
            MemoryMax=${SINGLE_MEM_LIMIT}
    fi
done

echo "✅ 设置完成"
