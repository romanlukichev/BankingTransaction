-- ===========================================================================================================
START TRANSACTION ;
-- ===========================================================================================================
SAVEPOINT before_money_transfer;
-- ===========================================================================================================
 SELECT a.cust_id  AS mm_cust_id    FROM account a
           WHERE a.cust_id IN
                       (SELECT c.cust_id FROM individual i
                         INNER JOIN customer c
                          ON i.cust_id = c.cust_id
                          WHERE i.fname = 'Frank' AND i.lname = 'Tucker')
           AND a.product_cd = 'MM' -- money market account
INTO @mm_cust_id;

SELECT '@mm_cust_id = ' , @mm_cust_id ;

UPDATE account SET last_activity_date = CURRENT_TIMESTAMP() , pending_balance = pending_balance - 50  , avail_balance = avail_balance - 50  -- Transfer from money market account
WHERE  cust_id = @mm_cust_id AND product_cd = 'MM';  -- Withdraw money from Money Market Account

-- ===========================================================================================================
SELECT a.cust_id     FROM account a
           WHERE a.cust_id IN
                       (SELECT c.cust_id FROM individual i
                         INNER JOIN customer c
                          ON i.cust_id = c.cust_id
                          WHERE i.fname = 'Frank' AND i.lname = 'Tucker')
           AND a.product_cd = 'CHK' -- checking account
INTO @chk_cust_id;

SELECT '@chk_cust_id = ' , @chk_cust_id ;

UPDATE account SET  last_activity_date = CURRENT_TIMESTAMP() ,   pending_balance = pending_balance + 50 , avail_balance = avail_balance + 50 -- Transfer to checking account
WHERE  cust_id = @chk_cust_id AND product_cd = 'CHK';

-- ===========================================================================================================

INSERT INTO transaction (txn_date, account_id, txn_type_cd, amount, teller_emp_id, execution_branch_id, funds_avail_date)
    VALUES (
      CURRENT_TIMESTAMP() ,
      @chk_cust_id , -- checking account
      'CDT',
      50 ,
      NULL  ,
      NULL  ,
      CURRENT_TIMESTAMP()
    );
-- ===========================================================================================================
SELECT '@chk_cust_id = ' , @chk_cust_id ;
-- ===========================================================================================================
INSERT INTO transaction (txn_date, account_id, txn_type_cd, amount, teller_emp_id, execution_branch_id, funds_avail_date)
    VALUES (
      CURRENT_TIMESTAMP() ,
      @mm_cust_id , -- money market account
      'DBT',
      50 ,
      NULL  ,
      NULL  ,
      CURRENT_TIMESTAMP()
    );
-- ===========================================================================================================
SELECT '@mm_cust_id = ' , @mm_cust_id ;
-- ===========================================================================================================
COMMIT ;
-- ===========================================================================================================
