# Migration 目录说明

后续每次发布版本涉及数据库结构变更时，在本目录增加按时间排序的 SQL 文件，例如：

- `20260409_add_upload_recog_type.sql`
- `20260410_add_position_runtime_status.sql`

当前版本仍保留应用启动时的兼容性迁移逻辑，用于照顾旧数据库。
