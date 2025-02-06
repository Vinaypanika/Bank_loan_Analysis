# Bank_loan_Dashboard

## KPI Calculations

### **1. Total Loan Applications (Overall & MTD)**

```sql
select count(id) as Total_application,
count(case when month(issue_date) = month(getdate()) and 
year(issue_date) = year(getdate()) then id end) as MTD_Application
from loandata;
```
