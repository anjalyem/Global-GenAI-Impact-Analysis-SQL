# 🤖 Global Generative AI Impact & Adoption Analysis (2025)

## 📌 Project Overview
This project performs an **end-to-end exploratory data analysis** on global Generative AI adoption, economic impact, public sentiment, and governance risks for 2025 using **MySQL Workbench**. The objective is to combine multi-dimensional datasets to uncover actionable insights across innovation, workforce displacement, financial exposure, and policy effectiveness.

---

## 🛠️ Tools & Technologies Used
* **Database Management System:** MySQL Workbench
* **Language:** SQL
* **Dataset Source:** Kaggle — Global Generative AI Dataset 2025
* **Key SQL Concepts:** CTEs, Advanced JOINs, Aggregations, Conditional Logic (`CASE`, `COALESCE`), Window Functions, and Data Transformation.

---

## 🗄️ Database Architecture (`genai_analysis`)
The relational schema consists of **5 interconnected tables** linked via `country` and `year`:

1. `gaaii_country_year`: Country-level AI adoption, digital divide index, cloud readiness, and economic impact.
2. `gaaii_incidents`: Logged AI safety breaches, financial losses, and incident categories.
3. `gaaii_model_releases`: Global open-source vs. closed-source AI model specs, Hugging Face downloads, and benchmark scores.
4. `gaaii_policy_events`: AI governance frameworks, regulation stringency ratings, and policy impact metrics.
5. `gaaii_survey_microdata`: Demographic survey data on job-loss anxiety, user trust, and unreported AI harm.

---

## 📊 Key Performance Indicators (KPIs)
* **AI Innovation Leader:** **China** leads globally in total AI patents filed.
* **Most Popular AI Model:** **Stable Audio 2** achieved top popularity with over **95 Million downloads**.
* **Highest Financial Loss:** **Saudi Arabia** recorded the largest single loss due to AI Bias in Hiring.
* **Highest AI Trust Index:** **The Netherlands** leads in public trust regarding Generative AI integration.
* **Highest Job Loss Anxiety:** The **55–64 age group** (retired / non-formal education) expressed the maximum fear of job displacement.

---

## 🔍 Key Business Analysis & Insights
1. **Infrastructure vs. Public Trust:** High cloud readiness and fast internet (e.g., Norway, Hungary) do not automatically guarantee high public trust.
2. **Model Releases vs. Patents:** The US dominates in AI model releases, whereas China leads in patent filings.
3. **Governance & Risk Mitigation:** Sectors with proactive regulatory frameworks experience lower financial losses despite high adoption.
4. **Labor Market Dynamics:** AI boosts global economic output, but initial job displacement slightly outpaces job creation, highlighting a skills gap.
5. **Digital Divide Impact:** Countries with a high digital divide index lag in GenAI adoption, proving that infrastructure and native language support are crucial.

---

## 💻 SQL Queries & Implementation

```sql
-- 1. Global AI Innovation Leader (Patents)
SELECT 
    country, 
    region, 
    COALESCE(genai_patents_filed, 0) AS max_patents_filed
FROM gaaii_country_year
WHERE year = 2025
ORDER BY genai_patents_filed DESC
LIMIT 1;

-- 2. Labor Market & Employment Impact by Region
SELECT
    region,
    ROUND(COALESCE(AVG(job_displacement_pct), 0), 2) AS avg_jobs_lost,
    ROUND(COALESCE(AVG(job_creation_pct), 0), 2) AS avg_jobs_created,
    ROUND(COALESCE(AVG(net_job_impact_pct), 0), 2) AS net_employment_impact,
    ROUND(COALESCE(AVG(gdp_contribution_bn_usd), 0), 2) AS avg_gdp_contribution_billion
FROM gaaii_country_year
WHERE year = 2025
GROUP BY region
ORDER BY net_employment_impact DESC;

-- 3. 360-Degree Country AI Performance Overview
WITH inc_summary AS (
    SELECT country, year, SUM(financial_damage_usd) AS total_damage
    FROM gaaii_incidents GROUP BY country, year
),
mod_summary AS (
    SELECT hq_country, COUNT(model_name) AS total_models
    FROM gaaii_model_releases GROUP BY hq_country
),
sur_summary AS (
    SELECT country, survey_year, AVG(fear_of_job_loss_score) AS avg_fear
    FROM gaaii_survey_microdata GROUP BY country, survey_year
)
SELECT
    c.country,
    c.region,
    COALESCE(c.global_genai_index_score, 0) AS country_overall_rank_score,
    COALESCE(c.genai_adoption_rate_pct, 0) AS national_adoption_rate,
    COALESCE(c.net_job_impact_pct, 0) AS net_job_market_impact,
    COALESCE(i.total_damage, 0) AS total_incident_losses_usd, 
    COALESCE(m.total_models, 0) AS models_developed_by_country, 
    ROUND(COALESCE(s.avg_fear, 0), 2) AS general_public_job_fear_rating 
FROM gaaii_country_year c
LEFT JOIN inc_summary i ON c.country = i.country AND c.year = i.year
LEFT JOIN mod_summary m ON c.country = m.hq_country
LEFT JOIN sur_summary s ON c.country = s.country AND c.year = s.survey_year
WHERE c.year = 2025
ORDER BY country_overall_rank_score DESC;
