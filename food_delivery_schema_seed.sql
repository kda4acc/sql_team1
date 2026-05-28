-- =====================================================
-- Supabase Food Delivery Mini App Setup
-- =====================================================
-- 실행 위치: Supabase SQL Editor
--
-- 중요:
-- 1. 이 파일 실행 후 Supabase Dashboard > Project Settings > API에서
--    Exposed schemas에 food_delivery를 추가해야 Python 앱에서 접근됩니다.
-- 2. 아래 SQL은 스키마 생성, 테이블 생성, 샘플 데이터 적재,
--    anon/authenticated 권한 부여까지 포함합니다.
-- =====================================================

-- =====================================================
-- 1. SCHEMA RESET
-- =====================================================
DROP SCHEMA IF EXISTS food_delivery CASCADE;
CREATE SCHEMA food_delivery;

-- =====================================================
-- 2. TABLES
-- =====================================================
CREATE TABLE food_delivery.customers (
    customer_id BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20) UNIQUE
);

CREATE TABLE food_delivery.restaurants (
    restaurant_id BIGSERIAL PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    avg_rating DECIMAL(2,1) DEFAULT 0.0
);

CREATE TABLE food_delivery.menu_items (
    menu_id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    menu_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (restaurant_id)
        REFERENCES food_delivery.restaurants(restaurant_id)
        ON DELETE CASCADE
);

CREATE TABLE food_delivery.orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    has_review BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id)
        REFERENCES food_delivery.customers(customer_id)
);

CREATE TABLE food_delivery.order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    menu_id BIGINT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id)
        REFERENCES food_delivery.orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (menu_id)
        REFERENCES food_delivery.menu_items(menu_id)
);

CREATE TABLE food_delivery.drivers (
    driver_id BIGSERIAL PRIMARY KEY,
    delivery_type VARCHAR(50),
    phone VARCHAR(20) UNIQUE
);

CREATE TABLE food_delivery.deliveries (
    delivery_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    driver_id BIGINT NOT NULL,
    delivery_status VARCHAR(30) NOT NULL,
    pickup_time TIMESTAMP,
    delivered_time TIMESTAMP,
    FOREIGN KEY (order_id)
        REFERENCES food_delivery.orders(order_id),
    FOREIGN KEY (driver_id)
        REFERENCES food_delivery.drivers(driver_id)
);

CREATE TABLE food_delivery.reviews (
    review_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    restaurant_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)
        REFERENCES food_delivery.orders(order_id),
    FOREIGN KEY (customer_id)
        REFERENCES food_delivery.customers(customer_id),
    FOREIGN KEY (restaurant_id)
        REFERENCES food_delivery.restaurants(restaurant_id)
);

-- =====================================================
-- 3. DATA INSERT
-- =====================================================
INSERT INTO food_delivery.customers (customer_name, address, phone) VALUES
('Kim Minsoo', 'Seoul Seongsu', '010-1111-1111'),
('Lee Jiyoung', 'Seoul Seongsu', '010-2222-2222'),
('Park Junho', 'Seoul Seongsu', '010-3333-3333'),
('Choi Mina', 'Seoul Seongsu', '010-4444-4444'),
('Jung Hyunwoo', 'Seoul Seongsu', '010-5555-5555');

INSERT INTO food_delivery.restaurants (restaurant_name, avg_rating) VALUES
('Pizza Heaven', 4.6),
('Chicken Star', 4.2),
('Burger House', 4.7);

INSERT INTO food_delivery.menu_items (restaurant_id, menu_name, price) VALUES
(1, 'Pepperoni Pizza', 22000),
(1, 'Cheese Pizza', 20000),
(1, 'Coke', 2000),
(2, 'Fried Chicken', 18000),
(2, 'Spicy Chicken', 19000),
(2, 'Garlic Chicken', 19500),
(3, 'Beef Burger', 9000),
(3, 'Double Burger', 12000),
(3, 'Cheese Burger', 10000),
(3, 'Cola', 2000);

INSERT INTO food_delivery.drivers (delivery_type, phone) VALUES
('Motorcycle', '010-9999-1111'),
('Scooter', '010-9999-2222'),
('Bicycle', '010-9999-3333');

INSERT INTO food_delivery.orders (customer_id, order_timestamp, has_review) VALUES
(1, '2025-05-01 11:30:00', TRUE),
(2, '2025-05-01 12:00:00', TRUE),
(3, '2025-05-01 12:10:00', FALSE),
(1, '2025-05-01 18:20:00', TRUE),
(4, '2025-05-02 12:00:00', FALSE),
(5, '2025-05-02 12:30:00', TRUE),
(3, '2025-05-02 13:00:00', FALSE),
(1, '2025-05-02 19:00:00', TRUE),
(2, '2025-05-02 20:00:00', TRUE),
(3, '2025-05-02 21:00:00', TRUE);

INSERT INTO food_delivery.order_items (order_id, menu_id, quantity) VALUES
(1, 1, 1),
(1, 3, 2),
(2, 4, 1),
(3, 7, 1),
(4, 2, 1),
(4, 3, 1),
(5, 5, 2),
(6, 8, 1),
(7, 4, 1),
(8, 1, 2),
(9, 6, 1),
(10, 2, 1),
(10, 3, 1);

INSERT INTO food_delivery.deliveries (order_id, driver_id, delivery_status, pickup_time, delivered_time) VALUES
(1, 1, 'DELIVERED', '2025-05-01 11:40', '2025-05-01 12:10'),
(2, 2, 'DELIVERED', '2025-05-01 12:10', '2025-05-01 12:40'),
(3, 3, 'DELIVERED', '2025-05-01 12:20', '2025-05-01 12:55'),
(4, 1, 'DELIVERED', '2025-05-01 18:30', '2025-05-01 19:00'),
(5, 2, 'ON_THE_WAY', '2025-05-02 12:10', NULL),
(6, 3, 'DELIVERED', '2025-05-02 12:40', '2025-05-02 13:10'),
(7, 1, 'PREPARING', NULL, NULL),
(8, 2, 'DELIVERED', '2025-05-02 19:10', '2025-05-02 19:40'),
(9, 3, 'DELIVERED', '2025-05-02 20:10', '2025-05-02 20:50'),
(10, 1, 'DELIVERED', '2025-05-02 21:10', '2025-05-02 21:40');

INSERT INTO food_delivery.reviews (order_id, customer_id, restaurant_id, rating, review_content) VALUES
(1, 1, 1, 5, '진짜 맛있어요'),
(2, 2, 2, 4, '괜찮아요'),
(4, 1, 1, 5, '재주문 의사 있음'),
(6, 5, 3, 4, '맛있어요'),
(8, 1, 1, 5, '최고입니다'),
(9, 2, 2, 4, '무난해요'),
(10, 3, 1, 5, '진짜 맛있다');

-- =====================================================
-- 4. PERMISSIONS FOR SUPABASE ANON KEY
-- =====================================================
-- Data API(PostgREST)가 food_delivery 스키마를 볼 수 있게 설정합니다.
-- Dashboard > Project Settings > Data API > Exposed schemas에서
-- food_delivery를 추가해도 됩니다.
ALTER ROLE authenticator SET pgrst.db_schemas = 'public, graphql_public, food_delivery';
NOTIFY pgrst, 'reload config';
NOTIFY pgrst, 'reload schema';

GRANT USAGE ON SCHEMA food_delivery TO anon, authenticated, service_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA food_delivery
TO anon, authenticated, service_role;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA food_delivery
TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA food_delivery
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA food_delivery
GRANT USAGE, SELECT ON SEQUENCES TO anon, authenticated, service_role;

-- =====================================================
-- 5. CHECK
-- =====================================================
SELECT 'food_delivery FULL SET CREATED SUCCESSFULLY' AS message;

SELECT
    (SELECT COUNT(*) FROM food_delivery.customers) AS customers_count,
    (SELECT COUNT(*) FROM food_delivery.restaurants) AS restaurants_count,
    (SELECT COUNT(*) FROM food_delivery.menu_items) AS menu_items_count,
    (SELECT COUNT(*) FROM food_delivery.orders) AS orders_count,
    (SELECT COUNT(*) FROM food_delivery.order_items) AS order_items_count,
    (SELECT COUNT(*) FROM food_delivery.deliveries) AS deliveries_count,
    (SELECT COUNT(*) FROM food_delivery.reviews) AS reviews_count;
