-- ============================================================
-- dim_supplier: 20 mock suppliers
-- ============================================================
CREATE TABLE IF NOT EXISTS raw.suppliers (
    supplier_id         SERIAL PRIMARY KEY,
    supplier_name       VARCHAR(100) NOT NULL,
    region              VARCHAR(50),
    country             VARCHAR(50),
    category            VARCHAR(50),
    avg_lead_time_days  INTEGER,
    reliability_score   NUMERIC(3,1),
    is_active           BOOLEAN,
    onboarded_date      DATE
);

INSERT INTO raw.suppliers 
    (supplier_name, region, country, category, avg_lead_time_days, reliability_score, is_active, onboarded_date)
VALUES
    ('Apex Packaging Co.',       'North',         'India',       'Packaging',      12,  8.4, TRUE,  '2021-03-15'),
    ('SilkRoute Textiles',       'International', 'Bangladesh',  'Raw Material',   21,  7.1, TRUE,  '2020-08-01'),
    ('Meridian Logistics',       'West',          'India',       'Logistics',       5,  9.2, TRUE,  '2022-01-10'),
    ('BrightChem Supplies',      'South',         'India',       'Chemicals',      18,  6.5, TRUE,  '2021-11-20'),
    ('FastTrack Carriers',       'East',          'India',       'Logistics',       4,  8.8, TRUE,  '2022-06-05'),
    ('GlobalPack Industries',    'International', 'China',       'Packaging',      28,  7.3, TRUE,  '2020-03-22'),
    ('Sunrise Raw Materials',    'South',         'India',       'Raw Material',   15,  8.1, TRUE,  '2021-07-18'),
    ('EcoWrap Solutions',        'West',          'India',       'Packaging',      10,  9.0, TRUE,  '2022-09-01'),
    ('PrimeChem Ltd.',           'North',         'India',       'Chemicals',      20,  6.8, TRUE,  '2020-12-05'),
    ('SwiftShip Logistics',      'East',          'India',       'Logistics',       3,  9.4, TRUE,  '2023-01-15'),
    ('Horizon Textiles',         'International', 'Vietnam',     'Raw Material',   25,  7.6, TRUE,  '2021-04-10'),
    ('Reliable Pack Co.',        'North',         'India',       'Packaging',      14,  8.2, TRUE,  '2022-03-28'),
    ('ChemBase Pvt. Ltd.',       'South',         'India',       'Chemicals',      17,  7.9, TRUE,  '2021-09-14'),
    ('Delta Freight Services',   'West',          'India',       'Logistics',       6,  8.6, TRUE,  '2022-11-03'),
    ('AgroRaw Supplies',         'East',          'India',       'Raw Material',   13,  8.3, TRUE,  '2021-06-22'),
    ('NovaPack International',   'International', 'China',       'Packaging',      30,  6.2, TRUE,  '2020-01-10'),
    ('QuickMove Carriers',       'North',         'India',       'Logistics',       5,  9.1, TRUE,  '2023-03-07'),
    ('OldGuard Trading',         'North',         'India',       'Raw Material',   30,  4.2, FALSE, '2019-01-01'),
    ('Pinnacle Films Ltd.',      'International', 'China',       'Packaging',      25,  7.8, TRUE,  '2020-05-14'),
    ('Coastal Freight Pvt.',     'East',          'India',       'Logistics',       7,  8.1, TRUE,  '2023-02-28');

	-- ============================================================
-- raw.skus: 50 mock SKUs across 5 categories
-- ============================================================
CREATE TABLE IF NOT EXISTS raw.skus (
    sku_id           SERIAL PRIMARY KEY,
    sku_code         VARCHAR(20) NOT NULL UNIQUE,
    sku_name         VARCHAR(100) NOT NULL,
    category         VARCHAR(50),
    unit_of_measure  VARCHAR(20),
    unit_cost        NUMERIC(10,2),
    reorder_point    INTEGER,
    is_active        BOOLEAN
);

INSERT INTO raw.skus
    (sku_code, sku_name, category, unit_of_measure, unit_cost, reorder_point, is_active)
VALUES
    ('PKG-001', 'Corrugated Box 30x20',     'Packaging',    'Units',  12.50,  500, TRUE),
    ('PKG-002', 'Bubble Wrap Roll 50m',     'Packaging',    'Rolls',  85.00,  200, TRUE),
    ('PKG-003', 'Stretch Film 400m',        'Packaging',    'Rolls',  65.00,  300, TRUE),
    ('PKG-004', 'Kraft Paper Bag 5kg',      'Packaging',    'Units',   8.75,  800, TRUE),
    ('PKG-005', 'Foam Sheet 10mm',          'Packaging',    'Sheets', 22.00,  400, TRUE),
    ('PKG-006', 'Cardboard Divider Set',    'Packaging',    'Sets',   18.00,  350, TRUE),
    ('PKG-007', 'Plastic Crate 50L',        'Packaging',    'Units',  95.00,  150, TRUE),
    ('PKG-008', 'Adhesive Tape 48mm',       'Packaging',    'Rolls',  12.00, 1000, TRUE),
    ('PKG-009', 'Pallet Wrap Film',         'Packaging',    'Rolls',  78.00,  200, TRUE),
    ('PKG-010', 'Label Sheet A4',           'Packaging',    'Sheets',  3.50, 2000, TRUE),
    ('RAW-001', 'Cotton Fabric Grade A',    'Raw Material', 'Metres', 180.00,  300, TRUE),
    ('RAW-002', 'Polyester Thread 5000m',   'Raw Material', 'Spools',  45.00,  500, TRUE),
    ('RAW-003', 'Denim Fabric 14oz',        'Raw Material', 'Metres', 220.00,  200, TRUE),
    ('RAW-004', 'Viscose Fabric',           'Raw Material', 'Metres', 160.00,  250, TRUE),
    ('RAW-005', 'Linen Blend Fabric',       'Raw Material', 'Metres', 195.00,  180, TRUE),
    ('RAW-006', 'Elastic Band 25mm',        'Raw Material', 'Metres',  15.00, 1000, TRUE),
    ('RAW-007', 'Metal Zipper 20cm',        'Raw Material', 'Units',   8.50, 2000, TRUE),
    ('RAW-008', 'Plastic Button Set',       'Raw Material', 'Sets',    4.25, 3000, TRUE),
    ('RAW-009', 'Hook & Eye Fastener',      'Raw Material', 'Pairs',   3.75, 2500, TRUE),
    ('RAW-010', 'Embroidery Thread 1000m',  'Raw Material', 'Spools',  35.00,  800, TRUE),
    ('CHM-001', 'Fabric Softener Conc.',    'Chemicals',    'Litres',  55.00,  400, TRUE),
    ('CHM-002', 'Industrial Detergent 5L',  'Chemicals',    'Units',   88.00,  300, TRUE),
    ('CHM-003', 'Bleaching Agent',          'Chemicals',    'Litres',  42.00,  350, TRUE),
    ('CHM-004', 'Starch Powder 25kg',       'Chemicals',    'Bags',   125.00,  200, TRUE),
    ('CHM-005', 'Dye Fixative Agent',       'Chemicals',    'Litres',  95.00,  150, TRUE),
    ('CHM-006', 'Anti-Static Spray 1L',     'Chemicals',    'Units',   72.00,  200, TRUE),
    ('CHM-007', 'Rust Inhibitor',           'Chemicals',    'Litres',  68.00,  180, TRUE),
    ('CHM-008', 'pH Neutraliser',           'Chemicals',    'Litres',  51.00,  220, TRUE),
    ('CHM-009', 'Solvent Cleaner 5L',       'Chemicals',    'Units',   98.00,  160, TRUE),
    ('CHM-010', 'Lubricant Oil 1L',         'Chemicals',    'Units',   85.00,  250, TRUE),
    ('EQP-001', 'Sewing Machine Needle',    'Equipment',    'Units',   18.00, 1000, TRUE),
    ('EQP-002', 'Cutting Blade Set',        'Equipment',    'Sets',   145.00,  100, TRUE),
    ('EQP-003', 'Presser Foot Set',         'Equipment',    'Sets',   280.00,   80, TRUE),
    ('EQP-004', 'Bobbin Case',              'Equipment',    'Units',   65.00,  200, TRUE),
    ('EQP-005', 'Feed Dog Assembly',        'Equipment',    'Units',  320.00,   50, TRUE),
    ('EQP-006', 'Tension Spring Set',       'Equipment',    'Sets',   175.00,   75, TRUE),
    ('EQP-007', 'Throat Plate',             'Equipment',    'Units',   95.00,  120, TRUE),
    ('EQP-008', 'Rotary Hook',              'Equipment',    'Units',  210.00,   60, TRUE),
    ('EQP-009', 'Motor Belt 5mm',           'Equipment',    'Units',   48.00,  300, TRUE),
    ('EQP-010', 'LED Work Light',           'Equipment',    'Units',  380.00,   40, TRUE),
    ('FIN-001', 'Kurta Set S',              'Finished',     'Units',  450.00,  200, TRUE),
    ('FIN-002', 'Kurta Set M',              'Finished',     'Units',  450.00,  300, TRUE),
    ('FIN-003', 'Kurta Set L',              'Finished',     'Units',  450.00,  250, TRUE),
    ('FIN-004', 'Salwar Suit S',            'Finished',     'Units',  680.00,  150, TRUE),
    ('FIN-005', 'Salwar Suit M',            'Finished',     'Units',  680.00,  200, TRUE),
    ('FIN-006', 'Salwar Suit L',            'Finished',     'Units',  680.00,  180, TRUE),
    ('FIN-007', 'Dupatta Cotton',           'Finished',     'Units',  220.00,  400, TRUE),
    ('FIN-008', 'Mehndi Kit Standard',      'Finished',     'Units',  350.00,  300, TRUE),
    ('FIN-009', 'Mehndi Kit Premium',       'Finished',     'Units',  580.00,  150, TRUE),
    ('FIN-010', 'Embroidered Stole',        'Finished',     'Units',  420.00,  200, TRUE);

-- ============================================================
-- raw.dim_date: 3 years (2022–2024)
-- ============================================================
CREATE TABLE IF NOT EXISTS raw.dim_date (
    date_id         INTEGER PRIMARY KEY,
    full_date       DATE NOT NULL,
    day_of_week     INTEGER,
    day_name        VARCHAR(10),
    day_of_month    INTEGER,
    month_number    INTEGER,
    month_name      VARCHAR(10),
    quarter         INTEGER,
    year            INTEGER,
    is_weekend      BOOLEAN,
    week_of_year    INTEGER
);

INSERT INTO raw.dim_date
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER            AS date_id,
    d                                           AS full_date,
    EXTRACT(DOW FROM d)::INTEGER                AS day_of_week,
    TO_CHAR(d, 'Day')                           AS day_name,
    EXTRACT(DAY FROM d)::INTEGER                AS day_of_month,
    EXTRACT(MONTH FROM d)::INTEGER              AS month_number,
    TO_CHAR(d, 'Month')                         AS month_name,
    EXTRACT(QUARTER FROM d)::INTEGER            AS quarter,
    EXTRACT(YEAR FROM d)::INTEGER               AS year,
    EXTRACT(DOW FROM d) IN (0, 6)               AS is_weekend,
    EXTRACT(WEEK FROM d)::INTEGER               AS week_of_year
FROM generate_series(
    '2022-01-01'::DATE,
    '2024-12-31'::DATE,
    '1 day'::INTERVAL
) AS d;

SELECT 'suppliers' AS table_name, COUNT(*) AS rows FROM raw.suppliers
UNION ALL
SELECT 'skus',     COUNT(*) FROM raw.skus
UNION ALL
SELECT 'dim_date', COUNT(*) FROM raw.dim_date;
```

Expected output:
```
suppliers  →  20
skus       →  50
dim_date   →  1096