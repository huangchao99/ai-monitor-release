# 安装说明

## 1. 基础环境

以下运行时需要预先安装在目标机：

- RKNN Runtime / MPP / RGA
- `ffmpeg-rk`，建议安装到 `/opt/ffmpeg-rk`
- `jemalloc`
- `sqlite3`
- `nginx` 或 `caddy`

## 2. 安装步骤

1. 执行 `scripts/package-release.sh <version>` 生成发布包。
2. 将发布包目录或压缩包复制到目标机。
3. 在目标机执行 `scripts/install.sh`。
4. 首次部署执行 `scripts/init-db.sh`。
5. 复制 `systemd/*.service` 到 `/etc/systemd/system/`。
6. 将 `nginx/ai-monitor.conf.example` 落到 Nginx 站点目录并启用。
7. 执行 `systemctl daemon-reload` 后按顺序启动服务。

## 3. 现场配置

首次安装后编辑以下文件：

- `/etc/ai-monitor/backend.env`
- `/etc/ai-monitor/python.env`
- `/etc/ai-monitor/infer.env`
- `/etc/ai-monitor/zlm.env`
- `/etc/ai-monitor/infer/server.json`
- `/etc/ai-monitor/zlm/config.ini`
