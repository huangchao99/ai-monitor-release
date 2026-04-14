PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

CREATE TABLE IF NOT EXISTS cameras (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    rtsp_url TEXT NOT NULL,
    location TEXT,
    status INTEGER DEFAULT 1 CHECK(status IN (0,1))
);

CREATE TABLE IF NOT EXISTS algorithms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    algo_key TEXT UNIQUE,
    algo_name TEXT NOT NULL,
    category TEXT,
    param_definition TEXT,
    upload_recog_type TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_name TEXT NOT NULL,
    camera_id INTEGER NOT NULL,
    alarm_device_id TEXT,
    status INTEGER DEFAULT 0 CHECK(status IN (0,1,2)),
    error_msg TEXT,
    remark TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (camera_id) REFERENCES cameras(id)
);

CREATE TABLE IF NOT EXISTS task_algo_details (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER,
    algo_id INTEGER,
    roi_config TEXT,
    algo_params TEXT,
    alarm_config TEXT,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (algo_id) REFERENCES algorithms(id),
    UNIQUE(task_id, algo_id)
);

CREATE TABLE IF NOT EXISTS alarms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER,
    algo_name TEXT,
    alarm_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    alarm_location TEXT,
    image_url TEXT,
    status INTEGER DEFAULT 0 CHECK(status IN (0,1)),
    alarm_details TEXT,
    task_name TEXT NOT NULL DEFAULT '',
    camera_name TEXT NOT NULL DEFAULT '',
    FOREIGN KEY (task_id) REFERENCES tasks(id)
);

CREATE INDEX IF NOT EXISTS idx_alarms_time ON alarms(alarm_time DESC);
CREATE INDEX IF NOT EXISTS idx_alarms_task_id ON alarms(task_id);
CREATE INDEX IF NOT EXISTS idx_alarms_status ON alarms(status);

CREATE TABLE IF NOT EXISTS zlm_streams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    camera_id INTEGER NOT NULL UNIQUE,
    app TEXT NOT NULL DEFAULT 'live',
    stream_key TEXT NOT NULL,
    proxy_key TEXT DEFAULT '',
    status INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (camera_id) REFERENCES cameras(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS models (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    model_name TEXT NOT NULL,
    model_path TEXT NOT NULL,
    labels_path TEXT,
    model_type TEXT DEFAULT 'yolov5',
    input_width INTEGER DEFAULT 640,
    input_height INTEGER DEFAULT 640,
    conf_threshold REAL DEFAULT 0.25,
    nms_threshold REAL DEFAULT 0.45
);

CREATE TABLE IF NOT EXISTS algo_model_map (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    algo_id INTEGER NOT NULL,
    model_id INTEGER,
    FOREIGN KEY (algo_id) REFERENCES algorithms(id),
    FOREIGN KEY (model_id) REFERENCES models(id)
);

CREATE TABLE IF NOT EXISTS system_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS voice_alarm_algo_map (
    algo_id INTEGER PRIMARY KEY,
    audio_file TEXT NOT NULL,
    FOREIGN KEY (algo_id) REFERENCES algorithms(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS alarm_upload_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alarm_id INTEGER NOT NULL UNIQUE,
    status INTEGER DEFAULT 0,
    retry_count INTEGER DEFAULT 0,
    last_error TEXT DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (alarm_id) REFERENCES alarms(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS position_runtime_status (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    provider_type TEXT NOT NULL DEFAULT '',
    source TEXT NOT NULL DEFAULT '',
    location_valid INTEGER NOT NULL DEFAULT 0,
    position_status TEXT NOT NULL DEFAULT '',
    navigation_state TEXT NOT NULL DEFAULT 'unknown',
    latitude REAL NOT NULL DEFAULT 0,
    latitude_dir TEXT NOT NULL DEFAULT '',
    longitude REAL NOT NULL DEFAULT 0,
    longitude_dir TEXT NOT NULL DEFAULT '',
    speed_knots REAL NOT NULL DEFAULT 0,
    speed_kmh REAL NOT NULL DEFAULT 0,
    course REAL NOT NULL DEFAULT 0,
    utc_time TEXT NOT NULL DEFAULT '',
    beijing_time TEXT NOT NULL DEFAULT '',
    error_message TEXT NOT NULL DEFAULT '',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
