package com.email;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

public class GoogleAuthServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String name = request.getParameter("name");
        String oauthId = request.getParameter("oauth_id");

        if (email != null && name != null && oauthId != null) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            try {
                // Load MySQL JDBC Driver
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

                // Insert or update user details
                String sql = "INSERT INTO users (email, name, oauth_provider, oauth_id) VALUES (?, ?, ?, ?) "
                           + "ON DUPLICATE KEY UPDATE name = VALUES(name), oauth_provider = VALUES(oauth_provider), oauth_id = VALUES(oauth_id)";

                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, email);
                pstmt.setString(2, name);
                pstmt.setString(3, "google");
                pstmt.setString(4, oauthId);
                pstmt.executeUpdate();

                // Store user details in session
                HttpSession session = request.getSession(true);
                session.setAttribute("userEmail", email);
                session.setAttribute("userName", name);

                // Redirect to dashboard
                response.sendRedirect("Dashboard.jsp");
            } catch (Exception e) {
                response.sendRedirect("auth.jsp?error=" + e.getMessage());
            } finally {
                try {
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        } else {
            response.sendRedirect("auth.jsp?error=Invalid Authentication");
        }
    }
}
