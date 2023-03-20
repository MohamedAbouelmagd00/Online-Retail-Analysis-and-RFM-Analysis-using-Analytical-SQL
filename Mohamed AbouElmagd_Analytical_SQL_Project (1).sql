

-- figuering out the countries in the market and their count.
SELECT country, COUNT(*) OVER(PARTITION BY COUNTRY)
FROM tableretail
GROUP BY country;

-- aggrigating per stock to get the highest stock in sales
SELECT DISTINCT stockcode, quantity, price
		, SUM(quantity) 		      OVER(PARTITION BY stockcode ) AS "Total_sold/stock"
		, COUNT(customer_ID)		  OVER(PARTITION BY stockcode ) AS "Total different people purchased"
		, ROUND(SUM(Quantity * Price) OVER(PARTITION BY stockcode )) AS "Total sells (GBP)/stock"
FROM tableretail
ORDER BY "Total_sold/stock" DESC ;

-- getting the total quantity sold for each stock
SELECT DISTINCT stockcode, quantity, price
		, SUM(quantity)  OVER(PARTITION BY stockcode ) AS "Total_sold/stock"
FROM tableretail
ORDER BY "Total_sold/stock" DESC ;

SELECT DISTINCT stockcode, quantity, price
		, COUNT(customer_ID)		  OVER(PARTITION BY stockcode ) AS "Total different people purchased"
FROM tableretail
ORDER BY "Total different people purchased" DESC ;

-- Getting total sells in (GBP) for each stock
SELECT DISTINCT stockcode, quantity, price
		, ROUND(SUM(Quantity * Price) OVER(PARTITION BY stockcode )) AS "Total sells (GBP)/stock"
FROM tableretail
ORDER BY "Total sells (GBP)/stock" DESC ;
-- ranking the stocks from the best seller.
SELECT rnk.stockcode, rnk."Total_sold/stock"
		, DENSE_RANK() OVER(ORDER BY "Total_sold/stock" DESC)
FROM (SELECT DISTINCT stockcode
			, SUM(quantity)  OVER(PARTITION BY stockcode ) AS "Total_sold/stock"
		FROM tableretail) AS rnk;

-- Gettign the average amout of money a customer spend 
SELECT DISTINCT customer_ID
		, AVG(Quantity * PRICE) OVER (PARTITION BY customer_ID ) AS "AVG_purchased (GBP)/customer"
FROM tableretail
ORDER BY "AVG_purchased (GBP)/customer" DESC;

-- getting the accomulative amount of money each customer spend 
SELECT DISTINCT customer_ID
		, ROUND(SUM(Quantity * PRICE) OVER (PARTITION BY customer_ID )) AS "Total_purchased (GBP)/customer"
FROM tableretail
ORDER BY "Total_purchased (GBP)/customer" DESC;

-- ranking the top customers based on thier total sales amount
SELECT cus.customer_ID, "Total_purchased (GBP)/customer"
	, DENSE_RANK() OVER(ORDER BY "Total_purchased (GBP)/customer" DESC)
FROM  (SELECT DISTINCT customer_ID
			, ROUND(SUM(Quantity * PRICE) OVER (PARTITION BY customer_ID )) AS "Total_purchased (GBP)/customer"
		FROM tableretail) AS cus;
		
-- total amount sold per each date
SELECT DISTINCT invoicedate
		, COUNT(*) OVER(PARTITION BY invoicedate) AS counting
FROM tableretail
ORDER BY counting DESC;



-- 2 




WITH customer_seg AS (SELECT DISTINCT customer_id
					  , COUNT(*) 			OVER (PARTITION BY customer_id) AS number_of_ORders
					  , SUM(quantity*price) OVER (PARTITION BY customer_id) AS sum_cost_fOR_each_customer
					  , ROUND(MAX(TO_DATE(invoicedate, 'MM/DD/YYYY HH24:MI')) 
							  				OVER() - MAX(TO_DATE(invoicedate, 'MM/DD/YYYY HH24:MI')) 
							  				OVER(PARTITION BY customer_id)) AS Recency
						FROM tableretail)
							, customer_ranking AS (SELECT DISTINCT customer_id
												   , NTILE(5) OVER (ORDER BY number_of_ORders) AS frequency
												   , NTILE(5) OVER (ORDER BY sum_cost_fOR_each_customer) AS monetary
												   , NTILE(5) OVER (ORDER BY RECENCY) AS r_score
									               , (NTILE(5) OVER (ORDER BY number_of_ORders) + NTILE(5) OVER (ORDER BY sum_cost_fOR_each_customer))/2 AS fm_score 
									   FROM customer_seg
									     			)
									   				SELECT DISTINCT Cs.customer_ID, Cs.Recency, Cr.frequency,Cr.monetary, Cr.r_score, Cr.fm_score
													 			,CASE 
																	WHEN((R_SCORE = 5) AND (FM_SCORE  =5 )) OR ((R_SCORE = 5) AND (FM_SCORE  =4 )) OR((R_SCORE = 4) AND (FM_SCORE  =4 ))
																	THEN 'Champions'
																	WHEN ( (R_SCORE = 5) AND (FM_SCORE  =2 ) ) OR ( (R_SCORE = 4) AND (FM_SCORE  =2 )) OR ( (R_SCORE = 3) AND (FM_SCORE  =3 ))OR ( (R_SCORE = 4) AND (FM_SCORE  =3 ))  
																	THEN 'Potential Loyalists'
																	WHEN ( (R_SCORE = 5) AND (FM_SCORE  =3)) OR ( (R_SCORE = 4) AND (FM_SCORE  =4)) OR ( (R_SCORE = 3) AND (FM_SCORE  =5 )) OR ( (R_SCORE = 3) AND (FM_SCORE  =4 )) 
																	THEN 'Loyal Customers'
																	WHEN (R_SCORE = 5) AND (FM_SCORE  =1 )
																	THEN 'Recent Customers'
																	WHEN ((R_SCORE = 4) AND (FM_SCORE  =1)) OR ( (R_SCORE = 3) AND (FM_SCORE  =1))
																	THEN 'Promising'
																	WHEN ( (R_SCORE = 3) AND (FM_SCORE  =2)) OR ( (R_SCORE = 2) AND (FM_SCORE  =3)) OR ( (R_SCORE = 2) AND (FM_SCORE  =2))
																	THEN ' Customers Needing Attention'
																	WHEN ((R_SCORE = 2) AND (FM_SCORE  =5 )) OR ( (R_SCORE = 2) AND (FM_SCORE  =4 )) OR ( (R_SCORE = 1) AND (FM_SCORE  =3))
																	THEN 'At Risk'
																	WHEN ((R_SCORE = 1) AND (FM_SCORE  =5 )) OR ((R_SCORE = 1) AND (FM_SCORE  =4)) 
																	THEN 'cant lose them'
																	WHEN (R_SCORE = 1) AND (FM_SCORE  =5 ) 
																	THEN 'Hibernating '
																	WHEN (R_SCORE =1) AND (FM_SCORE =2) 
																	THEN 'Hibernating'
																	WHEN (R_SCORE =1) AND (FM_SCORE =1 )
																	THEN 'Lost'
																	ELSE 'other'
																	END AS rfm_segment

											  FROM  customer_seg cs,customer_ranking cr
											  WHERE Cs.CUSTOMER_ID=Cr.CUSTOMER_ID;