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
    error_log("Vendor interest registration error: Invalid email format: " . $email);
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Please provide a valid email address']);
    exit;
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
    $welcomeSubject = 'Welcome to Chimes! 🍦 Let\'s get your ice cream business on the map!';
    $welcomeBody = "
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Chimes!</title>
</head>
<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto;'>
    <div style='background: linear-gradient(135deg, #2563eb, #7c3aed); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;'>
        <h1 style='margin: 0; font-size: 28px;'>🍦 Welcome to Chimes!</h1>
        <p style='margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;'>Let's get your ice cream business on the map!</p>
    </div>
    
    <div style='padding: 30px; background: white; border: 1px solid #e5e7eb; border-top: none;'>
        <p style='font-size: 16px; margin-bottom: 20px;'>Dear Ice Cream Vendor,</p>
        
        <p>Thank you for registering your interest in Chimes! We're excited to help you connect with more customers and grow your ice cream business.</p>
        
        <div style='background: #f8fafc; padding: 20px; border-radius: 8px; margin: 25px 0;'>
            <h2 style='color: #2563eb; margin-top: 0;'>What is Chimes?</h2>
            <p>Chimes is a revolutionary app that helps ice cream lovers find their favourite vans in real-time. When customers are craving ice cream, they open Chimes to see which vans are operating nearby and get notifications when their favourites are in the area.</p>
        </div>
        
        <h2 style='color: #2563eb;'>How Chimes Benefits Your Business</h2>
        <div style='background: #f0f9ff; padding: 20px; border-radius: 8px; margin: 15px 0;'>
            <ul style='padding-left: 20px;'>
                <li style='margin-bottom: 8px;'><strong>🔔 Advance Notifications</strong> - Customers are notified on their phone with an ice cream chime tone when you enter their area.</li>
                <li style='margin-bottom: 8px;'><strong>📶 Extended Reach</strong> - Many potential customers are out of range of your van chimes or may not have time to dash out when you arrive unexpectedly.</li>
                <li style='margin-bottom: 8px;'><strong>🛒 Pre-Orders Ready</strong> - When customers know in advance that you're on the way, they'll have a family-sized order ready by the time you arrive at their location.</li>
                <li style='margin-bottom: 8px;'><strong>🗺️ Interactive Tracking</strong> - Customers can follow you on the interactive map and if they're in need of ice cream, they will come and find you.</li>
                <li style='margin-bottom: 0;'><strong>📈 Increased Sales & Loyalty</strong> - More advance notice and extended reach means more customers, bigger orders, more revenue!</li>
            </ul>
        </div>
        
        <h2 style='color: #2563eb;'>How does it work?</h2>
        <div style='background: #f0f9ff; padding: 20px; border-radius: 8px; margin: 15px 0;'>
            <p style='margin-bottom: 15px;'>Chimes is like Uber for ice cream vans - simple and effective location sharing that connects you with customers.</p>
            <ul style='padding-left: 20px;'>
                <li style='margin-bottom: 8px;'><strong>📱 Your Phone Does Everything</strong> - Your smartphone sends regular location updates automatically when you're operating, no additional equipment or GPS trackers required.</li>
                <li style='margin-bottom: 8px;'><strong>🎯 Smart Notifications</strong> - Your location updates trigger notifications to your customers when you enter their notification zone, alerting them that you're nearby.</li>
                <li style='margin-bottom: 8px;'><strong>🗺️ Live Map Display</strong> - Your position appears on the interactive map on customers' phones, so they can see exactly where you are and track your movement.</li>
                <li style='margin-bottom: 8px;'><strong>🔒 Vendor Privacy</strong> - Only show your location when you want to - you are in complete control of when customers can see where you are.</li>
                <li style='margin-bottom: 0;'><strong>⚡ Simple Setup</strong> - Just download the Chimes app, let us know that you are ready to get started, and we will enable location tracking - no complicated installation or technical knowledge needed.</li>
            </ul>
        </div>
        
        <div style='background: #dbeafe; padding: 20px; border-radius: 8px; margin: 25px 0; text-align: center;'>
            <h2 style='color: #1d4ed8; margin-top: 0;'>Ready to Get Started for Free?</h2>
            <p>Complete your vendor profile to join our growing network:</p>
            <a href='https://chimesapp.com/vendor-getting-started' style='display: inline-block; background: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold; margin: 10px 0;'>Get Started Here →</a>
        </div>
        
        <div style='background: #ecfdf5; padding: 20px; border-radius: 8px; margin: 25px 0;'>
            <h3 style='color: #059669; margin-top: 0;'>Questions? Let's Chat!</h3>
            <p>Our team is here to help! If you'd like to discuss how Chimes can work for your business:</p>
            <p><strong>📱 WhatsApp the Chimes Team:</strong> <a href='https://wa.me/447812352262' style='color: #059669;'>07812 352262</a>, email us at <a href='mailto:chimesapp@just-iot.com' style='color: #059669;'>chimesapp@just-iot.com</a> or contact us via the message button on our <a href='https://facebook.com/chimesapp' style='color: #059669;'>Facebook page</a>.</p>
            <p style='font-size: 14px; color: #6b7280; margin-top: 15px;'><strong>Note:</strong> Please don't reply to this email.</p>
        </div>
        
        <h3 style='color: #2563eb;'>What Happens Next?</h3>
        <ol style='padding-left: 20px;'>
            <li>Complete the vendor registration form <a href='https://chimesapp.com/vendor-getting-started' style='color: #2563eb;'>here</a></li>
            <li>We'll review your application and get back to you within 24 hours</li>
            <li>We'll help you set up your profile and show you how to use the app</li>
            <li>Start getting discovered by ice cream lovers in your area!</li>
        </ol>
        
        <p style='margin-top: 20px;'><strong>Remember that it's completely free to get started, and will remain free until you are completely happy with the app and ready to start growing your customer base.</strong></p>
        
        <div style='border-top: 1px solid #e5e7eb; padding-top: 20px; margin-top: 30px; text-align: center; color: #6b7280; font-size: 14px;'>
            <p><strong>Welcome to the Chimes family!</strong> We're looking forward to helping you reach more customers and grow your business.</p>
            <p style='margin-top: 20px;'>Sweet regards,<br><strong>The Chimes Team 🍦</strong></p>
        </div>
    </div>
    
    <div style='background: #f9fafb; padding: 20px; text-align: center; border-radius: 0 0 10px 10px; border: 1px solid #e5e7eb; border-top: none; font-size: 12px; color: #6b7280;'>
        <p style='margin: 0;'><strong>Chimes - Connecting Ice Cream Lovers with Their Favourite Vans</strong></p>
        <p style='margin: 5px 0;'>Web: <a href='https://chimesapp.com' style='color: #2563eb;'>chimesapp.com</a> | WhatsApp: 07812 352262 | Email: chimesapp@just-iot.com</p>
        <p style='margin: 10px 0 0 0; font-style: italic;'>P.S. Don't forget to tell your fellow ice cream vendors about Chimes!</p>
    </div>
</body>
</html>
";
    
    // Send welcome email to vendor
    $welcomeResult = $mailer->send($email, $welcomeSubject, $welcomeBody, $from_name . ' <' . $from . '>');
    
    if ($welcomeResult) {
        error_log("Vendor interest: Welcome email sent successfully to vendor: " . $email);
    echo json_encode(['success' => true, 'message' => 'Thank you for your interest!<br><br>We\'ve sent you a welcome email with more information about joining our network.<br><br><small style="color: #666; font-size: 12px;">If you don\'t receive it, please check your spam folder, search for an email with the subject \'Welcome to Chimes!\', or contact us at chimesapp@just-iot.com.</small><br><br><p><a href="/#contact" style="color: #2563eb; text-decoration: underline;">Contact us</a></p>']);
    } else {
        error_log("Vendor interest: Welcome email failed to send to vendor: " . $email);
        echo json_encode(['success' => true, 'message' => 'Thank you for your interest! We\'ll be in touch within 24 hours with more information about joining our network.']);
    }
} else {
    error_log("Vendor interest: Notification email failed to send to: " . $to);
    error_log("Vendor interest: Last error: " . error_get_last()['message'] ?? 'Unknown error');
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Unable to register your interest right now. Please try again or contact us directly at chimesapp@just-iot.com']);
}
?>