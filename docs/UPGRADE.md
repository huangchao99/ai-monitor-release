# 升级与回滚

## 升级

1. 将新版本发布包复制到目标机。
2. 运行 `scripts/upgrade.sh`。
3. 检查 `/var/lib/ai-monitor/backups/` 中是否生成数据库备份。
4. 检查 `scripts/health-check.sh` 输出。

## 回滚

1. 查看 `/opt/ai-monitor/releases/` 中的历史版本目录。
2. 运行 `scripts/rollback.sh <version>`。
3. 如有需要，恢复对应时点的数据库备份。

## 原则

- 发布目录与现场数据分离。
- 升级只切换 `/opt/ai-monitor/current`。
- 数据库、截图与现场配置默认不被新版本覆盖。
