package com.email;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/SendEmailServlet")
public class SendEmailServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        // Get recipient details from request
        String recipientEmail = request.getParameter("recipient");
        String subject = request.getParameter("subject");
        String messageText = request.getParameter("message");



        // Validate inputs
        if (recipientEmail == null || recipientEmail.trim().isEmpty() ||
            subject == null || subject.trim().isEmpty() ||
            messageText == null || messageText.trim().isEmpty()) {
            out.println("<script>alert('Error: All fields are required.'); window.location='email.jsp';</script>");
            return;
        }

        // Insert email details into the 'sent' table
        String host = System.getenv("DB_HOST");
        String port = System.getenv("DB_PORT");
        String dbName = System.getenv("DB_NAME");
        String user = System.getenv("DB_USER");
        String pass = System.getenv("DB_PASS");

        String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            out.println("<script>alert('Database Driver Error: " + e.getMessage() + "'); window.location='email.jsp';</script>");
            return;
        }

        try (Connection con = DriverManager.getConnection(url, user, pass);
             PreparedStatement insertStmt = con.prepareStatement("INSERT INTO sent (recipient, subject, message) VALUES (?, ?, ?)")) {
            insertStmt.setString(1, recipientEmail);
            insertStmt.setString(2, subject);
            insertStmt.setString(3, messageText);
            insertStmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<script>alert('Database Error: " + e.getMessage() + "'); window.location='email.jsp';</script>");
            return;
        }

        // SMTP Properties for Hostinger (Using SSL on port 465)
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.host", "smtp.hostinger.com"); // Hostinger SMTP server
        properties.put("mail.smtp.port", "465"); // SSL port
        properties.put("mail.smtp.ssl.enable", "true");
        properties.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        properties.put("mail.smtp.socketFactory.port", "465");
        properties.put("mail.smtp.socketFactory.fallback", "false");

        // SMTP credentials
        final String smtpEmail = "rohan@tars.co.in"; // Your Hostinger email
        final String smtpPassword = "Tars@2322"; // Your email password or App Password

        // Create session
        Session mailSession = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpEmail, smtpPassword);
            }
        });

        // Enable debugging to see SMTP logs
        mailSession.setDebug(true);

        try {
            MimeMessage message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(smtpEmail));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            message.setSubject(subject);
            message.setText(messageText);

            Transport.send(message);
            out.println("<script>alert('Email sent successfully!'); window.location='email.jsp';</script>");
        } catch (MessagingException e) {
            e.printStackTrace();
            out.println("<script>alert('Error sending email: " + e.getMessage() + "'); window.location='email.jsp';</script>");
        }
    }
}
