
--KPI Calculations

-- 1. Total Loan Applications (Overall & MTD)
 
select count(id) as Total_application,
count(case when month(issue_date) = month(getdate()) and 
year(issue_date) = year(getdate()) then id end) as MTD_Application
from loandata
;

-- 2. Total Funded Amount (Overall & MTD)

select sum(loan_amount) as Overall_fund,
sum(case when month(issue_date) = month(getdate()) and 
year(issue_date) = year(getdate()) then loan_amount else 0 end ) as MTD_total_fund
from loandata;

--3. Total Amount Received (Overall & MTD)

select sum(total_payment) as Overall_amount_recieved,
sum(case when month(issue_date) = month(getdate()) and
year(issue_date) = year(getdate()) then total_payment else 0 end) as MTD_amount_recieved
from loandata;


--4. Average Interest Rate (Overall & MTD)

select round(avg(int_rate)*100.0,3) as Overall_intrest_rate,
round(avg(case when month(issue_date) = month(getdate()) and
year(issue_date) = year(getdate()) then int_rate end)*100.0,3) as MTD_Intrest_rate
from loandata;

--5. Average Debt-to-Income Ratio (DTI) (Overall & MTD)

select round(avg(dti)*100.0,3) as Overall_Dti,
round(avg(case when month(issue_date) = month(getdate()) and
year(issue_date) = year(getdate()) then dti end)*100.0,3) as MTD_Dti
from loandata;


-- Good Loan vs. Bad Loan KPIs

--1. Good Loan Application Percentage


select (count(case when loan_status in ('Fully Paid','Current') then id end)*100.0/count(id)) as 
good_loan_percentage from loandata;

-- 2. Good Loan Applications

select count(id) as good_loan_application from loandata
where loan_status in ('Fully Paid', 'Current');

--3. Good Loan Funded Amount

select sum(loan_amount) as Total_Good_load_fund
from loandata
where loan_status in ('Fully Paid', 'Current');

--4. Good Loan Total Received Amount

select sum(total_payment) as Total_Recived_Good_loan_amount
from loandata
where loan_status in ('Fully Paid', 'Current');

--5. Bad Loan Application Percentage

select count(case when loan_status ='Charged Off' then id end)*100.0/count(id)
as Bad_loan_percentage
from loandata;


--6. Bad Loan Applications

select count(id) as Bad_loan_application
from loandata
where loan_status ='Charged Off';

--7. Bad Loan Funded Amount

select sum(loan_amount) as Total_Bad_loan_fund
from loandata
where loan_status = 'Charged off';

--8. Bad Loan Total Received Amount

select sum(total_payment) as Total_Recived_Bad_loan_amount
from loandata 
where loan_status = 'Charged off';


-- Loan Status Grid View Report

/*Question:
How can we analyze the distribution of loans based on their status
while tracking key financial metrics such as total loan applications,
funded amounts, total received payments, month-to-date (MTD) funded amounts,
MTD received amounts, average interest rates, and average debt-to-income (DTI) ratios? */


select loan_status,
count(id) as Total_loan_applications,
sum(loan_amount) as Total_funded_amount,
sum(total_payment) as Total_recieved_amount,
sum(case when month(issue_date) = month(getdate()) and year(issue_date) = year(getdate()) then loan_amount end) as MTD_Funded_amount,
sum(case when month(issue_date) = month(getdate()) and year(issue_date) = year(getdate()) then total_payment end) as MTD_Received_amount,
round(avg(int_rate)*100.0,5) as Average_intrest_rate,
round(avg(dti)*100.0,5) as Average_Debt_to_income
from loandata
group by loan_status;


--Advanced SQL Questions

--1. Loan Performance Over Time
/* Question: How has the total loan amount, total received amount,
and average interest rate changed over the past 12 months? */

select year(issue_date) as year,
datename(month,issue_date) as month,
count(id) as Total_Loan_applications, 
sum(loan_amount) as Total_loan_amount,
sum(total_payment) as Total_received_amount,
round(avg(int_rate)*100.0,5) as Average_interest_rate
from loandata
where issue_date >= dateadd(year,-1,getdate())
group by year(issue_date),datename(month,issue_date),month(issue_date)
order by year(issue_date) desc,month(issue_date) desc;


--2. Loan Default Risk Analysis
/* Question: Which states have the highest percentage of 'Charged Off' loans,
and how does it compare to the total loans issued in each state? */

select address_state,
count(id) as Total_loan_applications,
count(case when loan_status = 'Charged off' then id end)*100.0/count(id) as default_Percentage
from loandata
group by address_state
order by count(case when loan_status = 'Charged off' then id end) desc;

--3. Borrowers with High Debt-to-Income (DTI) Ratio
/* Question: Which loan applicants have the highest debt-to-income (DTI) ratios,
and what is their repayment behavior? */

select top 5 emp_title,annual_income,
dti*100.0 as debt_to_income_ratio,
loan_amount,total_payment,loan_status
from loandata
order by dti desc;

-- 4. Good Loan vs. Bad Loan Funded Amount Trend
/* Question: How has the monthly funded amount for 'Good Loans' 
(Fully Paid, Current) and 'Bad Loans' (Charged Off) changed over the last year? */

select year(issue_date) as year,
datename(month,issue_date)as month,
sum(case when loan_status in ('Fully Paid','Current') then loan_amount else 0 end) as Total_Good_loan_fund,
sum(case when loan_status = 'Charged off' then loan_amount else 0 end) as total_bad_loan_fund
from loandata
where issue_date >= dateadd(year,-1,getdate())
group by year(issue_date),month(issue_date),datename(month,issue_date)
order by year(issue_date) desc,month(issue_date) desc,datename(month,issue_date) desc;

-- 5. Late Payments Analysis
/* Question: Which borrowers have the highest number of late payments,
and how does their loan status compare? */

select top 5 id,emp_title,loan_status,total_payment,last_payment_date,
datediff(day,last_payment_date,getdate()) as days_since_last_payment
from loandata
where loan_status in ('charged off','late') and
last_payment_date is NOT NULL
group by id,emp_title,loan_status,total_payment,last_payment_date
order by datediff(day,last_payment_date,getdate()) desc;

-- 6. Loan Repayment Behavior Based on Employment Title
/* Question: Which employment titles have the highest average loan amounts, 
and how does their repayment behavior differ? */

select top 5 emp_title,
count(id) as Loan_count,
avg(Loan_amount) as Average_Loan_amount,
sum(total_payment)*100.0/sum(loan_amount) as Percentage_of_repayment
from loandata
group by emp_title
order by avg(Loan_amount) desc;


