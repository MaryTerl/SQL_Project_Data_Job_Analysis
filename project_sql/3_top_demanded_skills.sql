/*
Question: What are the most in-demand skills for data analyst?
- Join job postings to inner join table.
- Identify the top 5 in-demand skills for a data analyst in Poland.
- Focus on all job postings.
*/



SELECT 
    skills,
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
    job_postings_fact.job_title_short = 'Data Analyst' AND
    job_postings_fact.job_location LIKE '%Poland%'
GROUP BY
    skills
ORDER BY
    skill_count DESC
LIMIT 5;


/* Results
[
  {
    "skills": "sql",
    "skill_count": "1415"
  },
  {
    "skills": "excel",
    "skill_count": "1095"
  },
  {
    "skills": "python",
    "skill_count": "857"
  },
  {
    "skills": "tableau",
    "skill_count": "619"
  },
  {
    "skills": "power bi",
    "skill_count": "594"
  }
]
*/
