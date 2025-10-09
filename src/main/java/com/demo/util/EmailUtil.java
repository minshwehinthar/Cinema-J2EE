package com.demo.util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailUtil {

	private static final boolean EMAIL_ENABLED = true; // Keep as false for simulation
	private static final String FROM_EMAIL = "minshwehinthar7@gmail.com";
	private static final String PASSWORD = "ijsy doxm ukpl gmej"
			+ "";

	public static boolean sendEmail(String to, String subject, String body) {
		if (!EMAIL_ENABLED) {
			// Log the email instead of sending it
			logEmail(to, subject, body);
			return true;
		}

		Properties props = new Properties();
		props.put("mail.smtp.host", "smtp.gmail.com");
		props.put("mail.smtp.port", "587"); // Try port 587 instead
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
			msg.setFrom(new InternetAddress(FROM_EMAIL));
			msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
			msg.setSubject(subject);
			msg.setText(body);

			Transport.send(msg);
			return true;

		} catch (Exception e) {
			System.err.println("Failed to send email to: " + to);
			// Fallback to simulation
			logEmail(to, subject, body);
			return true;
		}
	}

	private static void logEmail(String to, String subject, String body) {
		System.out.println("EMAIL SIMULATION - To: " + to + " - Subject: " + subject);
	}
}