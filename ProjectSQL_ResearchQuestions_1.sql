/* Vytvoøení pohledu, ve kterém lze najít srovnání mezd v sledovaném období v jednotlivých odvìtvích s tím, zda mzda v každém roce roste èi nikoliv
 * Je využit ve výsledných pøíkazech SELECT*/

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

/* Výsledná odvìtví, ve kterých po sledované období každý rok plat nerostl	
   Byl vyøazen rok 2006, který je poèáteèní a dìlal by potíž ve správném 
   výpoètu díky funkci LAG, která nerozlišuje v použitém pohledu jednotlivá odvìtví. */
SELECT  
	DISTINCT vpc.name, vpc.code 
FROM v_payroll_comparison vpc 
WHERE 
	`condition` = 'declining' ;

/* Výsledná odvìtví, ve kterých po sledované období každý rok plat rostl*/
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
