package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            // Database connection
           String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);
            System.out.println("LoginServlet: Database connection established successfully");

            // Check credentials and payment status
            String sql = "SELECT payment_status FROM company_registration1 WHERE email = ? AND password = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                int paymentStatus = rs.getInt("payment_status");
                System.out.println("LoginServlet: Found user with email " + email + ", payment_status: " + paymentStatus);
                if (paymentStatus == 1) {
                    // Payment completed, allow login
                    System.out.println("LoginServlet: Payment completed, redirecting to dashboard");
                    response.sendRedirect("dashboard.jsp"); // Replace with your dashboard page
                } else {
                    // Payment pending
                    System.out.println("LoginServlet: Payment pending for email " + email);
                    request.setAttribute("errorMessage", "Payment is pending. Please complete the payment to log in.");
                    request.getRequestDispatcher("dashadminLogin.jsp").forward(request, response);
                }
            } else {
                // Invalid credentials
                System.out.println("LoginServlet: Invalid credentials for email " + email);
                request.setAttribute("errorMessage", "Invalid email or password.");
                request.getRequestDispatcher("dashadminLogin.jsp").forward(request, response);
            }

            con.close();
            System.out.println("LoginServlet: Database connection closed");
        } catch (Exception e) {
            System.out.println("LoginServlet Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}