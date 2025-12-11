SELECT * FROM nyc_restaurants.inspections;

-- Total Inspections by Borough 
SELECT COUNT(camis) AS inspection_count, boro
FROM inspections
GROUP BY boro
ORDER BY inspection_count DESC;

-- Distribution of Grades (A, B, C)
SELECT imputed_grade, COUNT(imputed_grade) AS count
FROM inspections
GROUP BY imputed_grade
ORDER BY 1;

SELECT imputed_grade, boro, 
COUNT(imputed_grade) AS count
FROM inspections
GROUP BY imputed_grade, boro
ORDER BY boro, imputed_grade;

-- Most Common Inspection Types
SELECT inspection_type, COUNT(inspection_type) AS count
FROM inspections
GROUP BY inspection_type
ORDER BY count DESC LIMIT 5;

-- Top 10 Most Frequent Violations
SELECT violation_description, COUNT(violation_description) AS count
FROM inspections
GROUP BY violation_description
ORDER BY count DESC LIMIT 10;

-- Top 3 Most Frequent Violations per Borough
WITH boro_rankings AS
(SELECT boro, violation_description, COUNT(violation_description) AS count,
DENSE_RANK() OVER(PARTITION BY boro ORDER BY COUNT(violation_description) DESC) AS ranking
FROM inspections
GROUP BY boro, violation_description)
SELECT boro, violation_description, count, ranking
FROM boro_rankings
WHERE ranking <= 3;

-- Critical vs. Not Critical 
SELECT violation_description, COUNT(violation_description) AS count
FROM inspections
WHERE critical_flag = 'critical'
GROUP BY violation_description
ORDER BY count DESC LIMIT 10;

SELECT violation_description, COUNT(violation_description) AS count
FROM inspections
WHERE critical_flag = 'not critical'
GROUP BY violation_description
ORDER BY count DESC LIMIT 10;

SELECT SUM(CASE WHEN critical_flag = 'critical' THEN 1 ELSE 0 END) AS critical_count,
SUM(CASE WHEN critical_flag = 'not critical' THEN 1 ELSE 0 END) AS not_critical_count
FROM inspections;

-- Boroughs with highest rate of critical violations
SELECT boro, 
CONCAT(ROUND(SUM(CASE WHEN critical_flag = 'critical' THEN 1 ELSE 0 END) / COUNT(critical_flag) * 100, 2), '%') AS critical_rate
FROM inspections
GROUP BY boro
ORDER BY critical_rate DESC;

-- Grades by Cuisine Type
SELECT cuisine_clean, 
SUM(CASE WHEN imputed_grade = 'A' THEN 1 ELSE 0 END) AS sum_A,
SUM(CASE WHEN imputed_grade = 'B' THEN 1 ELSE 0 END) AS sum_B,
SUM(CASE WHEN imputed_grade = 'C' THEN 1 ELSE 0 END) AS sum_C
FROM inspections
WHERE cuisine_clean != 'Other'
GROUP BY cuisine_clean
ORDER BY sum_A DESC LIMIT 5;

WITH grade_totals AS
(SELECT cuisine_clean, 
COUNT(*) AS total_inspections,
SUM(CASE WHEN imputed_grade = 'A' THEN 1 ELSE 0 END) AS sum_A,
SUM(CASE WHEN imputed_grade = 'B' THEN 1 ELSE 0 END) AS sum_B,
SUM(CASE WHEN imputed_grade = 'C' THEN 1 ELSE 0 END) AS sum_C
FROM inspections
WHERE cuisine_clean != 'Other'
GROUP BY cuisine_clean)
SELECT cuisine_clean, total_inspections,
CONCAT(ROUND((sum_A / total_inspections) * 100, 2), '%') AS percent_A,
CONCAT(ROUND((sum_B / total_inspections) * 100, 2), '%') AS percent_B,
CONCAT(ROUND((sum_C / total_inspections) * 100, 2), '%') AS percent_C
FROM grade_totals
ORDER BY percent_A DESC;

# Rolling Average Scores by Month
WITH avg_scores AS
(SELECT DATE_FORMAT(inspection_date, '%Y-%m') as month, 
ROUND(AVG(score), 2) AS avg_score
FROM inspections
GROUP BY DATE_FORMAT(inspection_date, '%Y-%m')
ORDER BY month)
SELECT month, avg_score,
ROUND(AVG(avg_score) OVER(ORDER BY month), 2) AS rolling_average
FROM avg_scores;
