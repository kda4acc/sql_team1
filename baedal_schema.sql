CREATE SCHEMA food_delivery;

create table food_delivery.customers (
    customer_id bigserial primary key,
    customer_name VARCHAR(100) bigint not null,
    address VARCHAR(255),
    phone unique
);


create table food_delivery.restaurants(
    restaurant_id bigint primary key,
    restaurant_name VARCHAR(100) NOT NULL,
    avg_rating  DECIMAL(2,1) DEFAULT 0.0
);

CREATE TABLE food_delivery.menu_items (
    menu_id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id   BIGINT NOT NULL,
    menu_name       VARCHAR(100) NOT NULL,
    price           DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_menu_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(restaurant_id)
        ON DELETE CASCADE
);


CREATE TABLE food_delivery.orders (
    order_id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id         BIGINT NOT NULL,
    order_timestamp     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    has_review          BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
CREATE TABLE food_delivery.order_items (
    order_item_id   BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id        BIGINT NOT NULL,
    menu_id         BIGINT NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),

    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_orderitem_menu
        FOREIGN KEY (menu_id)
        REFERENCES menu_items(menu_id)
);

CREATE TABLE food_delivery.drivers (
    driver_id       BIGINT PRIMARY KEY AUTO_INCREMENT,
    delivery_type   VARCHAR(50),   
    phone           VARCHAR(20) UNIQUE
);

CREATE TABLE food_delivery.deliveries (
    delivery_id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id            BIGINT NOT NULL,
    driver_id           BIGINT NOT NULL,
    delivery_status     VARCHAR(30) NOT NULL, 
    pickup_time         DATETIME,
    delivered_time      DATETIME,

    CONSTRAINT fk_delivery_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_delivery_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
);

CREATE TABLE food_delivery.reviews (
    review_id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id            BIGINT NOT NULL UNIQUE,
    customer_id         BIGINT NOT NULL,
    restaurant_id       BIGINT NOT NULL,
    rating              INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_content      TEXT,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_review_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_review_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_review_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(restaurant_id)
);


alter table food_delivery.customers disable row level security;
alter table food_delivery.restaurants disable row level security;
alter table food_delivery.menu_items disable row level security;
alter table food_delivery.orders disable row level security;
alter table food_delivery.order_items disable row level security;
alter table food_delivery.drivers disable row level security;
alter table food_delivery.deliveries disable row level security;
alter table food_delivery.reviews disable row level security;


select 'food_delivery created' as message;
