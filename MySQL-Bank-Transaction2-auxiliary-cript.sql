
  -- Wrote some extra SQL queries to figure out how to write the main Transaction script.
  
SELECT a.avail_balance , a.pending_balance  FROM account a

SELECT a.cust_id , a.product_cd ,  a.avail_balance , a.pending_balance   FROM account a
WHERE a.cust_id IN
      (SELECT c.cust_id FROM individual i
INNER JOIN customer c
ON i.cust_id = c.cust_id
WHERE i.fname = 'Frank' AND i.lname = 'Tucker') ;

SELECT c.cust_id FROM individual i
INNER JOIN customer c
ON i.cust_id = c.cust_id
WHERE i.fname = 'Frank' AND i.lname = 'Tucker'
;

SELECT * FROM customer;

SELECT e.emp_id , e.fname , e.lname , a.product_cd , a.avail_balance , a.pending_balance  FROM employee e
INNER JOIN  account a
ON e.emp_id = a.open_emp_id;


-- ===========================================================================================================
START TRANSACTION ;

SAVEPOINT before_money_transfer;

UPDATE account SET avail_balance = avail_balance - 50  -- Transfer from money market account
WHERE  cust_id = (
           SELECT a.cust_id     FROM account a
           WHERE a.cust_id IN
                       (SELECT c.cust_id FROM individual i
                         INNER JOIN customer c
                          ON i.cust_id = c.cust_id
                          WHERE i.fname = 'Frank' AND i.lname = 'Tucker')
           AND a.product_cd = 'MM' -- money market account
);


UPDATE account SET avail_balance = avail_balance + 50  -- Transfer to checking account
WHERE  cust_id = (
           SELECT a.cust_id     FROM account a
           WHERE a.cust_id IN
                       (SELECT c.cust_id FROM individual i
                         INNER JOIN customer c
                          ON i.cust_id = c.cust_id
                          WHERE i.fname = 'Frank' AND i.lname = 'Tucker')
           AND a.product_cd = 'CHK' -- checking account
);

INSERT INTO transaction (txn_date, account_id, txn_type_cd, amount, teller_emp_id, execution_branch_id, funds_avail_date)
    VALUES (
      CURRENT_TIMESTAMP() ,
      (
        SELECT a.account_id FROM account a
        WHERE a.cust_id IN
        ( SELECT c.cust_id FROM individual i
          INNER JOIN customer c
                              ON i.cust_id = c.cust_id
                              WHERE i.fname = 'Frank' AND i.lname = 'Tucker')
        AND a.product_cd = 'CHK' -- checking account
      ) ,
      'CDT',
      50 ,
      NULL  ,
      NULL  ,
      CURRENT_TIMESTAMP()
    );

INSERT INTO transaction (txn_date, account_id, txn_type_cd, amount, teller_emp_id, execution_branch_id, funds_avail_date)
    VALUES (
      CURRENT_TIMESTAMP() ,
      (
        SELECT a.account_id FROM account a
        WHERE a.cust_id IN
        ( SELECT c.cust_id FROM individual i
          INNER JOIN customer c
                              ON i.cust_id = c.cust_id
                              WHERE i.fname = 'Frank' AND i.lname = 'Tucker')
        AND a.product_cd = 'MM' -- money market account
      ) ,
      'DBT',
      50 ,
      NULL  ,
      NULL  ,
      CURRENT_TIMESTAMP()
    );

-- ===========================================================================================================



SELECT * FROM  account WHERE cust_id = 3;




SELECT * FROM  transaction ;

DELETE FROM transaction WHERE txn_id BETWEEN 24 AND 28 ;

SELECT a.cust_id , a.product_cd ,  a.avail_balance , a.pending_balance , a.last_activity_date  FROM account a
WHERE a.cust_id IN
      (SELECT c.cust_id FROM individual i
INNER JOIN customer c
ON i.cust_id = c.cust_id
WHERE i.fname = 'Frank' AND i.lname = 'Tucker')
;

