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


/* Kolik je možné si koupit litrů mléka a kilogramů chleba 
za první a poslední srovnatelné období v dostupných datech cen a mezd? */


(SELECT 
	Industry,
	`Year`,
	average_wages,
	price_measured_from,
	price_measured_to,
	Food_category,
	round(avg(food_price), 2),
	round(average_wages / (round(avg(food_price), 2)), 0) AS amount,
	food_mena
FROM t_halyna_horbenko_project_sql_primary_final thhpspf 
	WHERE (category_code = 114201 OR category_code = 111301)
		AND (price_measured_from IN (SELECT min(price_measured_from) FROM t_halyna_horbenko_project_sql_primary_final thhpspf))
GROUP BY 
	Industry,
	price_measured_from,
	Food_category)
UNION 
(SELECT 
	Industry,
	`Year`,
	average_wages,
	price_measured_from,
	price_measured_to,
	Food_category,
	round(avg(food_price), 2),
	round(average_wages / (round(avg(food_price), 2)), 0) AS kkk,
	food_mena
FROM t_halyna_horbenko_project_sql_primary_final thhpspf 
	WHERE (category_code = 114201 OR category_code = 111301)
		AND (price_measured_from IN (SELECT max(price_measured_from) FROM t_halyna_horbenko_project_sql_primary_final thhpspf))
GROUP BY 
	Industry,
	price_measured_from,
	Food_category)
ORDER BY 
	Industry,
	`Year`,
	price_measured_from,
	Food_category;


/* Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?*/

-- Celkově pro databázi:


SELECT 
	Food_category,
	max(food_price) AS 'max',
	min(food_price) AS 'min',
	(max(food_price) - min(food_price)) AS rozdil,
	round(((max(food_price) - min(food_price)) / max(food_price))*100, 2) AS procent
FROM t_halyna_horbenko_project_sql_primary_final thhpspf
GROUP BY food_category
ORDER BY procent;


-- Podle roku:


SELECT 
	Food_category,
	`Year`,
	max(food_price) AS 'max',
	min(food_price) AS 'min',
	(max(food_price) - min(food_price)) AS rozdil,
	round(((max(food_price) - min(food_price)) / max(food_price))*100, 2) AS procent
FROM t_halyna_horbenko_project_sql_primary_final tp
WHERE 1=1
	-- AND `Year` = 2006 -- Možnost výběru konkrétního roku. Existuje 2006-2018
	GROUP BY 
		Food_category,
		`Year` 
ORDER BY 
	`Year`,
	procent;


-- vytvořit pohled:


CREATE OR REPLACE VIEW v_halyna_horbenko_project_sql_food AS (
SELECT 
	Food_category ,
	`Year` ,
	max(food_price) AS 'max',
	min(food_price) AS 'min',
	(max(food_price) - min(food_price)) AS rozdil,
	round(((max(food_price) - min(food_price)) / max(food_price))*100, 2) AS procent
FROM t_halyna_horbenko_project_sql_primary_final tp
WHERE 1=1
	-- AND `Year` = 2006 -- Možnost výběru konkrétního roku. Existuje 2006-2018
	GROUP BY 
		Food_category,
		`Year` 
ORDER BY 
	`Year`,
	procent);


-- Výběr z pohledu:


SELECT 
	Food_category,
	`Year`,
	min(procent)
FROM v_halyna_horbenko_project_sql_food vhhpsf 
GROUP BY 
	 `Year`;
	
	
	-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
	

SELECT 
	`Year`,
	Food_category,
	Industry,
	/* V případě potřeby lze toto pole zobrazit pro přehlednost výpočtu:
	(max(food_price) - min(food_price)) AS mezirocny_rozdil_cen,
	(max(average_wages) - min(average_wages)) AS mezirocny_rozdil_mezd,*/
	round(((max(average_wages) - min(average_wages)) / max(average_wages)*100), 1) AS Procent_narostu_mezd,
	round(((max(food_price) - min(food_price)) / max(food_price)*100), 1) AS Procent_narostu_cen,
	(round(((max(food_price) - min(food_price)) / max(food_price)*100), 1)) - (round(((max(average_wages) - min(average_wages)) / max(average_wages)*100), 1)) AS Difference,
	CASE 
		WHEN (round(((max(food_price) - min(food_price)) / max(food_price)*100), 1)) - (round(((max(average_wages) - min(average_wages)) / max(average_wages)*100), 1)) > 10 THEN 'rust cen vice 10% nez mzda' ELSE 0
	END AS 'Result'
FROM t_halyna_horbenko_project_sql_primary_final thhpspf
GROUP BY
	Industry,
	`Year`,
	Food_category 
ORDER BY 
	`Year`,
	Food_category,
	Industry; 


/*Má výška HDP vliv na změny ve mzdách a cenách potravin? 
 Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin 
či mzdách ve stejném nebo násdujícím roce výraznějším růstem?*/


SELECT 
	tp.`Year`,
	tp.Food_category,
	/*V případě potřeby lze toto pole zobrazit pro přehlednost výpočtu:
	min(tp.average_wages) AS min_mzda,
	max(tp.average_wages) AS max_mzda,
	max(tp.average_wages) - min(tp.average_wages) AS roz_mzda,
	min(tp.food_price) AS min_food,
	max(tp.food_price) AS max_food,
	max(tp.food_price) - min(tp.food_price) AS roz_food,*/
	round(((max(tp.average_wages) - min(tp.average_wages)) / max(tp.average_wages))*100, 0) AS procent_mzda,
	round(((max(tp.food_price) - min(tp.food_price)) / max(tp.food_price))*100, 0) AS procent_food,
	round(ts.GDP/ts.population, 0) AS HDP
	FROM t_halyna_horbenko_project_sql_primary_final tp  
	LEFT JOIN t_halyna_horbenko_project_sql_secondary_final ts
	ON tp.year = ts.YEAR
WHERE ts.country = 'Czech Republic'
GROUP BY 
 	tp.`Year`,
 	tp.Food_category 
ORDER BY 
	tp.`Year`,
	tp.Food_category;

	
-- Růst GDP podle roku:


SELECT 
	`year`,
	country,
	GDP,
	GDP - LAG(GDP, 1) OVER (ORDER BY `year`) AS diff,
	CASE 
		WHEN (GDP - LAG(GDP) OVER (ORDER BY `year`)) > 0 THEN 'rust GDP' ELSE 0
	END AS 'RESULT_GDP' 
FROM  t_halyna_horbenko_project_sql_secondary_final ts  
WHERE country = 'Czech Republic'; 


-- Růst mezd podle roku a industry:


SELECT 
	Industry,
	`Year`,
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
	`Year`;


-- Růst cen podle roku a category:


SELECT 
	Food_category,
	`Year`,
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
	Food_category,
	`Year`;