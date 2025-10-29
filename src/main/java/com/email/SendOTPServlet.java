package com.email;

import java.io.IOException;
import java.util.Properties;
import java.util.Random;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.mail.*;
import jakarta.mail.internet.*;


public class SendOTPServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("email");

        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Generate OTP
        int otp = new Random().nextInt(999999);
        session.setAttribute("otp", otp);

        // Send OTP via email
        final String fromEmail = "your-email@gmail.com"; // Change to your email
        final String password = "your-app-password"; // Use App Password for Gmail

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session mailSession = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            message.setSubject("Your OTP Code");
            message.setText("Your OTP for CRM Login is: " + otp);

            Transport.send(message);

            response.sendRedirect("verifyOtp.jsp");

        } catch (MessagingException e) {
            throw new RuntimeException(e);
        }
    }
}
