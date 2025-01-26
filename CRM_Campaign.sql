CREATE TABLE CRM_Campaign_Optimization (
    age INT,
    job VARCHAR(50),
    marital VARCHAR(20),
    education VARCHAR(50),
    default_status VARCHAR(10),
    housing VARCHAR(10),
    loan VARCHAR(10),
    contact VARCHAR(20),
    month VARCHAR(10),
    day_of_week VARCHAR(10),
    duration INT,
    campaign INT,
    pdays INT,
    previous INT,
    poutcome VARCHAR(20),
    emp_var_rate FLOAT,
    cons_price_idx FLOAT,
    cons_conf_idx FLOAT,
    euribor3m FLOAT,
    nr_employed FLOAT,
    y VARCHAR(10)
	
);

ALTER TABLE CRM_Campaign_Optimization ADD COLUMN contact_efficiency FLOAT;
ALTER TABLE CRM_Campaign_Optimization ADD COLUMN is_repeat_customer INT;


SELECT job,COUNT(*) FROM CRM_Campaign_Optimization
	GROUP BY job


COPY CRM_Campaign_Optimization 
	FROM 'C:/Drive(D)/CRM Dashboard/processed_bank_data.csv'
DELIMITER ','
CSV HEADER



SELECT * FROM CRM_Campaign_Optimization;


SELECT job,COUNT(y) AS YES, COUNT(*) FROM CRM_Campaign_Optimization
WHERE y='yes'
GROUP BY job

	

-- 1. Conversion Rate

SELECT 
    job, 
    COUNT(*) AS total_clients, 
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS conversions, 
     ROUND((SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2) AS conversion_rate
FROM CRM_Campaign_Optimization
GROUP BY job;



-- 2.Contact Method Efficiency

SELECT 
    contact,
    COUNT(*) AS total_contacts,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS conversions,
    ROUND((SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2) AS contact_method_efficiency
FROM CRM_Campaign_Optimization
GROUP BY contact;

-- 3. Success Rate by Contact Method and Job

SELECT 
    contact,
    job,
    COUNT(*) AS total_contacts,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS conversions,
    ROUND((SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2) AS success_rate
FROM CRM_Campaign_Optimization
GROUP BY contact, job;

-- 4. Contact Duration Analysis

SELECT 
    contact,
    AVG(duration) AS avg_duration,
    SUM(CASE WHEN y = 'yes' THEN duration ELSE 0 END) / NULLIF(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END), 0) AS avg_conversion_duration
FROM CRM_Campaign_Optimization
GROUP BY contact;

-- 5. Repeat Customers by Contact Method

SELECT 
    contact,
    is_repeat_customer,
    COUNT(*) AS total_clients,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS conversions,
    (SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS conversion_rate
FROM CRM_Campaign_Optimization
GROUP BY contact, is_repeat_customer;


-- 6.Age Groups

WITH AgeGroup AS (
	SELECT *,
		CASE 
			WHEN age < 30 THEN 'Under 30'
			WHEN age >= 30 AND age<40 THEN '30-39'
			WHEN age >= 40 AND age<50 THEN '40-49'
			WHEN age >= 50 AND age<60 THEN '50-59'
		ELSE '60+'
	END AS age_group
			
	FROM CRM_Campaign_Optimization
)

	SELECT age_group,
		COUNT(*) AS total_clients,
			SUM(CASE WHEN y='yes' THEN 1 ELSE 0 END) AS conversation,
			ROUND((SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2) AS success_rate
	FROM AgeGroup
	GROUP BY age_group

--7. Campaign Efficiency
	
SELECT 
    campaign, 
    COUNT(*) AS total_contacts, 
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS conversions, 
    (SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS campaign_efficiency
FROM CRM_Campaign_Optimization
GROUP BY campaign;

