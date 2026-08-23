const express = require('express');
const {
  getProducts,
  getProduct,
  createProduct,
  updateProduct,
  deleteProduct
} = require('../controllers/product.controller');
const { protect, protectFirebase, requirePermission } = require('../middleware/auth.middleware');

const router = express.Router();

router.route('/')
  .get(getProducts)
  .post(protect, requirePermission('manage_projects'), createProduct);

router.route('/:id')
  .get(protectFirebase, getProduct)
  .put(protect, requirePermission('manage_projects'), updateProduct)
  .delete(protect, requirePermission('manage_projects'), deleteProduct);

module.exports = router;
