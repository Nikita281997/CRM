package com.email;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;

public class EditprojectBYmanager extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        int leadId = Integer.parseInt(request.getParameter("leadId"));
        int progress = Integer.parseInt(request.getParameter("progress"));
        String newReport = request.getParameter("newReport");
        String[] addEmployees = request.getParameterValues("addEmployees");
        String[] removeEmployees = request.getParameterValues("removeEmployees");
        String projectName = request.getParameter("projectName");
        String reportDateStr = request.getParameter("reportDate");

        try (Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI")) {
            // Update progress in project table
            try (PreparedStatement ps = con.prepareStatement("UPDATE project SET percent = ? WHERE lead_id = ? AND company_id = ?")) {
                ps.setInt(1, progress);
                ps.setInt(2, leadId);
                ps.setInt(3, companyId);
                ps.executeUpdate();
            }

            // Store new daily report if provided
            if (newReport != null && !newReport.trim().isEmpty()) {
                // First delete reports older than 10 days
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM daily_reports WHERE lead_id = ? AND company_id = ? AND report_date < DATE_SUB(CURDATE(), INTERVAL 10 DAY)")) {
                    ps.setInt(1, leadId);
                    ps.setInt(2, companyId);
                    ps.executeUpdate();
                }

                // Parse the report date
                java.util.Date utilDate = new SimpleDateFormat("yyyy-MM-dd").parse(reportDateStr);
                java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());

                // Check if report date is after in_date from leads table
                Date inDate = null;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT in_date FROM leads WHERE lead_id = ? AND company_id = ?")) {
                    ps.setInt(1, leadId);
                    ps.setInt(2, companyId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            inDate = rs.getDate("in_date");
                        }
                    }
                }

                if (inDate != null && sqlDate.before(inDate)) {
                    session.setAttribute("popupMessage", "Error: Report date cannot be before the project's start date (" + inDate + ")");
                    session.setAttribute("popupType", "error");
                    response.sendRedirect("dashmanager.jsp");
                    return;
                }

                // Check if a report already exists for this date
                boolean reportExists = false;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT report_id FROM daily_reports WHERE lead_id = ? AND company_id = ? AND report_date = ?")) {
                    ps.setInt(1, leadId);
                    ps.setInt(2, companyId);
                    ps.setDate(3, sqlDate);
                    try (ResultSet rs = ps.executeQuery()) {
                        reportExists = rs.next();
                    }
                }

                if (reportExists) {
                    session.setAttribute("popupMessage", "Error: A report already exists for this date");
                    session.setAttribute("popupType", "error");
                    response.sendRedirect("dashmanager.jsp");
                    return;
                }

                // Insert new report
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO daily_reports (lead_id, company_id, report_date, report_content) VALUES (?, ?, ?, ?)")) {
                    ps.setInt(1, leadId);
                    ps.setInt(2, companyId);
                    ps.setDate(3, sqlDate);
                    ps.setString(4, newReport);
                    ps.executeUpdate();
                    
                    session.setAttribute("popupMessage", "Daily report added successfully!");
                    session.setAttribute("popupType", "success");
                }
            }

            // Assign project to selected employees (add to project)
            if (addEmployees != null) {
                for (String empId : addEmployees) {
                    try (PreparedStatement ps = con.prepareStatement("UPDATE interns SET project_name = ? WHERE empid = ? AND company_id = ?")) {
                        ps.setString(1, projectName);
                        ps.setInt(2, Integer.parseInt(empId));
                        ps.setInt(3, companyId);
                        ps.executeUpdate();
                    }
                }
            }

            // Remove project from selected employees (remove from project)
            if (removeEmployees != null) {
                for (String empId : removeEmployees) {
                    try (PreparedStatement ps = con.prepareStatement("UPDATE interns SET project_name = NULL WHERE empid = ? AND company_id = ? AND project_name = ?")) {
                        ps.setInt(1, Integer.parseInt(empId));
                        ps.setInt(2, companyId);
                        ps.setString(3, projectName);
                        ps.executeUpdate();
                    }
                }
            }
            // Rest of your existing code for employee assignment...
            // [Keep all your existing employee assignment code here]

            // Check if progress is 100% and insert data into testertable
            if (progress == 100) {
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT p.lead_id, p.project_name, p.due_date, p.customer_name, p.company_id " +
                        "FROM project p " +
                        "WHERE p.lead_id = ? AND p.company_id = ? AND p.percent = 100")) {
                    ps.setInt(1, leadId);
                    ps.setInt(2, companyId);
                    
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            boolean recordExists = false;
                            try (PreparedStatement checkPs = con.prepareStatement(
                                    "SELECT lead_id FROM testertable WHERE lead_id = ? AND company_id = ?")) {
                                checkPs.setInt(1, leadId);
                                checkPs.setInt(2, companyId);
                                
                                try (ResultSet checkRs = checkPs.executeQuery()) {
                                    recordExists = checkRs.next();
                                }
                            }
                            
                            if (!recordExists) {
                                try (PreparedStatement insertPs = con.prepareStatement(
                                        "INSERT INTO testertable (lead_id, project_name, due_date, customer_name, approved, status, company_id) " +
                                        "VALUES (?, ?, ?, ?, ?, ?, ?)")) {
                                    insertPs.setInt(1, rs.getInt("lead_id"));
                                    insertPs.setString(2, rs.getString("project_name"));
                                    insertPs.setDate(3, rs.getDate("due_date"));
                                    insertPs.setString(4, rs.getString("customer_name"));
                                    insertPs.setInt(5, 0);
                                    insertPs.setString(6, "Not Delivered");
                                    insertPs.setInt(7, rs.getInt("company_id"));
                                    insertPs.executeUpdate();
                                    
                                    session.setAttribute("popupMessage", "Project marked as 100% complete and moved to tester table!");
                                    session.setAttribute("popupType", "success");
                                }
                            }
                        }
                    }
                }
            }
            
            // If we reach here without setting any message, set a generic success message
            if (session.getAttribute("popupMessage") == null) {
                session.setAttribute("popupMessage", "Project updated successfully!");
                session.setAttribute("popupType", "success");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("popupMessage", "Error processing request: " + e.getMessage());
            session.setAttribute("popupType", "error");
        }
        response.sendRedirect("dashmanager.jsp");
    }
}