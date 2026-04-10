# AI Monitor Release Workspace

该目录用于生成和维护 AI Monitor 的版本化发布包。

约定：

- `config/` 保存环境变量与运行配置模板
- `scripts/` 保存构建、打包、安装、升级、回滚与健康检查脚本
- `systemd/` 保存服务单元模板
- `sql/` 保存数据库 schema、seed 与迁移脚本
- `manifest/` 保存版本号、构建元数据与校验信息
- `nginx/` 保存前端生产代理配置模板
- `docs/` 保存安装、升级与现场演练文档

文档入口：

- `docs/开发到发布到部署操作手册.md`
- `docs/INSTALL.md`
- `docs/UPGRADE.md`

推荐的运行时目录布局：

- 发布目录：`/opt/ai-monitor/releases/<version>/`
- 当前版本软链接：`/opt/ai-monitor/current`
- 现场配置：`/etc/ai-monitor/`
- 现场数据：`/var/lib/ai-monitor/`
