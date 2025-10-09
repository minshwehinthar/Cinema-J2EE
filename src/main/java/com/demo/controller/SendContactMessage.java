package com.demo.controller;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.demo.util.EmailUtil;

@WebServlet("/SendContactMessage")
public class SendContactMessage extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String message = request.getParameter("message");

		// Recipient email (where messages will be received)
//        String to = "minnyanhtaw07@gmail.com";

		String subject = "New Contact Message from " + name;
		String body = "Name: " + name + "\nEmail: " + email + "\n\nMessage:\n" + message;

		boolean sent = EmailUtil.sendEmail(email, subject, body);

		if (sent) {
			request.setAttribute("success", "✅ Message sent successfully!");
		} else {
			request.setAttribute("error", "❌ Failed to send message. Please try again later.");
		}

		RequestDispatcher dispatcher = request.getRequestDispatcher("contact.jsp");
		dispatcher.forward(request, response);
	}
}
