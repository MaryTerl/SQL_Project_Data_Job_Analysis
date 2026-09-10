-- ------------------------------- ZADANIA ---------------------------------

SELECT job_posted_date
FROM job_postings_fact
LIMIT 10;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date::DATE AS date  -- poprzez ::DATE usuwamy czas i zostawiamy datę tylko w formacie 'yyyy-mm-dd'
FROM
    job_postings_fact;

-- zmiana strefy czasowej
SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date
FROM
    job_postings_fact
LIMIT 5;

-- EXTRACT wyciąga konkretne dane z daty np. tylko miesiąc
SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date,
    EXTRACT(MONTH FROM job_posted_date) AS date_month,
    EXTRACT(YEAR FROM job_posted_date) AS date_year
FROM
    job_postings_fact
LIMIT 5;



-- Pytanie: jak zmieniają się trendy zatrudnień w ciągu miesięcy?
SELECT
    COUNT(job_id) AS job_count,
    EXTRACT(MONTH FROM job_posted_date) AS month 
FROM  
    job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY 
    month
ORDER BY 
    job_count DESC;


-- Problem 1:
-- Znajdź średnie zarobki roczne i godzinowe dla ofert pracy dodanych po June 1, 2023 i pogrupuj wyniki według job schedule type.

SELECT
    job_schedule_type,
    AVG(salary_year_avg),
    AVG(salary_hour_avg)
FROM
    job_postings_fact
WHERE 
    job_posted_date::DATE > '2023-06-01'
GROUP BY 
    job_schedule_type;


-- Problem 2: TRUDNE
-- Policz oferty pracy dla każdego miesiąca, dostosuj wczesniej job_posted_date żeby była w America/New York' time zone,
-- a job_posted_date jest w 'UTC'. Pogrupuj i posortuj według miesięcy.

SELECT
    COUNT(job_id) AS job_count,
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month
FROM
    job_postings_fact
GROUP BY 
    month
ORDER BY 
    month;


-- Problem 3:
-- Znajdź firmy, które w ofertach pracy oferują health insurance i zostały dodane w drugim kwartale 2023.
-- Użyj EXTRACT żeby przefiltrować po kwartałach.

SELECT * FROM company_dim;

SELECT
    company_dim.name AS company
FROM
    job_postings_fact
LEFT JOIN 
    company_dim 
    ON job_postings_fact.company_id = company_dim.company_id
WHERE job_postings_fact.job_health_insurance = TRUE AND 
    EXTRACT(QUARTER FROM job_postings_fact.job_posted_date::DATE) = 2;


-- TWORZENIE TABELI Z INNEJ TABELI NA PODSTAWIE WARUNKÓW
-- Practice Problem 6: 
CREATE TABLE january_jobs AS
    SELECT * 
    FROM job_postings_fact 
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT * 
    FROM job_postings_fact 
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT * 
    FROM job_postings_fact 
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT
    job_posted_date
FROM
    march_jobs;


-- CASE zmienia wartości w kolumnach na podstawie zadanych warunków
-- Zadanie: mieszkam w Nowym Yorku i chcę zmienić wartości w kolumnie job_location
SELECT
    job_title_short,
    job_location,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact;


SELECT
    COUNT(job_id) AS num_oj_jobs,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY
    location_category;


-- Practice Problem 1:
-- Chcemy skategoryzować zarobki z ofert pracy, żeby sprawdzić że odpowiadaja wymaganemu zakresowi.
-- wstaw zarobki do różnych przedziałów,
-- zdefiniuj wysokie, standardowe i niskie zarobki własnymi warunkami,
-- patrz tylko na role Data Analyst,
-- uszereguj od najwyższych do najniższych.

SELECT
    salary_year_avg,
    CASE 
        WHEN salary_year_avg BETWEEN 85000 AND 110000 THEN 'Standard'
        WHEN salary_year_avg > 110000 THEN 'High'
        WHEN salary_year_avg < 85000 THEN 'Low'
    END AS salary_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC;



-- ----------------- SubQueries & CTEs -----------------
SELECT *
FROM ( -- SubQuery starts here
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;
-- SubQuery ends here


WITH january_jobs AS ( -- CTE definition starts here
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) -- CTE definition ends here
SELECT *
FROM january_jobs;


-- Używamy SubQuery żeby najpierw wewnątrz wydobyć id firm, których oferty pracy nie wymagają dyplomu.
-- Następnie obudowujemy to wyborem nazw firm tych firm, które znajdują sie w innej tabeli.
SELECT 
    company_id,
    name AS contact_name
FROM 
    company_dim
WHERE company_id IN ( -- SubQuery starts here
    SELECT
        company_id
    FROM 
        job_postings_fact
    WHERE 
        job_no_degree_mention = TRUE
);


-- Szukamy firm, które mają najwięcej ofert pracy:
-- - bierzemy całkowitą liczbę ofert per company_id (tabela job_postings_fact)
-- - zwracamy całkowitą liczbę ofert wraz z nazwą firmy

WITH company_job_count AS (
    SELECT 
        company_id,
        COUNT(job_id) AS number_of_jobs
    FROM 
        job_postings_fact
    GROUP BY 
        company_id
)
SELECT 
    company_dim.name,
    company_job_count.number_of_jobs
FROM
    company_dim
LEFT JOIN company_job_count
    ON company_dim.company_id = company_job_count.company_id
ORDER BY
    company_job_count.number_of_jobs DESC;


-- Problem 1:
-- Znajdź top 5 skills, które są najczęściej wspominane w ofertach pracy.
-- użyj SubQuery żeby znaleźć najczęściej występujące skill_id w tabeli skills_job_dim
-- połącz wyniki z tabelą skills_dim, aby uzyskać nazwy tych skillsów

SELECT * FROM skills_dim;

SELECT 
    skills_dim.skills,
    job_count.job_count_for_skill
FROM
    skills_dim
INNER JOIN (
    SELECT
        skill_id,
        COUNT(job_id) AS job_count_for_skill
    FROM
        skills_job_dim
    GROUP BY
        skill_id
) AS job_count
ON 
    skills_dim.skill_id = job_count.skill_id
ORDER BY
    job_count.job_count_for_skill DESC
LIMIT 5;


-- Problem 2:
-- Ustal kategorię wielkości (small<10, 10<medium<50, large>50) dla każdej z firm na podstawie tego, ile wystawiła ofert pracy.
-- - użyj SubQuery by wyliczyć całkowitą liczbę ofert per company
-- - zagreguj liczbę ofert dla każdej z firm przed klasyfikacją rozmiarową

SELECT
    company_dim.name,
    CASE
        WHEN job_count < 10 THEN 'Small'
        WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS size,
    company_job_count.job_count
FROM
    company_dim
LEFT JOIN (
    SELECT
        company_id,
        COUNT(job_id) AS job_count
    FROM
        job_postings_fact
    GROUP BY company_id
) AS company_job_count
ON company_dim.company_id = company_job_count.company_id;


-- Practice Problem 7: ------------------------------------------------------------------------------------------
-- Znajdź liczbę zdalnych ofert pracy dla każdego skills.
-- - podaj top 5 skills wymaganych w pracach zdalnych (job_location = 'Anywhere' albo job_postings_fact.job_work_from_home = true)
-- - wyświetl skill id, nazwę, i liczbę ofert które go wymagają

SELECT * from skills_dim;
SELECT * from skills_job_dim;
SELECT * from job_postings_fact;

-- UŻYWAJĄC SUBQUERY
SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    job_count_for_skills.job_count
FROM
    skills_dim
JOIN (   -- JOIN to to samo co INNER JOIN !
    SELECT
        skills_job_dim.skill_id,
        COUNT(skills_job_dim.job_id) AS job_count
    FROM 
        skills_job_dim
    JOIN 
        job_postings_fact
    ON skills_job_dim.job_id = job_postings_fact.job_id
    WHERE
        job_postings_fact.job_work_from_home = true
    GROUP BY
        skill_id
) AS job_count_for_skills
ON skills_dim.skill_id = job_count_for_skills.skill_id
ORDER BY 
    job_count DESC
LIMIT 5;      
-- WAŻNE ŻEBY ORDER BY I LIMIT ZROBIĆ DOPIERO NA SAM KONIEC !


-- TO SAMO TYLKO PRZY UŻYCIU CTE
WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS job_count
    FROM
        skills_job_dim
    INNER JOIN job_postings_fact
        ON skills_job_dim.job_id = job_postings_fact.job_id
    WHERE 
        job_postings_fact.job_work_from_home = true
    GROUP BY
        skill_id
)
SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    remote_job_skills.job_count
FROM
    skills_dim
JOIN    
    remote_job_skills
ON 
    skills_dim.skill_id = remote_job_skills.skill_id
ORDER BY 
    job_count DESC
LIMIT 5;   

-- -------------------------------------------------------------------------------------------------------------

-- UNION łączy w pionie dwie lub więcej 'tabel' powstałych w wyniku zapytań SELECT
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION  -- połącz kolejną tabele

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION  -- połącz kolejną tabele

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs;

-- UNION ALL łączy w pionie dwie lub więcej 'tabel' powstałych w wyniku zapytań SELECT
-- różnica jest taka, że zwraca także duplikaty wierszy (jeśli takie są)
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION ALL -- połącz kolejną tabele

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION ALL -- połącz kolejną tabele

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs;
-- dostajemy więcej wierszy danych, bo wybraliśmy tylko niektóre kolumny z całej tabeli: 
-- trójki 'job_title_short, company_id, job_location' nie muszą mieć unikatowych wartości


-- Practice Problem 1:
-- Wybierz odpowiednie skills i skills type dla każdej oferty pracy w pierwszym kwartale
-- zawarte muszą być także te, które nie mają przypisanych żadnych skills
-- zobacz też skills i ich typ dla każdej oferty pracy w pierwszym kwartale, która ma salary > 70000

WITH q1_jobs AS (
    SELECT
        job_postings_fact.job_id AS job_id,
        skill_id
    FROM 
        job_postings_fact
    LEFT JOIN
    skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
    WHERE
        EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 1 AND
        job_postings_fact.salary_year_avg > 70000
)
SELECT
    q1_jobs.job_id,
    skills_dim.skills,
    skills_dim.type
FROM
    q1_jobs
LEFT JOIN
    skills_dim
ON 
    q1_jobs.skill_id = skills_dim.skill_id;


-- Practice Problem 8:
-- Znajdź oferty pracy, które mają pensję większa niż 70000.
-- najpierw połącz tabele z pierwszego kwartału (january_jobs, february_jobs, march_jobs)

WITH q1_jobs AS (
    SELECT *
    FROM january_jobs

    UNION ALL

    SELECT *
    FROM february_jobs

    UNION ALL

    SELECT *
    FROM march_jobs
)
SELECT
    q1_jobs.job_location,
    q1_jobs.salary_year_avg
FROM
    q1_jobs
WHERE 
    q1_jobs.salary_year_avg > 70000 AND 
    q1_jobs.job_title_short = 'Data Analyst'
ORDER BY
    q1_jobs.salary_year_avg DESC;

