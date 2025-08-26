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

// Extract and sanitize form data
$businessName = htmlspecialchars($input['businessName'] ?? '', ENT_QUOTES, 'UTF-8');
$contactName = htmlspecialchars($input['contactName'] ?? '', ENT_QUOTES, 'UTF-8');
$email = filter_var($input['email'] ?? '', FILTER_SANITIZE_EMAIL);
$phone = htmlspecialchars($input['phone'] ?? '', ENT_QUOTES, 'UTF-8');
$whatsapp = htmlspecialchars($input['whatsapp'] ?? '', ENT_QUOTES, 'UTF-8');
$website = htmlspecialchars($input['website'] ?? '', ENT_QUOTES, 'UTF-8');
$location = htmlspecialchars($input['location'] ?? '', ENT_QUOTES, 'UTF-8');
$postcodes = htmlspecialchars($input['postcodes'] ?? '', ENT_QUOTES, 'UTF-8');
$description = htmlspecialchars($input['description'] ?? '', ENT_QUOTES, 'UTF-8');
$facebook = htmlspecialchars($input['facebook'] ?? '', ENT_QUOTES, 'UTF-8');
$instagram = htmlspecialchars($input['instagram'] ?? '', ENT_QUOTES, 'UTF-8');
$socialOther1 = htmlspecialchars($input['socialOther1'] ?? '', ENT_QUOTES, 'UTF-8');
$socialOther2 = htmlspecialchars($input['socialOther2'] ?? '', ENT_QUOTES, 'UTF-8');
$numVans = htmlspecialchars($input['numVans'] ?? '', ENT_QUOTES, 'UTF-8');
$operatingDays = htmlspecialchars($input['operatingDays'] ?? '', ENT_QUOTES, 'UTF-8');

// Log the attempt for debugging
error_log("Vendor registration attempt from: " . $email . " for business: " . $businessName);

// Validate required fields (only 4 required: business name, email, phone, location)
$missingFields = [];
if (!$businessName) $missingFields[] = 'Business Name';
if (!$email) $missingFields[] = 'Email Address';
if (!$phone) $missingFields[] = 'Phone Number';
if (!$location) $missingFields[] = 'Main Location';

if (!empty($missingFields)) {
    error_log("Vendor registration error: Missing required fields: " . implode(', ', $missingFields));
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Please fill in the following required fields: ' . implode(', ', $missingFields)]);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    error_log("Vendor registration error: Invalid email format - " . $email);
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
$from_name = 'Chimes Website Vendor Form';

// Create mailer instance
$mailer = new SimpleMailer();
$mailer->setHost($smtp_host);
$mailer->setPort($smtp_port);
$mailer->setUsername($smtp_username);
$mailer->setPassword($smtp_password);
$mailer->setSMTPSecure('ssl');

// Subject
$subject = 'Website - New Vendor Registered';

// Email body with better formatting and spreadsheet-friendly data
$body = "
<!DOCTYPE html>
<html>
<head>
    <title>New Vendor Registration</title>
</head>
<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
    <h2 style='color: #2563eb;'>New Vendor Registration from Chimes Website</h2>
    
    <div style='background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;'>
        <h3>BUSINESS INFORMATION:</h3>
        <p><strong>Business Name:</strong> " . ($businessName ?: 'Not provided') . "</p>
        <p><strong>Contact Name:</strong> " . ($contactName ?: 'Not provided') . "</p>
        <p><strong>Email Address:</strong> " . ($email ?: 'Not provided') . "</p>
        <p><strong>Phone Number:</strong> " . ($phone ?: 'Not provided') . "</p>
        <p><strong>WhatsApp Number:</strong> " . ($whatsapp ?: 'Not provided') . "</p>
        <p><strong>Website URL:</strong> " . ($website ?: 'Not provided') . "</p>
    </div>
    
    <div style='background: #e8f5e8; padding: 20px; border-radius: 5px; margin: 20px 0;'>
        <h3>LOCATION:</h3>
        <p><strong>Main Location:</strong> " . ($location ?: 'Not provided') . "</p>
        <p><strong>Post Codes Covered:</strong> " . ($postcodes ?: 'Not provided') . "</p>
    </div>
    
    <div style='background: #fff3cd; padding: 20px; border-radius: 5px; margin: 20px 0;'>
        <h3>BUSINESS DESCRIPTION:</h3>
        <p>" . ($description ? nl2br($description) : 'Not provided') . "</p>
    </div>
    
    <div style='background: #e2e3f3; padding: 20px; border-radius: 5px; margin: 20px 0;'>
        <h3>SOCIAL MEDIA:</h3>
        <p><strong>Facebook:</strong> " . ($facebook ?: 'Not provided') . "</p>
        <p><strong>Instagram:</strong> " . ($instagram ?: 'Not provided') . "</p>
        <p><strong>Other Social Media 1:</strong> " . ($socialOther1 ?: 'Not provided') . "</p>
        <p><strong>Other Social Media 2:</strong> " . ($socialOther2 ?: 'Not provided') . "</p>
    </div>
    
    <div style='background: #f0f0f0; padding: 20px; border-radius: 5px; margin: 20px 0;'>
        <h3>VAN INFORMATION:</h3>
        <p><strong>Number of Vans:</strong> " . ($numVans ?: 'Not provided') . "</p>
        <p><strong>Operating Days:</strong> " . ($operatingDays ?: 'Not provided') . "</p>
    </div>
    
    <div style='background: #ffeaa7; padding: 20px; border-radius: 5px; margin: 20px 0;'>
        <h3>SPREADSHEET DATA (Semicolon-separated for easy copy/paste):</h3>
        <p style='font-family: monospace; background: #fff; padding: 10px; border: 1px solid #ddd; white-space: pre-wrap;'>" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $businessName) . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $contactName ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $email) . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $phone) . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $whatsapp ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $website ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $location) . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $postcodes ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $description ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $facebook ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $instagram ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $socialOther1 ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $socialOther2 ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $numVans ?: '') . ";" . 
        str_replace(array(";", "\r\n", "\r", "\n"), array(" ", " ", " ", " "), $operatingDays ?: '') . "</p>
        
        <h4 style='margin-top: 20px;'>Header Row (for reference):</h4>
        <p style='font-family: monospace; background: #fff; padding: 10px; border: 1px solid #ddd; white-space: pre-wrap;'>Business Name;Contact Name;Email;Phone;WhatsApp;Website;Location;Post Codes;Description;Facebook;Instagram;Social Other 1;Social Other 2;Number of Vans;Operating Days</p>
    </div>
    
    <hr style='margin: 30px 0;'>
    <p style='color: #666; font-size: 12px;'>
        <strong>Submitted:</strong> " . date('Y-m-d H:i:s') . " (UK Time)<br>
        <strong>From:</strong> " . ($_SERVER['HTTP_HOST'] ?? 'unknown') . "<br>
        <strong>User Agent:</strong> " . ($_SERVER['HTTP_USER_AGENT'] ?? 'Unknown') . "
    </p>
</body>
</html>
";

// Log email attempt
error_log("Vendor registration: Attempting to send email from: " . $from . " to: " . $to);
error_log("Vendor registration: Using SMTP host: " . $smtp_host . " port: " . $smtp_port);

// Send email using our mailer
$mailResult = $mailer->send($to, $subject, $body, $from_name . ' <' . $from . '>', $email);

if ($mailResult) {
    error_log("Vendor registration: Email sent successfully to: " . $to);
    echo json_encode(['success' => true, 'message' => 'Registration submitted successfully! We\'ll review your application and get back to you within 24 hours.']);
} else {
    error_log("Vendor registration: Email failed to send to: " . $to);
    error_log("Vendor registration: Last error: " . error_get_last()['message'] ?? 'Unknown error');
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to submit registration - please try again or email us directly']);
}
?>
