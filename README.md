# My_energo_project
SQL project
Cílem tohoto projektu bylo vytvořit dvě tabulky ze sad databází, pomocí kterých lze analyzovat změny cen u určitých produktů, změny mezd a porovnávat je s HDP.

t_Halyna_Horbenko_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky);

t_Halyna_Horbenko_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).

Data jsou čerpána z tabulek: 
czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR;
czechia_payroll_calculation – Číselník kalkulací v tabulce mezd;
czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd;
czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd;
czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd;
czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR;
czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu;
czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2;
czechia_district – Číselník okresů České republiky dle normy LAU;
countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace;
economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

Databázové soubory obsahují informace o mzdah za období 2001-2021, cenách potravin - 2006-2018, HDP - 1960-2020. Pro případné srovnání byla proto vybrána období, která jsou přítomna ve všech souborech dat, a to 2006-2018.

Výzkumné otázky

1.	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Ve většině období mzdy oproti předchozímu roku rostou, ale jsou roky, kdy klesají, i když nijak výrazně.

2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

Výsledkem vzorku je informace o množství litrů mléka a kilogramů chleba za první a poslední srovnatelné období

3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Tato otázka je prezentována třemi způsoby – pro databázi jako celek, zvlášť pro roky a prostřednictvím vytvoření pohledu.

4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Výsledek je prezentován jako procentuální nárůst cen, mezd a rozdílu mezi nimi.

5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

Mzdy rostou v obdobích růstu HDP. A v některých odvětvích klesá s poklesem HDP. Nebyla nalezena žádná silná korelace s cenami potravin.
Pro další vizualizaci je výsledek prezentován také ve třech samostatných vzorcích pro procentuální růst HDP, mezd a cen.
