-- ============================================================================
-- PROYEK: Analisis Penjualan & Efisiensi Operasional — UD Taquer Copy 
-- TOOLS: PostgreSQL
-- ============================================================================

-- BAGIAN 1: PEMBUATAN TABEL MENTAH (DDL)
-- ----------------------------------------------------------------------------
CREATE TABLE raw_customers (
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    customer_type VARCHAR(50),
    area VARCHAR(50),
    registration_date VARCHAR(30)
);

CREATE TABLE raw_products (
    product_id VARCHAR(20),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100),
    unit VARCHAR(30),
    unit_price NUMERIC(12, 2),
    unit_cost NUMERIC(12, 2),
    store_name VARCHAR(50)
);

CREATE TABLE raw_transactions (
    transaction_id VARCHAR(30),
    store_name VARCHAR(50),
    outlet_branch VARCHAR(50),
    order_datetime VARCHAR(30),
    completed_date VARCHAR(30),
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    order_channel VARCHAR(50),
    payment_method VARCHAR(50),
    quantity INT,
    unit_price NUMERIC(12, 2),
    discount_amount NUMERIC(12, 2),
    net_revenue NUMERIC(12, 2),
    total_cost NUMERIC(12, 2),
    order_status VARCHAR(30)
);


-- BAGIAN 2: PEMBERSIHAN DATA & PEMODELAN STAR-SCHEMA (ANALYTICAL VIEW)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_taquer_sales_analytics AS
WITH deduplicated_transactions AS (
    -- Menghapus 10 baris transaksi duplikat berdasarkan transaction_id
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id 
            ORDER BY order_datetime ASC
        ) AS row_num
    FROM raw_transactions
),
cleaned_transactions AS (
    -- Standardisasi teks, format tanggal, dan penanganan missing values
    SELECT 
        TRIM(transaction_id) AS transaction_id,
        TRIM(store_name) AS store_name,
        TRIM(outlet_branch) AS outlet_branch,
        CAST(order_datetime AS TIMESTAMP) AS order_datetime,
        DATE(CAST(order_datetime AS TIMESTAMP)) AS order_date,
        CASE 
            WHEN completed_date IS NULL OR TRIM(completed_date) = '' THEN NULL
            ELSE CAST(completed_date AS DATE)
        END AS completed_date,
        TRIM(customer_id) AS customer_id,
        TRIM(product_id) AS product_id,
        INITCAP(TRIM(order_channel)) AS order_channel,
        COALESCE(NULLIF(TRIM(payment_method), ''), 'Tidak Diketahui') AS payment_method,
        quantity,
        unit_price,
        discount_amount,
        net_revenue,
        total_cost,
        TRIM(order_status) AS order_status
    FROM deduplicated_transactions
    WHERE row_num = 1
)
SELECT 
    t.transaction_id,
    t.store_name,
    t.outlet_branch,
    t.order_datetime,
    t.order_date,
    t.completed_date,
    (t.completed_date - t.order_date) AS lead_time_days,
    t.order_channel,
    t.payment_method,
    t.order_status,
    -- Dimensi Pelanggan
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.area AS customer_area,
    CAST(c.registration_date AS DATE) AS customer_reg_date,
    -- Dimensi Produk
    p.product_id,
    p.category AS product_category,
    p.sub_category AS product_sub_category,
    p.product_name,
    p.unit AS product_unit,
    -- Metrik Keuangan & Profitabilitas
    t.quantity,
    t.unit_price,
    t.discount_amount,
    t.net_revenue,
    t.total_cost,
    (t.net_revenue - t.total_cost) AS gross_profit,
    ROUND(((t.net_revenue - t.total_cost) / NULLIF(t.net_revenue, 0)) * 100, 2) AS profit_margin_pct
FROM cleaned_transactions t
LEFT JOIN raw_customers c ON TRIM(t.customer_id) = TRIM(c.customer_id)
LEFT JOIN raw_products p ON TRIM(t.product_id) = TRIM(p.product_id);


-- BAGIAN 3: QUERY EKSPLORASI & ANALISIS BISNIS (MENJAWAB MASALAH BISNIS)
-- ----------------------------------------------------------------------------

-- 1. Perbandingan Performa Omzet & Profit Antar Cabang Outlet
SELECT 
    outlet_branch,
    COUNT(transaction_id) AS total_transaksi_valid,
    SUM(net_revenue) AS total_omzet,
    SUM(gross_profit) AS total_laba_kotor,
    ROUND(AVG(profit_margin_pct), 2) AS rata_rata_margin_pct
FROM vw_taquer_sales_analytics
WHERE order_status <> 'Dibatalkan'
GROUP BY outlet_branch
ORDER BY total_omzet DESC;

-- 2. Kontribusi Kategori Produk (Traffic Driver vs Revenue Driver)
SELECT 
    product_category,
    product_name,
    COUNT(transaction_id) AS frekuensi_transaksi,
    SUM(quantity) AS total_kuantitas,
    SUM(net_revenue) AS total_omzet,
    SUM(gross_profit) AS total_laba_kotor,
    ROUND(AVG(profit_margin_pct), 2) AS rata_rata_margin_pct
FROM vw_taquer_sales_analytics
WHERE order_status <> 'Dibatalkan'
GROUP BY product_category, product_name
ORDER BY total_omzet DESC;

-- 3. Audit Dampak Revisi/Cetak Ulang terhadap Margin Keuntungan
SELECT 
    order_status,
    COUNT(transaction_id) AS jumlah_pesanan,
    SUM(net_revenue) AS total_omzet,
    SUM(total_cost) AS total_biaya_produksi,
    SUM(gross_profit) AS total_laba_kotor,
    ROUND(AVG(profit_margin_pct), 2) AS rata_rata_margin_pct
FROM vw_taquer_sales_analytics
GROUP BY order_status;
