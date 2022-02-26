-- Vytvo�en� datov�ch podklad� Tabulka 1 

/* Vytvo�en� pohledu, ve kter�m vid�me rok m��en�, jednotku produktu, n�zev produktu a
 jeho cenu v jednotliv�ch kraj�ch.
 Data jsou br�na z tabulek czechia_price, czechia_price_category a czechia_region.
 Jedn� se o datovou sadu, kter� obsahuje 101 032 z�znam�. Z datov� sady byly odstran�ny
 z�znamy s nulovou hodnotou v region_code, kter� vyjad�uj� jakousi pr�m�rnou hodnotu za obdob�.
 Jedn� se o 7 217 z�znam�.  */
 
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
	
/* Vytvo�en� pohledu, ve kter�m vid�me rok m��en�, hodnotu platu a n�zev odv�tv�. 
 Data jsou br�na z tabulek czechia_payroll, czechia_payroll_value_type a czechia_payroll_industry_branch.
 Data jsou omezena na roky dle m��en� z tabulky cen potravin (2006-2018)
 Jedn� se o datovou sadu, kter� obsahuje 1 976 z�znam�.   */

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
	
/* Experiment: Vytvo�en� indexu pro rychlej�� po��t�n� pr�m�rn� ceny potravin a mezd. 
 * Bez toho operace trv� skoro 2s. */
CREATE OR REPLACE INDEX czechia_payroll_value__index ON czechia_payroll (value);
CREATE OR REPLACE INDEX czechia_price_value__index ON czechia_price (value);

/* Mno�inov� spojen� pohled� cen potravin, mezd a vytvo�en� Tabulky 1 pro v�zkumn� ot�zky.
 * Tabulka m� 589 z�znam� */

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
		
-- Vytvo�en� datov�ch podklad� Tabulka 2
	
/* Vytvo�en� v�sledn� Tabulky 2 pomoc� spojen� tabulek Countries, Economies. 
 * Tabulka obsahuje rok, n�zev zem�, velikost populace, HDP a Giniho koeficient. 
 * Tabulka m� 585 z�znam� */	
	
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
	
	
