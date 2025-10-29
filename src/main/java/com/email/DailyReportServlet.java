package com.email;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.json.JSONArray;
import org.json.JSONObject;

public class DailyReportServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        System.out.println("DailyReportServlet: Processing request");
        
        try {
            HttpSession session = request.getSession();
            String companyIdStr = (String) session.getAttribute("company_id");
            String leadIdStr = (String) session.getAttribute("lead_id");
            
            System.out.println("Session values - companyId: " + companyIdStr + ", leadId: " + leadIdStr);
            
            if (companyIdStr == null || leadIdStr == null) {
                System.out.println("Session values are null - redirecting to login");
                jsonResponse.put("error", "Session expired or invalid");
                out.print(jsonResponse.toString());
                return;
            }
            
            int companyId = Integer.parseInt(companyIdStr);
            int leadId = Integer.parseInt(leadIdStr);

            System.out.println("Connecting to database...");
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI")) {
                String query = "SELECT report_id, report_date, report_content FROM daily_reports " +
                              "WHERE company_id = ? AND lead_id = ? ORDER BY report_date DESC";
                
                System.out.println("Executing query: " + query);
                System.out.println("Parameters - companyId: " + companyId + ", leadId: " + leadId);
                
                try (PreparedStatement ps = con.prepareStatement(query)) {
                    ps.setInt(1, companyId);
                    ps.setInt(2, leadId);
                    
                    ResultSet rs = ps.executeQuery();
                    JSONArray reports = new JSONArray();
                    
                    System.out.println("Processing result set...");
                    while (rs.next()) {
                        JSONObject report = new JSONObject();
                        int id = rs.getInt("report_id");
                        String date = rs.getString("report_date");
                        String content = rs.getString("report_content");
                        
                        System.out.println("Found report - ID: " + id + ", Date: " + date + ", Content: " + content);
                        
                        report.put("id", id);
                        report.put("date", date);
                        report.put("content", content);
                        reports.put(report);
                    }
                    
                    System.out.println("Total reports found: " + reports.length());
                    jsonResponse.put("reports", reports);
                    jsonResponse.put("status", "success");
                }
            } catch (SQLException e) {
                System.err.println("SQL Error: " + e.getMessage());
                jsonResponse.put("error", "Database error: " + e.getMessage());
                e.printStackTrace();
            }
        } catch (NumberFormatException e) {
            System.err.println("Number format error: " + e.getMessage());
            jsonResponse.put("error", "Invalid ID format");
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            jsonResponse.put("error", "Server error: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("Sending response: " + jsonResponse.toString());
        out.print(jsonResponse.toString());
        out.flush();
    }
}