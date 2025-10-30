package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.math.BigDecimal;

@WebServlet("/ProposalsentServlet")
public class ProposalsentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get the logged-in company ID from the session
        HttpSession sessionVar = request.getSession();
        String companyIdStr = (String) sessionVar.getAttribute("company_id");

        Integer companyId = null;
        if (companyIdStr != null) {
            try {
                companyId = Integer.parseInt(companyIdStr);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // If the company is not logged in, redirect to login page
        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        String action = request.getParameter("action");
        String leadIdStr = request.getParameter("leadid");
        int leadId = 0;

        // Validate and parse leadid
        if (leadIdStr != null && !leadIdStr.trim().isEmpty()) {
            try {
                leadId = Integer.parseInt(leadIdStr);
            } catch (NumberFormatException e) {
                response.getWriter().println(
                    "<script type='text/javascript'>" +
                    "alert('Invalid Lead ID format. Please try again.');" +
                    "window.location.href = 'leadmanagement.jsp';" +
                    "</script>");
                return;
            }
        } else {
            response.getWriter().println(
                "<script type='text/javascript'>" +
                "alert('Lead ID is missing. Please try again.');" +
                "window.location.href = 'leadmanagement.jsp';" +
                "</script>");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        PreparedStatement checkPs = null;
        PreparedStatement psQuote = null;
        PreparedStatement psFinance = null;
        PreparedStatement leadDatePs = null;
        PreparedStatement psDescription = null;

        try {
             String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);

            // Check if lead belongs to the logged-in company
            String checkLeadSql = "SELECT COUNT(*) FROM leads WHERE lead_id = ? AND company_id = ?";
            PreparedStatement checkLeadStmt = conn.prepareStatement(checkLeadSql);
            checkLeadStmt.setInt(1, leadId);
            checkLeadStmt.setInt(2, companyId);
            ResultSet checkLeadRs = checkLeadStmt.executeQuery();

            if (checkLeadRs.next() && checkLeadRs.getInt(1) == 0) {
                // Unauthorized access
                response.getWriter().println(
                    "<script type='text/javascript'>" +
                    "alert('Unauthorized action: This lead does not belong to your company!');" +
                    "window.location.href = 'leadmanagement.jsp';" +
                    "</script>");
                return;
            }

            if ("addQuoteAndMove".equals(action)) {
                // Logic to add quote (from quoteservlet)
                String date = request.getParameter("date");
                String[] srNos = request.getParameterValues("srNo[]");
                String[] descriptions = request.getParameterValues("description[]");
                String[] prices = request.getParameterValues("price[]");
                String amt = request.getParameter("amount");

                // Validate amount is a valid number, remove commas
                BigDecimal amount;
                try {
                    amt = amt.replaceAll("[^0-9.]", ""); // Remove commas and other non-numeric characters except decimal point
                    if (amt.trim().isEmpty()) {
                        throw new NumberFormatException("Empty amount");
                    }
                    amount = new BigDecimal(amt);
                } catch (NumberFormatException e) {
                    response.getWriter().println(
                        "<script type='text/javascript'>" +
                        "alert('Invalid amount format. Please enter a valid number.');" +
                        "window.location.href = 'leadmanagement.jsp';" +
                        "</script>");
                    return;
                }

                // Step 1: Ensure the lead belongs to the logged-in company and get the in_date
                String leadCheckQuery = "SELECT in_date FROM leads WHERE lead_id = ? AND company_id = ?";
                leadDatePs = conn.prepareStatement(leadCheckQuery);
                leadDatePs.setInt(1, leadId);
                leadDatePs.setInt(2, companyId);
                ResultSet leadDateRs = leadDatePs.executeQuery();

                if (!leadDateRs.next()) {
                    response.getWriter().println(
                        "<script type='text/javascript'>" +
                        "alert('Unauthorized access: This lead does not belong to your company!');" +
                        "window.location.href = 'leadmanagement.jsp';" +
                        "</script>");
                    return;
                }

                String leadInDateStr = leadDateRs.getString("in_date");
                
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date leadInDate = sdf.parse(leadInDateStr);
                Date quotationDate = sdf.parse(date);
                
                if (quotationDate.before(leadInDate)) {
                    response.getWriter().println(
                        "<script type='text/javascript'>" +
                        "alert('Quotation date cannot be before the lead creation date (" + leadInDateStr + ").');" +
                        "window.location.href = 'leadmanagement.jsp';" +
                        "</script>");
                    return;
                }

                // Step 2: Check if the lead_id already exists in the Quotation table
                String checkQuoteQuery = "SELECT COUNT(*) FROM quotation WHERE lead_id = ? AND company_id = ?";
                checkPs = conn.prepareStatement(checkQuoteQuery);
                checkPs.setInt(1, leadId);
                checkPs.setInt(2, companyId);
                rs = checkPs.executeQuery();

                if (rs.next() && rs.getInt(1) > 0) {
                    response.getWriter().println(
                        "<script type='text/javascript'>" +
                        "alert('Lead ID already has a quotation. Cannot add duplicate quotes!');" +
                        "window.location.href = 'leadmanagement.jsp';" +
                        "</script>");
                    return;
                }

                // Begin transaction
                conn.setAutoCommit(false);

                try {
                    // Step 3: Insert descriptions
                    String insertDesc = "INSERT INTO description (lead_id, company_id, sr_no, descriptions, price) VALUES (?, ?, ?, ?, ?)";
                    psDescription = conn.prepareStatement(insertDesc);
                    for (int i = 0; i < srNos.length; i++) {
                        psDescription.setInt(1, leadId);
                        psDescription.setInt(2, companyId);
                        psDescription.setInt(3, Integer.parseInt(srNos[i]));
                        psDescription.setString(4, descriptions[i]);
                        psDescription.setBigDecimal(5, new BigDecimal(prices[i]));
                        psDescription.executeUpdate();
                    }

                    // Step 4: Insert the new quote using BigDecimal for the amount
                    String insertQuote = "INSERT INTO quotation(lead_id, quotation_date, amount, orgamt, company_id) VALUES (?, ?, ?, ?, ?)";
                    psQuote = conn.prepareStatement(insertQuote);
                    psQuote.setInt(1, leadId);
                    psQuote.setString(2, date);
                    psQuote.setBigDecimal(3, amount);
                    psQuote.setBigDecimal(4, amount);
                    psQuote.setInt(5, companyId);

                    int quoteResult = psQuote.executeUpdate();

                    if (quoteResult == 1) {
                        try {
                            String insertFinance = "INSERT INTO financemanagement(lead_id, quotes_values, orgamt, company_id) VALUES (?, ?, ?, ?)";
                            psFinance = conn.prepareStatement(insertFinance);
                            psFinance.setInt(1, leadId);
                            psFinance.setBigDecimal(2, amount);
                            psFinance.setBigDecimal(3, amount);
                            psFinance.setInt(4, companyId);
                            int financeResult = psFinance.executeUpdate();

                            if (financeResult != 1) {
                                throw new SQLException("Failed to insert financial record.");
                            }
                        } catch (SQLException e) {
                            // Handle specific data truncation error
                            if (e.getMessage().contains("Data truncation: Out of range value for column 'quotes_values'")) {
                                response.getWriter().println(
                                    "<script type='text/javascript'>" +
                                    "alert('The amount value is too large. Please contact support to increase the storage capacity.');" +
                                    "window.location.href = 'leadmanagement.jsp';" +
                                    "</script>");
                            } else {
                                // For other SQL errors
                                response.getWriter().println(
                                    "<script type='text/javascript'>" +
                                    "alert('Financial record could not be saved: " + e.getMessage().replace("'", "\\'") + "');" +
                                    "window.location.href = 'leadmanagement.jsp';" +
                                    "</script>");
                            }
                            throw e;
                        }
                    } else {
                        throw new SQLException("Failed to insert quote");
                    }

                    // Step 5: Move to Proposal stage
                    String insertProposalSql = "INSERT INTO proposalsent (lead_id, project_name, customer_name, email, company_id) "
                            + "SELECT lead_id, project_name, customer_name, email, company_id FROM leads WHERE lead_id = ?";
                    stmt = conn.prepareStatement(insertProposalSql);
                    stmt.setInt(1, leadId);
                    int rowsAffected = stmt.executeUpdate();

                    if (rowsAffected > 0) {
                        // Remove the lead from the connected stage (only for the same company)
                        String deleteSql = "DELETE FROM connected WHERE lead_id = ? AND company_id = ?";
                        stmt = conn.prepareStatement(deleteSql);
                        stmt.setInt(1, leadId);
                        stmt.setInt(2, companyId);
                        stmt.executeUpdate();

                        // Commit transaction
                        conn.commit();

                        // Success message
                        response.getWriter().println(
                            "<script type='text/javascript'>" +
                            "alert('Quote, descriptions, financial record added, and lead moved to Proposal stage successfully!');" +
                            "window.location.href = 'leadmanagement.jsp';" +
                            "</script>");
                    } else {
                        throw new SQLException("Failed to move lead to Proposal stage");
                    }
                } catch (Exception e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
            }

            // Handle direct move to Proposal if quote exists
            if ("moveWithoutQuote".equals(action)) {
                // Check if lead exists in the 'quotation' table for the same company
                String checkQuoteSql = "SELECT COUNT(*) FROM quotation WHERE lead_id = ? AND company_id = ?";
                stmt = conn.prepareStatement(checkQuoteSql);
                stmt.setInt(1, leadId);
                stmt.setInt(2, companyId);
                rs = stmt.executeQuery();

                if (rs.next() && rs.getInt(1) > 0) {
                    // Insert into 'proposalsent' table with company_id
                    String insertSql = "INSERT INTO proposalsent (lead_id, project_name, customer_name, email, company_id) "
                            + "SELECT lead_id, project_name, customer_name, email, company_id FROM leads WHERE lead_id = ?";
                    stmt = conn.prepareStatement(insertSql);
                    stmt.setInt(1, leadId);
                    int rowsAffected = stmt.executeUpdate();

                    if (rowsAffected > 0) {
                        // Remove the lead from the connected stage (only for the same company)
                        String deleteSql = "DELETE FROM connected WHERE lead_id = ? AND company_id = ?";
                        stmt = conn.prepareStatement(deleteSql);
                        stmt.setInt(1, leadId);
                        stmt.setInt(2, companyId);
                        stmt.executeUpdate();

                        // Success message
                        response.getWriter().println(
                            "<script type='text/javascript'>" +
                            "alert('Lead moved to Proposal stage successfully!');" +
                            "window.location.href = 'leadmanagement.jsp';" +
                            "</script>");
                    } else {
                        // Failure message
                        response.getWriter().println(
                            "<script type='text/javascript'>" +
                            "alert('Failed to move lead to Proposal stage.');" +
                            "window.location.href = 'leadmanagement.jsp';" +
                            "</script>");
                    }
                } else {
                    // If the lead is not in the quotation table, send error message
                    response.getWriter().println(
                        "<script type='text/javascript'>" +
                        "alert('Quotation is not available for this lead (" + leadId + "). Please add a quotation first.');" +
                        "window.location.href = 'leadmanagement.jsp';" +
                        "</script>");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            // Handle specific data truncation error for the quote table
            if (e.getMessage().contains("Data truncation: Out of range value for column 'amount'")) {
                response.getWriter().println(
                    "<script type='text/javascript'>" +
                    "alert('The amount value is too large. Please enter a smaller value or contact support.');" +
                    "window.location.href = 'leadmanagement.jsp';" +
                    "</script>");
            } else {
                // For other SQL errors
                response.getWriter().println(
                    "<script type='text/javascript'>" +
                    "alert('Database error: " + e.getMessage().replace("'", "\\'") + "');" +
                    "window.location.href = 'leadmanagement.jsp';" +
                    "</script>");
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.getWriter().println(
                "<script type='text/javascript'>" +
                "alert('System configuration error. Please contact support.');" +
                "window.location.href = 'leadmanagement.jsp';" +
                "</script>");
        } catch (ParseException e) {
            e.printStackTrace();
            response.getWriter().println(
                "<script type='text/javascript'>" +
                "alert('Invalid date format. Please use YYYY-MM-DD format.');" +
                "window.location.href = 'leadmanagement.jsp';" +
                "</script>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (checkPs != null) checkPs.close();
                if (psQuote != null) psQuote.close();
                if (psFinance != null) psFinance.close();
                if (psDescription != null) psDescription.close();
                if (leadDatePs != null) leadDatePs.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}