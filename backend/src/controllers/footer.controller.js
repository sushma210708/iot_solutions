const Footer = require('../models/footer.model');

const DEFAULT_QUICK_LINKS = [
  { label: 'Home', route: '/' },
  { label: 'Products', route: '/solutions' },
  { label: 'Services', route: '/services' },
  { label: 'Technology', route: '/technology' },
  { label: 'Mentors', route: '/mentors' },
  { label: 'About Us', route: '/about' },
  { label: 'Contact', route: '/contact' }
];

const DEFAULT_SERVICES_LINKS = [
  { label: 'IoT Energy Optimization', route: '/services' },
  { label: 'Smart APFC Automation', route: '/solutions' },
  { label: 'Industrial Automation', route: '/services' },
  { label: 'Real-Time Power Telemetry', route: '/technology' }
];

const DEFAULT_SOCIAL_LINKS = [
  { platform: 'instagram', url: 'https://instagram.com/greenfusioniotsolutions', label: '@greenfusioniotsolutions' },
  { platform: 'linkedin', url: 'https://linkedin.com/company/greenfusioniotsolutions', label: 'GreenFusion IoT Solutions' },
  { platform: 'twitter', url: 'https://twitter.com/greenfusioniot', label: '@GreenFusionIoT' }
];

exports.getFooter = async (req, res) => {
  try {
    let footer = await Footer.findOne();
    if (!footer) {
      footer = await Footer.create({
        quickLinks: DEFAULT_QUICK_LINKS,
        servicesLinks: DEFAULT_SERVICES_LINKS,
        socialLinks: DEFAULT_SOCIAL_LINKS
      });
    } else {
      let needsSave = false;
      if (!footer.quickLinks || footer.quickLinks.length === 0) {
        footer.quickLinks = DEFAULT_QUICK_LINKS;
        needsSave = true;
      }
      if (!footer.servicesLinks || footer.servicesLinks.length === 0) {
        footer.servicesLinks = DEFAULT_SERVICES_LINKS;
        needsSave = true;
      }
      if (!footer.socialLinks || footer.socialLinks.length === 0) {
        footer.socialLinks = DEFAULT_SOCIAL_LINKS;
        needsSave = true;
      }
      if (!footer.phones || footer.phones.length === 0) {
        footer.phones = [footer.phone1, footer.phone2, footer.phone3].filter(Boolean);
        needsSave = true;
      }
      if (!footer.emails || footer.emails.length === 0) {
        footer.emails = [footer.email].filter(Boolean);
        needsSave = true;
      }
      if (needsSave) {
        await footer.save();
      }
    }
    res.json({ success: true, data: footer });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateFooter = async (req, res) => {
  try {
    const updateData = { ...req.body };

    // Synchronize arrays if single fields are provided
    if (updateData.phones && Array.isArray(updateData.phones)) {
      updateData.phone1 = updateData.phones[0] || '';
      updateData.phone2 = updateData.phones[1] || '';
      updateData.phone3 = updateData.phones[2] || '';
    }
    if (updateData.emails && Array.isArray(updateData.emails)) {
      updateData.email = updateData.emails[0] || '';
    }

    let footer = await Footer.findOne();
    if (!footer) {
      footer = await Footer.create(updateData);
    } else {
      footer = await Footer.findByIdAndUpdate(footer._id, updateData, { new: true, runValidators: true });
    }
    res.json({ success: true, data: footer });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
