/*
Question: What are the top skills based on salary? (best-paid skills)
What is an average salary associated with a skill?
- Look at the average salary associated with each skill for Data Analyst positions.
- Focuses on roles with specified salaries, regardless of location.
*/



SELECT
    skills,
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
    job_location LIKE '%Poland%' AND
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 10;


/* Results
[
  {
    "skills": "mongo",
    "avg_salary": "165000"
  },
  {
    "skills": "linux",
    "avg_salary": "165000"
  },
  {
    "skills": "aws",
    "avg_salary": "165000"
  },
  {
    "skills": "hadoop",
    "avg_salary": "133750"
  },
  {
    "skills": "nosql",
    "avg_salary": "131750"
  },
  {
    "skills": "sas",
    "avg_salary": "111175"
  },
  {
    "skills": "bigquery",
    "avg_salary": "111175"
  },
  {
    "skills": "jira",
    "avg_salary": "111175"
  },
  {
    "skills": "qlik",
    "avg_salary": "111175"
  },
  {
    "skills": "snowflake",
    "avg_salary": "111175"
  }
]
*/

