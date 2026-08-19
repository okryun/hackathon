# AR Fashion Backend

`ar_fashion_app` Flutter 프론트엔드(오프라인 패션 매장용 AR 쇼핑 앱)를 위한 백엔드 API입니다.
프론트엔드의 `lib/services/*` 에 있던 Mock 구현(MockProductService, AuthProvider 등)을 그대로 대체할 수 있도록
동일한 데이터 형태로 설계했습니다.

## 스택

- Node.js + TypeScript + Express
- Prisma ORM + SQLite (기본값. 별도 DB 설치 없이 바로 실행 가능하며, Postgres로 손쉽게 전환 가능)
- JWT 기반 인증 (jsonwebtoken + bcryptjs)
- AI 컨시어지 챗봇: `ANTHROPIC_API_KEY`를 설정하면 실제 Claude API 호출, 없으면 기존 프론트의 Mock 응답과 동일하게 동작

## 빠른 시작

```bash
cd backend
cp .env.example .env      # 필요하면 JWT_SECRET, ANTHROPIC_API_KEY 수정
npm install
npx prisma migrate dev --name init   # DB 스키마 생성 (dev.db 파일 생성)
npm run seed                          # 상품 12개 + 데모 계정 시드
npm run dev                           # http://localhost:4000
```

헬스체크: `GET http://localhost:4000/health` → `{ "ok": true }`

데모 로그인 계정: `demo@arfashion.app` / `password123`

## Postgres로 전환하려면

1. `prisma/schema.prisma`의 `datasource db`에서 `provider = "sqlite"` → `provider = "postgresql"`
2. `.env`의 `DATABASE_URL`을 Postgres 연결 문자열로 변경
3. `npx prisma migrate dev` 재실행

## API 개요

인증이 필요한 엔드포인트는 `Authorization: Bearer <token>` 헤더가 필요합니다 (🔒 표시).

### 인증
| Method | Path | 설명 |
|---|---|---|
| POST | `/api/v1/auth/signup` | 회원가입 → `{ token, user }` |
| POST | `/api/v1/auth/login` | 로그인 → `{ token, user }` |
| GET | `/api/v1/auth/me` 🔒 | 현재 로그인 사용자 정보 |

### 상품
| Method | Path | 설명 |
|---|---|---|
| GET | `/api/v1/products?category=&search=` | 목록 조회 (카테고리/검색어 필터) |
| GET | `/api/v1/products/categories` | 카테고리 목록 (`['All', ...]`) |
| GET | `/api/v1/products/popular` | 리뷰 수 기준 인기 상품 6개 |
| GET | `/api/v1/products/recommended` | 평점 기준 추천 상품 6개 |
| GET | `/api/v1/products/:id` | 상품 상세 |
| GET | `/api/v1/products/:id/reviews` | 상품 리뷰 목록 |
| POST | `/api/v1/products/:id/reviews` 🔒 | 리뷰 작성 (`{ rating, comment, color? }`) |

### 장바구니 🔒
| Method | Path | 설명 |
|---|---|---|
| GET | `/api/v1/cart` | 장바구니 조회 |
| POST | `/api/v1/cart/items` | 담기 (`{ productId, color?, quantity? }`) |
| PATCH | `/api/v1/cart/items/:itemId` | 수량 변경 (`{ quantity }`) |
| DELETE | `/api/v1/cart/items/:itemId` | 항목 삭제 |
| DELETE | `/api/v1/cart` | 전체 비우기 |

### 주문 🔒
| Method | Path | 설명 |
|---|---|---|
| GET | `/api/v1/orders` | 주문 내역 |
| POST | `/api/v1/orders` | 장바구니 → 주문 전환 (장바구니 비워짐) |

### 찜 / 최근 본 상품 🔒
| Method | Path | 설명 |
|---|---|---|
| GET / POST / DELETE | `/api/v1/wishlist(/:productId)` | 찜 목록 조회/추가/삭제 |
| GET / POST | `/api/v1/recently-viewed(/:productId)` | 최근 본 상품 조회/기록 (최대 20개) |

### AR 세션 (로그인 선택)
| Method | Path | 설명 |
|---|---|---|
| POST | `/api/v1/ar-sessions/start` | AR 체험 시작 (`{ productId }`) |
| POST | `/api/v1/ar-sessions/:sessionId/end` | AR 체험 종료 |
| GET | `/api/v1/ar-sessions/history` 🔒 | 내 AR 체험 히스토리 |
| GET | `/api/v1/ar-sessions/stats/:productId` | 상품별 AR 사용 횟수/누적 시간 (매장 분석용) |

### 매장 체크인 🔒
| Method | Path | 설명 |
|---|---|---|
| POST | `/api/v1/store/checkin` | 체크인 (`{ storeId, storeName }`) |
| POST | `/api/v1/store/checkout` | 체크아웃 |
| GET | `/api/v1/store/current` | 현재 체크인 상태 |

### 피팅룸 예약 🔒
| Method | Path | 설명 |
|---|---|---|
| GET | `/api/v1/reservations` | 예약 내역 |
| GET | `/api/v1/reservations/upcoming` | 가장 최근 예정 예약 (QR 체크인용) |
| POST | `/api/v1/reservations` | 예약 생성 (`{ storeId, storeName, date, time, itemCount? }`) → QR에 사용할 `code` 포함 |
| POST | `/api/v1/reservations/:id/cancel` | 예약 취소 |

### AI 컨시어지 챗봇 (로그인 선택)
| Method | Path | 설명 |
|---|---|---|
| POST | `/api/v1/ai-chat` | `{ productId?, message }` → `{ reply }` |

## Flutter 프론트엔드 연동 상태

`lib/services/api_client.dart`(HTTP 클라이언트) + `lib/services/api_product_service.dart` 등으로
위 API 전체가 이미 연동되어 있습니다. 로그인 토큰은 `shared_preferences`에 저장됩니다.

로그인하지 않은 게스트 상태에서는 기존 Mock 동작(로컬 메모리 저장)이 그대로 유지되고, 로그인한 사용자는
장바구니/주문/찜/최근 본 상품/AR 세션/매장 체크인/예약이 실제로 서버(SQLite DB)에 저장됩니다.

## 참고

- 데이터베이스는 기본적으로 `backend/dev.db` (SQLite 파일)에 저장됩니다. 데모/해커톤용으로 별도 서버 설치 없이 바로 돌릴 수 있게 하기 위한 선택이며, 배포 시에는 Postgres 전환을 권장합니다.
- `colors` 필드는 SQLite에 배열 타입이 없어 JSON 문자열로 저장하고, API 응답에서는 다시 배열로 파싱해서 내려줍니다.
- `ANTHROPIC_API_KEY`가 없으면 AI 챗봇은 프론트엔드에 원래 있던 Mock 응답 문구를 그대로 반환하므로, 키 없이도 전체 플로우 데모가 가능합니다.
