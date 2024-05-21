
-- Vytvoření tabulky t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky)

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
 	
-- Vytvoření tabulky t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech)

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
		
-- Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

SELECT 
	Industry,
	`Year` ,
	round(avg(average_wages), 2) AS Mzda,
	LAG(round(avg(average_wages), 2),1) 
		OVER (PARTITION BY Industry ORDER BY Industry, `Year`) AS Predchozi_plat,
	(round(avg(average_wages), 2) - LAG(round(avg(average_wages), 2),1) 
		OVER (PARTITION BY Industry ORDER BY Industry, `Year`)) AS Rozdil,
	CASE
		WHEN (round(avg(average_wages), 2) - LAG(round(avg(average_wages), 2),1) 
				OVER (PARTITION BY Industry ORDER BY Industry, `Year`)) IS NULL 
		THEN 0 	
		WHEN (round(avg(average_wages), 2) - LAG(round(avg(average_wages), 2),1) 
				OVER (PARTITION BY Industry ORDER BY Industry, `Year`)) >= 0  
		THEN 'Rostou' 
		ELSE 'Klesají' 
	END AS Rost
FROM  t_halyna_horbenko_project_sql_primary_final thhpspf  
GROUP BY
Industry,
`Year` ;

-- Kolik je možné si koupit litrů mléka a kilogramů chleba 
-- za první a poslední srovnatelné období v dostupných datech cen a mezd?

(SELECT 
	Industry ,
	`Year`,
	average_wages ,
	price_measured_from ,
	price_measured_to ,
	Food_category ,
	round(avg(food_price), 2),
	round(average_wages /(round(avg(food_price), 2)), 0) AS amount,
	food_mena
FROM t_halyna_horbenko_project_sql_primary_final thhpspf 
	WHERE (category_code = 114201 OR category_code = 111301)
		AND (price_measured_from IN (SELECT min(price_measured_from) FROM t_halyna_horbenko_project_sql_primary_final thhpspf))
GROUP BY 
	Industry ,
	price_measured_from ,
	Food_category)
UNION 
(SELECT 
	Industry ,
	`Year`,
	average_wages ,
	price_measured_from ,
	price_measured_to ,
	Food_category ,
	round(avg(food_price), 2),
	round(average_wages /(round(avg(food_price), 2)), 0) AS kkk,
	food_mena
FROM t_halyna_horbenko_project_sql_primary_final thhpspf 
	WHERE (category_code = 114201 OR category_code = 111301)
		AND (price_measured_from IN (SELECT max(price_measured_from) FROM t_halyna_horbenko_project_sql_primary_final thhpspf))
GROUP BY 
	Industry ,
	price_measured_from ,
	Food_category)
ORDER BY 
	Industry ,
	`Year` ,
	price_measured_from ,
	Food_category ;

-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- Celkově pro databázi:
SELECT 
	Food_category ,
	max(food_price) AS 'max',
	min(food_price) AS 'min',
	(max(food_price) - min(food_price)) AS rozdil ,
	round(((max(food_price) - min(food_price))/max(food_price))*100, 2) AS procent
FROM t_halyna_horbenko_project_sql_primary_final thhpspf
GROUP BY food_category
ORDER BY procent;

-- Podle roku:
SELECT 
	Food_category ,
	`Year` ,
	max(food_price) AS 'max',
	min(food_price) AS 'min',
	(max(food_price) - min(food_price)) AS rozdil ,
	round(((max(food_price) - min(food_price))/max(food_price))*100, 2) AS procent
FROM t_halyna_horbenko_project_sql_primary_final tp
WHERE 1=1
	-- AND `Year` = 2006 -- Možnost výběru konkrétního roku. Existuje 2006-2018
	GROUP BY 
		Food_category,
		`Year` 
ORDER BY 
	`Year` ,
	procent;

-- vytvořit pohled:
CREATE OR REPLACE VIEW v_halyna_horbenko_project_sql_food AS (
SELECT 
	Food_category ,
	`Year` ,
	max(food_price) AS 'max',
	min(food_price) AS 'min',
	(max(food_price) - min(food_price)) AS rozdil ,
	round(((max(food_price) - min(food_price))/max(food_price))*100, 2) AS procent
FROM t_halyna_horbenko_project_sql_primary_final tp
WHERE 1=1
	-- AND `Year` = 2006 -- Možnost výběru konkrétního roku. Existuje 2006-2018
	GROUP BY 
		Food_category,
		`Year` 
ORDER BY 
	`Year` ,
	procent);

-- Výběr z pohledu:
SELECT 
	Food_category ,
	`Year` ,
	min(procent)
FROM v_halyna_horbenko_project_sql_food vhhpsf 
GROUP BY 
	 `Year` ;
	
	-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

SELECT 
	`Year` ,
	Food_category ,
	Industry ,
	-- V případě potřeby lze toto pole zobrazit pro přehlednost výpočtu:
	-- (max(food_price) - min(food_price)) AS mezirocny_rozdil_cen ,
	-- (max(average_wages) - min(average_wages)) AS mezirocny_rozdil_mezd ,
	round(((max(average_wages) - min(average_wages))/max(average_wages)*100), 1) AS Procent_narostu_mezd,
	round(((max(food_price) - min(food_price))/max(food_price)*100), 1) AS Procent_narostu_cen,
	(round(((max(food_price) - min(food_price))/max(food_price)*100), 1))-(round(((max(average_wages) - min(average_wages))/max(average_wages)*100), 1)) AS Difference,
	CASE 
		WHEN (round(((max(food_price) - min(food_price))/max(food_price)*100), 1))-(round(((max(average_wages) - min(average_wages))/max(average_wages)*100), 1))>10 THEN 'rust cen vice 10% nez mzda' ELSE 0
	END AS 'Result'
FROM t_halyna_horbenko_project_sql_primary_final thhpspf
GROUP BY
	Industry,
	`Year`,
	Food_category 
ORDER BY 
	`Year`,
	Food_category ,
	Industry ; 

/*/ Má výška HDP vliv na změny ve mzdách a cenách potravin? 
 Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin 
či mzdách ve stejném nebo násdujícím roce výraznějším růstem? /*/

SELECT 
	tp.`Year` ,
	tp.Food_category ,
	-- V případě potřeby lze toto pole zobrazit pro přehlednost výpočtu:
	/*/min(tp.average_wages) AS min_mzda,
	max(tp.average_wages) AS max_mzda,
	max(tp.average_wages) - min(tp.average_wages) AS roz_mzda,
	min(tp.food_price) AS min_food,
	max(tp.food_price) AS max_food,
	max(tp.food_price) - min(tp.food_price) AS roz_food, /*/
	round(((max(tp.average_wages) - min(tp.average_wages))/max(tp.average_wages))*100, 0) AS procent_mzda ,
	round(((max(tp.food_price) - min(tp.food_price))/max(tp.food_price))*100, 0) AS procent_food,
	round(ts.GDP/ts.population , 0) AS HDP
	FROM t_halyna_horbenko_project_sql_primary_final tp  
	LEFT JOIN t_halyna_horbenko_project_sql_secondary_final ts
	ON tp.year = ts.YEAR
WHERE ts.country = 'Czech Republic'
GROUP BY 
 	tp.`Year` ,
 	tp.Food_category 
ORDER BY 
	tp.`Year` ,
	tp.Food_category;
	
-- Růst GDP podle roku:
SELECT 
	`year` ,
	country ,
	GDP ,
	GDP -lag(GDP, 1) OVER (ORDER BY `year`) AS diff,
	CASE 
		WHEN (GDP -lag(GDP) OVER (ORDER BY `year`)) > 0 THEN 'rust GDP' ELSE 0
	END AS 'RESULT_GDP' 
FROM  t_halyna_horbenko_project_sql_secondary_final ts  
WHERE country = 'Czech Republic'; 

-- Růst mezd podle roku a industry:
SELECT 
	Industry,
	`Year` ,
	-- round(avg(average_wages), 2) AS Mzda,
	LAG(round(avg(average_wages), 2),1) 
		OVER (PARTITION BY Industry ORDER BY Industry, `Year`) AS Predchozi_plat,
	 (round(avg(average_wages), 2) - LAG(round(avg(average_wages), 2),1) 
	 OVER (PARTITION BY Industry ORDER BY Industry, `Year`)) AS Rozdil,
	CASE
		WHEN (round(avg(average_wages), 2) - LAG(round(avg(average_wages), 2),1) 
				OVER (PARTITION BY Industry ORDER BY Industry, `Year`)) IS NULL 
		THEN 0 	
		WHEN (round(avg(average_wages), 2) - LAG(round(avg(average_wages), 2),1) 
				OVER (PARTITION BY Industry ORDER BY Industry, `Year`)) >= 0  
		THEN 'Rostou' 
		ELSE 'Klesají' 
	END AS Rost_mzda
FROM  t_halyna_horbenko_project_sql_primary_final thhpspf  
GROUP BY
	Industry,
	`Year` ;

-- Růst cen podle roku a category:
SELECT 
	Food_category ,
	`Year` ,
	round(avg(food_price), 2) AS Price,
	LAG(round(avg(food_price), 2),1) 
		OVER (PARTITION BY Food_category  ORDER BY Food_category , `Year`) AS Predchozi_cena,
	(round(avg(food_price), 2) - LAG(round(avg(food_price), 2),1) 
		OVER (PARTITION BY Food_category ORDER BY Food_category , `Year`)) AS Rozdil_cen,
	CASE
		WHEN (round(avg(food_price), 2) - LAG(round(avg(food_price), 2),1) 
				OVER (PARTITION BY Food_category  ORDER BY Food_category , `Year`)) IS NULL 
		THEN 0 	
		WHEN (round(avg(food_price), 2) - LAG(round(avg(food_price), 2),1) 
				OVER (PARTITION BY Food_category  ORDER BY Food_category , `Year`)) >= 0  
		THEN 'Rostou' 
		ELSE 'Klesají' 
	END AS Rost_cen
FROM  t_halyna_horbenko_project_sql_primary_final thhpspf  
GROUP BY
	Food_category ,
	`Year` ;