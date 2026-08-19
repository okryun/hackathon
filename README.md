# AR Fashion App (MIRA)

오프라인 패션 매장을 위한 AR 쇼핑 앱입니다. Flutter 프론트엔드 + Node.js/Express 백엔드로 구성되어 있으며,
회원가입/로그인, 상품 탐색, AR 피팅, 장바구니/주문, 찜/최근 본 상품, 리뷰, 매장 체크인(QR), 피팅룸 예약,
AI 컨시어지 챗봇(Claude API) 기능을 제공합니다.

## 프로젝트 구조

```
hackathon/
├─ lib/            # Flutter 프론트엔드
├─ backend/        # Node.js + Express + Prisma 백엔드 API
└─ README.md       # (이 파일)
```

## 실행 방법

### 1) 백엔드 실행

```bash
cd backend
cp .env.example .env
# .env 파일을 열어서 JWT_SECRET을 아무 랜덤 문자열로 채우고,
# AI 챗봇을 실제로 쓰려면 ANTHROPIC_API_KEY도 채워주세요 (없어도 Mock 응답으로 동작합니다).
npm install
npx prisma migrate dev --name init   # DB 스키마 생성
npm run seed                          # 상품 12개 + 데모 계정 생성
npm run dev                           # http://localhost:4000 에서 실행
```

헬스체크: 브라우저에서 `http://localhost:4000/health` 접속 시 `{"ok":true}` 가 보이면 정상입니다.

데모 로그인 계정: `demo@arfashion.app` / `password123`

백엔드 API 전체 목록은 [`backend/README.md`](backend/README.md)에 정리되어 있습니다.

### 2) Flutter 앱 실행

백엔드가 실행 중인 상태에서, 새 터미널을 열고:

```bash
flutter pub get
flutter run -d chrome   # 또는 -d edge / -d windows 등 사용 가능한 디바이스
```

> Flutter 앱은 기본적으로 `http://localhost:4000`의 백엔드에 연결하도록 설정되어 있습니다
> (`lib/services/api_client.dart`의 `baseUrl`). 백엔드를 다른 주소로 배포하면 이 값을 바꿔주세요.

## 주요 기능

- 회원가입 / 로그인 (JWT 인증)
- 상품 목록/검색/카테고리별 탐색, 상세, 리뷰
- 장바구니, 바로구매, 주문 내역
- 찜(위시리스트), 최근 본 상품
- AR 피팅 세션 기록
- 매장 체크인 (NFC/QR 시뮬레이션)
- 피팅룸 예약 (생성 / 목록 / QR 확인 / 취소)
- AI 컨시어지 챗봇 (Anthropic Claude API, 키 미설정 시 Mock 응답으로 자동 대체)

## 참고 (팀원 공유 시 주의사항)

- `backend/.env` 파일에는 각자의 `JWT_SECRET`, `ANTHROPIC_API_KEY` 같은 비밀 값이 들어가며, 이 저장소에는
  커밋되지 않습니다(`.gitignore` 처리됨). 각자 `.env.example`을 복사해서 본인 값을 채워야 합니다.
- 로그인/AI 챗봇 등 실제 API 키가 필요한 기능도, 키가 없으면 기존 Mock 동작으로 자연스럽게 대체되므로
  키 없이도 전체 데모가 가능합니다.
