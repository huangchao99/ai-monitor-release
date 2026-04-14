# 安装说明

## 1. 基础环境

以下运行时需要预先安装在目标机：

- RKNN Runtime / MPP / RGA
- ZLMediaKit（含已验证的 `MediaServer` 与 `config.ini`）
- `ffmpeg-rk`，建议安装到 `/opt/ffmpeg-rk`
- `jemalloc`
- `python3` 与 `python3-venv`
- `sqlite3`
- `nginx` 或 `caddy`

## 2. 安装步骤

1. 执行 `scripts/package-release.sh <version>` 生成发布包。
2. 将发布包目录或压缩包复制到目标机。
3. 在目标机执行 `scripts/install.sh`。
4. `install.sh` 会在目标机上创建 `python/venv` 并使用 `python/wheels` 离线安装依赖。
5. 首次部署执行 `scripts/init-db.sh`。
6. 确认 `/etc/ai-monitor/zlm.env` 指向基础环境中已安装的 ZLMediaKit。
7. 复制 `systemd/*.service` 到 `/etc/systemd/system/`。
8. 将 `nginx/ai-monitor.conf.example` 落到 Nginx 站点目录并启用。
9. 执行 `systemctl daemon-reload` 后按顺序启动服务。

## 3. 现场配置

首次安装后编辑以下文件：

- `/etc/ai-monitor/backend.env`
- `/etc/ai-monitor/python.env`
- `/etc/ai-monitor/infer.env`
- `/etc/ai-monitor/zlm.env`
- `/etc/ai-monitor/infer/server.json`

说明：

- `/etc/ai-monitor/zlm.env` 只负责告诉 `systemd` 去哪里找到“基础环境里已安装的 ZLMediaKit”
- ZLMediaKit 的 `config.ini` 不再由应用发布包提供

## 4. Python 发布说明

发布包默认不再直接复用开发机里的 `venv` 作为正式交付物。

当前推荐方式：

- 开发机打包时生成 `python/wheels/`
- 目标机安装时创建自己的 `python/venv/`
- 使用离线 wheels 安装依赖

这样可以避免把开发机 `venv` 中写死的绝对路径和 shebang 带到目标机。
