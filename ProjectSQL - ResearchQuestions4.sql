-- Research question four

/* Vytvo�en� pohledu, ve kter�m zjist�me pr�m�rnou cenu ze v�ech jednotliv�ch potravin v letech 2006 - 2018 */
CREATE OR REPLACE VIEW v_avg_product AS
	SELECT 
		tpf.year_value ,
		avg(average) AS avg_product
	FROM t_frantisek_horak_projekt_sql_primary_final tpf
	WHERE tpf.code IS NULL
	GROUP BY tpf.year_value;
	
/* Vytvo�en� pohledu, ve kter�m zjist�me pr�m�rnou mzdu ze v�ech jednotliv�ch odv�tv� v letech 2006 - 2018 */
CREATE OR REPLACE VIEW v_avg_payroll AS
	SELECT 
		tpf.year_value ,
		avg(average) AS avg_payroll
	FROM t_frantisek_horak_projekt_sql_primary_final tpf
	WHERE tpf.code IS NOT NULL
	GROUP BY tpf.year_value;
	
/* Vytvo�en� pohledu, ve kter�m se spoj� p�edchoz� pohledy, tak aby pr�m�rn� hodnoty potravin a mezd v dan�m obdov� byly v samostatn�ch sloupc�ch */
CREATE OR REPLACE VIEW v_avg_payroll_product AS
SELECT 
	vap.year_value ,
	vap.avg_product ,
	vap2.avg_payroll 
FROM v_avg_product vap 
JOIN v_avg_payroll vap2 
	ON vap.year_value = vap2.year_value ;
	

/* Vytvo�en� pohledu, ve kter�m se vytvo�� meziro�n� rozd�ly pro pr�m�rnou cenu potravin a mezd v obdob� 2006-2018 */
CREATE OR REPLACE VIEW v_avg_payroll_product_comparison AS
SELECT 
	vapp.year_value ,
	vapp.avg_product ,
	vapp.avg_product  / LAG(vapp.avg_product) OVER (ORDER BY vapp.year_value)  AS "difference_product",
	vapp.avg_payroll ,
	vapp.avg_payroll / LAG(vapp.avg_payroll) OVER (ORDER BY vapp.year_value)  AS "difference_payroll"
FROM v_avg_payroll_product vapp 
GROUP BY vapp.year_value, vapp.avg_product, vapp.avg_payroll  ;


/* P�eveden� rozd�lu na procentu�ln� vyj�d�en� a vytvo�en� v�sledku pro v�zkumnou ot�zku*/
SELECT 
	vappc .year_value ,
	ROUND((difference_product-1)*100 , 2) AS difference_product_percent,
	ROUND((difference_payroll-1)*100,2) AS difference_payroll_percent,
	IF (ROUND((difference_product-1)*100 , 2) > 10, "Mezirocni narust cen potravin je vetsi nez 10%", "Mezirocni narust cen potravin je mensi nez 10%" ) AS 'result'
FROM v_avg_payroll_product_comparison vappc ;
