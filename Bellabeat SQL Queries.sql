use bellabeat_data;

-- =============================================
-- Query 1: Average Steps Per Day
-- =============================================
select
round(avg(TotalSteps),0) as AvgSteps,
round(avg(Calories), 0) as AvgCalories,
round(avg(WornMinutes), 0) as AvgWornMinutes
from dailyactivity_merged;

-- =============================================
-- Qury 2: Most Active Users
-- =============================================
Select
Id,
round(avg(TotalSteps),0) as AvgSteps,
round(avg(Calories), 0) as AvgCalories,
count(*) as TotalDays
from dailyactivity_merged
group by Id
order by AvgSteps desc;

-- =============================================
-- Query 3: Activity Level Analysis
-- =============================================

SELECT
    DataQualityFlag,
    FullDayTracked,
    COUNT(*) AS TotalDays,
    ROUND(AVG(TotalSteps), 0) AS AvgSteps,
    ROUND(AVG(Calories), 0) AS AvgCalories
FROM dailyactivity_merged
GROUP BY DataQualityFlag, FullDayTracked
ORDER BY AvgSteps DESC;

-- =============================================
-- Query 4: Sleep Quality Analysis
-- =============================================

SELECT
    SleepQuality,
    COUNT(*) AS TotalNights,
    ROUND(AVG(TotalMinutesAsleep), 0) AS AvgMinutesAsleep,
    ROUND(AVG(TotalTimeInBed), 0) AS AvgTimeInBed,
    ROUND(AVG(SleepEfficiency), 2) AS AvgEfficiency
FROM sleepday_merged
GROUP BY SleepQuality
ORDER BY AvgEfficiency DESC;

-- =============================================
-- Query 5: Most Active Hours of Day
-- =============================================

SELECT
    Hour,
    ROUND(AVG(StepTotal), 0) AS AvgSteps,
    SUM(StepTotal) AS TotalSteps,
    COUNT(*) AS TotalRecords
FROM hourlysteps_merged
GROUP BY Hour
ORDER BY Hour ASC;

-- =============================================
-- Query 6: Steps vs Calories Relationship
-- =============================================

SELECT
    CASE
        WHEN TotalSteps < 5000 THEN '1. Sedentary (0-5000)'
        WHEN TotalSteps < 10000 THEN '2. Low Active (5000-10000)'
        WHEN TotalSteps < 15000 THEN '3. Active (10000-15000)'
        ELSE '4. Very Active (15000+)'
    END AS ActivityLevel,
    COUNT(*) AS TotalDays,
    ROUND(AVG(Calories), 0) AS AvgCalories,
    ROUND(AVG(TotalSteps), 0) AS AvgSteps
FROM dailyactivity_merged
GROUP BY ActivityLevel
ORDER BY ActivityLevel;

-- =============================================
-- Query 7: Weekly Activity Pattern
-- =============================================
SELECT
    DAYNAME(STR_TO_DATE(ActivityDate, '%d-%m-%Y')) AS DayOfWeek,
    ROUND(AVG(TotalSteps), 0) AS AvgSteps,
    ROUND(AVG(Calories), 0) AS AvgCalories,
    COUNT(*) AS TotalRecords
FROM dailyactivity_merged
GROUP BY DayOfWeek
ORDER BY FIELD(DayOfWeek,
    'Monday','Tuesday','Wednesday',
    'Thursday','Friday','Saturday','Sunday');

-- =============================================
-- Query 8: Sleep vs Activity Relationship
-- =============================================
SELECT
    d.Id,
    ROUND(AVG(d.TotalSteps), 0) AS AvgSteps,
    ROUND(AVG(d.Calories), 0) AS AvgCalories,
    ROUND(AVG(s.TotalMinutesAsleep), 0) AS AvgMinutesAsleep,
    ROUND(AVG(s.SleepEfficiency), 2) AS AvgSleepEfficiency,
    s.SleepQuality
FROM dailyactivity_merged d
JOIN sleepday_merged s ON d.Id = s.Id
GROUP BY d.Id, s.SleepQuality
ORDER BY AvgSteps DESC;

-- =============================================
-- Query 9: Hourly Peak Activity
-- =============================================
SELECT
    Hour,
    ROUND(AVG(StepTotal), 0) AS AvgSteps,
    SUM(StepTotal) AS TotalSteps,
    StepCategory
FROM hourlysteps_merged
GROUP BY Hour, StepCategory
ORDER BY AvgSteps DESC
LIMIT 5;

-- =============================================
-- Query 10: User Engagement Analysis
-- =============================================
SELECT
    Id,
    COUNT(*) AS TotalDays,
    ROUND(AVG(WornMinutes), 0) AS AvgWornMinutes,
    ROUND(AVG(WornMinutes)/1440 * 100, 1) AS AvgWornPercent,
    SUM(CASE WHEN FullDayTracked = 'Yes' THEN 1 ELSE 0 END) AS FullDayCount,
    SUM(CASE WHEN DataQualityFlag = 'Low - Zero Steps/Calories' 
        THEN 1 ELSE 0 END) AS LowQualityDays
FROM dailyactivity_merged
GROUP BY Id
ORDER BY AvgWornPercent DESC;

-- =============================================
-- Query 11: Sleep Duration Analysis
-- =============================================
SELECT
    CASE
        WHEN TotalMinutesAsleep < 360 THEN '1. Under 6 hours'
        WHEN TotalMinutesAsleep < 420 THEN '2. 6-7 hours'
        WHEN TotalMinutesAsleep < 480 THEN '3. 7-8 hours'
        ELSE '4. Over 8 hours'
    END AS SleepDuration,
    COUNT(*) AS TotalNights,
    ROUND(AVG(SleepEfficiency), 2) AS AvgEfficiency,
    ROUND(AVG(TotalMinutesAsleep)/60, 1) AS AvgHoursAsleep
FROM sleepday_merged
GROUP BY SleepDuration
ORDER BY SleepDuration;

-- =============================================
-- Query 12: Complete User Profile
-- =============================================
SELECT
    d.Id,
    ROUND(AVG(d.TotalSteps), 0) AS AvgDailySteps,
    ROUND(AVG(d.Calories), 0) AS AvgDailyCalories,
    ROUND(AVG(d.VeryActiveMinutes), 0) AS AvgVeryActiveMin,
    ROUND(AVG(d.SedentaryMinutes), 0) AS AvgSedentaryMin,
    ROUND(AVG(s.TotalMinutesAsleep)/60, 1) AS AvgHoursAsleep,
    ROUND(AVG(s.SleepEfficiency), 2) AS AvgSleepEfficiency,
    COUNT(DISTINCT d.ActivityDate) AS DaysTracked
FROM dailyactivity_merged d
LEFT JOIN sleepday_merged s ON d.Id = s.Id
GROUP BY d.Id
ORDER BY AvgDailySteps DESC;
