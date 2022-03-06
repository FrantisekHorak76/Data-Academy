/* Vytvo�en� pomocn�ch tabulek pro v�sledn� v�po�et
 * Tabulka avg_product_difference = meziro�n� procentu�ln� rozd�lu jednotliv�ch potravin ve sledovan�m obdob�
 * Tabulka avg_percentage = se�azen� jednotliv�ch potravin podle pr�m�rn�ho meziro�n�ho procentu�ln�ho n�r�stu, nebo poklesu ceny za cel� obdob�.*/

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
/* Vytvo�en� v�sledn� odpov�di na ot�zku �.3 */
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
	