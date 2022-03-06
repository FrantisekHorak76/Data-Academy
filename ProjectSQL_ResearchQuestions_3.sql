/* Vytvoření pomocných tabulek pro výsledný výpočet
 * Tabulka avg_product_difference = meziroční procentuální rozdílu jednotlivých potravin ve sledovaném období
 * Tabulka avg_percentage = seřazení jednotlivých potravin podle průměrného meziročního procentuálního nárůstu, nebo poklesu ceny za celé období.*/

WITH avg_product_difference AS (
	SELECT 
		year_value ,
		name ,
		average ,
		((average / LAG(average) OVER (PARTITION BY name ORDER BY  name, year_value))-1)*100 AS "difference"
	FROM t_frantisek_horak_projekt_sql_primary_final tpf 
	WHERE code IS NULL 
	GROUP BY 
		year_value ,
		name ,
		average
	ORDER BY name, year_value
),
	avg_percentage AS (
		SELECT 
		 name, 
		 ROUND(AVG(difference),2) AS avg_year_percentage_increase,
		 ROUND(SUM(ROUND(difference,2)),2) AS avg_all_percentage_increase
	FROM avg_product_difference apd 
	GROUP BY  name
	ORDER BY avg_year_percentage_increase
)	
/* Vytvoření výsledné odpovědi na otázku č.3 */
SELECT 
	*
FROM avg_percentage 
WHERE  
	avg_year_percentage_increase IN ( 
		SELECT
			MIN(avg_year_percentage_increase)
		FROM avg_percentage
		WHERE avg_year_percentage_increase > 0) OR 
		avg_year_percentage_increase IN ( 
		SELECT
			MIN(avg_year_percentage_increase)
		FROM avg_percentage);
	
