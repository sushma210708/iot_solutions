/**
 * GreenFusion IoT Solutions — Google Apps Script for Gmail Email Automation
 * 
 * Instructions to deploy:
 * 1. Go to https://script.google.com/ and create a "New project".
 * 2. Replace all code in Code.gs with this file content.
 * 3. Update the AUTH_SECRET constant below with any secret string of your choice.
 * 4. Click "Deploy" > "New deployment".
 * 5. Select type: "Web app".
 *    - Description: "GreenFusion Email Webhook"
 *    - Execute as: "Me" (your Gmail account)
 *    - Who has access: "Anyone"
 * 6. Click "Deploy" and authorize the requested permissions (Gmail send permission).
 * 7. Copy the "Web app URL" and add it to backend/.env:
 *    GOOGLE_APPS_SCRIPT_URL="https://script.google.com/macros/s/XXXXX/exec"
 *    GOOGLE_APPS_SCRIPT_SECRET="your-chosen-secret"
 */

// Set this to any secret password/token to prevent unauthorized triggers
const AUTH_SECRET = "greenfusion_secure_script_token_2026";

function doPost(e) {
  try {
    if (!e || !e.postData || !e.postData.contents) {
      return responseJson({ success: false, message: "No payload provided" }, 400);
    }

    const data = JSON.parse(e.postData.contents);

    // Optional secret check if configured
    if (AUTH_SECRET && data.secret && data.secret !== AUTH_SECRET) {
      return responseJson({ success: false, message: "Invalid secret token" }, 403);
    }

    const to = data.to;
    const subject = data.subject;
    const htmlBody = data.htmlBody;
    const textBody = data.textBody || "";

    if (!to || !subject || !htmlBody) {
      return responseJson({ success: false, message: "Missing required parameters: to, subject, or htmlBody" }, 400);
    }

    // Send email using GmailApp / MailApp
    GmailApp.sendEmail(to, subject, textBody, {
      name: "GreenFusion IoT Solutions",
      htmlBody: htmlBody
    });

    return responseJson({
      success: true,
      message: "Email dispatched successfully via GmailApp",
      to: to,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    return responseJson({
      success: false,
      error: error.toString()
    }, 500);
  }
}

function doGet(e) {
  return responseJson({
    status: "online",
    service: "GreenFusion IoT Solutions Email Automation Service",
    timestamp: new Date().toISOString()
  });
}

function responseJson(data, statusCode) {
  const output = ContentService.createTextOutput(JSON.stringify(data));
  output.setMimeType(ContentService.MimeType.JSON);
  return output;
}
