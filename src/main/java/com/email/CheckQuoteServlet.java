package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import org.json.JSONObject;

public class CheckQuoteServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get company_id from session
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id");
        Integer companyId = null;
        if (companyIdStr != null) {
            try {
                companyId = Integer.parseInt(companyIdStr);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        // Get lead_id from request
        String leadIdStr = request.getParameter("leadId");
        int leadId;
        try {
            leadId = Integer.parseInt(leadIdStr);
        } catch (NumberFormatException e) {
            response.setContentType("application/json");
            response.getWriter().write(new JSONObject().put("error", "Invalid lead ID").toString());
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try { String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);

            // Check if a quote exists for the lead and company
            String sql = "SELECT COUNT(*) FROM quotation WHERE lead_id = ? AND company_id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, leadId);
            stmt.setInt(2, companyId);
            rs = stmt.executeQuery();

            boolean hasQuote = false;
            if (rs.next()) {
                hasQuote = rs.getInt(1) > 0;
            }

            // Send JSON response
            response.setContentType("application/json");
            JSONObject json = new JSONObject();
            json.put("hasQuote", hasQuote);
            response.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write(new JSONObject().put("error", "Database error: " + e.getMessage()).toString());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }}}