#!/bin/bash

# --- 配置区域 ---
# 1. 内存限制：512GB (字节)
MEM_LIMIT=$((512 * 1024 * 1024 * 1024))
# 2. 进程数量限制：每个用户最多 10 个
MAX_PROC_PER_USER=10
# 3. 目标进程关键词
TARGET_REGEX="rsession|ipykernel|jupyter-lab|jupyter-notebook"

while true; do
    # =======================================================
    # 功能一：遍历所有目标进程，施加 CPU 和 内存 限制
    # =======================================================
    # 获取所有匹配的 PID
    for pid in $(pgrep -f "$TARGET_REGEX"); do
        
        # 排除脚本自身和 grep/cpulimit 进程
        if [[ "$pid" == "$$" ]] || [[ "$pid" == "$BASHPID" ]]; then continue; fi
        
        # 1. 检查并补充内存限制
        if grep -q "Max address space.*unlimited" /proc/$pid/limits 2>/dev/null; then
            # echo "设置内存限制 -> PID $pid"
            sudo prlimit --pid $pid --as=$MEM_LIMIT
        fi

        # 2. 检查并启动 CPU 限制
        if ! pgrep -f "cpulimit.*-p $pid" > /dev/null; then
            echo "新进程发现: $pid -> 启动 CPU/内存限制"
            sudo cpulimit -p $pid -l 3200 -b -z
        fi
    done

    # =======================================================
    # 功能二：检查每个用户的进程总数，超标则杀掉最新的
    # =======================================================
    # 1. 找出当前运行这些进程的所有用户名 (去重)
    # ps -eo user,cmd 列出用户和命令，grep 筛选关键词，awk 提取用户名，sort|uniq 去重
    active_users=$(ps -eo user,cmd | grep -E "$TARGET_REGEX" | grep -v "grep" | awk '{print $1}' | sort | uniq)

    for user in $active_users; do
        # 2. 统计该用户运行了多少个目标进程
        count=$(pgrep -u "$user" -f "$TARGET_REGEX" | wc -l)

        # 3. 如果超过限制
        if [ "$count" -gt "$MAX_PROC_PER_USER" ]; then
            echo "警告: 用户 $user 运行了 $count 个计算进程 (上限 $MAX_PROC_PER_USER)"
            
            # 找出该用户“最新”启动的一个进程 (-n 参数表示 newest)
            newest_pid=$(pgrep -u "$user" -f "$TARGET_REGEX" -n)
            
            if [ -n "$newest_pid" ]; then
                echo "--> 杀掉超出限额的最新进程: $newest_pid"
                sudo kill -9 "$newest_pid"
            fi
        fi
    done

    sleep 3
done