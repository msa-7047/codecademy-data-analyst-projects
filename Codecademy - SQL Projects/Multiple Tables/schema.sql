
-- Trips table
CREATE TABLE trips (
    id INTEGER,
    date TEXT,
    pickup TEXT,
    dropoff TEXT,
    rider_id INTEGER,
    car_id INTEGER,
    type TEXT,
    cost INTEGER
);

-- Riders table
CREATE TABLE riders (
    id INTEGER,
    first TEXT,
    last TEXT,
    username TEXT,
    rating INTEGER,
    total_trips INTEGER,
    referred INTEGER
);

-- Additional riders table
CREATE TABLE riders2 (
    id INTEGER,
    first TEXT,
    last TEXT,
    username TEXT,
    rating INTEGER,
    total_trips INTEGER,
    referred INTEGER
);

-- Cars table
CREATE TABLE cars (
    id INTEGER,
    model TEXT,
    OS TEXT,
    status TEXT,
    trips_completed INTEGER
);
