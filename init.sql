CREATE TABLE IF NOT EXISTS conversations (
    id SERIAL PRIMARY KEY,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    topic TEXT,
    level INTEGER,
    chat_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
