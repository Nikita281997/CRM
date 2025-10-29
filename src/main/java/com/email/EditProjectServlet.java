package com.email;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@WebServlet("/EditProjectServlet")
public class EditProjectServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Retrieve session variable for company_id
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

        // Redirect to login if company_id is missing
        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        // Retrieve and validate leadId
        String leadIdStr = request.getParameter("leadId");
        if (leadIdStr == null || leadIdStr.trim().isEmpty()) {
            response.sendRedirect("projects.jsp?errorMessage=Lead ID is missing.");
            return;
        }

        int leadId;
        try {
            leadId = Integer.parseInt(leadIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("projects.jsp?errorMessage=Invalid Lead ID.");
            return;
        }

        // Get due date from the form
        String dueDate = request.getParameter("date");
        if (dueDate == null || dueDate.trim().isEmpty()) {
            response.sendRedirect("dashmanager.jsp?errorMessage=Due date is required.");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI")) {
                // Start transaction
                con.setAutoCommit(false);
                
                // First, retrieve the in_date from the leads table
                String inDateQuery = "SELECT in_date FROM leads WHERE lead_id = ? AND company_id = ?";
                LocalDate inDate = null;
                
                try (PreparedStatement psInDate = con.prepareStatement(inDateQuery)) {
                    psInDate.setInt(1, leadId);
                    psInDate.setInt(2, companyId);
                    
                    try (ResultSet rs = psInDate.executeQuery()) {
                        if (rs.next()) {
                            String inDateStr = rs.getString("in_date");
                            if (inDateStr != null && !inDateStr.trim().isEmpty()) {
                                inDate = LocalDate.parse(inDateStr);
                            } else {
                                response.sendRedirect("projects.jsp?errorMessage=In date not found for this lead.");
                                return;
                            }
                        } else {
                            response.sendRedirect("projects.jsp?errorMessage=Lead not found.");
                            return;
                        }
                    }
                }
                
                // Get quotation date from quotation table
                String quotationDateQuery = "SELECT quotation_date FROM quotation WHERE lead_id = ? AND company_id = ?";
                LocalDate quotationDate = null;
                
                try (PreparedStatement psQuotationDate = con.prepareStatement(quotationDateQuery)) {
                    psQuotationDate.setInt(1, leadId);
                    psQuotationDate.setInt(2, companyId);
                    
                    try (ResultSet rs = psQuotationDate.executeQuery()) {
                        if (rs.next()) {
                            String quotationDateStr = rs.getString("quotation_date");
                            if (quotationDateStr != null && !quotationDateStr.trim().isEmpty()) {
                                quotationDate = LocalDate.parse(quotationDateStr);
                            }
                        }
                    }
                }
                
                // Validate dates
                LocalDate dueDateObj;
                try {
                    dueDateObj = LocalDate.parse(dueDate);
                } catch (DateTimeParseException e) {
                    response.sendRedirect("projects.jsp?errorMessage=Invalid date format.");
                    return;
                }
                
                if (dueDateObj.isBefore(inDate)) {
                    response.sendRedirect("projects.jsp?errorMessage=Due date cannot be earlier than the in date (" + inDate.toString() + ").");
                    return;
                }
                
                if (quotationDate != null && dueDateObj.isBefore(quotationDate)) {
                    response.sendRedirect("projects.jsp?errorMessage=Due date cannot be earlier than the quotation date (" + quotationDate.toString() + ").");
                    return;
                }
                
                // Update due date in project table
                String updateProjectQuery = "UPDATE project SET due_date = ? WHERE lead_id = ? AND company_id = ?";
                try (PreparedStatement psProject = con.prepareStatement(updateProjectQuery)) {
                    psProject.setString(1, dueDate);
                    psProject.setInt(2, leadId);
                    psProject.setInt(3, companyId);
                    
                    int rowsUpdatedProject = psProject.executeUpdate();
                    if (rowsUpdatedProject == 0) {
                        con.rollback();
                        response.sendRedirect("projects.jsp?errorMessage=No project found with the given ID.");
                        return;
                    }
                }
                
                // Update due date in financemanagement table
                String updateFinanceQuery = "UPDATE financemanagement SET due_date = ? WHERE lead_id = ? AND company_id = ?";
                try (PreparedStatement psFinance = con.prepareStatement(updateFinanceQuery)) {
                    psFinance.setString(1, dueDate);
                    psFinance.setInt(2, leadId);
                    psFinance.setInt(3, companyId);
                    
                    int rowsUpdatedFinance = psFinance.executeUpdate();
                    if (rowsUpdatedFinance == 0) {
                        con.rollback();
                        response.sendRedirect("projects.jsp?errorMessage=No finance record found with the given ID.");
                        return;
                    }
                }
                
                // Commit transaction
                con.commit();
                response.sendRedirect("projects.jsp?successMessage=Due date updated successfully.");

            } catch (SQLException e) {
                e.printStackTrace();
                response.sendRedirect("projects.jsp?errorMessage=Database error: " + e.getMessage());
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("projects.jsp?errorMessage=Database error: " + e.getMessage());
        }
    }
}