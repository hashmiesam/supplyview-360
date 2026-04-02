-- ============================================================
-- raw.purchase_orders: ~500 PO lines (2022–2024)
-- ============================================================
CREATE TABLE IF NOT EXISTS raw.purchase_orders (
    po_id                SERIAL PRIMARY KEY,
    po_number            VARCHAR(20) NOT NULL UNIQUE,
    supplier_id          INTEGER REFERENCES raw.suppliers(supplier_id),
    sku_id               INTEGER REFERENCES raw.skus(sku_id),
    order_date           DATE,
    expected_delivery    DATE,
    actual_delivery      DATE,
    quantity_ordered     INTEGER,
    quantity_received    INTEGER,
    unit_cost            NUMERIC(10,2),
    status               VARCHAR(20),  -- DELIVERED, PENDING, CANCELLED, PARTIAL
    has_quality_issue    BOOLEAN,
    warehouse_region     VARCHAR(50)
);

INSERT INTO raw.purchase_orders
    (po_number, supplier_id, sku_id, order_date, expected_delivery,
     actual_delivery, quantity_ordered, quantity_received,
     unit_cost, status, has_quality_issue, warehouse_region)
SELECT
    'PO-' || LPAD(row_number() OVER ()::TEXT, 5, '0'),
    s.supplier_id,
    sk.sku_id,
    base.order_date,
    base.order_date + s.avg_lead_time_days,
    CASE
        WHEN random() < 0.75
            THEN base.order_date + s.avg_lead_time_days + (floor(random() * 5 - 2))::INTEGER
        WHEN random() < 0.90
            THEN base.order_date + s.avg_lead_time_days + (floor(random() * 10))::INTEGER
        ELSE NULL
    END,
    base.qty,
    CASE
        WHEN random() < 0.85 THEN base.qty
        WHEN random() < 0.95 THEN (base.qty * 0.9)::INTEGER
        ELSE (base.qty * 0.75)::INTEGER
    END,
    sk.unit_cost * (0.9 + random() * 0.2),
    CASE
        WHEN random() < 0.75 THEN 'DELIVERED'
        WHEN random() < 0.90 THEN 'PARTIAL'
        WHEN random() < 0.97 THEN 'PENDING'
        ELSE 'CANCELLED'
    END,
    random() > (s.reliability_score / 10.0),
    base.region
FROM (
    SELECT
        generate_series AS idx,
        ('2022-01-01'::DATE + (random() * 1000)::INTEGER) AS order_date,
        (floor(random() * 20 + 1))::INTEGER AS supplier_idx,
        (floor(random() * 50 + 1))::INTEGER AS sku_idx,
        (floor(random() * 900 + 100))::INTEGER AS qty,
        (ARRAY['North','South','East','West'])[floor(random()*4+1)::INTEGER] AS region
    FROM generate_series(1, 500)
) base
JOIN raw.suppliers s ON s.supplier_id = base.supplier_idx
JOIN raw.skus sk ON sk.sku_id = base.sku_idx;

-- ============================================================
-- raw.inventory_snapshots: monthly stock snapshot per SKU
-- ============================================================
CREATE TABLE IF NOT EXISTS raw.inventory_snapshots (
    snapshot_id       SERIAL PRIMARY KEY,
    snapshot_date     DATE NOT NULL,
    sku_id            INTEGER REFERENCES raw.skus(sku_id),
    warehouse_region  VARCHAR(50),
    stock_on_hand     INTEGER,
    stock_in_transit  INTEGER,
    avg_daily_demand  NUMERIC(8,2),
    reorder_point     INTEGER,
    is_below_reorder  BOOLEAN
);

INSERT INTO raw.inventory_snapshots
    (snapshot_date, sku_id, warehouse_region, stock_on_hand,
     stock_in_transit, avg_daily_demand, reorder_point, is_below_reorder)
SELECT
    d.full_date,
    sk.sku_id,
    region,
    stock,
    (stock * random() * 0.3)::INTEGER,
    demand,
    sk.reorder_point,
    stock < sk.reorder_point
FROM (
    SELECT
        full_date
    FROM raw.dim_date
    WHERE day_of_month = 1   -- first of each month only
) d
CROSS JOIN raw.skus sk
CROSS JOIN (
    VALUES ('North'), ('South'), ('East'), ('West')
) AS regions(region)
CROSS JOIN LATERAL (
    SELECT
        (sk.reorder_point * (0.4 + random() * 1.8))::INTEGER AS stock,
        (sk.reorder_point * (0.02 + random() * 0.06))::NUMERIC(8,2) AS demand
) AS calc;

-- ============================================================
-- raw.shipments: delivery records linked to POs
-- ============================================================
CREATE TABLE IF NOT EXISTS raw.shipments (
    shipment_id       SERIAL PRIMARY KEY,
    po_id             INTEGER REFERENCES raw.purchase_orders(po_id),
    supplier_id       INTEGER REFERENCES raw.suppliers(supplier_id),
    shipment_date     DATE,
    delivery_date     DATE,
    carrier           VARCHAR(50),
    freight_cost      NUMERIC(10,2),
    quantity_shipped  INTEGER,
    is_on_time        BOOLEAN,
    is_in_full        BOOLEAN,
    otif              BOOLEAN,
    damage_reported   BOOLEAN
);

INSERT INTO raw.shipments
    (po_id, supplier_id, shipment_date, delivery_date,
     carrier, freight_cost, quantity_shipped,
     is_on_time, is_in_full, otif, damage_reported)
SELECT
    po.po_id,
    po.supplier_id,
    po.order_date + 2,
    po.actual_delivery,
    (ARRAY[
        'BlueDart','Delhivery','DTDC',
        'Ecom Express','XpressBees','FedEx'
    ])[floor(random() * 6 + 1)::INTEGER],
    (po.quantity_ordered * po.unit_cost * (0.02 + random() * 0.04))::NUMERIC(10,2),
    po.quantity_received,
    po.actual_delivery <= po.expected_delivery,
    po.quantity_received >= po.quantity_ordered * 0.98,
    po.actual_delivery <= po.expected_delivery
        AND po.quantity_received >= po.quantity_ordered * 0.98,
    random() > 0.92
FROM raw.purchase_orders po
WHERE po.status IN ('DELIVERED', 'PARTIAL')
  AND po.actual_delivery IS NOT NULL;


-- OTIF rate overall (should be ~65-75%)
SELECT
    ROUND(100.0 * SUM(CASE WHEN otif THEN 1 ELSE 0 END) / COUNT(*), 1) AS otif_pct
FROM raw.shipments;

-- Worst supplier by quality issues
SELECT
    s.supplier_name,
    s.reliability_score,
    COUNT(*) AS total_pos,
    SUM(CASE WHEN po.has_quality_issue THEN 1 ELSE 0 END) AS quality_issues
FROM raw.purchase_orders po
JOIN raw.suppliers s ON s.supplier_id = po.supplier_id
GROUP BY s.supplier_name, s.reliability_score
ORDER BY quality_issues DESC
LIMIT 5;

TRUNCATE raw.shipments;
TRUNCATE raw.purchase_orders RESTART IDENTITY CASCADE;
INSERT INTO raw.purchase_orders
    (po_number, supplier_id, sku_id, order_date, expected_delivery,
     actual_delivery, quantity_ordered, quantity_received,
     unit_cost, status, has_quality_issue, warehouse_region)
SELECT
    'PO-' || LPAD(row_number() OVER ()::TEXT, 5, '0'),
    s.supplier_id,
    sk.sku_id,
    base.order_date,
    base.order_date + s.avg_lead_time_days,
    CASE
        WHEN base.delivery_roll < 0.70
            -- on time or early: -3 to 0 days vs expected
            THEN base.order_date + s.avg_lead_time_days - (floor(base.delay_small * 4))::INTEGER
        WHEN base.delivery_roll < 0.88
            -- late: +2 to +7 days
            THEN base.order_date + s.avg_lead_time_days + (floor(base.delay_large * 6 + 2))::INTEGER
        ELSE NULL
    END,
    base.qty,
    CASE
        WHEN base.qty_roll < 0.82 THEN base.qty
        WHEN base.qty_roll < 0.94 THEN (base.qty * 0.90)::INTEGER
        ELSE (base.qty * 0.75)::INTEGER
    END,
    sk.unit_cost * (0.9 + base.cost_roll * 0.2),
    CASE
        WHEN base.delivery_roll < 0.70 THEN 'DELIVERED'
        WHEN base.delivery_roll < 0.88 THEN 'PARTIAL'
        WHEN base.delivery_roll < 0.96 THEN 'PENDING'
        ELSE 'CANCELLED'
    END,
    base.quality_roll > (s.reliability_score / 10.0),
    base.region
FROM (
    SELECT
        generate_series                                                          AS idx,
        ('2022-01-01'::DATE + (random() * 1000)::INTEGER)                       AS order_date,
        (floor(random() * 20 + 1))::INTEGER                                     AS supplier_idx,
        (floor(random() * 50 + 1))::INTEGER                                     AS sku_idx,
        (floor(random() * 900 + 100))::INTEGER                                  AS qty,
        (ARRAY['North','South','East','West'])[floor(random()*4+1)::INTEGER]    AS region,
        random()                                                                 AS delivery_roll,
        random()                                                                 AS qty_roll,
        random()                                                                 AS cost_roll,
        random()                                                                 AS quality_roll,
        random()                                                                 AS delay_small,
        random()                                                                 AS delay_large
    FROM generate_series(1, 500)
) base
JOIN raw.suppliers s ON s.supplier_id = base.supplier_idx
JOIN raw.skus sk ON sk.sku_id = base.sku_idx;

INSERT INTO raw.shipments
    (po_id, supplier_id, shipment_date, delivery_date,
     carrier, freight_cost, quantity_shipped,
     is_on_time, is_in_full, otif, damage_reported)
SELECT
    po.po_id,
    po.supplier_id,
    po.order_date + 2,
    po.actual_delivery,
    (ARRAY[
        'BlueDart','Delhivery','DTDC',
        'Ecom Express','XpressBees','FedEx'
    ])[floor(random() * 6 + 1)::INTEGER],
    (po.quantity_ordered * po.unit_cost * (0.02 + random() * 0.04))::NUMERIC(10,2),
    po.quantity_received,
    po.actual_delivery <= po.expected_delivery                    AS is_on_time,
    po.quantity_received >= (po.quantity_ordered * 0.90)          AS is_in_full,
    po.actual_delivery <= po.expected_delivery
        AND po.quantity_received >= (po.quantity_ordered * 0.90)  AS otif,
    random() > 0.92                                               AS damage_reported
FROM raw.purchase_orders po
WHERE po.status IN ('DELIVERED', 'PARTIAL')
  AND po.actual_delivery IS NOT NULL;

--sanity testing
SELECT
    ROUND(100.0 * SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END) / COUNT(*), 1) AS on_time_pct,
    ROUND(100.0 * SUM(CASE WHEN is_in_full THEN 1 ELSE 0 END) / COUNT(*), 1) AS in_full_pct,
    ROUND(100.0 * SUM(CASE WHEN otif       THEN 1 ELSE 0 END) / COUNT(*), 1) AS otif_pct,
    COUNT(*) AS total_shipments
FROM raw.shipments;