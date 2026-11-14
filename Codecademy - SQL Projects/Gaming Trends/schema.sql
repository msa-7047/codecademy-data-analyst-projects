DROP TABLE IF EXISTS chat;
DROP TABLE IF EXISTS stream;

CREATE TABLE stream (
    time DATETIME,
    device_id TEXT,
    login TEXT,
    channel TEXT,
    country TEXT,
    player TEXT,
    game TEXT,
    stream_format TEXT,
    subscriber TEXT
);

CREATE TABLE chat (
    time DATETIME,
    device_id TEXT,
    login TEXT,
    channel TEXT,
    country TEXT,
    player TEXT,
    game TEXT
);

CREATE INDEX idx_stream_device_id ON stream(device_id);
CREATE INDEX idx_chat_device_id ON chat(device_id);
