/* Vytvo�en� pomocn�ch tabulek pro v�sledn� v�po�et
 * Tabulka avg_milk = pr�m�rn� cena ml�ka v letech 2006, 2018
 * Tabulka avg_bread = pr�m�rn� cena chleba v letech 2006, 2018
 * Tabulka avg_payroll = pr�m�rn� plat v letech 2006, 2018 */

WITH avg_milk AS (
	SELECT 
		year_value ,
		average AS avg_price_milk
	FROM t_frantisek_horak_projekt_sql_primary_final tpf
	WHERE 
		name = 'Ml�ko polotu�n� pasterovan�' AND 
		(year_value = '2006' OR year_value = '2018')
),
	avg_bread AS (
		SELECT 
			year_value ,
			average AS avg_price_bread
		FROM t_frantisek_horak_projekt_sql_primary_final tpf
		WHERE 
			name = 'Chl�b konzumn� km�nov�' AND 
			(year_value = '2006' OR year_value = '2018')
),
	avg_payroll AS (
		SELECT  
			year_value ,
			ROUND(AVG(average),2) AS avg_payroll
		FROM t_frantisek_horak_projekt_sql_primary_final tpf
		WHERE 
			year_value = '2006' AND 
		    code IS NOT NULL
		GROUP BY year_value 
		UNION   
		SELECT 
			year_value ,
			ROUND(AVG(average),2) AS avg_payrolL
		FROM t_frantisek_horak_projekt_sql_primary_final tpf
		WHERE 
			year_value = '2018' AND 
		    code IS NOT NULL
		GROUP BY year_value
)
/* V�sledn� odpov�� na v�zkumnou ot�zku ohledn� mo�n�ho mno�stv� koup� ml�ka a chleba na z�klad� pr�m�rn�ho platu ze v�ech odvv�tv� v letech 2006, 2018*/
SELECT 
	am.year_value ,
	am.avg_price_milk ,
	ab.avg_price_bread,
	ap.avg_payroll ,
	ROUND(ap.avg_payroll / am.avg_price_milk,2) AS possibility_milk,
	ROUND(ap.avg_payroll / ab.avg_price_bread ,2) AS possibility_bread
FROM avg_milk am 
JOIN avg_payroll ap 
	ON am.year_value = ap.year_value
JOIN avg_bread ab 
	ON am.year_value = ab.year_value ;