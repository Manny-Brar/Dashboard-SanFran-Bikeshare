SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

#Must set local_infile to 1 and make it a global variable
SET GLOBAL local_infile=1;

DROP SCHEMA IF EXISTS bikeshare;
CREATE SCHEMA bikeshare;
USE bikeshare;

DROP TABLE IF EXISTS bikesharedf;
CREATE  TABLE IF NOT EXISTS bikesharedf (
trip_id BIGINT,
duration_sec INT,
start_date TIMESTAMP,
start_station_name VARCHAR(20),
station_id INT,
end_date TIMESTAMP,
end_station_name VARCHAR(20),
end_station_id INT,
bike_number INT,
zip_code INT,
subscriber_type VARCHAR(20),
c_subscriber_type VARCHAR(20),
start_station_latittude DECIMAL(10,8),
start_station_longitude DECIMAL(11,8),
end_station_latitude DECIMAL(10,8),
end_station_longitude DECIMAL(11,8),
member_birth_year INT,
member_gender VARCHAR(10),
bike_share_for_all_trip VARCHAR(20),
start_station_geom VARCHAR(20),
end_station_geom VARCHAR(20));


truncate table bikesharedf;

# Load in the Accounts table, ignoring the header content. Need to set delimiter to ;
LOAD DATA LOCAL INFILE 'C:\\Users\\manny\\Downloads\\bikeshare_df.csv'
INTO TABLE bikesharedf
CHARACTER SET 'utf8'
fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n'
ignore 1 lines
;
##############################

SELECT * FROM bikesharedf ORDER BY start_date ;


#Count of station_id's
SELECT station_id, COUNT(station_id) AS trip_count FROM bikesharedf GROUP BY station_id ORDER BY trip_count DESC;

DROP TABLE IF EXISTS biketrip;
CREATE TABLE biketrip AS (
SELECT trip_id ,YEAR(start_date) AS ST_year, MONTHNAME(start_date) AS ST_month, DAY(start_date) AS ST_date, DAYNAME(start_date) AS ST_day, TIME(start_date) AS ST_time, duration_sec, station_id, end_station_id, bike_number, subscriber_type, start_station_latittude, start_station_longitude, end_station_latitude, end_station_longitude, (2019-member_birth_year ) AS member_age, member_gender
FROM bikesharedf
ORDER BY start_date);

DROP TABLE IF EXISTS trips;
CREATE TABLE trips AS(
SELECT *
       FROM biketrip
WHERE member_age != 2019);

DROP TABLE IF EXISTS day_df;
CREATE TABLE day_df AS(
SELECT ST_day, member_gender, member_age, COUNT(trip_id) AS trip_count
FROM trips
GROUP BY ST_day, member_gender, member_age
ORDER BY trip_count DESC);


DROP TABLE IF EXISTS day_duration;
CREATE TABLE day_duration AS(
SELECT ST_day, member_gender, member_age, SUM(duration_sec) AS trip_time
FROM trips
GROUP BY ST_day, member_gender, member_age
ORDER BY trip_time DESC);

SELECT *
FROM trips
;