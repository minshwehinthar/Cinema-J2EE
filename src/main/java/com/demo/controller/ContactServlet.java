package com.demo.controller;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

@WebServlet("/ContactServlet")
public class ContactServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String subject = request.getParameter("subject");
        String message = request.getParameter("message");

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        final String username = "your_email@gmail.com"; // your email
        final String password = "your_email_password"; // your email app password

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props,
            new jakarta.mail.Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username, password);
                }
            });

        try {
            Message mimeMessage = new MimeMessage(session);
            mimeMessage.setFrom(new InternetAddress(email)); // sender
            mimeMessage.setRecipients(Message.RecipientType.TO, InternetAddress.parse(username));
            mimeMessage.setSubject(subject);
            mimeMessage.setText("Name: " + name + "\nEmail: " + email + "\n\nMessage:\n" + message);

            Transport.send(mimeMessage);

            out.print("{\"success\": true, \"message\": \"Your message has been sent successfully!\"}");
        } catch (MessagingException e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Failed to send message.\"}");
        }
    }
}
