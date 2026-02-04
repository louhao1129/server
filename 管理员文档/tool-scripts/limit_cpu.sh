#!/bin/bash

# --- 配置区域 ---
# 单个用户限制为 32 核 (32 * 100%)
SINGLE_LIMIT="3200%"
# ----------------

echo "正在应用 CPU 限制策略..."
echo "目标：普通用户限制 [32核], 管理员 [无限制]"

# 1. 获取所有 UID >= 1000 的真实用户
for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
    
    # 获取用户 UID
    uid=$(id -u "$user")

    # 2. 检查是否是管理员 (在 sudo 或 wheel 组)
    if groups "$user" | grep -qE "(sudo|wheel)"; then
        echo "✅ 用户 [$user] (UID:$uid) 是管理员，跳过限制。"
        
        # 可选：如果管理员之前被限制过，可以取消限制（取消下面这行的注释）
        # sudo systemctl set-property user-$uid.slice CPUQuota=
    else
        echo "🔒 用户 [$user] (UID:$uid) 是普通用户，限制为 32 核..."
        
        # 3. 施加 3200% 的限制
        sudo systemctl set-property user-$uid.slice CPUQuota=${SINGLE_LIMIT}
    fi
done

echo "设置完成！"
echo "验证方法：cat /etc/systemd/system.control/user-$(id -u linzihan).slice.d/50-CPUQuota.conf
# This is a drop-in unit file extension, created via "systemctl set-property"
# or an equivalent operation. Do not edit.
[Slice]
CPUQuota=3200%