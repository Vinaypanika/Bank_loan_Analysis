# Bank_loan_Dashboard

## KPI Calculations

### **1. Total Loan Applications (Overall & MTD)**

```sql
select count(id) as Total_application,
count(case when month(issue_date) = month(getdate()) and 
year(issue_date) = year(getdate()) then id end) as MTD_Application
from loandata;
```

### **2. Total Funded Amount (Overall & MTD)**
``` sql
select sum(loan_amount) as Overall_fund,
sum(case when month(issue_date) = month(getdate()) and 
year(issue_date) = year(getdate()) then loan_amount else 0 end ) as MTD_total_fund
from loandata;
```

