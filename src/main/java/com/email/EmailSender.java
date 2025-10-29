package com.email;

import java.util.*;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailSender {
    // Hostinger SMTP credentials
    private static final String FROM_EMAIL = "rohan@tars.co.in";
    private static final String PASSWORD = "Tars@2322"; // Consider storing in env variables
    private static final String HOST = "smtp.hostinger.com";
    private static final String PORT = "587";

    public static void sendEmail(String to, String subject, String body) {
        Properties properties = new Properties();
        properties.put("mail.smtp.host", HOST);
        properties.put("mail.smtp.port", PORT);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(properties, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
            message.setSubject(subject);
            message.setText(body);

            Transport.send(message);
            System.out.println("Email sent successfully to " + to);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}
