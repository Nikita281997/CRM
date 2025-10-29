package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class OAuthServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String name = request.getParameter("name");
        String oauthId = request.getParameter("oauth_id");

        try (Connection conn = DBConnection.getConnection()) {
            // Check if user exists
            String checkUser = "SELECT * FROM users WHERE email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkUser);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();

            if (!rs.next()) { // If user does not exist, insert into DB
                String insertUser = "INSERT INTO users (email, name, oauth_provider, oauth_id) VALUES (?, ?, 'google', ?)";
                PreparedStatement insertStmt = conn.prepareStatement(insertUser);
                insertStmt.setString(1, email);
                insertStmt.setString(2, name);
                insertStmt.setString(3, oauthId);
                insertStmt.executeUpdate();
            }

            // Set session and redirect to Dashboard
            HttpSession session = request.getSession();
            session.setAttribute("user", email);
            response.sendRedirect("Dashboard.jsp");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
