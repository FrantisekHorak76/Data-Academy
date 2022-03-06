/* Vytvo�en� pohled�, kter� budou pou�ity pro v�sledn� �e�en� ot�zky �.4 a �.5:
 * v_avg_product = pr�m�rnou cenu ze v�ech jednotliv�ch potravin v letech 2006 - 2018 
 * v_avg_payroll = pr�m�rnou mzdu ze v�ech jednotliv�ch odv�tv� v letech 2006 - 2018 
 * v_avg_payroll_product = spoj� tabulky v_avg_product a v_avg_payroll, tak aby pr�m�rn� hodnoty potravin a mezd v dan�m obdob� 
 * byly v samostatn�ch sloupc�ch */	

CREATE OR REPLACE VIEW v_avg_product AS
	SELECT 
		tpf.year_value ,
		avg(average) AS avg_product
	FROM t_frantisek_horak_projekt_sql_primary_final tpf
	WHERE tpf.code IS NULL
	GROUP BY tpf.year_value;

CREATE OR REPLACE VIEW v_avg_payroll AS
	SELECT 
		tpf.year_value ,
		avg(average) AS avg_payroll
	FROM t_frantisek_horak_projekt_sql_primary_final tpf
	WHERE tpf.code IS NOT NULL
	GROUP BY tpf.year_value;

CREATE OR REPLACE VIEW v_avg_payroll_product AS
SELECT 
	vap.year_value ,
	vap.avg_product ,
	vap2.avg_payroll 
FROM v_avg_product vap 
JOIN v_avg_payroll vap2 
	ON vap.year_value = vap2.year_value ;

/* Vytvo�en� v�sledn� tabulky, ve kter� lze naj�t meziro�n� procentu�ln� rozd�l pro pr�m�rnou cenu potravin a mezd v obdob� 2006-2018 
 * a n�sledn� vyhodnocen� podle podm�nky z v�zkumn� ot�zky*/
SELECT 
	vapp.year_value ,
	ROUND(((vapp.avg_product  / LAG(vapp.avg_product) OVER ( ORDER BY vapp.year_value)-1)*100),2)  AS "difference_product_percent",
	ROUND(((vapp.avg_payroll / LAG(vapp.avg_payroll) OVER (ORDER BY vapp.year_value)-1)*100),2)  AS "difference_payroll_percent",
	IF (ROUND(((vapp.avg_product  / LAG(vapp.avg_product) OVER ( ORDER BY vapp.year_value)-1)*100),2) > 10, "Mezirocni narust cen potravin je vetsi nez 10%", "Mezirocni narust cen potravin je mensi nez 10%" ) AS 'result'
FROM v_avg_payroll_product vapp 
GROUP BY vapp.year_value;
