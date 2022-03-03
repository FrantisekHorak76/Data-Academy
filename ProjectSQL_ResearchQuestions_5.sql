-- Vytvoøení pohledu, ve kterém je vidìt ve sledovaném období HDPP Èeské republiky. 
CREATE OR REPLACE VIEW v_gdp_cze AS
	SELECT 
		`year` ,
		GDP 
	FROM t_frantisek_horak_projekt_sql_secondary_final tsf
	WHERE 
		country = 'Czech Republic';

-- Vytvoøení pohledu,ve kterém je vidìt meziroèní rùst, nebo pokles prùmìrné ceny potravin, mezd, HDP
CREATE OR REPLACE VIEW v_avg_payroll_product_gdp_comparison AS	
	SELECT 
		vapp.year_value ,
		vapp.avg_product ,
		vapp.avg_product - LAG(vapp.avg_product) OVER (ORDER BY vapp.year_value) AS different_avg_product,
		vapp.avg_payroll ,
		vapp.avg_payroll  - LAG(vapp.avg_payroll) OVER (ORDER BY vapp.year_value) AS different_avg_payroll,
		vgc.GDP ,
		vgc.GDP - LAG(vgc.GDP) OVER (ORDER BY vapp.year_value) AS different_GDP	
	FROM v_avg_payroll_product vapp 
	JOIN v_gdp_cze vgc 
		ON vapp.year_value = vgc.`year` 
	GROUP BY 
		vapp.year_value ,
		vapp.avg_product ,
		vgc.GDP;

-- Vytvoøení výsledku otázky, zda HPP má vliv na prùmìrnou cenu potravin a mezd.
SELECT 
 *,
 CASE 
 	WHEN different_avg_product > 0 AND different_avg_payroll > 0 AND different_GDP > 0 OR 
 		 different_avg_product < 0 AND different_avg_payroll < 0 AND different_GDP < 0 THEN 'HDP ma vliv na prumernou cenou potravin a mezd' 
 	ELSE 'HDP nema vliv na prumernou cenou potravin a mezd'
 END AS `result` 		
FROM v_avg_payroll_product_gdp_comparison vapgc 
