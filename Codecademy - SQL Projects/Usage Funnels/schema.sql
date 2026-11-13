
CREATE TABLE survey (
    question TEXT,
    user_id TEXT,
    response TEXT
);

CREATE TABLE quiz (
    user_id TEXT,
    style TEXT,
    fit TEXT,
    shape TEXT,
    color TEXT
);

CREATE TABLE home_try_on (
    user_id TEXT,
    number_of_pairs TEXT,
    address TEXT
);

CREATE TABLE purchase (
    user_id TEXT,
    product_id INTEGER,
    style TEXT,
    model_name TEXT,
    color TEXT,
    price INTEGER
);
