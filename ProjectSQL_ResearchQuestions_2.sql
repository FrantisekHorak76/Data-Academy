-- Research question two

/* Vytvoøení pohledu, ve kterém lze najít prùmìrnou cenu mléka v letech 2006, 2018*/
CREATE OR REPLACE VIEW v_avg_milk AS
	SELECT 
		year_value ,
		average AS avg_price_milk
	FROM t_frantisek_horak_projekt_sql_primary_final tpf
	WHERE 
		name = 'Mléko polotuèné pasterované' AND 
		(year_value = '2006' OR year_value = '2018');
	
/* Vytvoøení pohledu, ve kterém lze najít prùmìrnou cenu chleba v letech 2006, 2018*/
CREATE OR REPLACE VIEW v_avg_bread AS
	SELECT 
		year_value ,
		average AS avg_price_bread
	FROM t_frantisek_horak_projekt_sql_primary_final tpf
	WHERE 
		name = 'Chléb konzumní kmínový' AND 
		(year_value = '2006' OR year_value = '2018');
	
/* Vytvoøení pohledu, ve kterém lze najít prùmìrný plat ze všech odvìtví v letech 2006, 2018*/
CREATE OR REPLACE VIEW v_avg_payroll AS
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
	GROUP BY year_value ;

/* Výsledná odpovìï na výzkumnou otázku ohlednì možného množství koupì mléka a chleba na základì prùmìrného platu ze všech odvvìtví  v letech 2006, 2018*/

SELECT 
	vam.year_value ,
	vam.avg_price_milk ,
	vab.avg_price_bread,
	vap.avg_payroll ,
	ROUND(vap.avg_payroll / vam.avg_price_milk,2) AS possibility_milk,
	ROUND(vap.avg_payroll / vab.avg_price_bread ,2) AS possibility_bread
FROM v_avg_milk vam 
JOIN v_avg_payroll vap 
	ON vam.year_value = vap.year_value
JOIN v_avg_bread vab 
	ON vam.year_value = vab.year_value ;