package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            // Load JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Connect to Database
            Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Insert query with oauth_id set to 'N/A' for manual registration
            String query = "INSERT INTO users (email, name, password, oauth_provider, oauth_id) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, email);
            pst.setString(2, name);
            pst.setString(3, password);
            pst.setString(4, "manual"); // Default auth provider
            pst.setString(5, "N/A"); // Default oauth_id for manual users

            int rowCount = pst.executeUpdate();
            
            if (rowCount > 0) {
                response.getWriter().println("<script>alert('Registration Successful!'); window.location='Login.jsp';</script>");
            } else {
                response.getWriter().println("<script>alert('Registration Failed! Try Again.'); window.location='register.jsp';</script>");
            }

            pst.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('Database Error! Check Console.'); window.location='register.jsp';</script>");
        }
    }
}
