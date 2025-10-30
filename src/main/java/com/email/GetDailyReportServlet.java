package com.email;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.json.JSONObject;

public class GetDailyReportServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        try {
            int leadId = Integer.parseInt(request.getParameter("leadId"));
            String reportDate = request.getParameter("reportDate");
            
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
                jsonResponse.put("error", "Unauthorized access");
                out.print(jsonResponse.toString());
                return;
            }

            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(url, user, pass)) {
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT report_content FROM daily_reports WHERE lead_id = ? AND company_id = ? AND report_date = ?")) {
                    ps.setInt(1, leadId);
                    ps.setInt(2, companyId);
                    ps.setDate(3, Date.valueOf(reportDate));
                    
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            // Explicitly put String value to avoid ambiguity
                            jsonResponse.put("report", rs.getString("report_content"));
                        } else {
                            jsonResponse.put("report", JSONObject.NULL);
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                jsonResponse.put("error", "Database error");
            }
        } catch (NumberFormatException e) {
            jsonResponse.put("error", "Invalid lead ID");
        } catch (IllegalArgumentException e) {
            jsonResponse.put("error", "Invalid date format");
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("error", "Server error");
        }
        
        out.print(jsonResponse.toString());
    }
}