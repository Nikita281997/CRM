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
             String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);

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
