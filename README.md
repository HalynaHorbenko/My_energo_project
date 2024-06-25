# SQL_project_Horbenko
SQL project
Cílem tohoto projektu bylo vytvořit dvě tabulky ze sad databází, pomocí kterých lze analyzovat změny cen u určitých produktů, změny mezd a porovnávat je s HDP.

Než odpovíme na položené otázky, musíme vytvořit tabulky s databázemi, které potřebujeme. projektSQL_tvorba_tabul.sql s tím pomůže.

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

Ve většině oblastí mzdy v letech 2010 a 2013 klesají. V jiných obdobích mzdy rostou, ale jsou určité oblasti, kde mzdy klesají.

2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

V prvním období 1. 2. 2006 - 1. 8. 2006 koupíte v průměru 14,9 kg chleba a 14,3 litrů mléka. V posledním období 12.10.2018 - 16.12.2018 - průměrně 24,7 kg chleba a 19,6 litrů mléka.

3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Tato otázka je prezentována třemi způsoby – pro databázi jako celek, zvlášť pro roky a prostřednictvím vytvoření pohledu.

4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Výsledek je prezentován jako procentuální nárůst cen, mezd a rozdílu mezi nimi.

5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

Mzdy rostou v obdobích růstu HDP. A v některých odvětvích klesá s poklesem HDP. Nebyla nalezena žádná silná korelace s cenami potravin.
Pro další vizualizaci je výsledek prezentován také ve třech samostatných vzorcích pro procentuální růst HDP, mezd a cen.
