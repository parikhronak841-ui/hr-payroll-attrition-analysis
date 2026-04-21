# 👥 HR Payroll & Attrition Analysis

![SQL](https://img.shields.io/badge/SQL-MySQL%20%2F%20SQLite-orange?logo=mysql)
![Python](https://img.shields.io/badge/Python-3.9+-blue?logo=python)
![Domain](https://img.shields.io/badge/Domain-HR%20%2F%20Payroll-green)
![Excel](https://img.shields.io/badge/Power%20BI-Dashboard%20Ready-F2C811?logo=powerbi)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## 📌 Project Overview

A comprehensive HR and payroll analytics project using **SQL + Python** to analyze workforce costs, employee attrition, payroll trends, and compensation equity across departments. Directly relevant to **Payroll Coordinator, HR Analyst, and Finance Operations** roles.

---

## 🎯 Business Questions Answered

- What is the total payroll cost by department YTD?
- Which departments have the highest attrition rates?
- Are high-performing employees being properly compensated (retention risk)?
- Where is overtime cost highest — and is it a staffing signal?
- Are there payroll reconciliation errors (CRA compliance risk)?
- How does compensation vary by education level and gender?

---

## 🗂️ Database Schema

```
┌─────────────────┐     ┌───────────────────┐
│  departments    │     │    employees       │
│─────────────────│     │───────────────────│
│ dept_id (PK)    │────<│ emp_id (PK)        │
│ dept_name       │     │ dept_id (FK)       │
│ dept_head       │     │ job_title          │
│ budget          │     │ hire_date          │
└─────────────────┘     │ termination_date   │
                        │ status             │
         ┌──────────────│ gender, age        │
         │              └───────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌───────────────────┐
│    payroll      │     │   performance     │
│─────────────────│     │───────────────────│
│ payroll_id (PK) │     │ review_id (PK)    │
│ emp_id (FK)     │     │ emp_id (FK)       │
│ pay_period      │     │ review_year       │
│ gross_pay       │     │ rating (1–5)      │
│ net_pay         │     └───────────────────┘
│ tax_deducted    │
│ cpp_deducted    │
│ ei_deducted     │
│ overtime_pay    │
│ bonus           │
└─────────────────┘
```

---

## 🔧 Tools & Technologies

| Tool | Purpose |
|---|---|
| `SQL (MySQL / SQLite)` | 10 business queries across schema |
| `Python + SQLite3` | Data generation + query execution |
| `Pandas` | Data aggregation |
| `Plotly` | Interactive charts |

---

## 📊 SQL Queries Included

| # | Query | Business Purpose |
|---|---|---|
| Q1 | Payroll cost by department YTD | Budget tracking |
| Q2 | Monthly payroll trend | Period-over-period analysis |
| Q3 | Attrition rate by department | Workforce stability |
| Q4 | Attrition by tenure band | Onboarding effectiveness |
| Q5 | Gender pay gap analysis | Equity & compliance |
| Q6 | High performers with no bonus | Retention risk |
| Q7 | Top overtime earners | Staffing signal |
| Q8 | Payroll reconciliation / discrepancy check | CRA compliance |
| Q9 | New hire vs. attrition balance | Net headcount trend |
| Q10 | Education level vs. salary | Compensation benchmarking |

---

## 💡 Key Insights

1. **Overtime as a Staffing Signal** — Persistent overtime in key departments may cost more than hiring an additional FTE
2. **Early Attrition (1–3 Years)** — Highest attrition risk occurs in years 1–3; invest in structured onboarding
3. **Retention Risk** — High-performing employees with zero bonuses are a flight risk
4. **Payroll Reconciliation** — Automated discrepancy detection ensures CRA compliance and employee trust
5. **Gender Pay Equity** — Q5 surfaces department-level salary gaps for HR review

---

## 🇨🇦 Canadian Payroll Context

This project applies **Canadian payroll standards**:
- **CPP** (Canada Pension Plan) deductions — 5.95% employee contribution
- **EI** (Employment Insurance) deductions — 1.66% employee rate
- **CRA** compliance through payroll reconciliation checks
- Province-based workforce distribution (Ontario, BC, Alberta, Quebec, Manitoba)

---

## 📁 Project Structure

```
project4_hr_payroll/
│
├── hr_payroll_analysis.sql     # Full SQL query library (MySQL compatible)
├── hr_payroll_python.py        # Data generator + Python analysis
├── hr_payroll.db               # SQLite database (auto-generated)
├── payroll_by_dept.html        # Interactive chart
├── attrition_by_dept.html      # Interactive chart
├── monthly_payroll_trend.html  # Interactive chart
├── gender_by_dept.html         # Interactive chart
└── README.md                   # This file
```

---

## 🚀 How to Run

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/hr-payroll-analysis.git
cd hr-payroll-analysis

# 2. Install dependencies
pip install pandas numpy plotly

# 3. Run the Python analysis (generates DB + charts)
python hr_payroll_python.py

# 4. Explore SQL queries
# Open hr_payroll_analysis.sql in MySQL Workbench or DBeaver
# Connect to hr_payroll.db via SQLite for immediate testing
```

---

## 👤 Author

**Ronak Parikh**
- 📧 parikhronak841@gmail.com
- 💼 [LinkedIn](https://www.linkedin.com/in/yourprofile)
- 🎓 Business Administration – Finance | Conestoga College
- 📜 PCP (In Progress) | IFIC Mutual Fund License | IBM Data Analyst Certificate (In Progress)

---

## 📝 License

MIT License
