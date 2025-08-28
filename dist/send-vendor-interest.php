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

// Get the form data
$email = filter_var($_POST['email'] ?? '', FILTER_SANITIZE_EMAIL);

// Log the attempt for debugging
error_log("Vendor interest registration attempt from: " . $email);

// Validate required fields
if (!$email) {
    error_log("Vendor interest registration error: Missing email address");
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Please provide your business email address']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    error_log("Vendor interest registration error: Invalid email format - " . $email);
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Please provide a valid email address']);
    exit;
}

// Email configuration - STANDARD BLUEHOST SMTP SETTINGS
$smtp_host = 'mail.chimesapp.com';  // Standard format: mail.yourdomain.com
$smtp_port = 465;              // SSL port
$smtp_username = 'website@chimesapp.com';  // The email account you created
$smtp_password = 'Barsing.73'; // Your email password

// Email addresses
$to = 'chimesapp@just-iot.com';  // Back to your Zoho email
$from = 'website@chimesapp.com'; // Your Bluehost email (sender)
$from_name = 'Chimes Website Vendor Interest';

// Create mailer instance
$mailer = new SimpleMailer();
$mailer->setHost($smtp_host);
$mailer->setPort($smtp_port);
$mailer->setUsername($smtp_username);
$mailer->setPassword($smtp_password);
$mailer->setSMTPSecure('ssl');

// Subject
$subject = 'Website - New Vendor Interest Registration';

// Email body
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
    error_log("Vendor interest: Email sent successfully to: " . $to);
    echo json_encode(['success' => true, 'message' => 'Thank you for your interest! We\'ll be in touch within 24 hours with more information about joining our network.']);
} else {
    error_log("Vendor interest: Email failed to send to: " . $to);
    error_log("Vendor interest: Last error: " . error_get_last()['message'] ?? 'Unknown error');
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Unable to register your interest right now. Please try again or email us directly at chimesapp@just-iot.com']);
}
?>
