# -*- coding: utf-8 -*-
"""
delivery_app_supabase.py

Supabase DB와 연결해서 터미널에서 실행하는 배달앱 미니 프로그램입니다.

실행 전 준비:
1. Supabase SQL Editor에서 food_delivery 스키마/데이터 SQL을 먼저 실행합니다.
2. Supabase Dashboard > Project Settings > API > Exposed schemas에
   food_delivery를 추가합니다.
3. anon key로 읽기/쓰기가 가능하도록 food_delivery 스키마와 테이블 권한을 허용합니다.
4. 설치: pip install supabase
5. 실행: python delivery_app_supabase.py
"""

from datetime import datetime
from getpass import getpass
from typing import Any, Optional

from supabase import create_client


DB_SCHEMA = "food_delivery"


def connect_supabase():
    while True:
        url = input("Supabase URL 입력: ").strip()
        if url:
            break
        print("Supabase URL을 입력해야 다음 단계로 넘어갑니다.")

    while True:
        anon_key = getpass("Supabase anon key 입력: ").strip()
        if anon_key:
            break
        print("Supabase anon key를 입력해야 연결할 수 있습니다.")

    client = create_client(url, anon_key)
    print("Supabase 연결 완료")
    return client


supabase = connect_supabase()


def table(table_name: str):
    """food_delivery 스키마 안의 테이블을 선택합니다."""
    return supabase.schema(DB_SCHEMA).table(table_name)


def execute(query, error_message: str = "Supabase 요청 중 오류가 발생했습니다."):
    try:
        return query.execute()
    except Exception as exc:
        print(f"\n{error_message}")
        print(f"오류 내용: {exc}")
        print("확인할 것: food_delivery 스키마가 Supabase API Exposed schemas에 추가되어 있어야 합니다.")
        print("권한 오류라면 anon 역할에 food_delivery 스키마/테이블/시퀀스 권한이 필요합니다.")
        print("PGRST205 오류라면 SQL Editor에서 NOTIFY pgrst, 'reload schema'; 를 실행한 뒤 다시 시도하세요.")
        return None


def to_int(value: Any) -> int:
    return int(float(value))


def money(value: Any) -> str:
    return f"{to_int(value):,}원"


def ask_int(message: str, allow_zero: bool = False):
    while True:
        raw = input(message).strip()

        if allow_zero and raw == "0":
            return 0

        try:
            return int(raw)
        except ValueError:
            print("숫자로 입력해주세요.")


def ask_rating():
    while True:
        rating = ask_int("평점 입력(1~5): ")
        if 1 <= rating <= 5:
            return rating
        print("평점은 1부터 5까지 입력할 수 있습니다.")


def fetch_all(table_name: str, columns: str = "*", order_column: Optional[str] = None):
    query = table(table_name).select(columns)
    if order_column:
        query = query.order(order_column)

    res = execute(query, f"{table_name} 데이터를 불러오지 못했습니다.")
    return res.data if res else []


def fetch_restaurants():
    return fetch_all("restaurants", "restaurant_id, restaurant_name, avg_rating", "restaurant_id")


def fetch_customers():
    return fetch_all("customers", "customer_id, customer_name, address, phone", "customer_id")


def fetch_menus():
    return fetch_all("menu_items", "menu_id, restaurant_id, menu_name, price", "menu_id")


def fetch_drivers():
    return fetch_all("drivers", "driver_id, delivery_type, phone", "driver_id")


def show_restaurants():
    restaurants = fetch_restaurants()

    print("\n=== 음식점 목록 ===")
    if not restaurants:
        print("등록된 음식점이 없습니다.")
        return

    for row in restaurants:
        print(
            f"{row['restaurant_id']}. {row['restaurant_name']} "
            f"/ 평균평점 {row.get('avg_rating', 0)}"
        )


def show_menu_items():
    restaurants = {row["restaurant_id"]: row for row in fetch_restaurants()}
    menus = fetch_menus()

    print("\n=== 메뉴 목록 ===")
    if not menus:
        print("등록된 메뉴가 없습니다.")
        return

    selected_restaurant_id = input("특정 음식점 메뉴만 보려면 음식점id 입력, 전체는 Enter: ").strip()

    for menu in menus:
        if selected_restaurant_id and str(menu["restaurant_id"]) != selected_restaurant_id:
            continue

        restaurant = restaurants.get(menu["restaurant_id"], {})
        restaurant_name = restaurant.get("restaurant_name", "알 수 없음")
        print(
            f"{menu['menu_id']}. [{restaurant_name}] "
            f"{menu['menu_name']} - {money(menu['price'])}"
        )


def select_customer():
    customers = fetch_customers()

    print("\n=== 고객 선택 ===")
    for customer in customers:
        print(
            f"{customer['customer_id']}. {customer['customer_name']} "
            f"/ {customer['address']} / {customer['phone']}"
        )

    customer_ids = {row["customer_id"] for row in customers}
    while True:
        customer_id = ask_int("고객id 입력: ")
        if customer_id in customer_ids:
            return customer_id
        print("존재하지 않는 고객id입니다.")


def select_restaurant():
    restaurants = fetch_restaurants()

    print("\n=== 음식점 선택 ===")
    for restaurant in restaurants:
        print(f"{restaurant['restaurant_id']}. {restaurant['restaurant_name']}")

    restaurant_ids = {row["restaurant_id"] for row in restaurants}
    while True:
        restaurant_id = ask_int("음식점id 입력: ")
        if restaurant_id in restaurant_ids:
            return restaurant_id
        print("존재하지 않는 음식점id입니다.")


def select_order_items(restaurant_id: int):
    menus = [
        row
        for row in fetch_menus()
        if row["restaurant_id"] == restaurant_id
    ]
    menu_map = {row["menu_id"]: row for row in menus}
    selected_items = []

    print("\n=== 주문할 메뉴 선택 ===")
    for menu in menus:
        print(f"{menu['menu_id']}. {menu['menu_name']} - {money(menu['price'])}")

    print("메뉴 선택을 끝내려면 메뉴id에 0을 입력하세요.")

    while True:
        menu_id = ask_int("메뉴id 입력: ", allow_zero=True)
        if menu_id == 0:
            break

        if menu_id not in menu_map:
            print("선택한 음식점의 메뉴id만 입력할 수 있습니다.")
            continue

        quantity = ask_int("수량 입력: ")
        if quantity <= 0:
            print("수량은 1개 이상이어야 합니다.")
            continue

        selected_items.append({
            "menu_id": menu_id,
            "quantity": quantity,
            "menu_name": menu_map[menu_id]["menu_name"],
            "price": menu_map[menu_id]["price"],
        })

        print(f"{menu_map[menu_id]['menu_name']} {quantity}개 추가")

    return selected_items


def calculate_total_price(order_items):
    total = 0
    for item in order_items:
        total += to_int(item["price"]) * item["quantity"]
    return total


def create_delivery(order_id: int):
    drivers = fetch_drivers()
    if not drivers:
        print("배달원 데이터가 없어 deliveries 테이블에는 저장하지 못했습니다.")
        return

    driver = drivers[0]
    delivery = {
        "order_id": order_id,
        "driver_id": driver["driver_id"],
        "delivery_status": "PREPARING",
        "pickup_time": None,
        "delivered_time": None,
    }

    execute(
        table("deliveries").insert(delivery),
        "배달 상태 저장에 실패했습니다."
    )


def order_food():
    customer_id = select_customer()
    restaurant_id = select_restaurant()
    selected_items = select_order_items(restaurant_id)

    if not selected_items:
        print("선택한 메뉴가 없어 주문을 취소합니다.")
        return

    order = {
        "customer_id": customer_id,
        "order_timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "has_review": False,
    }

    order_res = execute(
        table("orders").insert(order),
        "주문 저장에 실패했습니다."
    )

    if not order_res or not order_res.data:
        return

    order_id = order_res.data[0]["order_id"]
    order_item_rows = [
        {
            "order_id": order_id,
            "menu_id": item["menu_id"],
            "quantity": item["quantity"],
        }
        for item in selected_items
    ]

    item_res = execute(
        table("order_items").insert(order_item_rows),
        "주문 상세 저장에 실패했습니다."
    )

    if not item_res:
        return

    create_delivery(order_id)

    print("\n주문이 Supabase에 저장되었습니다.")
    print(f"주문id: {order_id}")
    print(f"총 주문금액: {calculate_total_price(selected_items):,}원")


def find_restaurant_id_by_order(order_id: int):
    item_res = execute(
        table("order_items").select("menu_id").eq("order_id", order_id).limit(1),
        "주문 상세를 조회하지 못했습니다."
    )

    if not item_res or not item_res.data:
        return None

    menu_id = item_res.data[0]["menu_id"]
    menu_res = execute(
        table("menu_items").select("restaurant_id").eq("menu_id", menu_id).limit(1),
        "메뉴 정보를 조회하지 못했습니다."
    )

    if not menu_res or not menu_res.data:
        return None

    return menu_res.data[0]["restaurant_id"]


def update_restaurant_rating(restaurant_id: int):
    review_res = execute(
        table("reviews").select("rating").eq("restaurant_id", restaurant_id),
        "리뷰 평점 조회에 실패했습니다."
    )

    if not review_res or not review_res.data:
        return

    ratings = [row["rating"] for row in review_res.data]
    avg_rating = round(sum(ratings) / len(ratings), 1)

    execute(
        table("restaurants")
        .update({"avg_rating": avg_rating})
        .eq("restaurant_id", restaurant_id),
        "음식점 평균평점 업데이트에 실패했습니다."
    )


def write_review():
    show_orders()

    order_id = ask_int("\n리뷰를 작성할 주문id 입력: ")

    order_res = execute(
        table("orders").select("order_id, customer_id").eq("order_id", order_id).limit(1),
        "주문 정보를 조회하지 못했습니다."
    )

    if not order_res or not order_res.data:
        print("존재하지 않는 주문id입니다.")
        return

    exists_res = execute(
        table("reviews").select("review_id").eq("order_id", order_id).limit(1),
        "리뷰 중복 확인에 실패했습니다."
    )

    if exists_res and exists_res.data:
        print("이미 리뷰가 작성된 주문입니다.")
        return

    restaurant_id = find_restaurant_id_by_order(order_id)
    if restaurant_id is None:
        print("이 주문에는 주문 상세 메뉴가 없어 음식점을 찾을 수 없습니다.")
        return

    customer_id = order_res.data[0]["customer_id"]
    rating = ask_rating()
    review_content = input("리뷰 내용 입력: ").strip()

    review = {
        "order_id": order_id,
        "customer_id": customer_id,
        "restaurant_id": restaurant_id,
        "rating": rating,
        "review_content": review_content,
    }

    review_res = execute(
        table("reviews").insert(review),
        "리뷰 저장에 실패했습니다."
    )

    if not review_res:
        return

    execute(
        table("orders").update({"has_review": True}).eq("order_id", order_id),
        "주문 리뷰 여부 업데이트에 실패했습니다."
    )
    update_restaurant_rating(restaurant_id)

    print("리뷰가 Supabase에 저장되었습니다.")


def show_reviews_by_restaurant():
    restaurant_id = select_restaurant()

    reviews = fetch_all("reviews", "review_id, order_id, customer_id, restaurant_id, rating, review_content, created_at")
    customers = {row["customer_id"]: row for row in fetch_customers()}
    restaurant_reviews = [
        row
        for row in reviews
        if row["restaurant_id"] == restaurant_id
    ]

    print("\n=== 가게별 리뷰 보기 ===")
    if not restaurant_reviews:
        print("아직 리뷰가 없습니다.")
        return

    avg_rating = round(
        sum(row["rating"] for row in restaurant_reviews) / len(restaurant_reviews),
        1
    )
    print(f"평균 평점: {avg_rating} / 리뷰 수: {len(restaurant_reviews)}")

    for review in restaurant_reviews:
        customer = customers.get(review["customer_id"], {})
        customer_name = customer.get("customer_name", "알 수 없음")
        print(
            f"- 주문 {review['order_id']} / {customer_name} / "
            f"{review['rating']}점 / {review['review_content']} "
            f"({review['created_at']})"
        )


def build_order_rows():
    orders = fetch_all("orders", "order_id, customer_id, order_timestamp, has_review", "order_id")
    customers = {row["customer_id"]: row for row in fetch_customers()}
    menus = {row["menu_id"]: row for row in fetch_menus()}
    restaurants = {row["restaurant_id"]: row for row in fetch_restaurants()}
    order_items = fetch_all("order_items", "order_id, menu_id, quantity")
    deliveries = fetch_all("deliveries", "order_id, driver_id, delivery_status, pickup_time, delivered_time")
    reviews = fetch_all("reviews", "order_id, rating")

    items_by_order = {}
    for item in order_items:
        items_by_order.setdefault(item["order_id"], []).append(item)

    delivery_by_order = {row["order_id"]: row for row in deliveries}
    review_by_order = {row["order_id"]: row for row in reviews}

    rows = []
    for order in orders:
        customer = customers.get(order["customer_id"], {})
        items = items_by_order.get(order["order_id"], [])
        delivery = delivery_by_order.get(order["order_id"], {})
        review = review_by_order.get(order["order_id"])

        item_texts = []
        total_price = 0
        restaurant_names = set()

        for item in items:
            menu = menus.get(item["menu_id"], {})
            restaurant = restaurants.get(menu.get("restaurant_id"), {})
            restaurant_names.add(restaurant.get("restaurant_name", "알 수 없음"))
            item_total = to_int(menu.get("price", 0)) * item["quantity"]
            total_price += item_total
            item_texts.append(
                f"{menu.get('menu_name', '알 수 없음')} x {item['quantity']}"
            )

        rows.append({
            "order_id": order["order_id"],
            "customer_name": customer.get("customer_name", "알 수 없음"),
            "order_timestamp": order["order_timestamp"],
            "restaurants": ", ".join(sorted(restaurant_names)) if restaurant_names else "주문상세 없음",
            "items": ", ".join(item_texts) if item_texts else "주문상세 없음",
            "total_price": total_price,
            "delivery_status": delivery.get("delivery_status", "배달정보 없음"),
            "has_review": "Y" if review else "N",
        })

    return rows


def show_orders():
    rows = build_order_rows()

    print("\n=== 주문 목록 보기 ===")
    if not rows:
        print("등록된 주문이 없습니다.")
        return

    for row in rows:
        print(
            f"{row['order_id']}. {row['customer_name']} / "
            f"{row['restaurants']} / {row['items']} / "
            f"{row['total_price']:,}원 / "
            f"{row['delivery_status']} / 리뷰 {row['has_review']} / "
            f"{row['order_timestamp']}"
        )


def print_menu():
    print("\n=== 배달앱 미니 프로그램 ===")
    print("1. 음식점 목록 보기")
    print("2. 메뉴 보기")
    print("3. 음식 주문하기")
    print("4. 리뷰 작성하기")
    print("5. 가게별 리뷰 보기")
    print("6. 주문 목록 보기")
    print("0. 종료")


def run_app():
    while True:
        print_menu()
        menu = input("메뉴 선택: ").strip()

        if menu == "1":
            show_restaurants()
        elif menu == "2":
            show_menu_items()
        elif menu == "3":
            order_food()
        elif menu == "4":
            write_review()
        elif menu == "5":
            show_reviews_by_restaurant()
        elif menu == "6":
            show_orders()
        elif menu == "0":
            print("프로그램을 종료합니다.")
            break
        else:
            print("0~6 중에서 선택해주세요.")


if __name__ == "__main__":
    run_app()
