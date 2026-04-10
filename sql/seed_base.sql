INSERT OR IGNORE INTO system_settings (key, value) VALUES
    ('voice_alarm_enabled', '0'),
    ('voice_device_ip', ''),
    ('voice_device_user', ''),
    ('voice_device_pass', ''),
    ('alarm_upload_enabled', '0'),
    ('alarm_upload_url', ''),
    ('alarm_upload_device_id', ''),
    ('navigation_speed_threshold_knots', '0.5'),
    ('navigation_check_interval_sec', '30'),
    ('position_provider_type', 'serial_modbus');

INSERT OR IGNORE INTO position_runtime_status (
    id, provider_type, source, location_valid, position_status, navigation_state,
    latitude, latitude_dir, longitude, longitude_dir,
    speed_knots, speed_kmh, course, utc_time, beijing_time, error_message
) VALUES (
    1, '', '', 0, '', 'unknown',
    0, '', 0, '',
    0, 0, 0, '', '', ''
);

INSERT OR IGNORE INTO algorithms (algo_key, algo_name, category, upload_recog_type, param_definition) VALUES
    ('no_person', '离岗', '行为分析', 'rylg', '[{"key":"confidence","label":"置信度阈值","type":"number","default":0.35,"min":0.1,"max":1.0,"step":0.05},{"key":"duration","label":"持续时间(秒)","type":"number","default":120,"min":1,"max":600,"step":1},{"key":"skip_frame","label":"跳帧数","type":"number","default":10,"min":1,"max":30,"step":1}]'),
    ('eye_close', '闭眼', '行为分析', 'by', '[{"key":"duration","label":"持续时间(秒)","type":"number","default":30,"min":1,"max":300,"step":1},{"key":"ear_threshold","label":"EAR阈值","type":"number","default":0.22,"min":0.05,"max":0.4,"step":0.01}]'),
    ('yawning', '打哈欠', '行为分析', 'dhq', '[{"key":"yawn_count","label":"哈欠次数","type":"number","default":3,"min":1,"max":10,"step":1},{"key":"yawn_duration","label":"统计窗口(秒)","type":"number","default":180,"min":30,"max":600,"step":1}]'),
    ('eat_banana', '吃香蕉', '行为分析', '', '[{"key":"confidence","label":"置信度阈值","type":"number","default":0.35,"min":0.1,"max":1.0,"step":0.05},{"key":"duration","label":"持续时间(秒)","type":"number","default":30,"min":1,"max":300,"step":1}]'),
    ('no_hardhat', '未戴安全帽', 'PPE', 'wcaqm', '[]'),
    ('no_mask', '未戴口罩', 'PPE', 'Driver-NoMask', '[]'),
    ('no_safety_vest', '未穿救生衣', 'PPE', 'unwear_lifejacket', '[]'),
    ('call', '打电话', '行为分析', 'call_phone', '[]'),
    ('phone', '玩手机', '行为分析', 'play_phone', '[]'),
    ('smoke', '吸烟', '行为分析', 'xy', '[]');
