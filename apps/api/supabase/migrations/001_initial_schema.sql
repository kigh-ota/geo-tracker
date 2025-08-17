-- デバイス情報テーブル
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID UNIQUE NOT NULL,
    model TEXT,
    os_version TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 位置情報テーブル
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_uuid UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    latitude NUMERIC(10, 7) NOT NULL CHECK (latitude >= -90 AND latitude <= 90),
    longitude NUMERIC(10, 7) NOT NULL CHECK (longitude >= -180 AND longitude <= 180),
    accuracy NUMERIC(10, 2) CHECK (accuracy >= 0),
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    altitude NUMERIC(10, 2),
    speed NUMERIC(10, 2) CHECK (speed >= 0),
    heading NUMERIC(5, 2) CHECK (heading >= 0 AND heading <= 360),
    battery_level NUMERIC(3, 2) CHECK (battery_level >= 0 AND battery_level <= 1),
    activity_type TEXT CHECK (activity_type IN ('unknown', 'stationary', 'walking', 'running', 'automotive', 'cycling')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックス作成
CREATE INDEX idx_locations_device_uuid ON locations(device_uuid);
CREATE INDEX idx_locations_timestamp ON locations(timestamp);
CREATE INDEX idx_devices_device_id ON devices(device_id);

-- 更新時刻自動更新のトリガー
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_devices_updated_at 
    BEFORE UPDATE ON devices 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();