#!/bin/bash

set -e

# ============ 颜色定义 ============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============ 默认值 ============
REMOTE_PATH="/software/positron"

# ============ 帮助函数 ============
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

必填参数:
  -p, --path <path>         压缩包完整路径
  -c, --commit-id <id>      Commit ID

可选参数:
  -r, --remote <path>       百度网盘中压缩包存放的路径 (默认: /software/positron，注意填写压缩包所在的文件夹名称)
  -h, --help                显示帮助

说明:
  如果压缩包已存在，将跳过下载步骤

示例:
  $0 -p /home/user/downloads/positron/app.tar.gz -c abc123def
  $0 -p /home/user/downloads/positron/app.tar.gz -c abc123def -r /backup/positron

EOF
    exit 1
}

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============ 参数 ============
ARCHIVE_PATH=""
COMMIT_ID=""

# ============ 解析参数 ============
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            ARCHIVE_PATH="$2"
            shift 2
            ;;
        -c|--commit-id)
            COMMIT_ID="$2"
            shift 2
            ;;
        -r|--remote)
            REMOTE_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "未知参数: $1"
            usage
            ;;
    esac
done

# ============ 参数验证 ============
if [[ -z "$ARCHIVE_PATH" ]]; then
    log_error "缺少必填参数: 压缩包路径 (-p)"
    usage
fi

if [[ -z "$COMMIT_ID" ]]; then
    log_error "缺少必填参数: COMMIT_ID (-c)"
    usage
fi

# ============ 定义路径 ============
TARGET_DIR="$HOME/.positron-server/bin/$COMMIT_ID"
FILENAME=$(basename "$ARCHIVE_PATH")

# ============ Step 1: 下载 ============
log_info "========== Step 1: 下载文件 =========="

if [[ -f "$ARCHIVE_PATH" ]]; then
    log_warn "压缩包已存在，跳过下载: $ARCHIVE_PATH"
else
    log_info "网盘路径: $REMOTE_PATH"
    log_info "开始下载..."
    BaiduPCS-Go d "$REMOTE_PATH"
    
    # 下载后再次检查
    if [[ ! -f "$ARCHIVE_PATH" ]]; then
        log_error "下载失败，压缩包不存在: $ARCHIVE_PATH"
        exit 1
    fi
    log_info "下载完成"
fi

# ============ Step 2: 准备目标目录 ============
log_info "========== Step 2: 准备目标目录 =========="
log_info "目标目录: $TARGET_DIR"

if [[ -d "$TARGET_DIR" ]]; then
    log_warn "目录已存在，清空内容..."
    rm -rf "${TARGET_DIR:?}"/*
else
    log_info "创建目录..."
    mkdir -p "$TARGET_DIR"
fi

# ============ Step 3: 移动压缩包 ============
log_info "========== Step 3: 移动压缩包 =========="
mv "$ARCHIVE_PATH" "$TARGET_DIR/"
log_info "已移动到: $TARGET_DIR/$FILENAME"

# ============ Step 4: 解压 ============
log_info "========== Step 4: 解压 =========="
cd "$TARGET_DIR"
tar -xzf "$FILENAME" --strip-components=1
log_info "解压完成"

# ============ Step 5: 清理 ============
log_info "========== Step 5: 清理 =========="
rm -f "$FILENAME"
log_info "已删除压缩包"

# ============ 完成 ============
echo ""
log_info "✅ 部署完成!"
log_info "安装路径: $TARGET_DIR"