-- VYTVOØENÍ DATOVÝCH PODKLADÙ TABULKA 1 

/* Vytvoøení indexu pro rychlejší poèítání prùmìrné ceny potravin a mezd. Bez toho operace trvá skoro 2s. */

CREATE OR REPLACE INDEX czechia_payroll_value__index ON czechia_payroll (value);
CREATE OR REPLACE INDEX czechia_price_value__index ON czechia_price (value);

CREATE TABLE IF NOT EXISTS t_frantisek_horak_projekt_SQL_primary_final AS 
/* Vytvoøení pomocných tabulek pro získání tabulky výsledné.
 * Tabulka product_price = rok mìøení, jednotku produktu, název produktu a jeho cenu v jednotlivých krajích.
     - Data jsou brána z tabulek czechia_price, czechia_price_category a czechia_region.
     - Jedná se o datovou sadu, která obsahuje 101 032 záznamù. 
     - Z datové sady byly odstranìny záznamy s nulovou hodnotou v region_code, které vyjadøují jakousi prùmìrnou hodnotu za období a v našich otázkách je nebudeme potøebovat.
     - Jedná se o 7 217 záznamù.  
 * Tabulka payroll_industry_branch = rok mìøení, hodnotu platu a název odvìtví. 
 	- Data jsou brána z tabulek czechia_payroll, czechia_payroll_value_type a czechia_payroll_industry_branch.
 	- Data jsou omezena na roky dle mìøení z tabulky cen potravin (2006-2018)
 	- Jedná se o datovou sadu, která obsahuje 1 976 záznamù.*/
	WITH product_price AS ( 	
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
			ON cp.region_code = cr.code
	),
		payroll_industry_branch AS (
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
			cp.payroll_year BETWEEN 2006 AND 2018
	)	
/* Vytvoøení Tabulky 1 pro výzkumné otázky.
 	- Množinové spojení pomocných tabulek cen potravin a mezd. 
 	- Spoèítání prùmìrné ceny jednotlivých potravin a prùmìrných platù v jednotlivých odvìtvích  v jednotlivých letech sledovaného období, 
   	- Pøipojení kódu oznaèení pro jednotlivá prùmyslová odvìtví, které využijeme pøi hledání odpovìdi z jedné zadané otázky. 
   	- Tabulka má 589 záznamù */
	SELECT 
		union_payroll_product_price.year_value ,
		union_payroll_product_price.name ,
		union_payroll_product_price.average,
		cpib.code
	FROM 
		(SELECT 
			year_value,
			name,
			ROUND(AVG(payroll_value),2) AS average
		FROM payroll_industry_branch vpib 
		GROUP BY 
			year_value ,
			name
		UNION
		SELECT 
			year_value,
			name , 
			ROUND(AVG(price_Kc),2) AS average
		FROM product_price vpp
		GROUP BY
			year_value,
			name ) AS union_payroll_product_price
	LEFT JOIN czechia_payroll_industry_branch cpib 
		ON union_payroll_product_price.name = cpib.name 
	ORDER BY 
		cpib.code, union_payroll_product_price.year_value;
		
-- VYTVOØENÍ DATOVÝCH PODKLADÙ TABULKA 2
	
/* Vytvoøení výsledné Tabulky 2 pomocí spojení tabulek Countries, Economies. 
   - Tabulka obsahuje rok, název zemì, velikost populace, HDP a Giniho koeficient pro všechny evropské zemì ve sledovaném období (2006-2018).
   - Tabulka má 585 záznamù */	
	
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
	

