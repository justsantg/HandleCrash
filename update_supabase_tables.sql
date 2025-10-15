-- SQL script to update the vehicles table in Supabase to match the latest schema
-- Execute this script in your Supabase SQL editor

-- Add missing columns if they don't exist
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS insurance_company TEXT;
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS insurance_policy TEXT;
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS synced BOOLEAN DEFAULT FALSE;

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_vehicles_vin ON vehicles(vin);
CREATE INDEX IF NOT EXISTS idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX IF NOT EXISTS idx_vehicles_synced ON vehicles(synced);

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger if it doesn't exist
DROP TRIGGER IF EXISTS update_vehicles_updated_at ON vehicles;
CREATE TRIGGER update_vehicles_updated_at
    BEFORE UPDATE ON vehicles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security if not already
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable all operations for authenticated users" ON vehicles;

-- Create policy for authenticated users
CREATE POLICY "Enable all operations for authenticated users" ON vehicles
    FOR ALL USING (auth.role() = 'authenticated');
