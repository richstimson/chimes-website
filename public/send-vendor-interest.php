<?php
// Enable error logging for debugging
error_reporting(E_ALL);
ini_set('display_errors', 0); // Don't display errors to user
ini_set('log_errors', 1);


// Include our simple mailer
require_once 'PHPMailer.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// The homepage script asks for JSON. A plain form post (no JavaScript) gets
// a page instead: a redirect on success, a short message on failure.
$wantsJson = strpos($_SERVER['HTTP_ACCEPT'] ?? '', 'application/json') !== false;
function respond($success, $message, $status = 200) {
    global $wantsJson;
    if (!$wantsJson) {
        if ($success) {
            header('Location: /register/thanks/', true, 303);
        } else {
            http_response_code($status);
            header('Content-Type: text/html; charset=UTF-8');
            echo '<p>' . htmlspecialchars(strip_tags($message), ENT_QUOTES, 'UTF-8') . '</p><p><a href="/">Back</a></p>';
        }
        exit;
    }
    http_response_code($status);
    echo json_encode(['success' => $success, 'message' => $message]);
    exit;
}

// Honeypot: the hidden "hp_check" field is left empty by people and filled
// in by bots. Pretend it worked and send nothing (no welcome email to a
// bot-supplied address).
if (!empty($_POST['hp_check'])) {
    error_log("Vendor interest: honeypot filled, dropped: " . json_encode($_POST));
    respond(true, 'Thank you for your interest!');
}

// Get the form data
$email = filter_var($_POST['email'] ?? '', FILTER_SANITIZE_EMAIL);

// Log the attempt for debugging
error_log("Vendor interest registration attempt from: " . $email);

// Validate required fields
if (!$email) {
    error_log("Vendor interest registration error: Missing email address");
    respond(false, 'Please provide your business email address', 400);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    error_log("Vendor interest registration error: Invalid email format: " . $email);
    respond(false, 'Please provide a valid email address', 400);
}

// Email configuration
$to = 'chimesapp@just-iot.com';
$from = 'noreply@chimesapp.com';
$from_name = 'Chimes Website';
$subject = 'New Vendor Interest Registration - ' . $email;


// SMTP configuration - match Contact Us form
$smtp_host = 'mail.chimesapp.com';
$smtp_port = 465; // SSL port
$smtp_username = 'website@chimesapp.com';
$smtp_password = 'Barsing.73';
$smtp_secure = 'ssl';

// Create mailer instance
$mailer = new SimpleMailer();
$mailer->setHost($smtp_host);
$mailer->setPort($smtp_port);
$mailer->setUsername($smtp_username);
$mailer->setPassword($smtp_password);
$mailer->setSMTPSecure($smtp_secure);

// Create email body for notification to us
$body = "
<!DOCTYPE html>
<html>
<head>
    <title>New Vendor Interest Registration</title>
</head>
<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
    <h2 style='color: #2563eb;'>New Vendor Interest from Chimes Website</h2>
    
    <div style='background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;'>
        <h3>VENDOR INTEREST REGISTRATION:</h3>
        <p><strong>Business Email:</strong> " . htmlspecialchars($email, ENT_QUOTES, 'UTF-8') . "</p>
        <p><strong>Registration Type:</strong> Interest Registration (Simple)</p>
        <p><strong>Next Steps:</strong> Follow up with vendor to get full registration details</p>
    </div>
    
    <div style='background: #fff3cd; padding: 20px; border-radius: 5px; margin: 20px 0;'>
        <h3>FOLLOW-UP ACTIONS:</h3>
        <ul>
            <li>Send welcome email to vendor</li>
            <li>Provide full registration form link</li>
            <li>Schedule onboarding call if appropriate</li>
            <li>Add to vendor prospect list</li>
        </ul>
    </div>
    
    <hr style='margin: 30px 0;'>
    <p style='color: #666; font-size: 12px;'>
        <strong>Submitted:</strong> " . date('Y-m-d H:i:s') . " (UK Time)<br>
        <strong>From:</strong> " . ($_SERVER['HTTP_HOST'] ?? 'unknown') . "<br>
        <strong>User Agent:</strong> " . ($_SERVER['HTTP_USER_AGENT'] ?? 'Unknown') . "<br>
        <strong>IP Address:</strong> " . ($_SERVER['REMOTE_ADDR'] ?? 'Unknown') . "
    </p>
</body>
</html>
";

// Log email attempt
error_log("Vendor interest: Attempting to send email from: " . $from . " to: " . $to);
error_log("Vendor interest: Using SMTP host: " . $smtp_host . " port: " . $smtp_port);


// Send email using our mailer
$mailResult = $mailer->send($to, $subject, $body, $from_name . ' <' . $from . '>', $email);

if ($mailResult) {
    error_log("Vendor interest: Notification email sent successfully to: " . $to);
    
    // Now send welcome email to the vendor
    // Kept short on purpose (owner, 2026-10-31): an intro, then steer the
    // vendor to the app or /register. Images are JPEG, not WebP, for Outlook.
    $welcomeSubject = 'Welcome to Chimes! 🍦 Get your van on the map';
    $welcomeBody = "
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>Welcome to Chimes!</title>
</head>
<body style='margin: 0; padding: 0; background: #ffffff;'>
<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='background: #ffffff;'>
<tr><td align='center' style='padding: 24px 16px;'>
<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='max-width: 560px; font-family: Arial, Helvetica, sans-serif; font-size: 16px; line-height: 1.5; color: #1f2937;'>
    <tr><td>
        <h1 style='margin: 0 0 12px 0; font-size: 24px; line-height: 1.25; color: #a3173f;'>Thanks for your interest in Chimes 🍦</h1>
        <p style='margin: 0 0 20px 0;'>Chimes puts your van on a map that local customers can see, and sends them a chime on their phone when you're nearby. Getting started is free.</p>

        <p style='margin: 0 0 8px 0; font-weight: bold;'>1. Download Chimes on your iPhone</p>
        <p style='margin: 0 0 20px 0;'><a href='https://apps.apple.com/gb/app/chimes/id6738628000' style='display: inline-block; background: #c81e54; color: #ffffff; padding: 12px 22px; border-radius: 999px; font-weight: bold; text-decoration: none;'>Get Chimes on the App Store</a></p>

        <p style='margin: 0 0 8px 0; font-weight: bold;'>2. Register your business</p>
        <p style='margin: 0 0 20px 0;'>In Chimes, tap the orange settings button, then <strong>Register your business</strong>. Or <a href='https://chimesapp.com/register' style='color: #a3173f;'>register on our website</a> and we'll set you up.</p>
    </td></tr>
    <tr><td>
        <table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0'>
        <tr>
            <td width='50%' valign='top' align='center' style='padding: 0 6px 0 0; font-size: 13px; color: #6b7280;'>
                <img src='https://chimesapp.com/images/email/customer-view.jpg' width='240' alt='Chimes map showing a vendor card with Live status, WhatsApp and Call buttons' style='display: block; width: 100%; max-width: 240px; height: auto; border: 1px solid #e5e7eb; border-radius: 12px;'>
                <p style='margin: 6px 0 0 0;'>What customers see</p>
            </td>
            <td width='50%' valign='top' align='center' style='padding: 0 0 0 6px; font-size: 13px; color: #6b7280;'>
                <img src='https://chimesapp.com/images/email/register-in-app.jpg' width='240' alt='The Register your business screen in the Chimes app' style='display: block; width: 100%; max-width: 240px; height: auto; border: 1px solid #e5e7eb; border-radius: 12px;'>
                <p style='margin: 6px 0 0 0;'>Register your business in the app</p>
            </td>
        </tr>
        </table>
    </td></tr>
    <tr><td style='padding-top: 24px;'>
        <p style='margin: 0 0 16px 0;'>Questions? WhatsApp us on <a href='https://wa.me/447812352262' style='color: #a3173f;'>07812 352262</a> or email <a href='mailto:chimesapp@just-iot.com' style='color: #a3173f;'>chimesapp@just-iot.com</a>.</p>
        <p style='margin: 0 0 24px 0;'>The Chimes Team</p>
        <p style='margin: 0; font-size: 12px; color: #6b7280;'>You're getting this because you entered this address at <a href='https://chimesapp.com' style='color: #6b7280;'>chimesapp.com</a>. Please don't reply to this email.</p>
    </td></tr>
</table>
</td></tr>
</table>
</body>
</html>
";
    
    // Send welcome email to vendor
    $welcomeResult = $mailer->send($email, $welcomeSubject, $welcomeBody, $from_name . ' <' . $from . '>');
    
    if ($welcomeResult) {
        error_log("Vendor interest: Welcome email sent successfully to vendor: " . $email);
        respond(true, 'Thank you for your interest!<br><br>We\'ve sent you a welcome email with more information about joining our network.<br><br><small style="color: #666; font-size: 12px;">If you don\'t receive it, please check your spam folder, search for an email with the subject \'Welcome to Chimes!\', or contact us at chimesapp@just-iot.com.</small><br><br><p><a href="/#contact" style="color: #2563eb; text-decoration: underline;">Contact us</a></p>');
    } else {
        error_log("Vendor interest: Welcome email failed to send to vendor: " . $email);
        respond(true, 'Thank you for your interest! We\'ll be in touch within 24 hours with more information about joining our network.');
    }
} else {
    error_log("Vendor interest: Notification email failed to send to: " . $to);
    error_log("Vendor interest: Last error: " . (error_get_last()['message'] ?? 'Unknown error'));
    respond(false, 'Unable to register your interest right now. Please try again or contact us directly at chimesapp@just-iot.com', 500);
}
?>