package com.email;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class AddIntegrationServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("text/html");

        // Retrieve integration details
        String provider = request.getParameter("provider");
        String serviceName = request.getParameter("serviceName");
        String buyDateStr = request.getParameter("buyDate");
        String durationStr = request.getParameter("duration");
        String costStr = request.getParameter("cost");

        // Get company_id from session
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id");
        Integer companyId = (companyIdStr != null) ? Integer.parseInt(companyIdStr) : null;

        // Validate input
        if (provider == null || serviceName == null || buyDateStr == null || 
            durationStr == null || costStr == null || companyId == null) {
            response.getWriter().println("<script>alert('Error: Missing required fields!'); window.history.back();</script>");
            return;
        }

        // Parse input values
        try {
            // Parse dates and numbers
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate buyDate = LocalDate.parse(buyDateStr, formatter);
            int duration = Integer.parseInt(durationStr);
            double cost = Double.parseDouble(costStr);
            
            // Calculate expiry date by adding duration months to buy date
            LocalDate expiryDate = buyDate.plusMonths(duration);

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
            
                Class.forName("com.mysql.cj.jdbc.Driver");
               con = DriverManager.getConnection(url, user, pass);

                // Modified query to match your table structure
                String query = "INSERT INTO integrations (provider, service_name, buy_date, expiry_date, cost, company_id) VALUES (?, ?, ?, ?, ?, ?)";
                ps = con.prepareStatement(query);
                ps.setString(1, provider);
                ps.setString(2, serviceName);
                ps.setDate(3, Date.valueOf(buyDate)); // Using the user-provided buy date
                ps.setDate(4, Date.valueOf(expiryDate));
                ps.setDouble(5, cost);
                ps.setInt(6, companyId);

                int rowsInserted = ps.executeUpdate();
                if (rowsInserted > 0) {
                    response.sendRedirect("integration.jsp");
                } else {
                    response.getWriter().println("<script>alert('Error: Integration could not be added!'); window.history.back();</script>");
                }
            } catch (ClassNotFoundException e) {
                response.getWriter().println("<script>alert('Error: Database driver not found!'); window.history.back();</script>");
                e.printStackTrace();
            } catch (SQLException e) {
                response.getWriter().println("<script>alert('Error: Database operation failed!'); window.history.back();</script>");
                e.printStackTrace();
            } finally {
                try {
                    if (ps != null) ps.close();
                    if (con != null) con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            response.getWriter().println("<script>alert('Error: Invalid input format!'); window.history.back();</script>");
            e.printStackTrace();
        }
    }
}