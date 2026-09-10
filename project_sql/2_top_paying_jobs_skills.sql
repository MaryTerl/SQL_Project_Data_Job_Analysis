/*
Question: What skills are required for the top-paying data analyst jobs?
- Use the top 10 highest-paying Data Analyst jobs from the first query.
- Add the specific skills required for these roles.
*/

WITH top_10_jobs AS (
    SELECT 
        job_id,
        job_title,
        company_dim.name AS company_name,
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
    LIMIT 10
)
SELECT
    top_10_jobs.*,  -- .* gives all data from a specified table
    skills_dim.skills AS skill
FROM 
    top_10_jobs
INNER JOIN
    skills_job_dim
ON top_10_jobs.job_id = skills_job_dim.job_id
INNER JOIN
    skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY 
    salary_year_avg DESC;


