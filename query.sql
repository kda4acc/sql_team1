-- 1. 음식점 목록과 평균 평점 조회
SELECT
    restaurant_id,
    restaurant_name,
    avg_rating
FROM food_delivery.restaurants
ORDER BY restaurant_id;

-- 2. 음식점별 메뉴 목록 조회
SELECT
    r.restaurant_name,
    m.menu_name,
    m.price
FROM food_delivery.menu_items m
JOIN food_delivery.restaurants r
    ON m.restaurant_id = r.restaurant_id
ORDER BY r.restaurant_id, m.menu_id;

-- 3. 주문별 주문 고객, 메뉴, 수량 조회
SELECT
    o.order_id,
    c.customer_name,
    m.menu_name,
    oi.quantity,
    o.order_timestamp
FROM food_delivery.orders o
JOIN food_delivery.customers c
    ON o.customer_id = c.customer_id
JOIN food_delivery.order_items oi
    ON o.order_id = oi.order_id
JOIN food_delivery.menu_items m
    ON oi.menu_id = m.menu_id
ORDER BY o.order_id;

-- 4. 음식점별 총 매출 조회
SELECT
    r.restaurant_name,
    SUM(m.price * oi.quantity) AS total_sales
FROM food_delivery.order_items oi
JOIN food_delivery.menu_items m
    ON oi.menu_id = m.menu_id
JOIN food_delivery.restaurants r
    ON m.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_sales DESC;

-- 5. 가게별 리뷰 개수와 평균 평점 조회
SELECT
    r.restaurant_name,
    COUNT(rv.review_id) AS review_count,
    ROUND(AVG(rv.rating), 1) AS avg_review_rating
FROM food_delivery.restaurants r
LEFT JOIN food_delivery.reviews rv
    ON r.restaurant_id = rv.restaurant_id
GROUP BY r.restaurant_name
ORDER BY avg_review_rating DESC;
