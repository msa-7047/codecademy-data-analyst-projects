-- Codeflix fictional subscription dataset
CREATE TABLE subscriptions (
    id INTEGER PRIMARY KEY,
    subscription_start TEXT NOT NULL,
    subscription_end TEXT,
    segment INTEGER NOT NULL
);
