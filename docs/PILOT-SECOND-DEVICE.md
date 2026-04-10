# 第二台设备演练清单

本文件用于完成“参考机构建，第二台同类设备安装/升级/回滚演练”。

## 安装演练

- 校验基础依赖：`ffmpeg-rk`、RKNN Runtime、RGA、`jemalloc`、`sqlite3`、`nginx`
- 执行 `scripts/install.sh`
- 执行 `scripts/init-db.sh`
- 安装并启动 `systemd` 服务
- 配置 Nginx 站点
- 执行 `scripts/health-check.sh`

## 功能验收

- 前端页面可访问
- 摄像头可新增并启动推流
- 任务可启动
- Python 服务可收到推理结果
- 告警能落库并生成截图
- 语音报警能触发
- 报警上传可成功

## 升级演练

- 在已运行旧版本的设备上执行 `scripts/upgrade.sh`
- 验证 `/opt/ai-monitor/current` 已切换
- 验证现场数据库与截图目录未被覆盖

## 回滚演练

- 执行 `scripts/rollback.sh <old-version>`
- 验证服务恢复
- 必要时恢复数据库备份

## 演练记录

- 设备型号：
- OS / 内核：
- 发布版本：
- 结果：
- 遗留问题：
