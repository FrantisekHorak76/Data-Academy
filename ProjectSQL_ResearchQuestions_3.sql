/* Vytvo�en� pohledu, ve kter�m lze naj�t p�edv�sledek procentu�ln�ho rozd�lu jednotliv�ch potravin 
 * v jednotliv�ch letech sledovan�ho obdob�*/

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
		
/* Vytvo�en� v�sledn� odpov�di na ot�zku. Zde vid�me se�azen� jednotliv�ch potravin podle 
   pr�m�rn�ho procentu�ln�ho n�r�stu, nebo poklesu ceny za cel� obdob�.
   Byl vy�azen rok 2006, kter� je po��te�n� a d�lal by pot� ve spr�vn�m 
   v�po�tu d�ky funkci LAG, kter� nerozli�uje v pou�it�m pohledu jednotliv� potraviny.  */

SELECT 
  name, 
  ROUND(SUM(ROUND((difference - 1)*100,2))/12,2) AS avg_year_percentage_increase,
  ROUND(SUM(ROUND((difference - 1)*100,2)),2) AS avg_all_percentage_increase
FROM v_avg_product_difference vapd 
WHERE year_value != '2006'
GROUP BY  name
ORDER BY avg_year_percentage_increase ;
	