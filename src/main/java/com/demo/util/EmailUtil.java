package com.demo.util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailUtil {

    private static final boolean EMAIL_ENABLED = true; // Set to true for real emails
    private static final String FROM_EMAIL = "minshwehinthar17@gmail.com";
    private static final String PASSWORD = "lrnm kyey gtpl veng";

    public static boolean sendEmail(String to, String subject, String body) {
        if (!EMAIL_ENABLED) {
            // Log the email instead of sending it
            logEmail(to, subject, body);
            return true;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.connectiontimeout", "10000");

        try {
            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
                }
            });

            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(FROM_EMAIL, "CINEZY Cinema"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            msg.setSubject(subject);
            
            // Use red-themed HTML email content
            String htmlBody = createHtmlEmail(body);
            msg.setContent(htmlBody, "text/html; charset=utf-8");

            Transport.send(msg);
            System.out.println("✅ Email sent successfully to: " + to);
            return true;

        } catch (Exception e) {
            System.err.println("❌ Failed to send email to: " + to);
            e.printStackTrace();
            // Fallback to simulation
            logEmail(to, subject, body);
            return false;
        }
    }

    private static String createHtmlEmail(String plainBody) {
        return """
        <!DOCTYPE html>
        <html lang='en'>
        <head>
            <meta charset='UTF-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <title>J-Seven Cinema Notification</title>
            <style>
                body {
                    font-family: 'Segoe UI', Arial, sans-serif;
                    background-color: #f4f4f4;
                    margin: 0;
                    padding: 0;
                    color: #333;
                }
                .container {
                    max-width: 600px;
                    background: #ffffff;
                    margin: 40px auto;
                    border-radius: 12px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                    overflow: hidden;
                }
                .header {
                    background-color: #B91C1C;
                    color: #ffffff;
                    text-align: center;
                    padding: 25px 20px;
                }
                .header h2 {
                    margin: 0;
                    font-size: 24px;
                    letter-spacing: 1px;
                }
                .content {
                    padding: 25px 30px;
                    background-color: #fff8f8;
                    line-height: 1.6;
                }
                .content p {
                    margin: 10px 0;
                    font-size: 15px;
                }
                .content pre {
                    background: #fff;
                    padding: 15px;
                    border-radius: 8px;
                    font-family: 'Segoe UI', sans-serif;
                    white-space: pre-wrap;
                    color: #111;
                }
                .footer {
                    text-align: center;
                    padding: 15px 10px;
                    background-color: #f1f1f1;
                    color: #777;
                    font-size: 13px;
                }
                .footer a {
                    color: #B91C1C;
                    text-decoration: none;
                }
                .footer a:hover {
                    text-decoration: underline;
                }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h2> Cinezy Cinema</h2>
                    <p style='margin-top:6px; font-size:14px;'>Your movie & food booking system</p>
                </div>
                <div class='content'>
                    <p>Hello,</p>
                    <pre>%s</pre>
                    <p>Thank you for choosing <b>CINEZY Cinema</b>. We hope to see you again soon!</p>
                </div>
                <div class='footer'>
                    <p>© 2025 CINEZY Cinema. All rights reserved.</p>
                    <p><a href='#'>Visit our website</a> | <a href='#'>Contact Support</a></p>
                </div>
            </div>
        </body>
        </html>
        """.formatted(plainBody);
    }

    private static void logEmail(String to, String subject, String body) {
        System.out.println("=== EMAIL SIMULATION ===");
        System.out.println("To: " + to);
        System.out.println("Subject: " + subject);
        System.out.println("Body: " + body);
        System.out.println("========================");
    }
}
