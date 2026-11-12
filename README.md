# Consumer Complaint Trends and Response Intelligence Platform

**AnalystLab Africa | Experience Lab Internship Programme | Week 4 | Data Analytics Track**
**Prepared by:** Stephanie Georgewill Alaye
**Date:** 12 November 2026
**Tools:** Power BI, Power Query (M), DAX, SQL, Excel, Python

---

## 1. Project overview

This project analyses 62,516 consumer complaint records relating to Bank of America (CFPB data, 1 May 2017 to 28 August 2023). I cleaned and validated the data, defined and calculated the required KPIs, and built a four-page interactive Power BI dashboard so stakeholders can monitor complaint volumes, products and issues, company responses, and CFPB forwarding timelines.

**Important:** a complaint is an issue reported by a consumer. It does not establish misconduct or a regulatory violation. All findings are presented objectively from the available data.

### Business questions answered
| # | Question | Where answered |
|---|---|---|
| 1 | How have complaint volumes changed 2017 to 2023? | Dashboard pages 1 and 4 |
| 2 | Which products have the highest volumes? | Pages 1 and 2 |
| 3 | What are the most frequently reported issues? | Page 2 |
| 4 | How do issues differ across products? | Page 2 (product vs issue matrix) |
| 5 | How long does the CFPB take to forward a complaint? | Page 4 |
| 6 | What company response categories are most frequent? | Page 3 |
| 7 | What percentage of complaints had a timely response? | Pages 1 and 3 |
| 8 | Have response patterns changed over time? | Page 3 |
| 9 | Can history support volume forecasting? | Not built as a model in this deliverable (Data Analytics track dashboard task); trend charts on pages 1 and 4 show the history a forecast would use |
| 10 | How can stakeholders access validated insights? | The interactive dashboard with slicers |

---

## 2. Deliverables checklist

| Required deliverable | Where to find it |
|---|---|
| Cleaned dataset or reproducible cleaning process | Section 4 (Power Query steps), `clean.py`, `Consumer_Complaints_Clean.csv` |
| SQL queries or analytical scripts | `complaints_queries.sql`, `clean.py` |
| KPI definitions and calculations | Section 5 |
| Interactive dashboard | `Customer Complaints.pbix` (Section 6) |
| At least five business insights | Section 7 and `Business_Insights_and_Recommendations.pdf` |
| At least three actionable recommendations | Section 8 and `Business_Insights_and_Recommendations.pdf` |
| README and data-quality documentation | This file (Sections 3 and 4) |

### Files
```
Consumer_Complaints.xlsx                       Original dataset (not modified)
Customer Complaints.pbix                       Power BI dashboard (4 pages)
Consumer_Complaints_Clean.csv                  Cleaned export with derived fields
clean.py                                       Reproducible cleaning and KPI script
complaints_queries.sql                         SQL for KPIs 1 to 12
KPI_Summary.xlsx                               KPI, annual, product, monthly and response tables
Business_Insights_and_Recommendations.pdf      Insights and recommendations
README.md                                      This document
```

---

## 3. Data-quality documentation

### Dataset profile
| Item | Result |
|---|---|
| Records / columns | 62,516 / 12 (one worksheet named `Data`) |
| Date range | 1 May 2017 to 28 August 2023 |
| Primary key | `Complaint ID`, 0 duplicates, so it is a valid unique key |
| States | 51 values, no blanks |
| Products / issues | 9 products, 76 issues (46 sub-products, 158 sub-issues) |
| Submission channels | Web 45,423; Referral 10,766; Phone 4,684; Postal mail 1,318; Fax 233; Web Referral 90; Email 2 |

### Checks and findings
| Check | Finding | Decision |
|---|---|---|
| Duplicate Complaint IDs | None | No rows removed |
| Date validity | No `Date received` earlier than `Date submitted`; no missing dates | No changes needed |
| Missing Sub-issue | 10,858 blanks | Not every product or issue has a sub-issue (per data dictionary). Treated as "not applicable". Kept in the data; excluded only from sub-issue visuals |
| Missing Sub-product | 7 blanks | Same treatment as Sub-issue |
| Missing Company public response | 2,175 blanks | Field is optional (per data dictionary). Kept in the data; excluded only from the public-response chart |
| Blank Timely response? | 1,494 blanks | All 1,494 belong to complaints with status "In progress". **Not** treated as "No". Excluded from the timely-response denominator and reported separately |
| Company response "Closed" | 8 records, all with Timely = No | Rare category; kept as recorded |
| Whitespace / spelling variants | None found in any text column | No standardisation required |
| Long product names | Three names too long for charts | Shortened for display (see Product_Final below). Original `Product` kept |
| Unusual forwarding intervals | Maximum 275 days; 99th percentile = 25 days | 623 records over 25 days flagged as unusually long. Kept, not removed |
| Partial year | 2023 ends on 28 August; 2017 starts in May | Documented on dashboard footers. Year-over-year for 2023 is compared on a Jan to Aug basis in the analysis |

### Handling of blanks (summary)
Blanks were **kept** in the dataset and handled at the visual level, so cards and totals always reflect all 62,516 records. Filters that exclude blanks apply only to the specific visuals named above.

### Validation after cleaning
These control totals were checked in the dashboard against an independent calculation in Python:
| Control | Expected | Dashboard |
|---|---|---|
| Total complaints | 62,516 | 62,516 |
| Timely response % | 96.06% | 96.06% |
| Timely Yes / No | 58,619 / 2,403 | matches |
| Excluded from timely % (In progress) | 1,494 | 1,494 |
| Average / median forwarding days | 1.22 / 0 | 1.22 / 0 |
| Same-day forwarded | 79.4% | 79.4% |
| Long forwarding (over 25 days) | 623 | 623 |

---

## 4. Data cleaning process (reproducible)

The original Excel file is never modified. All steps are applied in Power Query (**Home > Transform data**), so refreshing the report repeats them automatically. The same logic is also implemented in `clean.py`.

1. **Import** `Consumer_Complaints.xlsx` (sheet `Data`) with **Get data > Excel workbook**. Power Query records the Source, Navigation and Promoted Headers steps.
2. **Set data types.** `Date submitted` and `Date received` = Date; text columns = Text.
3. **Inspect quality** using Column quality, Column distribution and Column profile (View tab) to check blanks, errors, distinct values and duplicates.
4. **Add derived fields** (Add Column > Custom Column unless noted):

| New field | How it was created | Purpose |
|---|---|---|
| `Year` | Add Column > Date > Year (on `Date submitted`) | Annual analysis and slicer |
| `Month Name` / `Month` | Add Column > Date > Month > Name of Month | Seasonality |
| `Month_Num` | Add Column > Date > Month | Sorting months in calendar order |
| `Quarter` | Add Column > Date > Quarter | Quarterly analysis |
| `Month Start` | `Date.StartOfMonth([Date submitted])` (type Date) | Continuous monthly trend axis |
| `Forwarding_Interval_Days` | `Duration.Days([Date received] - [Date submitted])` (Whole number) | CFPB forwarding interval |
| `Product_Final` | `Text.BeforeDelimiter([Product], ",")` | Short product names for charts and slicers |

5. **Standardise products.** The three long names contain commas, so taking the text before the first comma gives *Credit reporting*, *Money transfer* and *Payday loan*. All other product names are unchanged. The original `Product` column is kept.
6. **Create the interval bucket** (DAX calculated column) used for the distribution chart:
```
Fwd Bucket =
SWITCH(TRUE(),
  Data[Forwarding_Interval_Days] = 0, "1. Same day",
  Data[Forwarding_Interval_Days] = 1, "2. 1 day",
  Data[Forwarding_Interval_Days] <= 3, "3. 2-3 days",
  Data[Forwarding_Interval_Days] <= 7, "4. 4-7 days",
  Data[Forwarding_Interval_Days] <= 25, "5. 8-25 days",
  "6. Over 25 days")
```
7. **Sort Month by Month_Num** (Column tools > Sort by column).
8. **Close & Apply** to load the cleaned table into the model.
9. **Validate** the totals listed in Section 3.

**Alternative (script):** `python clean.py` reads the original Excel and writes `Consumer_Complaints_Clean.csv` and `KPI_Summary.xlsx`. In that CSV, blank Sub-issue and Sub-product are labelled "Not applicable", blank public responses "Not provided (optional field)", and blank Timely response "Not applicable (In progress)". Counts and KPIs are identical to the dashboard.

---

## 5. KPI definitions and calculations

All measures are DAX measures on the `Data` table, stored in the model.

| # | KPI | Definition | DAX | Result |
|---|---|---|---|---|
| 1 | Total complaints | Number of complaint records | `Total Complaints = COUNTROWS(Data)` | 62,516 |
| 2 | Annual complaint volume | Total Complaints by `Year` | Same measure, `Year` on the axis | 2017: 5,394; 2018: 7,872; 2019: 7,075; 2020: 8,942; 2021: 11,149; 2022: 12,953; 2023 (to 28 Aug): 9,131 |
| 3 | Monthly complaint volume | Total Complaints by `Month Start` | Same measure, `Month Start` on the axis | 76 months; peak July 2023 (1,749) |
| 4 | Complaints by financial product | Total Complaints by `Product_Final` | Same measure | Checking/savings 24,814; Credit cards 16,197 |
| 5 | Complaints by reported issue | Total Complaints by `Issue` (top 10 shown) | Same measure | Managing an account 15,109 |
| 6 | Complaints by sub-product and sub-issue | Total Complaints by `Sub-product`, `Sub-issue` | Same measure (blanks excluded in these visuals) | Page 2 treemap and table |
| 7 | Product share of total | Product complaints divided by all selected complaints | `Product Share % = DIVIDE([Total Complaints], CALCULATE([Total Complaints], ALLSELECTED(Data[Product_Final])))` | Checking/savings 39.7%; Credit cards 25.9% |
| 8 | Company response category distribution | Total Complaints by `Company response to consumer` | Same measure | Closed with explanation 41,044 (65.7%); monetary relief 14,697 (23.5%); non-monetary relief 5,273 (8.4%); In progress 1,494 (2.4%); Closed 8 |
| 9 | Timely response % | Records marked Yes divided by records marked Yes or No. In-progress records excluded | `Timely Response % = DIVIDE(CALCULATE(COUNTROWS(Data), Data[Timely response?]="Yes"), CALCULATE(COUNTROWS(Data), Data[Timely response?] IN {"Yes","No"}))` | 96.06% (58,619 of 61,022) |
| 9a | Untimely complaints | Records marked No | `CALCULATE(COUNTROWS(Data), Data[Timely response?]="No")` | 2,403 |
| 9b | Records excluded from timely % | Records without a Yes or No value | `CALCULATE(COUNTROWS(Data), NOT(Data[Timely response?] IN {"Yes","No"}))` | 1,494 |
| 10 | Complaints in progress | Records whose company response is "In progress" | `CALCULATE(COUNTROWS(Data), Data[Company response to consumer]="In progress")` | 1,494 |
| 11 | Average forwarding interval | Mean of (`Date received` minus `Date submitted`) in days. This is CFPB forwarding time, not company resolution time | `AVERAGE(Data[Forwarding_Interval_Days])` | 1.22 days |
| 11a | Median forwarding interval | Middle value of the same interval | `MEDIAN(Data[Forwarding_Interval_Days])` | 0 days |
| 11b | Same-day forwarded % | Share of complaints with interval = 0 | `DIVIDE(CALCULATE(COUNTROWS(Data), Data[Forwarding_Interval_Days]=0), COUNTROWS(Data))` | 79.4% |
| 11c | Long forwarding count | Records with interval over 25 days (above the 99th percentile) | `CALCULATE(COUNTROWS(Data), Data[Forwarding_Interval_Days] > 25)` | 623 |
| 12 | Year-over-year change | (This year minus previous year) divided by previous year | `Prev Year = VAR CurrentYear = MAX(Data[Year]) RETURN CALCULATE(COUNTROWS(Data), ALL(Data[Year]), Data[Year] = CurrentYear - 1)` and `YoY % = VAR Prev = [Prev Year] RETURN IF(ISBLANK(Prev), BLANK(), DIVIDE(COUNTROWS(Data) - Prev, Prev))` | 2018 +45.9%; 2019 -10.1%; 2020 +26.4%; 2021 +24.7%; 2022 +16.2%; 2023 -29.5% (partial year; +9.4% on a Jan to Aug basis) |

SQL versions of all KPIs are in `complaints_queries.sql`.

---

## 6. Dashboard guide

**Interactive filters (all pages, synced):** Year, Product, State, Submitted via.

| Page | Purpose | Main visuals |
|---|---|---|
| 1. Executive Overview | Headline picture | Cards (Total Complaints, Timely Response %, Avg Forwarding Days, In Progress); monthly volume line; complaints by product bar; annual volume column; KPI definitions |
| 2. Product & Issue Analysis | Where complaints come from | Complaints by product; top 10 issues; sub-product treemap; product vs issue matrix; sub-product and sub-issue detail table |
| 3. Company Response Analysis | How the company responded | Cards (In Progress, Untimely, Timely %, Excluded); response categories; timely vs untimely donut; public response categories; timely % by year; response mix over time |
| 4. Complaint Timeline Analysis | CFPB forwarding speed and trends | Cards (average, median, same-day %, long count); annual volume with YoY %; monthly volume; interval distribution; average interval by product; list of intervals over 25 days |

### Design choices
- Canvas 1280 x 720; title bar at the top with the page name on the right; slicer row below; KPI cards, then charts, then a page-specific footnote.
- Font: Segoe UI. Titles 12 pt bold; labels 9 to 10 pt.
- Colours: navy **#1F3A5F** (primary), teal **#2A9D8F** (accent), light grey **#F2F4F7** (background), grey **#6B7280** (footnotes), red **#D1495B** (untimely responses and the 2021 timeliness dip only).
- Every page footnote states the 2023 partial-year limitation where relevant and that a complaint is not proof of misconduct.

---

## 7. Business insights

1. **Complaint volume grew strongly.** Annual complaints rose from 5,394 (2017, from May) to 12,953 (2022). On a like-for-like January to August basis, 2023 (9,131) is 9.4% above 2022 (8,350). The apparent 2023 drop is only because the year is incomplete.
2. **Two products drive about two-thirds of complaints.** Checking or savings accounts (39.7%) and credit cards (25.9%).
3. **"Managing an account" is the top issue.** 15,109 complaints (about 24%), almost entirely linked to checking and savings accounts.
4. **Timely responses dipped sharply in 2021.** 99.3% to 99.9% in 2017 to 2020, then 89.0% in 2021, 95.6% in 2022 and 93.2% in 2023.
5. **Forwarding is fast but has a long tail.** Median 0 days and 79.4% forwarded the same day, yet 623 complaints took more than 25 days (maximum 275).
6. **July 2023 was the busiest month.** 1,749 complaints, about 57% above the January to June 2023 average. The data does not show the cause.
7. **Most complaints close with an explanation only.** 65.7% explanation, 23.5% monetary relief, 8.4% non-monetary relief. Public responses are almost uniform (99.95% chose not to provide one), so that field adds little analytical value.

## 8. Recommendations

1. **Target the highest-volume problems first**: account-management issues in checking and savings accounts, and purchase disputes in credit cards, through root-cause review and better self-service tools.
2. **Monitor timeliness and investigate the 2021 dip**, and set a monthly alert if the timely response rate falls below an agreed threshold (for example 97%).
3. **Review the 623 long forwarding cases** for common products, channels or periods, and track them as exceptions on the Complaint Timeline page.

---

## 9. Limitations and notes
- 2023 covers 1 January to 28 August; August 2023 is incomplete and 2017 starts in May, so year-over-year comparisons at the ends of the range are not like-for-like.
- The forwarding interval measures CFPB forwarding time only, not company response or resolution time.
- Complaint counts are not normalised by customer or transaction numbers, so they should not be read as a measure of risk or misconduct.
- The data dictionary does not define the "In progress" and "Closed" statuses. Treating the 1,494 blank timely values as in-progress records is based on the data (all blanks match "In progress").
- Forecasting (question 9) is outside the dashboard track deliverable. The monthly trend history is available to support it.

## 10. How to reproduce
1. Place `Consumer_Complaints.xlsx` in the project folder.
2. Open `Customer Complaints.pbix` in Power BI Desktop and click **Refresh**, or follow the Power Query steps in Section 4 from scratch.
3. Optional: run `python clean.py` to regenerate the cleaned CSV and KPI workbook, and run `complaints_queries.sql` against the CSV loaded as `complaints_clean` to verify the KPIs.
