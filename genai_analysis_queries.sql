CREATE DATABASE genai_analysis;
USE genai_analysis;


SELECT * FROM gaaii_country_year;
SELECT * FROM gaaii_incidents;
SELECT * FROM gaaii_model_releases;
SELECT * FROM gaaii_policy_events;
SELECT * FROM gaaii_survey_microdata;

# =========================================================================
# KEY PERFORMANCE INDICATORS (KPIs) - SINGLE ROW ANALYSIS
# =========================================================================

# 1. Country with the Highest AI Innovation (Most Patents Filed)
# Objective: To identify the single country that leads globally in Generative AI innovation by achieving the highest number of patent filings in 2025.
SELECT 
    country, 
    region, 
    COALESCE(genai_patents_filed, 0) AS max_patents_filed
FROM gaaii_country_year
WHERE year = 2025
ORDER BY genai_patents_filed DESC
LIMIT 1;
#OUTPUT:China has the highest number of AI patents

# 2. identify the most popular AI model globally based on the highest number of downloads.
# Objective: To pinpoint the single most popular Open-Source or Closed-Source AI model based on the maximum number of Hugging Face downloads.
SELECT
    model_name,
    open_source,
    COALESCE(huggingface_downloads_mn, 0) AS total_downloads_millions,
    COALESCE(benchmark_score_mmlu, 0) AS benchmark_score_mmlu
FROM gaaii_model_releases
ORDER BY
    COALESCE(huggingface_downloads_mn, 0) DESC,
    COALESCE(benchmark_score_mmlu, 0) DESC
LIMIT 1;
#OUTPUT: Stable Audio 2 is the most popular AI model globally, with 95 million downloads.
# 3. Maximum Financial Damage Caused by a Single AI Incident
# Objective: To identify the most severe AI-related incident that resulted in the highest individual financial loss, along with the sector affected.
SELECT 
    incident_id, 
    country, 
    sector_affected, 
    incident_category, 
    COALESCE(financial_damage_usd, 0) AS highest_financial_loss -- NULL വന്നാൽ 0 കാണിക്കാൻ
FROM gaaii_incidents
ORDER BY financial_damage_usd DESC
LIMIT 1;
#OUTPUT: Saudi Arabia recorded the highest financial AI loss due to AI Bias in Hiring.

# 4. Country with the Highest Public Trust in Generative AI
# Objective: To discover the single country where the general public has the highest confidence and trust index score toward GenAI technologies in 2025.
SELECT 
    country, 
    region, 
    COALESCE(public_trust_score, 0) AS highest_trust_score 
FROM gaaii_country_year
WHERE year = 2025
ORDER BY public_trust_score DESC
LIMIT 1;
#OUTPUT:The Netherlands has the highest AI trust score in Europe.

# 5. Demographic Profile with the Highest Fear of Job Loss
# Objective: To extract the specific demographic group (Age, Education, and Employment type) that experiences the maximum anxiety regarding AI-driven job displacement.
SELECT 
    age_group, 
    education_level, 
    employment_type, 
    COALESCE(AVG(fear_of_job_loss_score), 0) AS highest_avg_job_fear 
FROM gaaii_survey_microdata
GROUP BY age_group, education_level, employment_type
ORDER BY highest_avg_job_fear DESC
LIMIT 1;
#OUTPUT:The 55–64 retired group with no formal education showed the highest fear of AI-related job loss

# =========================================================================
# DETAILED BUSINESS ANALYSIS
# =========================================================================

# 1. This objective compares AI readiness with public trust.
# Objective: To analyze the relationship between a country’s AI readiness, cloud infrastructure, internet speed, and the level of public trust in Generative AI technologies.
SELECT 
    country, 
    region, 
    COALESCE(cloud_readiness_score, 0) AS cloud_readiness_score,
    COALESCE(avg_internet_speed_mbps, 0) AS avg_internet_speed_mbps,
    COALESCE(public_trust_score, 0) AS public_trust_score,
    CASE 
        WHEN public_trust_score > 70 THEN 'High Trust'
        WHEN public_trust_score >= 40 THEN 'Moderate Trust'
        ELSE 'Low Trust'
    END AS trust_category
FROM gaaii_country_year
WHERE year = 2025
ORDER BY cloud_readiness_score DESC;
#Hungary, Norway, and Sweden rank highest in AI readiness, but strong infrastructure alone doesn't guarantee public trust.


# 2. This objective compares AI model releases with AI patents.
# Objective: To evaluate whether countries that release more AI models also demonstrate stronger innovation through a higher number of Generative AI patent filings.
SELECT 
    c.country,
    COUNT(m.model_name) AS total_models_released,
    ROUND(COALESCE(AVG(m.benchmark_score_mmlu), 0), 2) AS avg_mmlu_score, 
    COALESCE(MAX(c.genai_patents_filed), 0) AS total_patents_filed 
FROM gaaii_country_year c
LEFT JOIN gaaii_model_releases m ON c.country = m.hq_country 
WHERE c.year = 2025
GROUP BY c.country
ORDER BY total_models_released DESC;
#OUTPUT:The US leads in AI model releases, while China leads in AI patents.


# 3. This objective analyzes AI adoption and financial losses by industry.
# Objective: To compare AI adoption across different industries and identify which sectors experience the highest financial losses due to AI-related incidents.
SELECT 
    c.country,
    COALESCE(c.finance_genai_adoption_pct, 0) AS finance_adoption,
    COALESCE(SUM(CASE WHEN i.sector_affected = 'Finance' THEN i.financial_damage_usd ELSE 0 END), 0) AS finance_damage_usd,
    COALESCE(c.healthcare_genai_adoption_pct, 0) AS healthcare_adoption,
    COALESCE(SUM(CASE WHEN i.sector_affected = 'Healthcare' THEN i.financial_damage_usd ELSE 0 END), 0) AS healthcare_damage_usd
FROM gaaii_country_year c
LEFT JOIN gaaii_incidents i ON c.country = i.country AND c.year = i.year
WHERE c.year = 2025
GROUP BY c.country, c.finance_genai_adoption_pct, c.healthcare_genai_adoption_pct;
#High AI adoption doesn't always mean higher financial losses."
#"Good governance helps reduce AI-related financial losses."


# 4. AI Anxiety and Job Loss Fear Profile (Survey Analysis)
# Objective: To assess AI anxiety and job loss fear across different demographic profiles.
SELECT
    age_group,
    education_level,
    employment_type,
    ROUND(COALESCE(AVG(fear_of_job_loss_score), 0), 2) AS avg_job_fear, 
    ROUND(COALESCE(AVG(trust_in_genai_score), 0), 2) AS avg_user_trust   
FROM gaaii_survey_microdata
GROUP BY age_group, education_level, employment_type
ORDER BY avg_job_fear DESC;
#OUTPUT:4.	Public Trust vs Job Fear: "Many people trust AI but still worry about job loss, IT the need for reskilling.


# 5. This objective analyzes AI regulations and policy effectiveness.
# Objective: To assess whether countries with stronger AI regulations and data privacy policies experience fewer AI-related incidents and greater policy effectiveness.
SELECT
    c.country,
    COALESCE(c.regulation_stringency_score, 0) AS regulation_stringency_score,
    COALESCE(c.data_privacy_score, 0) AS data_privacy_score,
    COUNT(DISTINCT i.incident_id) AS total_incidents,
    ROUND(COALESCE(AVG(p.policy_impact_score), 0), 2) AS actual_policy_impact
FROM gaaii_country_year c
LEFT JOIN gaaii_incidents i ON c.country = i.country AND c.year = i.year
LEFT JOIN gaaii_policy_events p ON c.country = p.country AND c.year = p.year
WHERE c.year = 2025
GROUP BY c.country, c.regulation_stringency_score, c.data_privacy_score
ORDER BY c.regulation_stringency_score DESC;
#OUTPUT: Countries with strong AI regulations have fewer AI risks.


# 6. Labor Market Impact of Generative AI
# Objective: To analyze the impact of Generative AI on employment by comparing job creation, job displacement, and overall economic contribution across different regions.
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
#OUTPUT: AI boosts the economy, but job losses are slightly higher than job creation. This highlights the importance of reskilling the workforce

# 7. Digital Divide and AI Adoption Analysis
# Objective: To investigate how digital inequality, language support, and technological accessibility influence the adoption of Generative AI across countries.
SELECT
    country,
    low_resource_language_country,
    native_lang_llm_support,
    COALESCE(digital_divide_index, 0) AS digital_divide_index,
    COALESCE(genai_adoption_rate_pct, 0) AS genai_adoption_rate_pct,
    COALESCE(global_genai_index_score, 0) AS global_genai_index_score
FROM gaaii_country_year
WHERE year = 2025
ORDER BY digital_divide_index DESC;
#countries with a high digital divide have lower AI adoption. 
#this shows that good digital infrastructure and local language support help increase AI adoption.

# 8. This objective compares public AI harm reports with official AI incidents.
# To compare citizens' reported experiences of AI-related harm with officially recorded AI incidents.
WITH survey_agg AS (
    SELECT country, survey_year,
           COUNT(DISTINCT respondent_id) AS total_surveyed,
           SUM(CASE WHEN has_experienced_ai_harm = 'Yes' THEN 1 ELSE 0 END) AS citizens_reporting_harm
    FROM gaaii_survey_microdata
    GROUP BY country, survey_year
),
incident_agg AS (
    SELECT country, year,
           COUNT(DISTINCT incident_id) AS official_incidents_reported
    FROM gaaii_incidents
    GROUP BY country, year
)
SELECT
    s.country,
    COALESCE(s.total_surveyed, 0) AS total_surveyed,
    COALESCE(s.citizens_reporting_harm, 0) AS citizens_reporting_harm,
    COALESCE(i.official_incidents_reported, 0) AS official_incidents_reported -- NULL വന്നാൽ 0 കാണിക്കാൻ
FROM survey_agg s
LEFT JOIN incident_agg i ON s.country = i.country AND s.survey_year = i.year
ORDER BY s.citizens_reporting_harm DESC;
#" public reports of AI harm are higher than official records. 
#This suggests that some AI incidents are not officially reported, so better monitoring and reporting are needed."


# 9. Financial Impact of AI Incidents by Perpetrator Type
# Objective: To identify which categories of perpetrators are responsible for the highest financial losses.
SELECT
    perpetrator_type,
    incident_category,
    COUNT(*) AS incident_count,
    COALESCE(SUM(financial_damage_usd), 0) AS total_loss, 
    ROUND(COALESCE(AVG(media_coverage_score), 0), 2) AS media_hype_score
FROM gaaii_incidents
GROUP BY perpetrator_type, incident_category
ORDER BY total_loss DESC;
# AI plagiarism caused the highest financial loss, AI bias in hiring was the most common incident, 
#AI surveillance abuse received the highest media attention."


# 10. Open-Source vs. Closed-Source AI Model Performance
# Objective: To compare the popularity and performance of open-source and closed-source AI models.
SELECT
    open_source,
    multilingual,
    multimodal,
    COUNT(*) AS model_count,
    COALESCE(SUM(huggingface_downloads_mn), 0) AS total_downloads_millions, -- NULL വന്നാൽ 0 കാണിക്കാൻ
    ROUND(COALESCE(AVG(benchmark_score_mmlu), 0), 2) AS avg_quality_score
FROM gaaii_model_releases
GROUP BY open_source, multilingual, multimodal
ORDER BY total_downloads_millions DESC;


# Final Conclusion: 360-Degree Global Generative AI Impact Assessment
# Objective: To provide a comprehensive overview of each country's Generative AI ecosystem.
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
#countries with high AI adoption perform well, but without strong governance and security, 
#they can face financial losses and job challenges. 
#Estonia and Slovenia show that responsible AI adoption leads to better outcomes.