package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
@WebServlet("/SaveDraftServlet")
public class SaveDraftServlet extends HttpServlet {
	
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
     
    	String recipient = request.getParameter("recipient");
        String subject = request.getParameter("subject");
        String message = request.getParameter("message");
        boolean send = Boolean.parseBoolean(request.getParameter("send")); // Check if the message should be sent
        PrintWriter out=response.getWriter();
        try { 
             String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, pass);
            if (send) {
                // Insert into sent table
                String insertSent = "INSERT INTO sent (recipient, subject, message) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertSent)) {
                    ps.setString(1, recipient);
                    ps.setString(2, subject);
                    ps.setString(3, message);
                    ps.executeUpdate();
                }
               // response.getWriter().println("Message sent successfully!");
            } else {
                // Insert into drafts table
                String insertDraft = "INSERT INTO drafts (recipient, subject, message) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertDraft)) {
                    ps.setString(1, recipient);
                    ps.setString(2, subject);
                    ps.setString(3, message);
                    ps.executeUpdate();
                }
              
               out.println("<script>alert('saved at Draft'); window.location='email.jsp';</script>");
            }
        } catch (Exception e) {
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
