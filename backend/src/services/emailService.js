const axios = require('axios');
const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    this.adminEmail = process.env.ADMIN_NOTIFICATION_EMAIL || process.env.GMAIL_USER || 'Gfiotsolutions@gmail.com';
    this.appsScriptUrl = process.env.GOOGLE_APPS_SCRIPT_URL || 'https://script.google.com/macros/s/AKfycbyj_5hnXaSAYJgLumiztbCBzoDE90nQ22IiYedpFD1EMzSKhzergTenDNxxNRyw-ws/exec';
    this.appsScriptSecret = process.env.GOOGLE_APPS_SCRIPT_SECRET || 'greenfusion_secure_script_token_2026';
    this.siteUrl = process.env.FRONTEND_URL || 'https://greenfusioniotsolutions.web.app';

    // Transporter for direct SMTP/Gmail if configured
    this.transporter = null;
    if (process.env.GMAIL_USER && (process.env.GMAIL_APP_PASSWORD || process.env.SMTP_PASS)) {
      this.transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.GMAIL_USER,
          pass: process.env.GMAIL_APP_PASSWORD || process.env.SMTP_PASS
        }
      });
    } else if (process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASS) {
      this.transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: parseInt(process.env.SMTP_PORT || '587'),
        secure: process.env.SMTP_SECURE === 'true',
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS
        }
      });
    }
  }

  /**
   * Send notification to admin/team recipients when new project inquiry arrives
   */
  async sendAdminInquiryNotification(inquiry, recipientEmails = null) {
    let targets = [];
    if (Array.isArray(recipientEmails) && recipientEmails.length > 0) {
      targets = recipientEmails
        .map(e => (typeof e === 'string' ? e.trim() : ''))
        .filter(e => e.length > 0);
    }
    if (targets.length === 0) {
      targets = [this.adminEmail];
    }
    // Deduplicate
    targets = [...new Set(targets)];

    const subject = 'New Project Inquiry — GreenFusion IoT Solutions';
    const submissionDate = new Date(inquiry.createdAt || Date.now()).toLocaleString('en-IN', {
      timeZone: 'Asia/Kolkata',
      dateStyle: 'medium',
      timeStyle: 'short'
    });

    const htmlBody = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>New Project Inquiry</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; margin: 0; padding: 24px; color: #1e293b; }
    .container { max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); }
    .header { background: linear-gradient(135deg, #1d4ed8 0%, #2563eb 100%); padding: 32px 28px; text-align: left; }
    .header h1 { color: #ffffff; font-size: 22px; margin: 0 0 6px 0; font-weight: 700; letter-spacing: -0.5px; }
    .header p { color: #dbeafe; font-size: 14px; margin: 0; opacity: 0.95; }
    .content { padding: 32px 28px; }
    .badge { display: inline-block; background-color: #eff6ff; color: #1d4ed8; font-size: 12px; font-weight: 600; padding: 4px 10px; border-radius: 9999px; border: 1px solid #bfdbfe; margin-bottom: 20px; }
    .detail-table { width: 100%; border-collapse: collapse; margin-bottom: 24px; }
    .detail-table td { padding: 12px 0; border-bottom: 1px solid #f1f5f9; font-size: 14px; vertical-align: top; }
    .detail-table td.label { width: 140px; color: #64748b; font-weight: 600; }
    .detail-table td.value { color: #0f172a; font-weight: 500; }
    .requirements-box { background: #f8fafc; border-left: 4px solid #2563eb; padding: 16px 20px; border-radius: 4px 8px 8px 4px; margin-top: 8px; font-size: 14px; line-height: 1.6; color: #334155; white-space: pre-wrap; }
    .actions { text-align: center; margin-top: 32px; padding-top: 24px; border-top: 1px solid #e2e8f0; }
    .btn { display: inline-block; background: #2563eb; color: #ffffff !important; text-decoration: none; font-weight: 600; font-size: 14px; padding: 12px 28px; border-radius: 6px; box-shadow: 0 2px 4px rgba(37, 99, 235, 0.2); }
    .footer { background: #f8fafc; padding: 20px 28px; text-align: center; font-size: 12px; color: #94a3b8; border-top: 1px solid #f1f5f9; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>GreenFusion IoT Solutions</h1>
      <p>New Project Inquiry Notification</p>
    </div>
    <div class="content">
      <span class="badge">Inquiry ID: ${inquiry.inquiryId || inquiry._id}</span>
      <p style="margin-top: 0; font-size: 15px; color: #334155;">A new project collaboration inquiry has been received from the website.</p>
      
      <table class="detail-table">
        <tr>
          <td class="label">Full Name</td>
          <td class="value"><strong>${inquiry.name}</strong></td>
        </tr>
        <tr>
          <td class="label">Email Address</td>
          <td class="value"><a href="mailto:${inquiry.email}" style="color: #2563EB; text-decoration: none;">${inquiry.email}</a></td>
        </tr>
        <tr>
          <td class="label">Phone Number</td>
          <td class="value"><a href="tel:${inquiry.phone}" style="color: #2563EB; text-decoration: none;">${inquiry.phone}</a></td>
        </tr>
        <tr>
          <td class="label">Received Date</td>
          <td class="value">${submissionDate}</td>
        </tr>
      </table>

      <div style="font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 4px;">Project Requirements:</div>
      <div class="requirements-box">${inquiry.message || inquiry.projectRequirements || 'No description provided.'}</div>

      <div class="actions">
        <a href="${this.siteUrl}/#/admin" class="btn">View in Admin Dashboard &rarr;</a>
      </div>
    </div>
    <div class="footer">
      GreenFusion IoT Solutions &bull; Industrial & Energy IoT Innovations<br/>
      Automated System Notification &bull; Delivered to configured team recipients.
    </div>
  </div>
</body>
</html>
    `;

    const textBody = `New Project Inquiry from ${inquiry.name} (${inquiry.email}, ${inquiry.phone}):\n\n${inquiry.message || inquiry.projectRequirements || 'No description provided.'}\n\nID: ${inquiry.inquiryId || inquiry._id}\nView at: ${this.siteUrl}/#/admin`;

    let successCount = 0;
    let lastProvider = 'unknown';
    let lastError = '';

    for (const target of targets) {
      try {
        const sendResult = await this._sendEmail({
          to: target,
          subject,
          html: htmlBody,
          text: textBody,
          type: 'inquiry_notification',
          metadata: { inquiryId: inquiry.inquiryId || inquiry._id, recipientEmail: target }
        });

        if (sendResult.success) {
          successCount++;
          lastProvider = sendResult.provider || lastProvider;
        } else if (sendResult.error) {
          lastError = sendResult.error;
        }
      } catch (err) {
        lastError = err.message;
      }
    }

    return {
      success: successCount > 0,
      recipients: targets,
      sentCount: successCount,
      provider: lastProvider,
      error: lastError
    };
  }

  /**
   * Send custom campaign or broadcast email to registered users
   */
  async sendCampaignEmail({ recipients, subject, message, campaignId, htmlCustom = null }) {
    const results = [];
    let successful = 0;
    let failed = 0;

    for (const recipient of recipients) {
      const email = recipient.email;
      const name = recipient.name || 'Valued User';

      const personalizedHtml = htmlCustom ? htmlCustom.replace(/{{name}}/g, name) : `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>${subject}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; margin: 0; padding: 24px; color: #1e293b; }
    .container { max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #e2e8f0; }
    .header { background: #059669; padding: 24px 28px; text-align: left; }
    .header h1 { color: #ffffff; font-size: 20px; margin: 0; font-weight: 700; }
    .content { padding: 32px 28px; font-size: 15px; line-height: 1.6; color: #334155; }
    .footer { background: #f8fafc; padding: 20px 28px; text-align: center; font-size: 12px; color: #94a3b8; border-top: 1px solid #f1f5f9; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>GreenFusion IoT Solutions</h1>
    </div>
    <div class="content">
      <p style="font-weight: 600; color: #0f172a;">Dear ${name},</p>
      <div style="white-space: pre-wrap; margin: 20px 0;">${message}</div>
      <p style="margin-top: 24px; color: #64748b; font-size: 14px;">Best regards,<br/><strong>Team GreenFusion IoT Solutions</strong></p>
    </div>
    <div class="footer">
      &copy; 2026 GreenFusion IoT Solutions. All rights reserved.<br/>
      You are receiving this notification because you are a registered user of GreenFusion IoT Solutions.
    </div>
  </div>
</body>
</html>
      `;

      try {
        const sendResult = await this._sendEmail({
          to: email,
          subject,
          html: personalizedHtml,
          text: message,
          type: 'user_campaign',
          metadata: { campaignId, recipientEmail: email }
        });

        if (sendResult.success) {
          successful++;
          results.push({ email, name, status: 'sent' });
        } else {
          failed++;
          results.push({ email, name, status: 'failed', error: sendResult.error || 'Send failed' });
        }
      } catch (err) {
        failed++;
        results.push({ email, name, status: 'failed', error: err.message });
      }

      // Small throttle between emails to respect provider limits
      if (recipients.length > 1) {
        await new Promise(r => setTimeout(r, 200));
      }
    }

    return {
      total: recipients.length,
      successful,
      failed,
      results
    };
  }

  /**
   * Send email reply to customer regarding their project inquiry
   */
  async sendCustomerInquiryReply({ to, customerName, inquiryId, message, subject, adminName }) {
    const emailSubject = subject || `Regarding your Project Inquiry (${inquiryId}) — GreenFusion IoT Solutions`;

    const htmlBody = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>${emailSubject}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; margin: 0; padding: 24px; color: #1e293b; }
    .container { max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); }
    .header { background: linear-gradient(135deg, #1d4ed8 0%, #2563eb 100%); padding: 28px; text-align: left; }
    .header h1 { color: #ffffff; font-size: 22px; margin: 0 0 4px 0; font-weight: 700; letter-spacing: -0.5px; }
    .header p { color: #dbeafe; font-size: 14px; margin: 0; }
    .content { padding: 32px 28px; }
    .badge { display: inline-block; background-color: #eff6ff; color: #1d4ed8; font-size: 12px; font-weight: 600; padding: 4px 10px; border-radius: 9999px; border: 1px solid #bfdbfe; margin-bottom: 20px; }
    .message-box { background: #f8fafc; border-left: 4px solid #2563eb; padding: 18px 20px; border-radius: 4px 8px 8px 4px; margin: 20px 0; font-size: 15px; line-height: 1.6; color: #1e293b; white-space: pre-wrap; }
    .portal-info { background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 14px 16px; margin: 24px 0; font-size: 13px; color: #166534; line-height: 1.5; }
    .btn { display: inline-block; background: #2563eb; color: #ffffff !important; text-decoration: none; font-weight: 600; font-size: 14px; padding: 12px 28px; border-radius: 6px; box-shadow: 0 2px 4px rgba(37, 99, 235, 0.2); }
    .footer { background: #f8fafc; padding: 20px 28px; text-align: center; font-size: 12px; color: #94a3b8; border-top: 1px solid #f1f5f9; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>GreenFusion IoT Solutions</h1>
      <p>Project Inquiry Response</p>
    </div>
    <div class="content">
      <span class="badge">Inquiry Reference: ${inquiryId}</span>
      <p style="font-weight: 600; font-size: 16px; color: #0f172a; margin-top: 0;">Dear ${customerName || 'Valued Customer'},</p>
      <p style="font-size: 14px; color: #475569; line-height: 1.5;">Thank you for connecting with GreenFusion IoT Solutions. Our team has reviewed your project inquiry and has sent you the following update:</p>
      
      <div class="message-box">${message}</div>

      <div class="portal-info">
        <strong>Track in Your Customer Portal:</strong> You can review this response, track status updates, and view your project history anytime on your Customer Portal at GreenFusion IoT Solutions.
      </div>

      <div style="text-align: center; margin: 28px 0 16px 0;">
        <a href="${this.siteUrl}/#/login" class="btn">Open Customer Portal &rarr;</a>
      </div>

      <p style="margin-top: 24px; color: #64748b; font-size: 13px;">Best regards,<br/><strong>${adminName || 'Team GreenFusion IoT Solutions'}</strong><br/>GreenFusion IoT Solutions</p>
    </div>
    <div class="footer">
      &copy; 2026 GreenFusion IoT Solutions. Industrial & Energy IoT Innovations.<br/>
      Need assistance? Contact us at Gfiotsolutions@gmail.com
    </div>
  </div>
</body>
</html>
    `;

    return await this._sendEmail({
      to,
      subject: emailSubject,
      html: htmlBody,
      text: `Dear ${customerName},\n\nRegarding your inquiry (${inquiryId}):\n\n${message}\n\nYou can track this inquiry anytime on your Customer Portal at ${this.siteUrl}/#/dashboard.\n\nBest regards,\n${adminName || 'Team GreenFusion IoT Solutions'}`,
      type: 'customer_inquiry_reply',
      metadata: { inquiryId, recipientEmail: to }
    });
  }

  /**
   * Internal dispatcher: Google Apps Script Webhook -> Nodemailer / SMTP -> Simulated fallback
   */
  async _sendEmail({ to, subject, html, text, type, metadata = {} }) {
    // 1. Check Google Apps Script Webhook
    if (this.appsScriptUrl) {
      try {
        const payload = {
          secret: this.appsScriptSecret,
          to,
          subject,
          htmlBody: html,
          textBody: text,
          type,
          metadata
        };

        const response = await axios.post(this.appsScriptUrl, payload, {
          timeout: 15000,
          maxRedirects: 5,
          headers: { 'Content-Type': 'application/json' }
        });

        if (response.data && response.data.success !== false) {
          console.log(`[EmailService] Sent email to ${to} via Google Apps Script.`);
          return { success: true, provider: 'google_apps_script' };
        } else {
          console.warn(`[EmailService] Google Apps Script responded with:`, response.data);
          // If error returned by Apps Script, fall through to nodemailer if available
        }
      } catch (gasErr) {
        console.error(`[EmailService] Google Apps Script error:`, gasErr.message);
      }
    }

    // 2. Check Nodemailer / SMTP
    if (this.transporter) {
      try {
        const fromAddress = process.env.SMTP_FROM || `"GreenFusion IoT Solutions" <${process.env.GMAIL_USER || this.adminEmail}>`;
        await this.transporter.sendMail({
          from: fromAddress,
          to,
          subject,
          html,
          text
        });

        console.log(`[EmailService] Sent email to ${to} via SMTP/Nodemailer.`);
        return { success: true, provider: 'smtp' };
      } catch (smtpErr) {
        console.error(`[EmailService] SMTP error:`, smtpErr.message);
        return { success: false, error: smtpErr.message };
      }
    }

    // 3. Simulated Fallback (Logs to console so application works cleanly even before keys are supplied)
    console.log(`\n======================================================`);
    console.log(`[EmailService - SIMULATED DELIVERY / NO CREDENTIALS CONFIGURED]`);
    console.log(`TO: ${to}`);
    console.log(`SUBJECT: ${subject}`);
    console.log(`TYPE: ${type}`);
    console.log(`(Configure GOOGLE_APPS_SCRIPT_URL or GMAIL_USER + GMAIL_APP_PASSWORD in backend/.env for live dispatch)`);
    console.log(`======================================================\n`);

    return { 
      success: true, 
      provider: 'simulated', 
      note: 'Logged to server console. Configure GOOGLE_APPS_SCRIPT_URL or GMAIL_USER + GMAIL_APP_PASSWORD in .env for live inbox delivery.' 
    };
  }
}

module.exports = new EmailService();
