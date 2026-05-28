# 배달앱 미니 프로그램

Supabase와 Python을 연결해서 터미널에서 실행하는 배달앱 미니 프로그램입니다.

## 주요 기능

- 음식점 목록 보기
- 음식점별 메뉴 보기
- 음식 주문하기
- 리뷰 작성하기
- 가게별 리뷰 보기
- 주문 목록 보기

## 파일 구성

| 파일명 | 설명 |
| --- | --- |
| `food_delivery_schema_seed.sql` | Supabase 스키마 생성, 샘플 데이터 적재, 권한 설정 SQL |
| `delivery_app_supabase.py` | 터미널에서 실행하는 Python 배달앱 프로그램 |
| `query.sql` | 과제용 분석/조회 SQL 5개 |
| `baedal_data.sql` | 기존 팀 작업 SQL 파일 |

## Supabase 준비 방법

1. Supabase 프로젝트를 생성합니다.
2. SQL Editor에서 `food_delivery_schema_seed.sql` 전체 내용을 실행합니다.
3. Project Settings > API 또는 Data API 설정에서 Exposed schemas에 `food_delivery`를 추가합니다.
4. Python 실행 시 Supabase URL과 anon public key를 입력합니다.

## Supabase 권한 설정 SQL

아래 오류가 나면 Supabase SQL Editor에서 이 SQL을 실행해야 합니다.

```text
Invalid schema: food_delivery
Only the following schemas are exposed: public, graphql_public
```

실행할 SQL:

```sql
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
```

## Python 실행 방법

```powershell
cd "C:\Users\KDA 6\Documents\sql_pract"
pip install supabase
python delivery_app_supabase.py
```

실행 후 아래 메뉴에서 원하는 기능을 선택합니다.

```text
=== 배달앱 미니 프로그램 ===
1. 음식점 목록 보기
2. 메뉴 보기
3. 음식 주문하기
4. 리뷰 작성하기
5. 가게별 리뷰 보기
6. 주문 목록 보기
0. 종료
```

## 입력 예시

메뉴 전체를 보려면 음식점id 입력 없이 Enter를 누릅니다.

```text
특정 음식점 메뉴만 보려면 음식점id 입력, 전체는 Enter:
```

특정 음식점 메뉴만 보고 싶으면 아래처럼 입력합니다.

```text
1 입력: Pizza Heaven 메뉴 보기
2 입력: Chicken Star 메뉴 보기
3 입력: Burger House 메뉴 보기
```

리뷰를 작성할 때는 주문 목록에서 `리뷰 N`으로 표시된 주문id를 입력합니다.

```text
리뷰를 작성할 주문id 입력: 3
평점 입력(1~5): 5
리뷰 내용 입력: 맛있어요
```

## 자주 발생하는 오류

### Invalid schema: food_delivery

Supabase API 설정에서 `food_delivery` 스키마가 노출되지 않은 상태입니다.

해결 방법:

- Supabase Dashboard의 Exposed schemas에 `food_delivery` 추가
- 또는 위의 "Supabase 권한 설정 SQL" 실행

### Could not find the table in the schema cache

Supabase API의 스키마 캐시가 갱신되지 않은 상태입니다.

해결 방법:

```sql
NOTIFY pgrst, 'reload schema';
```

## 분석 쿼리 예시

`query.sql`에는 아래 분석 쿼리가 포함되어 있습니다.

- 음식점 목록과 평균 평점 조회
- 음식점별 메뉴 목록 조회
- 주문별 고객, 메뉴, 수량 조회
- 음식점별 총 매출 조회
- 가게별 리뷰 개수와 평균 평점 조회
