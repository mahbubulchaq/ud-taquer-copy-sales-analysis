# ud-taquer-copy-sales-analysis

# 📊 Sales & Operational Efficiency Analysis — UD Taquer Copy

![SQL](https://shields.io)
![Tableau](https://shields.io)
![Status](https://shields.io)

## 📌 Project Overview & Business Problem
**UD Taquer Copy** is a retail printing and photocopying business operating two branches in Yogyakarta (**Outlet Utama (Pusat)** and **Outlet Cabang Kampus**). Despite steady daily foot traffic, management lacked visibility into which services actually drove net profitability, how branch characteristics differed, and how operational bottlenecks affected margins.

This end-to-end analytics project processes **3,010 raw transaction records** (Jan 2025 – Oct 2026) into a clean analytical model using **SQL** and visualizes actionable insights via a **2-page interactive Tableau dashboard**.

🔗 **[View Interactive Dashboard on Tableau Public](INSERT_YOUR_TABLEAU_PUBLIC_LINK_HERE)**

---

## 🗂️ Dataset & Data Architecture
The raw data follows a star-schema structure consisting of three tables:
1. `raw_transactions`: 3,010 transactional records containing timestamps, branch info, order channels, payment methods, quantities, discounts, revenues, costs, and order statuses.
2. `raw_customers`: 160 unique customer profiles segmented by type (*Mahasiswa/Pelajar*, *Individu*, *Instansi/Kampus*, *Perusahaan/UMKM*, *Event Organizer*) and area.
3. `raw_products`: 13 printing & photocopying SKUs grouped into 4 main categories (*Fotocopy*, *Buku*, *Cover*, *Undangan*).

---

## 🧹 Data Cleaning & SQL Pipeline
Before visualization, an analytical view (`vw_taquer_sales_analytics`) was built in SQL to clean and transform the raw data. Key data quality improvements included:
* **Deduplication:** Removed 10 duplicate transaction rows (reducing 3,010 raw rows to **3,000 unique transactions**) using `ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY order_datetime ASC)`.
* **Channel Standardization:** Normalized inconsistent casing in `order_channel` (e.g., `walk-in`, `WALK-IN`, `whatsapp order`) using `INITCAP(TRIM(...))`.
* **Missing Value Imputation:** Handled empty strings and nulls in `payment_method` by imputing `'Tidak Diketahui'` via `COALESCE(NULLIF(...))`.
* **Metric Engineering & Status Preservation:** Calculated `lead_time_days`, `gross_profit`, and `profit_margin_pct`, while retaining `'Dibatalkan'` (Cancelled) and `'Revisi/Cetak Ulang'` (Reprint) orders to audit operational efficiency.

📄 *Full SQL script is available in [`sql/data_cleaning_and_modeling.sql`](sql/data_cleaning_and_modeling.sql).*

---

## 💡 Key Business Insights

1. **Traffic Drivers vs. Revenue Drivers**
   * **Fotocopy services** (`PRD-01` B&W, `PRD-02` Color, `PRD-03` Binding) generate the highest daily transaction frequency with strong percentage margins (50%–60%), but low ticket sizes.
   * **Book Printing** (`PRD-06` Yearbooks, `PRD-04` Modules) and **Invitations** (`PRD-12` Hardcover Foil) act as the primary revenue and gross profit engines per order.

2. **Margin Erosion from Revisions/Reprints**
   * Orders flagged as `Revisi/Cetak Ulang` incur a **20% surge in `total_cost`** with zero additional revenue.
   * On high-value orders like Yearbooks (`PRD-06`), a single reprint slashes gross profit margin from **40.56% down to 28.67%**.

3. **Distinct Branch Customer Profiles**
   * **Outlet Cabang Kampus** is heavily driven by *Mahasiswa/Pelajar* (students) ordering thesis hardcovers (`PRD-08`), softcovers, and daily photocopying.
   * **Outlet Utama (Pusat)** captures larger B2B/institutional contracts (*Instansi/Kampus*, *Event Organizers*) for bulk module printing and thousands of event invitations.

4. **Lead Time & Fulfillment Patterns**
   * Standard photocopy and binding orders achieve same-day fulfillment (`0–1 day`), whereas custom books require **3–10 days** and invitations take **4–14 days**.

5. **Digital Channel & Cashless Adoption**
   * Digital channels (**WhatsApp Order**, **Marketplace**, **Email/Web Form**) contribute significantly alongside traditional *Walk-In* orders.
   * **QRIS** and **Transfer Bank** dominate retail payments, while **Invoice Tempo** is utilized exclusively by institutional and corporate clients.

---

## 🎯 Business Recommendations

1. **Enforce a Mandatory Digital Proofing SOP Before Mass Printing**
   * Require formal customer sign-off on final PDF mockups/dummies before printing high-value items (Yearbooks, Books, Invitations) to eliminate the 20% reprint cost penalty and protect >11% in profit margin.
2. **Launch Branch-Specific Bundling & Pricing Strategies**
   * **Outlet Cabang Kampus:** Introduce student thesis bundles (*"Print + Softcover + Hardcover Skripsi"*) to increase Average Order Value (AOV).
   * **Outlet Utama (Pusat):** Implement tiered volume discounts and dedicated account handling for B2B institutions and Event Organizers.
3. **Optimize Shift Scheduling & Paper Inventory Using Peak Hour Data**
   * Align operator shifts with peak order hours identified in the Tableau heatmap, and maintain buffer stock for A4/F4 HVS paper to prevent bottlenecks during peak academic months.

---

## 📁 Repository Structure
```text
├── data/
│   ├── raw_customers.csv
│   ├── raw_products.csv
│   ├── raw_transactions.csv
│   └── vw_taquer_sales_analytics.csv   # Cleaned dataset exported for Tableau
├── sql/
│   └── data_cleaning_and_modeling.sql  # DDL & Analytical View query
├── images/
│   ├── dashboard_page1_sales.png       # Screenshot of Tableau Page 1
│   └── dashboard_page2_ops.png         # Screenshot of Tableau Page 2
└── README.md
```
