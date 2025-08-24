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

// Get the JSON input
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    // Try form data instead
    $input = $_POST;
}

$email = filter_var($input['email'] ?? '', FILTER_SANITIZE_EMAIL);
$message = htmlspecialchars($input['message'] ?? '', ENT_QUOTES, 'UTF-8');

// Log the attempt for debugging
error_log("Contact form submission attempt from: " . $email);

if (!$email || !$message) {
    error_log("Contact form error: Missing email or message");
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Email and message are required']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    error_log("Contact form error: Invalid email format - " . $email);
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid email address']);
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
$from_name = 'Chimes Website Contact Form';

// Try adding additional headers to force external delivery
$additional_delivery_headers = [
    'X-Priority: 3',
    'X-Mailer: Chimes Website Contact Form',
    'Message-ID: <' . time() . '.' . uniqid() . '@chimesapp.com>'
];

// Create mailer instance
$mailer = new SimpleMailer();
$mailer->setHost($smtp_host);
$mailer->setPort($smtp_port);
$mailer->setUsername($smtp_username);
$mailer->setPassword($smtp_password);
$mailer->setSMTPSecure('ssl');

        $headers = [
            'From: ' . $from,
            'Reply-To: ' . ($replyTo ?: $from),
            'MIME-Version: 1.0',
            'Content-Type: text/html; charset=UTF-8',
            'X-Mailer: PHP/' . phpversion(),
            'Return-Path: ' . $from,
            'X-Priority: 3',
            'Message-ID: <' . time() . '.' . uniqid() . '@chimesapp.com>'
        ];

// Subject
$subject = 'Contact Form Submission - Chimes Website';

// Email body with better formatting
$body = "
<!DOCTYPE html>
<html>
<head>
    <title>Contact Form Submission</title>
</head>
<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
    <h2 style='color: #2563eb;'>New Contact Form Submission</h2>
    <div style='background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;'>
        <p><strong>From:</strong> {$email}</p>
        <p><strong>Date:</strong> " . date('Y-m-d H:i:s') . "</p>
        <p><strong>User Agent:</strong> " . ($_SERVER['HTTP_USER_AGENT'] ?? 'Unknown') . "</p>
    </div>
    <h3>Message:</h3>
    <div style='background: #fff; padding: 15px; border: 1px solid #ddd; border-radius: 5px;'>
        <p>" . nl2br($message) . "</p>
    </div>
    <hr style='margin: 30px 0;'>
    <p style='color: #666; font-size: 12px;'>
        This message was sent from the Chimes website contact form at " . ($_SERVER['HTTP_HOST'] ?? 'unknown') . "
    </p>
</body>
</html>
";

// Log email attempt
error_log("Contact form: Attempting to send email from: " . $from . " to: " . $to);
error_log("Contact form: Using SMTP host: " . $smtp_host . " port: " . $smtp_port);

// Send email using our mailer
$mailResult = $mailer->send($to, $subject, $body, $from_name . ' <' . $from . '>', $email);

if ($mailResult) {
    error_log("Contact form: Email sent successfully to: " . $to);
    echo json_encode(['success' => true, 'message' => 'Message sent successfully']);
} else {
    error_log("Contact form: Email failed to send to: " . $to);
    error_log("Contact form: Last error: " . error_get_last()['message'] ?? 'Unknown error');
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to send message - please try again or email us directly']);
}
?>
