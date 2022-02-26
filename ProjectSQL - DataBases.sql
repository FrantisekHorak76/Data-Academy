-- Vytvoøení datových podkladù Tabulka 1 

/* Vytvoøení pohledu, ve kterém vidíme rok mìøení, jednotku produktu, název produktu a
 jeho cenu v jednotlivých krajích.
 Data jsou brána z tabulek czechia_price, czechia_price_category a czechia_region.
 Jedná se o datovou sadu, která obsahuje 101 032 záznamù. Z datové sady byly odstranìny
 záznamy s nulovou hodnotou v region_code, které vyjadøují jakousi prùmìrnou hodnotu za období.
 Jedná se o 7 217 záznamù.  */
 
CREATE OR REPLACE VIEW v_product_price AS 	
	SELECT 
		YEAR(date_from) AS year_value,
		CONCAT(cpc.price_value, cpc.price_unit) AS unit,
		cpc.name AS name,
		cp.value AS price_Kc,
		cr.name AS name_of_region
	FROM czechia_price cp 
	JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code
	JOIN czechia_region cr 
		ON cp.region_code = cr.code;
	
/* Vytvoøení pohledu, ve kterém vidíme rok mìøení, hodnotu platu a název odvìtví. 
 Data jsou brána z tabulek czechia_payroll, czechia_payroll_value_type a czechia_payroll_industry_branch.
 Data jsou omezena na roky dle mìøení z tabulky cen potravin (2006-2018)
 Jedná se o datovou sadu, která obsahuje 1 976 záznamù.   */

CREATE OR REPLACE VIEW v_payroll_industry_branch AS
	SELECT 
		cp.payroll_year AS year_value,
		cp.value AS payroll_value,
		cpib.name AS name
	FROM czechia_payroll cp 
	JOIN czechia_payroll_value_type cpvt 
		ON cp.value_type_code = cpvt.code 
	JOIN czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code = cpib.code 
	WHERE 	 
		cp.value_type_code = '5958' AND 
		cp.payroll_year BETWEEN 2006 AND 2018;
	
/* Experiment: Vytvoøení indexu pro rychlejší poèítání prùmìrné ceny potravin a mezd. 
 * Bez toho operace trvá skoro 2s. */
CREATE OR REPLACE INDEX czechia_payroll_value__index ON czechia_payroll (value);
CREATE OR REPLACE INDEX czechia_price_value__index ON czechia_price (value);

/* Množinové spojení pohledù cen potravin, mezd a vytvoøení Tabulky 1 pro výzkumné otázky.
 * Tabulka má 589 záznamù */

CREATE TABLE IF NOT EXISTS t_frantisek_horak_projekt_SQL_primary_final AS
	SELECT 
		*
	FROM 
		(SELECT 
			year_value,
			name,
			ROUND(AVG(payroll_value),2) AS average
		FROM v_payroll_industry_branch vpib 
		GROUP BY 
			year_value ,
			name
		UNION
		SELECT 
			year_value,
			name , 
			ROUND(AVG(price_Kc),2) AS average
		FROM v_product_price vpp
		GROUP BY
			year_value,
			name ) AS union_payroll_product_price
	ORDER BY 
		year_value, name ;
		
-- Vytvoøení datových podkladù Tabulka 2
	
/* Vytvoøení výsledné Tabulky 2 pomocí spojení tabulek Countries, Economies. 
 * Tabulka obsahuje rok, název zemì, velikost populace, HDP a Giniho koeficient. 
 * Tabulka má 585 záznamù */	
	
CREATE TABLE IF NOT EXISTS t_frantisek_horak_projekt_SQL_secondary_final AS	
	SELECT 
		e.`year` ,
		c.country ,
		c.continent ,
		c.population ,
		e.GDP ,
		e.gini 
	FROM countries c 
	JOIN economies e 
		ON c.country = e.country 
	WHERE 
		c.continent IN ('Europe') AND 
		e.`year`BETWEEN 2006 AND 2018
	ORDER BY 
		e.`year`,
		c.country  ;
	
	
