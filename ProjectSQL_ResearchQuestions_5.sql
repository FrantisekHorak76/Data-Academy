-- Vytvo�en� pohledu, ve kter�m je vid�t ve sledovan�m obdob� HDPP �esk� republiky. 
CREATE OR REPLACE VIEW v_gdp_cze AS
	SELECT 
		`year` ,
		GDP 
	FROM t_frantisek_horak_projekt_sql_secondary_final tsf
	WHERE 
		country = 'Czech Republic';

-- Vytvo�en� pohledu,ve kter�m je vid�t meziro�n� r�st, nebo pokles pr�m�rn� ceny potravin, mezd, HDP
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

-- Vytvo�en� v�sledku ot�zky, zda HPP m� vliv na pr�m�rnou cenu potravin a mezd.
SELECT 
 *,
 CASE 
 	WHEN different_avg_product > 0 AND different_avg_payroll > 0 AND different_GDP > 0 OR 
 		 different_avg_product < 0 AND different_avg_payroll < 0 AND different_GDP < 0 THEN 'HDP ma vliv na prumernou cenou potravin a mezd' 
 	ELSE 'HDP nema vliv na prumernou cenou potravin a mezd'
 END AS `result` 		
FROM v_avg_payroll_product_gdp_comparison vapgc 
