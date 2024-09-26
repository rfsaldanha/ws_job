-- Sensor Type: 504
-- Manufacturer: 
-- Data Structure Type: 15
-- Data Structure Description: WeatherLink Live Health Record
CREATE TABLE estacoes.station_195669_sensor_772002
(
    lsid integer,
    sensor_type integer,
    battery_voltage integer,   -- millivolts
    wifi_rssi integer,         -- received signal strength indicator
    rapid_records_sent bigint, -- none
    network_error integer,     -- none
    ip_v4_address text,        -- none
    ip_v4_gateway text,        -- none
    bluetooth_version bigint,  -- none
    bgn text,                  -- none
    firmware_version bigint,   -- none
    tz_offset integer,
    local_api_queries bigint,  -- none
    rx_bytes bigint,           -- none
    health_version integer,    -- none
    radio_version bigint,      -- none
    ip_address_type integer,   -- 1 = Dynamic; 2 = Secondary; 3 = Public
    link_uptime bigint,        -- seconds
    input_voltage integer,     -- millivolts
    tx_bytes bigint,           -- none
    ip_v4_netmask text,        -- none
    rapid_seconds_sent bigint,
    uptime bigint,             -- seconds
    touchpad_wakeups integer,  -- none
    ip_v4_addrress text,       -- none
    bootloader_version bigint, -- none
    espressif_version bigint,  -- none
    dns_type_used integer,     -- 1 = Primary, 2 = Secondary; 3 = Public
    network_type integer,      -- 1 = WiFi; 2 = Ethernet
    ts timestamp
);


-- Sensor Type: 242
-- Manufacturer: Davis Instruments
-- Data Structure Type: 12
-- Data Structure Description: WeatherLink Live non-ISS Current Conditions Record
CREATE TABLE estacoes.station_195669_sensor_772003
(
    lsid integer,
    sensor_type integer,
    bar_absolute float8,  -- inches of mercury
    tz_offset integer,
    bar_sea_level float8, -- inches of mercury
    bar_offset float8,    -- inches of mercury
    bar_trend float8,     -- inches of mercury
    ts timestamp
);

-- Sensor Type: 243
-- Manufacturer: Davis Instruments
-- Data Structure Type: 12
-- Data Structure Description: WeatherLink Live non-ISS Current Conditions Record
CREATE TABLE estacoes.station_195669_sensor_772004
(
    lsid integer,
    sensor_type integer,
    temp_in float8,       -- degrees Fahrenheit
    tz_offset integer,
    heat_index_in float8, -- degrees Fahrenheit
    dew_point_in float8,  -- degrees Fahrenheit
    ts timestamp,
    hum_in float8         -- percent relative humidity
);

-- Sensor Type: 45
-- Manufacturer: Davis Instruments
-- Data Structure Type: 10
-- Data Structure Description: WeatherLink Live ISS Current Conditions Record
CREATE TABLE estacoes.station_195669_sensor_772005
(
    lsid integer,
    sensor_type integer,
    rx_state integer,                         -- configured receiver state at end of interval: 0 = synched and receiving; 1 = rescan; 2 = lost
    wind_speed_hi_last_2_min float8,          -- miles per hour
    hum float8,                               -- percent relative humidity
    wind_dir_at_hi_speed_last_10_min integer, -- degrees
    wind_chill float8,                        -- degrees Fahrenheit
    rain_rate_hi_last_15_min_clicks integer,  -- clicks
    thw_index float8,                         -- degrees Fahrenheit
    wind_dir_scalar_avg_last_10_min integer,  -- degrees
    rain_size integer,                        -- 1 = 0.01 inch; 2 = 0.2 mm; 3 = 0.1 mm; 4 = 0.001 inch
    uv_index float8,                          -- ultraviolet index
    wind_speed_last float8,                   -- miles per hour
    rainfall_last_60_min_clicks integer,      -- clicks 
    wet_bulb float8,                          -- degrees Fahrenheit
    rainfall_monthly_clicks integer,          -- clicks
    wind_speed_avg_last_10_min float8,        -- miles per hour
    wind_dir_at_hi_speed_last_2_min integer,  -- degrees
    rainfall_daily_in float8,                 -- inches
    wind_dir_last integer,                    -- degrees
    rainfall_daily_mm float8,                 -- milimeters
    rain_storm_last_clicks integer,           -- clicks
    tx_id float8,
    rain_storm_last_start_at timestamp,       -- seconds
    rain_rate_hi_clicks integer,              -- clicks
    rainfall_last_15_min_in float8,           -- clicks
    rainfall_daily_clicks integer,            -- clicks
    dew_point float8,                         -- degrees Fahrenheit
    rainfall_last_15_min_mm float8,           -- milimeters
    rain_rate_hi_in float8,                   -- inches
    rain_storm_clicks integer,                -- clicks
    rain_rate_hi_mm float8,                   -- milimeters
    rainfall_year_clicks integer,             -- clicks
    rain_storm_in float8,                     -- inches
    rain_storm_last_end_at timestamp,         -- seconds
    rain_storm_mm float8,                     -- milimeters
    wind_dir_scalar_avg_last_2_min integer,   -- degrees
    heat_index float8,                        -- degrees Fahrenheit
    rainfall_last_24_hr_in float8,            -- inches
    rainfall_last_60_min_mm float8,           -- milimeters
    trans_battery_flag integer,               -- 0 = battery ok; 1 = battery low
    rainfall_last_60_min_in float8,           -- inches
    rain_storm_start_time timestamp,          -- seconds
    rainfall_last_24_hr_mm float8,            -- milimeters
    rainfall_year_in float8,                  -- inches
    wind_speed_hi_last_10_min float8,         -- miles per hour
    rainfall_last_15_min_clicks integer,      -- clicks
    rainfall_year_mm float8,                  -- milimeters
    wind_dir_scalar_avg_last_1_min integer,   -- degrees
    temp float8,                              -- degrees Fahrenheit
    wind_speed_avg_last_2_min float8,         -- miles per hour
    solar_rad integer,                        -- watts per square meter
    rainfall_monthly_mm float8,               -- milimiters
    rain_storm_last_mm float8,                -- milimeters
    wind_speed_avg_last_1_min float8,         -- miles per hour
    thsw_index float8,                        -- degrees Fahrenheit
    rainfall_monthly_in float8,               -- inches
    rain_rate_last_mm float8,                 -- millimeters
    rain_rate_last_clicks integer,            -- clicks
    rainfall_last_24_hr_clicks integer,       -- clicks
    rain_storm_last_in float8,                -- inches
    rain_rate_last_in float8,                 -- inches
    rain_rate_hi_last_15_min_mm float8,       -- milimeters
    rain_rate_hi_last_15_min_in float8,       -- inches
    tz_offset integer,
    ts timestamp
);
