INSERT OR IGNORE INTO models (
    id, model_name, model_path, labels_path, model_type,
    input_width, input_height, conf_threshold, nms_threshold
) VALUES
    (1, 'YOLOv11official', '/opt/ai-monitor/current/models/yolo11official/yolo11n-rk3576.rknn', '/opt/ai-monitor/current/models/yolo11official/yolo11n-labels.txt', 'yolov11', 640, 640, 0.25, 0.45),
    (2, 'fatigue_detection', 'fatigue_detection', '', 'pipeline', 0, 0, 0.5, 0.0),
    (3, 'PPE-YOLOv8n', '/opt/ai-monitor/current/models/ppe-yolov8n_rknn_model/ppe-yolov8n-rk3576.rknn', '/opt/ai-monitor/current/models/ppe-yolov8n_rknn_model/ppe-yolov8n-rk3576.txt', 'yolov8', 640, 640, 0.25, 0.45),
    (8, 'phone-smoke-detect-0330', '/opt/ai-monitor/current/models/phone-cigarette-model/aimonitor_stage2_0330-rk3576-864.rknn', '/opt/ai-monitor/current/models/phone-cigarette-model/label.txt', 'yolov11', 864, 864, 0.25, 0.05),
    (9, 'yolov11-firesmoke0420', '/opt/ai-monitor/current/models/fire-smoke-model/firesmoke_0420-rk3576.rknn', '/opt/ai-monitor/current/models/fire-smoke-model/firesmoke-rk3576-label.txt', 'yolov11', 640, 640, 0.35, 0.45),
    (10, 'yolov11n-fatigue', '/opt/ai-monitor/current/models/fatigue/fatigue_0415-rk3576.rknn', '/opt/ai-monitor/current/models/fatigue/fatigue-label.txt', 'yolov11', 640, 640, 0.35, 0.45);

INSERT OR IGNORE INTO algorithms (
    id, algo_key, algo_name, category, param_definition, upload_recog_type
) VALUES
    (1, 'no_person', '离岗', '行为分析', '[{"key":"skip_frame","label":"跳帧频率","type":"number","default":10,"min":1,"max":100},{"key":"confidence","label":"置信度","type":"slider","default":0.35,"min":0,"max":1,"step":0.01},{"key":"duration","label":"离岗判定时长(秒)","type":"number","default":120,"min":10,"max":3600}]', 'rylg'),
    (5, 'eye_close', '闭眼', '行为分析', '[{"key":"ear_threshold","label":"EAR闭眼阈值","type":"number","default":0.22,"min":0.1,"max":0.5,"step":0.01},{"key":"duration","label":"持续闭眼时间(秒)","type":"number","default":10,"min":1,"max":30,"step":1},{"key":"skip_frame","label":"跳帧数","type":"number","default":5,"min":1,"max":30,"step":1}]', 'by'),
    (6, 'yawning', '打哈欠', '行为分析', '[{"key":"mar_threshold","label":"MAR打哈欠阈值","type":"number","default":0.5,"min":0.2,"max":2,"step":0.01},{"key":"yawn_duration","label":"判定时间窗口(秒)","type":"number","default":180,"min":30,"max":600,"step":10},{"key":"yawn_count","label":"哈欠次数阈值","type":"number","default":3,"min":1,"max":20,"step":1},{"key":"skip_frame","label":"跳帧数","type":"number","default":1,"min":1,"max":30,"step":1}]', 'dhq'),
    (7, 'no_hardhat', '未戴安全帽', '安全合规', '[{"key":"skip_frame","label":"跳帧频率","type":"number","default":5,"min":1,"max":100},{"key":"confidence","label":"置信度","type":"slider","default":0.35,"min":0,"max":1,"step":0.01},{"key":"duration","label":"持续检测时长(秒)","type":"number","default":10,"min":3,"max":600}]', 'wcaqm'),
    (8, 'no_mask', '未戴口罩', '安全合规', '[{"key":"skip_frame","label":"跳帧频率","type":"number","default":5,"min":1,"max":100},{"key":"confidence","label":"置信度","type":"slider","default":0.35,"min":0,"max":1,"step":0.01},{"key":"duration","label":"持续检测时长(秒)","type":"number","default":10,"min":3,"max":600}]', 'Driver-NoMask'),
    (9, 'no_safety_vest', '未穿救生衣', '安全合规', '[{"key":"skip_frame","label":"跳帧频率","type":"number","default":5,"min":1,"max":100},{"key":"confidence","label":"置信度","type":"slider","default":0.35,"min":0,"max":1,"step":0.01},{"key":"duration","label":"持续检测时长(秒)","type":"number","default":10,"min":3,"max":600}]', 'unwear_lifejacket'),
    (10, 'call', '打电话', '行为分析', '[{"key":"skip_frame","label":"跳帧频率","type":"number","default":5,"min":1,"max":100},{"key":"confidence","label":"置信度","type":"slider","default":0.35,"min":0,"max":1,"step":0.01},{"key":"duration","label":"持续检测时长(秒)","type":"number","default":30,"min":3,"max":600}]', 'call_phone'),
    (11, 'phone', '玩手机', '行为分析', '[{"key":"skip_frame","label":"跳帧频率","type":"number","default":5,"min":1,"max":100},{"key":"confidence","label":"置信度","type":"slider","default":0.35,"min":0,"max":1,"step":0.01},{"key":"duration","label":"持续检测时长(秒)","type":"number","default":30,"min":3,"max":600}]', 'play_phone'),
    (12, 'smoke', '抽烟', '行为分析', '[{"key":"skip_frame","label":"跳帧频率","type":"number","default":5,"min":1,"max":100},{"key":"confidence","label":"置信度","type":"slider","default":0.35,"min":0,"max":1,"step":0.01},{"key":"duration","label":"持续检测时长(秒)","type":"number","default":30,"min":3,"max":600}]', 'xy'),
    (14, 'fire_detect', '火焰检测', '消防检测', '[{"key":"skip_frame","label":"跳帧频率","type":"number","default":10,"min":1,"max":100,"step":1},{"key":"confidence","label":"置信度","type":"slider","default":0.7,"min":0.05,"max":1,"step":0.01},{"key":"duration","label":"持续检测时长(秒)","type":"number","default":5,"min":1,"max":60,"step":1}]', 'fire'),
    (15, 'smoke_detect', '烟雾检测', '消防检测', '[{"key":"skip_frame","label":"跳帧频率","type":"number","default":10,"min":1,"max":100,"step":1},{"key":"confidence","label":"置信度","type":"slider","default":0.8,"min":0.05,"max":1,"step":0.01},{"key":"duration","label":"持续检测时长(秒)","type":"number","default":10,"min":1,"max":60,"step":1}]', 'smoke'),
    (16, 'eye_close_yolo', '闭眼YOLO版', '行为分析', '[{"key":"duration","label":"持续闭眼时间(秒)","type":"number","default":10,"min":1,"max":30,"step":1},{"key":"skip_frame","label":"跳帧数","type":"number","default":5,"min":1,"max":30,"step":1}]', 'by'),
    (17, 'yawning_yolo', '打哈欠YOLO版', '行为分析', '[{"key":"yawn_duration","label":"判定时间窗口(秒)","type":"number","default":180,"min":30,"max":600,"step":10},{"key":"yawn_count","label":"哈欠次数阈值","type":"number","default":3,"min":1,"max":20,"step":1},{"key":"skip_frame","label":"跳帧数","type":"number","default":5,"min":1,"max":30,"step":1}]', 'dhq');

INSERT OR IGNORE INTO algo_model_map (id, algo_id, model_id) VALUES
    (12, 5, 2),
    (13, 6, 2),
    (14, 7, 3),
    (15, 8, 3),
    (16, 9, 3),
    (46, 11, 8),
    (47, 10, 8),
    (48, 12, 8),
    (51, 1, 8),
    (53, 15, 9),
    (54, 14, 9),
    (55, 16, 10),
    (57, 17, 10);

INSERT OR IGNORE INTO voice_alarm_algo_map (algo_id, audio_file) VALUES
    (1, 'rylg'),
    (5, 'by'),
    (6, 'dhq'),
    (7, 'wcaqm'),
    (9, 'unwear_lifejacket'),
    (10, 'call_phone'),
    (11, 'play_phone'),
    (12, 'xy'),
    (16, 'by'),
    (17, 'dhq');
