/* Vytvo�en� pohledu, ve kter�m lze naj�t srovn�n� mezd v sledovan�m obdob� v jednotliv�ch odv�tv�ch s t�m, zda mzda v ka�d�m roce roste �i nikoliv
 * Je vyu�it ve v�sledn�ch p��kazech SELECT*/

CREATE OR REPLACE VIEW v_payroll_comparison AS
	SELECT 
		year_value ,
		name ,
		average ,
		code ,
		average - LAG(average) OVER (PARTITION BY code ORDER BY  code, year_value) AS "difference",
		IF (average - LAG(average) OVER (PARTITION BY code ORDER BY  code, year_value)< 0, "declining","grows") AS `condition`
	FROM t_frantisek_horak_projekt_sql_primary_final tfhpspf 
	WHERE code IS NOT NULL
	GROUP BY 
		year_value ,
		name ,
		average,
		code
	ORDER BY code, year_value;

/* V�sledn� odv�tv�, ve kter�ch po sledovan� obdob� ka�d� rok plat nerostl	
   Byl vy�azen rok 2006, kter� je po��te�n� a d�lal by pot� ve spr�vn�m 
   v�po�tu d�ky funkci LAG, kter� nerozli�uje v pou�it�m pohledu jednotliv� odv�tv�. */
SELECT  
	DISTINCT vpc.name, vpc.code 
FROM v_payroll_comparison vpc 
WHERE 
	`condition` = 'declining' ;

/* V�sledn� odv�tv�, ve kter�ch po sledovan� obdob� ka�d� rok plat rostl*/
SELECT 
	*
FROM (
	SELECT 
		cpib.name, cpib.code
	FROM czechia_payroll_industry_branch cpib
	EXCEPT
	SELECT  
		DISTINCT vpc.name, vpc.code 
	FROM v_payroll_comparison vpc 
	WHERE 
		`condition` = 'declining' 
	) AS grows_over_the_period;
