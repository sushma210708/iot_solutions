require('dotenv').config();
const express = require('express');
const cors = require('cors');
const healthRoutes = require('./routes/health.routes');
const productRoutes = require('./routes/product.routes');
const uploadRoutes = require('./routes/uploadRoutes');
const achievementRoutes = require('./routes/achievement.routes');
const heroRoutes = require('./routes/hero.routes');
const adminRoutes = require('./routes/admin.routes');
const mentorRoutes = require('./routes/mentor.routes');
const footerRoutes = require('./routes/footer.routes');
const authRoutes = require('./routes/auth.routes');
const errorHandler = require('./middleware/error.middleware');
const connectDB = require('./config/db');
const { connectCloudinary } = require('./config/cloudinary');

const app = express();

// Connect to Database & Cloudinary
connectDB();
connectCloudinary();

// Middleware
const allowedOrigins = process.env.FRONTEND_URL 
  ? [process.env.FRONTEND_URL, 'http://localhost:5000', 'http://localhost:3000'] 
  : '*';

app.use(cors({
  origin: allowedOrigins,
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/health', healthRoutes);
app.use('/api/products', productRoutes);
app.use('/api/achievements', achievementRoutes);
app.use('/api/hero', heroRoutes);
app.use('/api/footer', footerRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/admins', adminRoutes);
app.use('/api/mentors', mentorRoutes);
app.use('/api/upload', uploadRoutes);

// 404 Handler
app.use((req, res, next) => {
  res.status(404).json({ success: false, message: 'API endpoint not found' });
});

// Global Error Handler
app.use(errorHandler);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode.`);
});
