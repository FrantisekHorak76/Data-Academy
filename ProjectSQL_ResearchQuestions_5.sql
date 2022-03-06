/*Vytvoøení pomocných tabulek pro vytvoøení odpovìdi na otázku è.5
 *Tabulka gdp_cze = HDP ÈR ve sledovaném období (2006-2018)
 *Tabulka avg_payroll_product_gdp_comparison = zde je vidìt meziroèní rùst, nebo pokles prùmìrné ceny potravin, mezd a HDP */
WITH gdp_cze AS (
	SELECT 
		`year` ,
		GDP 
	FROM t_frantisek_horak_projekt_sql_secondary_final tsf
	WHERE 
		country = 'Czech Republic'
),
	avg_payroll_product_gdp_comparison AS (	
		SELECT 
			vapp.year_value ,
			vapp.avg_product ,
			vapp.avg_product - LAG(vapp.avg_product) OVER (ORDER BY vapp.year_value) AS different_avg_product,
			vapp.avg_payroll ,
			vapp.avg_payroll  - LAG(vapp.avg_payroll) OVER (ORDER BY vapp.year_value) AS different_avg_payroll,
			gc.GDP ,
			gc.GDP - LAG(gc.GDP) OVER (ORDER BY vapp.year_value) AS different_GDP	
		FROM v_avg_payroll_product vapp  -- Pohled, který je vytvoøen pøi øešení otázky è.4
		JOIN gdp_cze gc 
			ON vapp.year_value = gc.`year` 
		GROUP BY 
			vapp.year_value ,
			vapp.avg_product ,
			gc.GDP
)
-- Vytvoøení výsledné tabulky na otázku è. 5.
SELECT 
 *,
 CASE 
 	WHEN different_avg_product > 0 AND different_avg_payroll > 0 AND different_GDP > 0 OR 
 		 different_avg_product < 0 AND different_avg_payroll < 0 AND different_GDP < 0 THEN 'HDP ma vliv na prumernou cenou potravin a mezd' 
 	ELSE 'HDP nema vliv na prumernou cenou potravin a mezd'
 END AS `result` 		
FROM avg_payroll_product_gdp_comparison vapgc 
