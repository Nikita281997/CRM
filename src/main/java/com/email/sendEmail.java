package com.email;

import java.io.IOException;
import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class sendEmail extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String toEmail = request.getParameter("toEmail");  // Receiver Email
        String subject = request.getParameter("subject");
        String messageText = request.getParameter("message");

        // SMTP Server Configuration
        String host = "smtp.gmail.com";  
        final String user = "your-email@gmail.com";  // Sender Email
        final String password = "your-email-password";  // App Password (Enable 2-Step Verification & Create App Password)

        // Mail Server Properties
        Properties props = new Properties();
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        // Create Session
        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, password);
            }
        });

        try {
            // Create Email Message
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(user));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
            message.setSubject(subject);
            message.setText(messageText);

            // Send Email
            Transport.send(message);
            response.getWriter().println("Email Sent Successfully!");
        } catch (MessagingException e) {
            e.printStackTrace();
            response.getWriter().println("Error Sending Email: " + e.getMessage());
        }
    }
}
