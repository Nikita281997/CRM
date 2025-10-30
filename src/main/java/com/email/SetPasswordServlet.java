package com.email;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

  // Servlet URL Mapping
public class SetPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        // Retrieve parameters from the form
        String leadIdStr = request.getParameter("leadId");
        String password = request.getParameter("password");

        // Convert leadId to Integer
        int leadId = 0;
        try {
            leadId = Integer.parseInt(leadIdStr);
        } catch (NumberFormatException e) {
            out.println("<script>alert('Invalid Lead ID'); window.history.back();</script>");
            return;
        }

        if (password == null || password.trim().isEmpty()) {
            out.println("<script>alert('Password cannot be empty!'); window.history.back();</script>");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        
        try {
             String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");

            con = DriverManager.getConnection(url, user, pass);

            // Query to update password for a specific lead_id
            String query = "UPDATE project SET password = ? WHERE lead_id = ?";
            ps = con.prepareStatement(query);
            ps.setString(1, password); // Store password directly (Consider hashing for security)
            ps.setInt(2, leadId);

            int rowsUpdated = ps.executeUpdate();

            if (rowsUpdated > 0) {
                out.println("<script>alert('Password set successfully!'); window.location='projects.jsp';</script>");
            } else {
                out.println("<script>alert('Error: Lead ID not found!'); window.history.back();</script>");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Database error: " + e.getMessage() + "'); window.history.back();</script>");
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
