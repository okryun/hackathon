import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

// Flutter 프론트엔드의 lib/data/mock_products.dart 데이터를 그대로 포팅한 시드 데이터.
// 상품 id(p001~p012)를 동일하게 맞춰서, 프론트를 Mock -> API로 교체해도
// 기존 화면/딥링크가 그대로 동작하도록 했다.
const products = [
  {
    id: 'p001', brand: 'MELROSE', name: 'Aren Mini Hobo Bag', price: 1250000,
    image: 'https://picsum.photos/seed/p001/800/1000', category: 'Bag',
    colors: ['Black', 'Camel', 'Ivory'],
    description: '시그니처 모노그램 패턴의 미니 호보백. 데일리로 활용하기 좋은 사이즈감과 가벼운 무게가 특징입니다.',
    stock: 4, storeLocation: '1F A구역 - 3번 진열대', arAvailable: true, rating: 4.8, reviewCount: 128,
  },
  {
    id: 'p002', brand: 'MELROSE', name: 'Aren Shoulder Bag', price: 1550000,
    image: 'https://picsum.photos/seed/p002/800/1000', category: 'Bag',
    colors: ['Black', 'Brown'],
    description: '숄더로도, 크로스로도 착용 가능한 2-way 스트랩 디자인. 견고한 하드웨어와 부드러운 그레인 레더를 사용했습니다.',
    stock: 2, storeLocation: '1F A구역 - 4번 진열대', arAvailable: true, rating: 4.8, reviewCount: 96,
  },
  {
    id: 'p003', brand: 'STARK', name: 'Stark Backpack Mini', price: 980000,
    image: 'https://picsum.photos/seed/p003/800/1000', category: 'Bag',
    colors: ['Black', 'Grey'],
    description: '가볍게 매치하기 좋은 미니 백팩. 노트북 수납이 가능한 내부 포켓을 갖췄습니다.',
    stock: 0, storeLocation: '1F B구역 - 1번 진열대', arAvailable: true, rating: 4.6, reviewCount: 58,
  },
  {
    id: 'p004', brand: 'MILLA', name: 'Milla Tote Bag Large', price: 1120000,
    image: 'https://picsum.photos/seed/p004/800/1000', category: 'Bag',
    colors: ['Beige', 'Black'],
    description: '여유로운 수납공간의 라지 토트백. 오피스룩과 캐주얼룩 모두에 잘 어울립니다.',
    stock: 6, storeLocation: '1F B구역 - 2번 진열대', arAvailable: true, rating: 4.7, reviewCount: 41,
  },
  {
    id: 'p005', brand: 'NOIR LINE', name: 'Classic Trench Coat', price: 890000,
    image: 'https://picsum.photos/seed/p005/800/1000', category: 'Outer',
    colors: ['Beige', 'Black'],
    description: '클래식한 실루엣의 트렌치코트. 사계절 아우터로 활용도가 높습니다.',
    stock: 5, storeLocation: '2F C구역 - 1번 진열대', arAvailable: false, rating: 4.5, reviewCount: 22,
  },
  {
    id: 'p006', brand: 'STARK', name: 'Stark Crossbody Small', price: 760000,
    image: 'https://picsum.photos/seed/p006/800/1000', category: 'Bag',
    colors: ['Black', 'Red'],
    description: '컴팩트한 사이즈의 크로스백. 필수 소지품만 담아 가볍게 외출할 때 좋습니다.',
    stock: 3, storeLocation: '1F A구역 - 5번 진열대', arAvailable: true, rating: 4.4, reviewCount: 33,
  },
  {
    id: 'p007', brand: 'MELROSE', name: 'Aren Card Wallet', price: 320000,
    image: 'https://picsum.photos/seed/p007/800/1000', category: 'Accessory',
    colors: ['Black', 'Camel'],
    description: '슬림한 카드 지갑. 백 컬렉션과 통일감 있게 매치하기 좋습니다.',
    stock: 12, storeLocation: '1F A구역 - 6번 진열대', arAvailable: false, rating: 4.6, reviewCount: 77,
  },
  {
    id: 'p008', brand: 'MILLA', name: 'Milla Bucket Bag', price: 990000,
    image: 'https://picsum.photos/seed/p008/800/1000', category: 'Bag',
    colors: ['Ivory', 'Brown'],
    description: '이지한 무드의 버킷백. 조절 가능한 스트랩으로 다양한 룩에 매치할 수 있습니다.',
    stock: 7, storeLocation: '1F B구역 - 3번 진열대', arAvailable: true, rating: 4.9, reviewCount: 64,
  },
  {
    id: 'p009', brand: 'NOIR LINE', name: 'Wool Blend Jacket', price: 670000,
    image: 'https://picsum.photos/seed/p009/800/1000', category: 'Outer',
    colors: ['Charcoal', 'Camel'],
    description: '울 혼방 소재의 자켓. 적당한 두께감으로 간절기에도 활용하기 좋습니다.',
    stock: 8, storeLocation: '2F C구역 - 2번 진열대', arAvailable: false, rating: 4.3, reviewCount: 15,
  },
  {
    id: 'p010', brand: 'STARK', name: 'Stark Weekender Bag', price: 1420000,
    image: 'https://picsum.photos/seed/p010/800/1000', category: 'Bag',
    colors: ['Black', 'Navy'],
    description: '짧은 여행에 적합한 위켄더백. 넉넉한 수납력과 견고한 내구성을 갖췄습니다.',
    stock: 1, storeLocation: '1F B구역 - 4번 진열대', arAvailable: true, rating: 4.7, reviewCount: 29,
  },
  {
    id: 'p011', brand: 'MELROSE', name: 'Aren Zip Pouch', price: 280000,
    image: 'https://picsum.photos/seed/p011/800/1000', category: 'Accessory',
    colors: ['Black', 'Ivory', 'Camel'],
    description: '실용적인 사이즈의 지퍼 파우치. 백 안 소품 정리용으로도, 미니백으로도 활용 가능합니다.',
    stock: 15, storeLocation: '1F A구역 - 7번 진열대', arAvailable: false, rating: 4.5, reviewCount: 19,
  },
  {
    id: 'p012', brand: 'MILLA', name: 'Milla Mini Crossbody', price: 540000,
    image: 'https://picsum.photos/seed/p012/800/1000', category: 'Bag',
    colors: ['Black', 'Pink'],
    description: '데일리로 부담 없이 매치하기 좋은 미니 크로스백. 체인 스트랩 디테일이 포인트입니다.',
    stock: 5, storeLocation: '1F B구역 - 5번 진열대', arAvailable: true, rating: 4.6, reviewCount: 47,
  },
];

const authorPool = ['수민', '지훈', '하은', '민준', '서연', '도윤', '예은', '준서', '유진', '시우'];
const highlightComments = [
  '기대했던 것보다 훨씬 고급스러워요. 마감이 정말 꼼꼼합니다.',
  'AR로 미리 착용해보고 구매했는데 실물이랑 거의 똑같아서 놀랐어요.',
  '컬러감이 화면에서 본 것보다 예뻐요. 재구매 의사 100%입니다.',
];
const neutralComments = [
  '전반적으로 무난하고 괜찮아요. 배송도 빨랐습니다.',
  '가격 대비 만족스러운 편이에요. 다음엔 다른 컬러도 사보려고요.',
];

async function main() {
  for (const p of products) {
    await prisma.product.upsert({
      where: { id: p.id },
      update: {},
      create: { ...p, colors: JSON.stringify(p.colors) },
    });
  }

  // 상품당 최대 8개의 데모 리뷰를 생성 (원본 Flutter의 generateMockReviews와 비슷한 톤).
  for (const p of products) {
    const existingCount = await prisma.review.count({ where: { productId: p.id } });
    if (existingCount > 0) continue;

    const count = Math.min(p.reviewCount, 8);
    for (let i = 0; i < count; i++) {
      const rating = Math.max(3, Math.min(5, Math.round(p.rating) - (i % 3 === 0 ? 1 : 0)));
      const comment = rating >= 5 ? highlightComments[i % highlightComments.length] : neutralComments[i % neutralComments.length];
      await prisma.review.create({
        data: {
          productId: p.id,
          authorName: `${authorPool[i % authorPool.length]}***`,
          rating,
          comment,
          color: p.colors[i % p.colors.length],
          helpfulCount: i * 3,
        },
      });
    }
  }

  // 데모 로그인용 계정 (email: demo@arfashion.app / password: password123)
  const hashed = await bcrypt.hash('password123', 10);
  await prisma.user.upsert({
    where: { email: 'demo@arfashion.app' },
    update: {},
    create: { name: '지민', email: 'demo@arfashion.app', password: hashed },
  });

  console.log('시드 데이터 생성 완료: 상품 12개, 데모 계정 demo@arfashion.app / password123');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
