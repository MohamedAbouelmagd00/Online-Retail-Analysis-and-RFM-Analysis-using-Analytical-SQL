# Online Retail Analysis and RFM Analysis using Analytical SQL

This target is to perform analysis on the OnlineRetail data to track the customer behavior, and get insights, catch the customers' patterns and get the most effective way to target the customers

## Background:

Customers has purchasing transaction that we shall be monitoring to get intuition behind each customer behavior to target the customers in the most efficient and proactive way, to increase sales/revenue , improve customer retention and decrease churn.

> All the operations on the dataset will be performed using ***Analytica SQL*** Functions to get useful business requirements.
> 

### 1st Exploring the *OnlineRetail* data using Analytical SQL to tell a story.

- writing small description about the business meaning behind each query

---

### Then, Performing ***RFM Analysis*** on the *OnlineRetail* data

- Implementing a *Monetary model* for customers behavior for product purchasing and segment each customer.

---

---

## 1st Exploring the *OnlineRetail* data using Analytical SQL to tell a story.

- writing small description about the business meaning behind each query

### Starting with figuring out the countries in the market and their count.

```sql
-- figuering out the countries in the market and their count.
SELECT country, COUNT(*) OVER(PARTITION BY COUNTRY)
FROM tableretail
GROUP BY country;
```

![Untitled](Online%20Retail%20Analysis%20and%20RFM%20Analysis%20using%20Anal%20f8698dd45dac4ca889e5a3a718bbb1e4/Untitled.png)

- Getting to know the market countries and its count, I found that there is one country in the date set **UK United Kingdom** , So the currency we have here in (GBP)

### Getting the total quantity sold for each stock

```sql
-- getting the total quantity sold for each stock
SELECT DISTINCT stockcode, quantity, price
		, SUM(quantity)  OVER(PARTITION BY stockcode ) AS "Total_sold/stock"
FROM tableretail
ORDER BY "Total_sold/stock" DESC ;
```

![Untitled](Online%20Retail%20Analysis%20and%20RFM%20Analysis%20using%20Anal%20f8698dd45dac4ca889e5a3a718bbb1e4/Untitled%201.png)

- Found that there is a very big difference between stocks in the amount sold as the highest stock is  sold 7824 while the lowest is sold only 1 time so I needed to check another factor like the total sells in (GBP) for each stock.

### Getting total sells in (GBP) for each stock

```sql
-- Getting total sells in (GBP) for each stock
SELECT DISTINCT stockcode, quantity, price
		, ROUND(SUM(Quantity * Price) OVER(PARTITION BY stockcode )) AS "Total sells (GBP)/stock"
FROM tableretail
ORDER BY "Total sells (GBP)/stock" DESC ;
```

![Untitled](Online%20Retail%20Analysis%20and%20RFM%20Analysis%20using%20Anal%20f8698dd45dac4ca889e5a3a718bbb1e4/Untitled%202.png)

- I found that the highest stock to get sells in (GBP) is 9115 mean while there is plenty of other items which have not been touched in the stores or sold only once or twice. It started to get clue about which items is gets more profit.

### Ranking to get the best seller stock.

```sql
-- ranking the stocks from the best seller.
SELECT rnk.stockcode, rnk."Total_sold/stock"
		, DENSE_RANK() OVER(ORDER BY "Total_sold/stock" DESC)
FROM (SELECT DISTINCT stockcode
			, SUM(quantity)  OVER(PARTITION BY stockcode ) AS "Total_sold/stock"
		FROM tableretail) AS rnk;
```

![Untitled](Online%20Retail%20Analysis%20and%20RFM%20Analysis%20using%20Anal%20f8698dd45dac4ca889e5a3a718bbb1e4/Untitled%203.png)

- Getting the best seller stock tells us what our customers need exactly!, what category we want to invest in more? , and it can indicate related items that our customers may be interested in as we want to keep all possibilities open to get more revenue.

### Getting the accumulative amount of money each customer spend

```sql
SELECT DISTINCT customer_ID
		, ROUND(SUM(Quantity * PRICE) OVER (PARTITION BY customer_ID )) AS "Total_purchased (GBP)/customer"
FROM tableretail
ORDER BY "Total_purchased (GBP)/customer" DESC;
```

![Untitled](Online%20Retail%20Analysis%20and%20RFM%20Analysis%20using%20Anal%20f8698dd45dac4ca889e5a3a718bbb1e4/Untitled%204.png)

- The total amount of money spend for each customer can be useful to make promotions for the customers when they break a certain limit so that keeps them motivated to do more shopping and spend more money. and based on that we can simply rank the customers.

### Ranking the top customers based on their total sales amount

```sql
-- ranking the top customers based on their total sales amount
SELECT cus.customer_ID, "Total_purchased (GBP)/customer"
	, DENSE_RANK() OVER(ORDER BY "Total_purchased (GBP)/customer" DESC)
FROM  (SELECT DISTINCT customer_ID
			, ROUND(SUM(Quantity * PRICE) OVER (PARTITION BY customer_ID )) AS "Total_purchased (GBP)/customer"
		FROM tableretail) AS cus;
```

![Untitled](Online%20Retail%20Analysis%20and%20RFM%20Analysis%20using%20Anal%20f8698dd45dac4ca889e5a3a718bbb1e4/Untitled%205.png)

- Ranking the customers can be useful in analysis as studying the top ranking customers can identify more clearly the customer segment that we need to focus our effort on.
- It can indicates other segments that we need to attract to buy more.
- It also can give a way of motivation for customers to make them buy more and spend more money for example by giving the top ranking customers valuable gifts.

### Engaging time in the analysis by getting the total sold amount per each date

```sql
-- total amount sold per each date
SELECT DISTINCT invoicedate
		, COUNT(*) OVER(PARTITION BY invoicedate) AS counting
FROM tableretail
ORDER BY counting DESC;
```

![Untitled](Online%20Retail%20Analysis%20and%20RFM%20Analysis%20using%20Anal%20f8698dd45dac4ca889e5a3a718bbb1e4/Untitled%206.png)

- Getting the time into the equation makes every thing clear as time is useful in explaining other factors.
- Looking at the amount sold per each date can indicates the golden days that I need to focus on to get more sales as in special occasions, and the times I need to find a channel to get more sales in depression days.

---

---

---

---

## Part 2 Performing ***RFM Analysis*** on the *OnlineRetail* data.

- implementing a Monetary model for customers behavior for product purchasing and segment each customer based on the following 10 categories :-
    - [ Champions - Loyal Customers - Potential Loyalists – Recent Customers – Promising - Customers Needing Attention - At Risk - Cant Lose Them – Hibernating – Lost ]
- The customers will be grouped based on 3 main values
    - **Recency** => how recent the last transaction is (Hint: choose a reference date, which is
    the most recent purchase in the dataset )
    - **Frequency** => how many times the customer has bought from our store
    - **Monetary** => how much each customer has paid for our products.
- As there are many groups for each of the R, F, and M features, there are also many potential permutations, this number is too much to manage in terms of marketing strategies.
    - For this, we would decrease the permutations by getting the average scores of the frequency and monetary (as both of them are indicative to purchase volume anyway
- Customers will be labeled based on the below values

![Untitled](Online%20Retail%20Analysis%20and%20RFM%20Analysis%20using%20Anal%20f8698dd45dac4ca889e5a3a718bbb1e4/Untitled%207.png)

```sql
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
```

![Untitled](Online%20Retail%20Analysis%20and%20RFM%20Analysis%20using%20Anal%20f8698dd45dac4ca889e5a3a718bbb1e4/Untitled%208.png)

---

---

---

---