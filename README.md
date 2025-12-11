# NYC Restaurant Inspection Analysis 

## Project Overview
This project analyzes 10+ years of inspection data from the NYC Department of Health to understand hygiene trends across different cuisines and boroughs.

**Key Questions Asked:**
* Which boroughs have the highest rate of critical violations?
* WHat are the most frequent violations?
* Which cuisines are statistically the safest to eat at?

## The Code
* **[Data Cleaning (Python)](./1_Data_Cleaning_Pipeline.ipynb):**
  * **Feature Engineering:** Imputed missing `GRADE` values based on official NYC score ranges (0-13=A, 14-27=B, 28+=C) to recover ~15,000 ungraded inspections for analysis.
  * **Categorical Reduction:** Reduced cuisine cardinality from 89 to 16 categories using a "Top 15 + Other" strategy and merging overlapping groups (e.g., "Asian Fusion" → "Chinese").
  * **Data Standardization:** Normalized string formatting, sanitized zip codes, and handled missing data strategically (preserving perfect inspections vs. dropping administrative placeholders).
  * **ETL Pipeline:** Built a secure SQLAlchemy connection to migrate the final processed dataset directly into a local MySQL database.
    
* **[Data Analysis (SQL)](./2_SQL_Analysis_Queries.sql):**
  * **Window Functions & Ranking:** Used `DENSE_RANK()` to partition data by borough and identify the Top 3 specific violations for each region.
  * **Complex Aggregation (CTEs):** Constructed Common Table Expressions to normalize inspection counts and calculate the "Success Rate" (percentage of 'A' grades) for each cuisine type.
  * **Time-Series Analysis:** tracked hygiene trends over time by calculating monthly average scores and cumulative rolling averages.
  * **Risk Analysis:** Quantified public health risks by calculating the ratio of "Critical" vs. "Non-Critical" flags per borough.

## Key Findings
* Coffee/Tea restaurants had the highest percentage of A grades with 49.88% and 18,901 total inspections.
* Chinese restaurants had the highest percentage of C grades with 42.75% and 32,436 total inspections.
* Queens was the borough with the highest rate of critical violations with 56.74%, although all 5 boroughs were very similar.
* The most common critical violation was an unclean food contact surface with 18,596 occurences.
