# 👥 HR Employee Attrition Analysis | Power BI · DAX · SQL · Power Query

> **People Analytics / HR Analytics case study:** where are employees leaving, who is most at risk, and what should HR do first?

**Keywords:** `HR Analytics` · `People Analytics` · `Employee Attrition` · `Power BI` · `DAX` · `Power Query (M)` · `SQL Server / T-SQL` · `Star Schema` · `Data Modeling` · `Data Cleaning` · `KPI Dashboard` · `Outlier Detection (IQR)` · `Root Cause Analysis` · `Data Storytelling` · `Business Recommendations`

<p align="center">
  <img src="hr-attrition-repo/images/dashboard_page1_overview.png" alt="HR Attrition Dashboard, page 1: KPIs and attrition by department, age group, overtime and tenure" width="100%">
</p>

---

## 📌 At a Glance

| | |
|---|---|
| **Dataset** | 1,470 employees × 35 columns (one flat HR table) |
| **Outcome** | 237 employees left → **16.12% attrition rate** |
| **Deliverables** | Star-schema data model · DAX measures · 2-page Power BI dashboard · SQL query · written recommendations · 5-minute presentation |
| **Tools** | Power BI, Power Query, DAX, SQL Server (SSMS) |
| **Biggest signal** | Overtime: **30.53%** attrition vs **10.44%** without it |

---

## 📖 The Story

A large organization noticed that employees kept leaving, but nobody could say **where the problem was concentrated** or **what was linked to it**. Leadership didn't want a static report. They wanted to know **where to look first**.

I was handed one flat HR table and an open brief:

> *Model the data, find the patterns behind attrition, and tell us what to do about it.*

**Chapter 1: Understand and clean the data.** Before building anything I checked the table: no empty or error values, `EmployeeNumber` is unique, and three columns (`EmployeeCount`, `Over18`, `StandardHours`) hold a single value for everyone, so I removed them. `Attrition` was converted from Yes/No to **1 = left, 0 = stayed** so it can be counted and averaged.

**Chapter 2: Build a proper model.** A flat file is hard to maintain, so I split it into a **star schema**: one fact table and five dimensions.

**Chapter 3: Ask the right questions.** Where do exits concentrate? Who leaves, and how early? Does overtime matter? Does pay matter? Are high-income outliers a problem, or just senior roles?

**Chapter 4: Turn answers into actions.** Every finding ended in a recommendation HR can test on a small group and measure.

---

## 🎯 Business Questions

1. How large is the attrition problem, and where does it concentrate (department, job role)?
2. Which groups leave the most (age group, tenure)?
3. Is overtime linked to attrition, and in which roles?
4. Is income linked to attrition, and are income outliers a concern?
5. What should HR do first, and how will it know it worked?

---

## 🧹 Data Preparation (Power Query)

| Step | What I did | Why |
|---|---|---|
| 1 | Loaded the table into a base query (`HR_Base`, not loaded to the model) | One clean source for every dimension |
| 2 | Changed data types and removed `EmployeeCount`, `Over18`, `StandardHours` | Constant columns add no information |
| 3 | Replaced `Attrition` Yes/No with **1/0** | Enables counting and rate calculations |
| 4 | Added an `AgeGroup` conditional column | Makes age analysis readable |
| 5 | Created each dimension with **Reference**: keep needed columns → remove duplicates → add index key → rename → reorder | Clean, deduplicated dimensions with surrogate keys |
| 6 | Merged the keys back into `Fact_Employee` and expanded them | Fact table keeps numbers plus keys |

---

## 🧱 Data Model (Star Schema)

<p align="center">
  <img src="hr-attrition-repo/images/data_model.png" alt="Star schema data model: Fact_Employee with five dimension tables and a Measures table" width="100%">
</p>

| Table | What it holds |
|---|---|
| `Fact_Employee` | Age, monthly income, distance from home, years at company, tenure group, Attrition flag, and the dimension keys |
| `Dim_Job` | Department, job role, job level |
| `Dim_Demographics` | Age group, gender, marital status |
| `Dim_Education` | Education level and field |
| `Dim_WorkConditions` | Business travel, overtime |
| `Dim_Satisfaction` | Environment satisfaction, job satisfaction, work-life balance |
| `Measures` | All DAX measures in one table |

Five **one-to-many** relationships connect each dimension to the fact table.

**DAX measures:** Active Employees · Attrition Count · Attrition Rate % · Attrition vs Company · Income Upper Fence · Income Outliers Count · Income Outliers Attrition Rate

---

## 📊 Power BI Dashboard

### Page 1: Details
KPI cards (Total Employees **1,470**, Active Employees **1,233**, Attrition Count **237**, Avg Monthly Income **6,503**, Attrition Rate **16.12%**), plus attrition rate by **department**, **age group**, **overtime** and **tenure**, with slicers for department, gender and job role.

### Page 2: Problems and Outliers
Income upper fence (**IQR method**), outlier count and attrition rate, income outliers by job role, average income of leavers vs. stayers, income vs. tenure by attrition status, and a **job role × overtime** matrix with conditional formatting.

<p align="center">
  <img src="hr-attrition-repo/images/dashboard_page2_outliers.png" alt="HR Attrition Dashboard, page 2: income outliers, income vs tenure, and job role by overtime matrix" width="100%">
</p>

---

## 🗃️ SQL Analysis (SQL Server / T-SQL)

The same question answered directly on the raw data: which department has the most exits?

```sql
SELECT Department, COUNT(*) AS Total_Per_Department
FROM dbo.HR_Employee_Attrition
WHERE Attrition = 'Yes'
GROUP BY Department
ORDER BY Total_Per_Department DESC;
```

<p align="center">
  <img src="hr-attrition-repo/images/sql_result.jpg" alt="SQL Server Management Studio result: R&D 133, Sales 92, Human Resources 12" width="90%">
</p>

| Department | Exits |
|---|---|
| Research & Development | 133 |
| Sales | 92 |
| Human Resources | 12 |

The result matches the dashboard (133 + 92 + 12 = 237). File: [`sql/attrition_by_department.sql`](hr-attrition-repo/sql/attrition_by_department.sql)

---

## 🔍 Key Findings

| Area | Finding |
|---|---|
| **Department** | R&D has the most exits (133), but **Sales has the highest rate (20.63%)**, then HR (19.05%) and R&D (13.84%), against 16.12% overall. HR is small, with only 12 exits |
| **Age** | Employees **under 25 leave at 39.18%**; 25–34 at 20.22%; 35–54 around 10%; 55+ at 15.94% |
| **Tenure** | **34.88% in the first year**, 18.08% at 2–4 years, 11.07% at 5–9 years, 10.38% at 10+ years |
| **Overtime** | **30.53% with overtime vs 10.44% without** (about 3x). Overtime workers are ~28% of staff but ~54% of exits (127 of 237) |
| **Role + overtime** | Sales Representative 66.67% (24 employees), Laboratory Technician 50.00% (62), HR 38.46% (13), Research Scientist 34.02% (97), Sales Executive 32.98% (94) |
| **Income** | Leavers earn about 4.8K/month on average vs about 6.8K for stayers |
| **Outliers** | 114 employees sit above the upper fence (~16.58K): 74 Managers and 40 Research Directors. Their attrition is only 4.39%. They are real senior roles, not data errors, so I kept them |

> ⚠️ These are **associations, not proven causes.** Income, job level and tenure move together, so pay should be compared within the same role and level.

---

## ✅ Recommendations

Each action is a **test**: start with a small group, measure the change, then expand.

| # | Action | Evidence | How to measure |
|---|---|---|---|
| 1 | Review overtime workload, starting with Sales Representatives, Laboratory Technicians and Research Scientists | 30.53% vs 10.44%; up to 66.67% for Sales Reps | Monthly attrition rate of the overtime group |
| 2 | Strengthen onboarding and check-ins in the first two years, especially for employees under 25 | 34.88% in year 1; 39.18% under 25 | First-year attrition rate |
| 3 | Run exit interviews in Sales, HR and R&D | Sales 20.63%, HR 19.05%; R&D has 133 of 237 exits | Share of exits with a recorded reason |
| 4 | Compare pay within the same role and level before changing pay | ~4.8K vs ~6.8K, but role and level are mixed in | Pay gap by role and level |

Findings should be validated with HR records and exit interviews before any policy change.

---

## ⚠️ Assumptions & Limitations (kept honest)

- The data has **no dates and no exit reasons**, so rates describe a **snapshot**, not a yearly loss. I did not invent a date column.
- Age groups (under 25, 25–34, 35–44, 45–54, 55+) and tenure groups (0–1, 2–4, 5–9, 10+) were defined for this analysis.
- Units for income and distance are not stated, and rating codes (education, satisfaction, etc.) are unlabeled; their meanings follow the public dataset documentation and should be confirmed.
- Outliers were identified with the IQR rule and **kept** in the analysis.
- Small groups (for example 24 Sales Representatives with overtime) should be read together with their counts.

---

## 🛠️ Skills Demonstrated

**Power BI** dashboard design · **DAX** measures · **Power Query (M)** transformations · **Star schema** modeling · **SQL Server (T-SQL)** aggregation · **Data cleaning & validation** · **Outlier detection (IQR)** · **KPI reporting** · **Root-cause analysis** · **Data storytelling & presentation**

---

## 📁 Repository Structure

```
├── data/        HR_Employee_Attrition.csv
├── powerbi/     HR_Attrition_Dashboard.pbix
├── sql/         attrition_by_department.sql
├── docs/        Recommendations.docx, Presentation.pptx
├── images/      dashboard, data model and SQL screenshots
└── README.md
```

> To open the `.pbix`, update the data source path in Power Query (**Transform data → Data source settings**) to your local copy of the data.

---

## 💡 What I Learned

- A clean star schema makes DAX simpler and dashboards easier to maintain.
- Honest assumptions beat forced analysis: no dates in the data meant no invented trends.
- A finding only matters when it ends in an action someone can test and measure.

---

## 👤 Author

**Eslam Arafa**, Data Analyst
🔗 [LinkedIn](https://linkedin.com/in/eslam-m-arafa/) · 💻 [GitHub](https://github.com/EslamArafa2003)
