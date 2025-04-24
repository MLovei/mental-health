SELECT
    SurveyID
  , Description
  , COUNT(*) 'ROW COUNT'
FROM Survey
GROUP BY
    SurveyID
  , Description
;

SELECT *
FROM Answer
;

SELECT
FROM Question
WHERE questionid
;

CREATE VIEW united_table AS
SELECT
    a.AnswerText
  , a.SurveyID
  , a.UserID
  , q.questionid
  , q.questiontext
FROM Answer a
         JOIN Question q ON a.QuestionID = q.questionid
;

SELECT *
FROM united_table
;

SELECT
    SurveyID                                                      'YEAR OF SURVEY'
  , COUNT(CASE
              WHEN questionid = 2
                  AND LOWER(AnswerText) = 'male' THEN 1 END)   AS 'MALE SURVEY COUNT'
  , COUNT(CASE
              WHEN questionid = 2
                  AND LOWER(AnswerText) = 'female' THEN 1 END) AS 'FEMALE SURVEY COUNT'
  , COUNT(*)                                                      'OVERALL SURVEY COUNT'
FROM united_table
GROUP BY
    SurveyID
;

SELECT
    CASE
        WHEN LOWER(AnswerText) IN ('non-binary', 'nonbinary', 'non binary') THEN 'nonbinary'
        WHEN AnswerText = '-1' THEN 'other'
        ELSE LOWER(AnswerText)
        END AS gender
  , COUNT(*)   gender_count
FROM united_table
WHERE questionid = 2
  AND gender NOT IN ('male', 'female')
GROUP BY
    gender
HAVING gender_count > 1
ORDER BY
    gender_count DESC
;

SELECT
    CASE
        WHEN AnswerText IN ('United States of America', 'United States') THEN 'United States'
        WHEN AnswerText IN ('-1', 'other') THEN 'Other'
        ELSE AnswerText
        END AS country
  , COUNT(*)   country_count
FROM united_table
WHERE questionid = 3
GROUP BY
    country
HAVING country_count > 20
ORDER BY
    country_count DESC
;

WITH cte AS (SELECT
                 CASE
                     WHEN CAST(u.AnswerText AS integer) BETWEEN 13 AND 19 THEN 'Adolescent'
                     WHEN CAST(u.AnswerText AS integer) BETWEEN 20 AND 34 THEN 'Young Adult'
                     WHEN CAST(u.AnswerText AS integer) BETWEEN 35 AND 44 THEN 'Early Midlife'
                     WHEN CAST(u.AnswerText AS integer) BETWEEN 45 AND 54 THEN 'Late Midlife'
                     WHEN CAST(u.AnswerText AS integer) BETWEEN 55 AND 64 THEN 'Early Senior'
                     WHEN CAST(u.AnswerText AS integer) BETWEEN 65 AND 74 THEN 'Mid-Senior'
                     WHEN CAST(u.AnswerText AS integer) BETWEEN 75 AND 84 THEN 'Late Senior'
                     WHEN CAST(u.AnswerText AS integer) >= 85 THEN 'Oldest'
                     END AS age_group
               , CASE
                     WHEN q32.AnswerText = 'Yes' THEN 'Had Mental Illness'
                     WHEN q33.AnswerText = 'Yes' THEN 'Has Mental Illness'
                     ELSE 'No Reported Mental Illness'
                     END AS mental_illness_status
             FROM united_table u
                      LEFT JOIN united_table q32
                                ON u.UserID = q32.UserID
                                    AND q32.questionid = 32
                      LEFT JOIN united_table q33
                                ON u.UserID = q33.UserID
                                    AND q33.questionid = 33
             WHERE (u.questionid = 1
                 AND (CAST(u.AnswerText AS integer) BETWEEN 13 AND 100))
               AND u.AnswerText != -1)
SELECT
    age_group
  , mental_illness_status
  , COUNT(*) AS age_count
FROM cte
GROUP BY
    age_group
  , mental_illness_status
ORDER BY
    CASE
        WHEN age_group = 'Adolescent' THEN 1
        WHEN age_group = 'Young Adult' THEN 2
        WHEN age_group = 'Early Midlife' THEN 3
        WHEN age_group = 'Late Midlife' THEN 4
        WHEN age_group = 'Early Senior' THEN 5
        WHEN age_group = 'Mid-Senior' THEN 6
        WHEN age_group = 'Late Senior' THEN 7
        WHEN age_group = 'Oldest' THEN 8
        END
  , mental_illness_status
;

WITH cte AS (SELECT
                 CASE
                     WHEN q32.AnswerText = 'Yes' THEN 'Had Mental Illness'
                     WHEN q33.AnswerText = 'Yes' THEN 'Has Mental Illness'
                     ELSE 'No Reported Mental Illness'
                     END AS mental_illness_status
               , CASE
                     WHEN q89.AnswerText != -1 THEN q89.AnswerText
                     ELSE 'Unknown race'
                     END AS race
               , CASE
                     WHEN LOWER(q2.AnswerText) IN ('non-binary', 'nonbinary', 'non binary') THEN 'nonbinary'
                     WHEN q2.AnswerText = '-1' THEN 'other'
                     ELSE LOWER(q2.AnswerText)
                     END AS gender
             FROM united_table u
                      LEFT JOIN united_table q32
                                ON u.UserID = q32.UserID AND
                                   q32.questionid = 32
                      LEFT JOIN united_table q33
                                ON u.UserID = q33.UserID
                                    AND q33.questionid = 33
                      LEFT JOIN united_table q89
                                ON u.UserID = q89.UserID
                                    AND q89.questionid = 89
                      LEFT JOIN united_table q2
                                ON u.UserID = q2.UserID
                                    AND q2.questionid = 2
             WHERE (u.questionid = 1
                 AND (CAST(u.AnswerText AS integer) BETWEEN 13 AND 100))
               AND u.AnswerText != -1)
SELECT DISTINCT
    mental_illness_status
  , race
  , gender
  , COUNT(*) AS count
FROM cte

GROUP BY
    mental_illness_status
  , race
  , gender
HAVING count > 2