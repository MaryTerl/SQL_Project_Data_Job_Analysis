# Introduction
This project explores top-paying jobs, in-demand skills and where high demand meets high salary in data analytics.

SQL queries: [project_sql folder](/project_sql/).

### The questions I wanted to answer through my analysis were:
1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn as data analyst?

# Tools I Used
To successfully complete this project, it was essential to work with several key tools and technologies, including:
- **SQL**, which enables creating queries to interact with the database.
- **PostgreSQL**, a system used for building and managing the database.
- **Visual Studio Code**, the environment where SQL queries were written and executed.
- **Git & GitHub**, necessary for version control and sharing the project code.

# The Analysis

### 1.

```sql
SELECT 
    job_id,
    job_title,
    company_dim.name AS company_name,
    job_location,
    job_schedule_type,
    salary_year_avg    
FROM 
    job_postings_fact
LEFT JOIN company_dim
ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Analyst' AND 
    job_work_from_home = TRUE AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;
```

# What I Learned
Throughout this project, I not only improved my ability to use fundamental SQL operations such as GROUP BY, WHERE, and aggregate functions, but also learned how to build more advanced queries involving multiple JOIN operations, subqueries, and Common Table Expressions (CTEs). These techniques allowed me to analyze data in a more flexible, structured, and efficient way, Additionally, I gained experience in transforming analytical questions into SQL queries that deliver clear, actionable answers.

# Conclusions
1. **Top-Paying Data Analyst Jobs**: 
... 
