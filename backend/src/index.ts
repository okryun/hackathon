import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.routes';
import productsRoutes from './routes/products.routes';
import cartRoutes from './routes/cart.routes';
import ordersRoutes from './routes/orders.routes';
import wishlistRoutes from './routes/wishlist.routes';
import recentlyViewedRoutes from './routes/recentlyViewed.routes';
import arSessionsRoutes from './routes/arSessions.routes';
import storeRoutes from './routes/store.routes';
import reservationsRoutes from './routes/reservations.routes';
import aiChatRoutes from './routes/aiChat.routes';
import { errorHandler } from './middleware/errorHandler';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true }));

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/products', productsRoutes);
app.use('/api/v1/cart', cartRoutes);
app.use('/api/v1/orders', ordersRoutes);
app.use('/api/v1/wishlist', wishlistRoutes);
app.use('/api/v1/recently-viewed', recentlyViewedRoutes);
app.use('/api/v1/ar-sessions', arSessionsRoutes);
app.use('/api/v1/store', storeRoutes);
app.use('/api/v1/reservations', reservationsRoutes);
app.use('/api/v1/ai-chat', aiChatRoutes);

app.use(errorHandler);

const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;
app.listen(PORT, () => {
  console.log(`AR Fashion backend listening on http://localhost:${PORT}`);
});
