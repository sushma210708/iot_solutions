const express = require('express');
const {
  getEligibleRecipients,
  sendCampaign,
  getCampaigns,
  getCampaignById
} = require('../controllers/email.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect); // All email management actions require verified administrator

router.get('/recipients', getEligibleRecipients);
router.post('/send', sendCampaign);
router.get('/campaigns', getCampaigns);
router.get('/campaigns/:id', getCampaignById);

module.exports = router;
