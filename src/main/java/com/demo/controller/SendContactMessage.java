package com.demo.controller;

import com.demo.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/contact")
public class ContactServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Your email where you want to receive contact messages
    private static final String YOUR_EMAIL = "cinezy17@gmail.com";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get form parameters
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String message = request.getParameter("message");
        
        // Validate required fields
        if (name == null || name.trim().isEmpty() || 
            email == null || email.trim().isEmpty() || 
            message == null || message.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "All fields are required!");
            request.getRequestDispatcher("/contact.jsp").forward(request, response);
            return;
        }
        
        // Create email content
        String subject = "New Contact Form Submission from " + name;
        String body = "Name: " + name + "\n" +
                     "Email: " + email + "\n" +
                     "Message: " + message + "\n\n" +
                     "This message was sent from your website contact form.";
        
        // Send email
        boolean emailSent = EmailUtil.sendEmail(YOUR_EMAIL, subject, body);
        
        if (emailSent) {
            request.setAttribute("successMessage", "Thank you for your message! We'll get back to you soon.");
        } else {
            request.setAttribute("errorMessage", "Sorry, there was an error sending your message. Please try again.");
        }
        
        request.getRequestDispatcher("/contact.jsp").forward(request, response);
    }
}