# systemd 模板说明

发布包中的服务单元默认读取 `/etc/ai-monitor/*.env`。

建议安装顺序：

1. `zlmediakit.service`
2. `infer-server.service`
3. `ai-monitor-python.service`
4. `ai-monitor-backend.service`

Nginx 使用系统自带 `nginx.service`，站点配置参考 `../nginx/ai-monitor.conf.example`。
