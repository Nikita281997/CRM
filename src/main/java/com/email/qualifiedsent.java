package com.email;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/qualifiedsent")
public class qualifiedsent extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get the logged-in company ID from the session
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id");

        if (companyIdStr == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        int companyId = Integer.parseInt(companyIdStr);
        String leadIdParam = request.getParameter("leadId");

        if (leadIdParam == null || leadIdParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Lead ID is required.");
            return;
        }

        int leadId = Integer.parseInt(leadIdParam);
        Connection conn = null;
        PreparedStatement pstmtFetch = null, pstmtInsertQualified = null, pstmtInsertProject = null, 
                         pstmtUpdateFinance = null, pstmtDelete = null, pstmtGetQuotation = null;
        ResultSet rs = null, quotationRs = null;

        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Validate that the lead belongs to the logged-in company
            String checkLeadSql = "SELECT * FROM proposalsent WHERE lead_id = ? AND company_id = ?";
            pstmtFetch = conn.prepareStatement(checkLeadSql);
            pstmtFetch.setInt(1, leadId);
            pstmtFetch.setInt(2, companyId);
            rs = pstmtFetch.executeQuery();

            if (!rs.next()) {
                response.getWriter().println("<script>alert('Unauthorized access!'); window.location.href='leadmanagement.jsp';</script>");
                return;
            }

            // Retrieve project details
            String projectName = rs.getString("project_name");
            String customerName = rs.getString("customer_name");
            String email = rs.getString("email");  // Fetch email from proposalsent table

            // Get quotation details with proper handling of large decimal values
            String getQuotationSql = "SELECT amount, addiamt FROM quotation WHERE lead_id = ? AND company_id = ?";
            pstmtGetQuotation = conn.prepareStatement(getQuotationSql);
            pstmtGetQuotation.setInt(1, leadId);
            pstmtGetQuotation.setInt(2, companyId);
            quotationRs = pstmtGetQuotation.executeQuery();

            BigDecimal amount = BigDecimal.ZERO;
            BigDecimal addiamt = BigDecimal.ZERO;

            if (quotationRs.next()) {
                // Handle large decimal values by getting them as strings first
                String amountStr = quotationRs.getString("amount");
                String addiamtStr = quotationRs.getString("addiamt");
                
                if (amountStr != null) {
                    amount = new BigDecimal(amountStr);
                }
                if (addiamtStr != null) {
                    addiamt = new BigDecimal(addiamtStr);
                }
            }

            // Calculate total quotes value
            BigDecimal quotesValue = amount.add(addiamt);

            // Insert into 'qualified' table
            String insertSqlQualified = "INSERT INTO qualified (lead_id, project_name, customer_name, company_id) VALUES (?, ?, ?, ?)";
            pstmtInsertQualified = conn.prepareStatement(insertSqlQualified);
            pstmtInsertQualified.setInt(1, leadId);
            pstmtInsertQualified.setString(2, projectName);
            pstmtInsertQualified.setString(3, customerName);
            pstmtInsertQualified.setInt(4, companyId);
            pstmtInsertQualified.executeUpdate();

            // Insert into 'project' table (Added email field)
            String insertSqlProject = "INSERT INTO project (lead_id, project_name, customer_name, email, company_id) VALUES (?, ?, ?, ?, ?)";
            pstmtInsertProject = conn.prepareStatement(insertSqlProject);
            pstmtInsertProject.setInt(1, leadId);
            pstmtInsertProject.setString(2, projectName);
            pstmtInsertProject.setString(3, customerName);
            pstmtInsertProject.setString(4, email);  // Adding email
            pstmtInsertProject.setInt(5, companyId);
            pstmtInsertProject.executeUpdate();

            // Update 'financemanagement' table with proper handling of large decimal values
            String updateSqlFinance = "UPDATE financemanagement SET " +
                                     "project_name = ?, " +
                                     "customer_name = ?, " +
                                     "quotes_values = ?, " +
                                     "balance = ?, " +
                                     "total = ?, " +
                                     "addiamt = ? " +
                                     "WHERE lead_id = ? AND company_id = ?";
            
            pstmtUpdateFinance = conn.prepareStatement(updateSqlFinance);
            pstmtUpdateFinance.setString(1, projectName);
            pstmtUpdateFinance.setString(2, customerName);
            pstmtUpdateFinance.setBigDecimal(3, quotesValue);  // quotes_values
            pstmtUpdateFinance.setBigDecimal(4, quotesValue);   // initial balance = quotes_value
            pstmtUpdateFinance.setBigDecimal(5, BigDecimal.ZERO); // initial total payments = 0
            pstmtUpdateFinance.setBigDecimal(6, addiamt);       // additional amount
            pstmtUpdateFinance.setInt(7, leadId);
            pstmtUpdateFinance.setInt(8, companyId);
            pstmtUpdateFinance.executeUpdate();

            // Delete from 'proposalsent' table
            String deleteSql = "DELETE FROM proposalsent WHERE lead_id = ? AND company_id = ?";
            pstmtDelete = conn.prepareStatement(deleteSql);
            pstmtDelete.setInt(1, leadId);
            pstmtDelete.setInt(2, companyId);
            pstmtDelete.executeUpdate();

            // Redirect to lead management page
            response.sendRedirect("leadmanagement.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while processing the request: " + e.getMessage());
        } finally {
            // Close resources
            try {
                if (quotationRs != null) quotationRs.close();
                if (rs != null) rs.close();
                if (pstmtFetch != null) pstmtFetch.close();
                if (pstmtInsertQualified != null) pstmtInsertQualified.close();
                if (pstmtInsertProject != null) pstmtInsertProject.close();
                if (pstmtUpdateFinance != null) pstmtUpdateFinance.close();
                if (pstmtDelete != null) pstmtDelete.close();
                if (pstmtGetQuotation != null) pstmtGetQuotation.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}