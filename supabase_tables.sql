-- SQL script to create the necessary tables for HandleCrash app in Supabase
-- Execute this script in your Supabase SQL editor

-- Create vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    year TEXT NOT NULL,
    license_plate TEXT NOT NULL,
    color TEXT NOT NULL,
    vin TEXT NOT NULL UNIQUE,
    owner_name TEXT NOT NULL,
    owner_phone TEXT NOT NULL,
    insurance_company TEXT,
    insurance_policy TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    synced BOOLEAN DEFAULT FALSE
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_vehicles_vin ON vehicles(vin);
CREATE INDEX IF NOT EXISTS idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX IF NOT EXISTS idx_vehicles_synced ON vehicles(synced);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_vehicles_updated_at
    BEFORE UPDATE ON vehicles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users (adjust as needed for your auth setup)
-- For now, allowing all operations for authenticated users
CREATE POLICY "Enable all operations for authenticated users" ON vehicles
    FOR ALL USING (auth.role() = 'authenticated');

-- If you want to allow anonymous access (not recommended for production):
-- CREATE POLICY "Enable all operations for anonymous users" ON vehicles FOR ALL USING (true);
