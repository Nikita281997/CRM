package com.email;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

public class SaveUserServlet extends HttpServlet {
 
    private static final String JDBC_URL = "jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb";
    private static final String JDBC_USER =  "atharva";
    private static final String JDBC_PASS = "AVNS_SFoivcl39tz_B7wqssI";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String name = request.getParameter("name");
        String oauthProvider = "google"; // Since we are using Google OAuth

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS);

            // Check if user already exists
            String checkUser = "SELECT * FROM users WHERE email=?";
            PreparedStatement ps = conn.prepareStatement(checkUser);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                // Insert new user
                String insertUser = "INSERT INTO users (email, name, oauth_provider) VALUES (?, ?, ?)";
                ps = conn.prepareStatement(insertUser);
                ps.setString(1, email);
                ps.setString(2, name);
                ps.setString(3, oauthProvider);
                ps.executeUpdate();
            }

            // Start session
            HttpSession session = request.getSession();
            session.setAttribute("user", name);
            response.sendRedirect("Dashboard.jsp");

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
