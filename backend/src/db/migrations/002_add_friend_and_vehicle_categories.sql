-- ==========================================================
-- Migration: 002_add_friend_and_vehicle_categories.sql
-- Description: Adds 'car' vehicle category and 'Book for a Friend' columns
-- Project: Bodaboda Express
-- Author: Eng. Likindy Ismail
-- ==========================================================

-- 1. Create or update vehicle_category enum
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vehicle_category') THEN
        CREATE TYPE vehicle_category AS ENUM ('bodaboda', 'bajaji', 'car');
    ELSE
        -- If already exists, ensure 'car' value is present
        BEGIN
            ALTER TYPE vehicle_category ADD VALUE IF NOT EXISTS 'car';
        EXCEPTION
            WHEN duplicate_object THEN null;
        END;
    END IF;
END $$;

-- 2. Alter passenger_rides table
ALTER TABLE passenger_rides 
    ADD COLUMN IF NOT EXISTS vehicle_type vehicle_category DEFAULT 'bodaboda',
    ADD COLUMN IF NOT EXISTS is_for_friend BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS friend_name VARCHAR(120),
    ADD COLUMN IF NOT EXISTS friend_phone VARCHAR(20);

-- 3. Create index for querying friend rides if needed
CREATE INDEX IF NOT EXISTS idx_passenger_rides_friend ON passenger_rides(is_for_friend) WHERE is_for_friend = true;
CREATE INDEX IF NOT EXISTS idx_passenger_rides_vehicle ON passenger_rides(vehicle_type);
