/*
Question: What are the most optimal skills to learn? 
(What is in high demand and a high-paying skill for data analyst role?)
Concentrates on offers in Poland with specified salaries.
*/


WITH skills_demand AS (
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS skill_count
    FROM 
        job_postings_fact
    INNER JOIN
        skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN
        skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_postings_fact.job_title_short = 'Data Analyst' 
        AND job_postings_fact.job_location LIKE '%Poland%' 
        AND salary_year_avg IS NOT NULL
    GROUP BY
        skills_dim.skill_id
), avg_salary_for_skills AS (
    SELECT
        skills_job_dim.skill_id,
        ROUND(AVG(job_postings_fact.salary_year_avg)) AS avg_salary
    FROM 
        job_postings_fact
    INNER JOIN
        skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN
        skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_location LIKE '%Poland%' 
        AND job_title_short = 'Data Analyst' 
        AND salary_year_avg IS NOT NULL
    GROUP BY
        skills_job_dim.skill_id
)

SELECT 
    skills_demand.*,
    avg_salary_for_skills.avg_salary
FROM 
    skills_demand
INNER JOIN
    avg_salary_for_skills
ON skills_demand.skill_id = avg_salary_for_skills.skill_id
WHERE 
    skill_count > 5
ORDER BY
    skill_count DESC,
    avg_salary DESC;



