PRAGMA foreign_keys = ON;

INSERT OR IGNORE INTO algorithms (
    algo_key, algo_name, category, upload_recog_type, param_definition
) VALUES
    (
        'eye_close_yolo',
        '闭眼YOLO版',
        '行为分析',
        'by',
        '[{"key":"duration","label":"持续闭眼时间(秒)","type":"number","default":10,"min":1,"max":30,"step":1},{"key":"skip_frame","label":"跳帧数","type":"number","default":5,"min":1,"max":30,"step":1}]'
    ),
    (
        'yawning_yolo',
        '打哈欠YOLO版',
        '行为分析',
        'dhq',
        '[{"key":"yawn_duration","label":"判定时间窗口(秒)","type":"number","default":180,"min":30,"max":600,"step":10},{"key":"yawn_count","label":"哈欠次数阈值","type":"number","default":3,"min":1,"max":20,"step":1},{"key":"skip_frame","label":"跳帧数","type":"number","default":1,"min":1,"max":30,"step":1}]'
    );

INSERT OR IGNORE INTO algo_model_map (algo_id, model_id)
SELECT a.id, m.id
FROM algorithms a
JOIN models m ON m.model_path = '/home/hzhy/models/fatigue_0415-rk3576.rknn'
WHERE a.algo_key = 'eye_close_yolo';

INSERT OR IGNORE INTO algo_model_map (algo_id, model_id)
SELECT a.id, m.id
FROM algorithms a
JOIN models m ON m.model_path = '/home/hzhy/models/fatigue_0415-rk3576.rknn'
WHERE a.algo_key = 'yawning_yolo';

INSERT OR IGNORE INTO voice_alarm_algo_map (algo_id, audio_file)
SELECT
    a.id,
    COALESCE(
        (
            SELECT v.audio_file
            FROM voice_alarm_algo_map v
            JOIN algorithms old_a ON old_a.id = v.algo_id
            WHERE old_a.algo_key = 'eye_close'
            LIMIT 1
        ),
        'by'
    )
FROM algorithms a
WHERE a.algo_key = 'eye_close_yolo';

INSERT OR IGNORE INTO voice_alarm_algo_map (algo_id, audio_file)
SELECT
    a.id,
    COALESCE(
        (
            SELECT v.audio_file
            FROM voice_alarm_algo_map v
            JOIN algorithms old_a ON old_a.id = v.algo_id
            WHERE old_a.algo_key = 'yawning'
            LIMIT 1
        ),
        'dhq'
    )
FROM algorithms a
WHERE a.algo_key = 'yawning_yolo';
