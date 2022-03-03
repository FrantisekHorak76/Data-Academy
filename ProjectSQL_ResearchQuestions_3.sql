/* Vytvoøení pohledu, ve kterém lze najít pøedvýsledek procentuálního rozdílu jednotlivých potravin 
 * v jednotlivých letech sledovaného období*/

CREATE OR REPLACE VIEW v_avg_product_difference AS 
	SELECT 
		year_value ,
		name ,
		average ,
		average / LAG(average) OVER (ORDER BY  name, year_value) AS "difference"
	FROM t_frantisek_horak_projekt_sql_primary_final tpf 
	WHERE code IS NULL
	GROUP BY 
		year_value ,
		name ,
		average
	ORDER BY name, year_value;
		
/* Vytvoøení výsledné odpovìdi na otázku. Zde vidíme seøazení jednotlivých potravin podle 
   prùmìrného procentuálního nárùstu, nebo poklesu ceny za celé období.
   Byl vyøazen rok 2006, který je poèáteèní a dìlal by potíž ve správném 
   výpoètu díky funkci LAG, která nerozlišuje v použitém pohledu jednotlivé potraviny.  */

SELECT 
  name, 
  ROUND(SUM(ROUND((difference - 1)*100,2))/12,2) AS avg_year_percentage_increase,
  ROUND(SUM(ROUND((difference - 1)*100,2)),2) AS avg_all_percentage_increase
FROM v_avg_product_difference vapd 
WHERE year_value != '2006'
GROUP BY  name
ORDER BY avg_year_percentage_increase ;
	