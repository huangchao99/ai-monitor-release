# systemd 模板说明

发布包中的服务单元默认读取 `/etc/ai-monitor/*.env`。

其中 `zlmediakit.service` 只是一份控制模板：

- `zlm.env` 应指向基础环境中已安装的 `MediaServer`
- ZLMediaKit 本体与 `config.ini` 不由应用发布包提供

建议安装顺序：

1. `zlmediakit.service`
2. `infer-server.service`
3. `ai-monitor-python.service`
4. `ai-monitor-backend.service`

Nginx 使用系统自带 `nginx.service`，站点配置参考 `../nginx/ai-monitor.conf.example`。
