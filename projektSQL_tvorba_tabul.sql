
/*Vytvoření tabulky t_{jmeno}_{prijmeni}_project_SQL_primary_final 
(pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky)*/


CREATE OR REPLACE TABLE t_halyna_horbenko_project_SQL_primary_final AS   
SELECT  
	cpay.industry_branch_code AS Industry_code,
	cpib.name AS Industry, 
	cpay.payroll_quarter AS Quarter,
	cpay.payroll_year AS Year, 
	cpay.value AS average_wages, 
	cpu.name AS mena,
	date_format(cp.date_from, '%Y.%m.%d') AS price_measured_from,
 	date_format(cp.date_to, '%Y.%m.%d' ) AS price_measured_to,
 	cp.category_code,
 	cpc.name AS Food_category,
 	cpc.price_value,
 	cpc.price_unit AS Food_mena,
 	cp.value AS food_price,
 	cp.region_code,
 	cr.name AS Region
 FROM 
	(SELECT * FROM czechia_payroll ) cpay
	LEFT JOIN
		(SELECT * FROM czechia_payroll_industry_branch cpib ) cpib
		ON cpay.industry_branch_code = cpib.code
	LEFT JOIN
		(SELECT * FROM czechia_payroll_unit ) cpu 
		ON cpay.unit_code = cpu.code
	LEFT JOIN 
		(SELECT * FROM czechia_price ) cp
		ON (cpay.payroll_year = year(cp.date_from) 
		AND ((cpay.payroll_quarter=4 AND (MONTH(cp.date_from)=10) 
		OR (cpay.payroll_quarter=4 AND (MONTH(cp.date_from)=11)) 
		OR (cpay.payroll_quarter=4 AND (MONTH(cp.date_from)=12))))
		OR  
		(cpay.payroll_year = year(cp.date_from) 
		AND ((cpay.payroll_quarter=1 AND (MONTH(cp.date_from)=01)) 
		OR (cpay.payroll_quarter=1 AND (MONTH(cp.date_from)=02)) 
		OR (cpay.payroll_quarter=1 AND (MONTH(cp.date_from)=03))))
		OR 
		(cpay.payroll_year = year(cp.date_from) 
		AND ((cpay.payroll_quarter=2 AND (MONTH(cp.date_from)=04)) 
		OR (cpay.payroll_quarter=2 AND (MONTH(cp.date_from)=05)) 
		OR (cpay.payroll_quarter=2 AND (MONTH(cp.date_from)=06))))
		OR 
		(cpay.payroll_year = year(cp.date_from) 
		AND ((cpay.payroll_quarter=3 AND (MONTH(cp.date_from)=07)) 
		OR (cpay.payroll_quarter=3 AND (MONTH(cp.date_from)=08)) 
		OR (cpay.payroll_quarter=3 AND (MONTH(cp.date_from)=09)))))
	LEFT JOIN 
		(SELECT * FROM czechia_price_category ) cpc
 		ON cp.category_code = cpc.code
 	LEFT JOIN 
	 	(SELECT * FROM czechia_region ) cr
 		ON cp.region_code = cr.code
WHERE 1=1 
	AND cpay.value IS NOT NULL 
	AND cpay.industry_branch_code IS NOT NULL 
	AND cp.region_code IS NOT NULL 
	AND cp.date_from IS NOT NULL
	AND cpay.value_type_code = 5958 
	AND cpay.calculation_code = 200
ORDER BY cpib.name ASC;

 	
/*Vytvoření tabulky t_{jmeno}_{prijmeni}_project_SQL_secondary_final 
(pro dodatečná data o dalších evropských státech)*/


CREATE OR REPLACE TABLE t_halyna_horbenko_project_SQL_secondary_final AS
SELECT 
	c.continent,
	e.country,
	c.capital_city,
	e.year,
	e.GDP,
	e.population,
	e.gini,
	c.religion
FROM 
	(SELECT * FROM economies ) e
	LEFT JOIN
		(SELECT * FROM countries ) c
		ON c.country = e.country
	WHERE 1=1
		AND e.GDP IS NOT NULL
		AND e.YEAR IS NOT NULL 
		AND e.YEAR >=2006 AND e.YEAR <= 2018
ORDER BY 
	e.country ASC,
	e.year;
		
