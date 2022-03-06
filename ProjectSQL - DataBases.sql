-- VYTVO�EN� DATOV�CH PODKLAD� TABULKA 1 

/* Vytvo�en� indexu pro rychlej�� po��t�n� pr�m�rn� ceny potravin a mezd. Bez toho operace trv� skoro 2s. */

CREATE OR REPLACE INDEX czechia_payroll_value__index ON czechia_payroll (value);
CREATE OR REPLACE INDEX czechia_price_value__index ON czechia_price (value);

CREATE TABLE IF NOT EXISTS t_frantisek_horak_projekt_SQL_primary_final AS 
/* Vytvo�en� pomocn�ch tabulek pro z�sk�n� tabulky v�sledn�.
 * Tabulka product_price = rok m��en�, jednotku produktu, n�zev produktu a jeho cenu v jednotliv�ch kraj�ch.
     - Data jsou br�na z tabulek czechia_price, czechia_price_category a czechia_region.
     - Jedn� se o datovou sadu, kter� obsahuje 101 032 z�znam�. 
     - Z datov� sady byly odstran�ny z�znamy s nulovou hodnotou v region_code, kter� vyjad�uj� jakousi pr�m�rnou hodnotu za obdob� a v na�ich ot�zk�ch je nebudeme pot�ebovat.
     - Jedn� se o 7 217 z�znam�.  
 * Tabulka payroll_industry_branch = rok m��en�, hodnotu platu a n�zev odv�tv�. 
 	- Data jsou br�na z tabulek czechia_payroll, czechia_payroll_value_type a czechia_payroll_industry_branch.
 	- Data jsou omezena na roky dle m��en� z tabulky cen potravin (2006-2018)
 	- Jedn� se o datovou sadu, kter� obsahuje 1 976 z�znam�.*/
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
/* Vytvo�en� Tabulky 1 pro v�zkumn� ot�zky.
 	- Mno�inov� spojen� pomocn�ch tabulek cen potravin a mezd. 
 	- Spo��t�n� pr�m�rn� ceny jednotliv�ch potravin a pr�m�rn�ch plat� v jednotliv�ch odv�tv�ch  v jednotliv�ch letech sledovan�ho obdob�, 
   	- P�ipojen� k�du ozna�en� pro jednotliv� pr�myslov� odv�tv�, kter� vyu�ijeme p�i hled�n� odpov�di z jedn� zadan� ot�zky. 
   	- Tabulka m� 589 z�znam� */
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
		
-- VYTVO�EN� DATOV�CH PODKLAD� TABULKA 2
	
/* Vytvo�en� v�sledn� Tabulky 2 pomoc� spojen� tabulek Countries, Economies. 
   - Tabulka obsahuje rok, n�zev zem�, velikost populace, HDP a Giniho koeficient pro v�echny evropsk� zem� ve sledovan�m obdob� (2006-2018).
   - Tabulka m� 585 z�znam� */	
	
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
	

