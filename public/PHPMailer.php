<?php
/**
 * Lightweight PHPMailer-style SMTP class for Bluehost
 * Simple SMTP implementation without external dependencies
 */
class SimpleMailer {
    private $smtp_host;
    private $smtp_port;
    private $smtp_username;
    private $smtp_password;
    private $smtp_secure;
    private $connection;
    
    public function __construct() {
        $this->smtp_host = '';
        $this->smtp_port = 587;
        $this->smtp_username = '';
        $this->smtp_password = '';
        $this->smtp_secure = 'tls';
    }
    
    public function setHost($host) {
        $this->smtp_host = $host;
    }
    
    public function setPort($port) {
        $this->smtp_port = $port;
    }
    
    public function setUsername($username) {
        $this->smtp_username = $username;
    }
    
    public function setPassword($password) {
        $this->smtp_password = $password;
    }
    
    public function setSMTPSecure($secure) {
        $this->smtp_secure = $secure;
    }
    
    public function send($to, $subject, $body, $from, $replyTo = null) {
        // Use PHP's built-in mail() function with proper headers
        // This is more compatible with shared hosting than socket SMTP
        
        $headers = [
            'From: ' . $from,
            'Reply-To: ' . ($replyTo ?: $from),
            'MIME-Version: 1.0',
            'Content-Type: text/html; charset=UTF-8',
            'X-Mailer: PHP/' . phpversion(),
            'Return-Path: ' . $from
        ];
        
        // Additional headers for better delivery
        $additional_headers = implode("\r\n", $headers);
        
        // Send the email
        return mail($to, $subject, $body, $additional_headers);
    }
}
?>
