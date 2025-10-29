package com.email;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/deletequalified")
public class deletequalified extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response); // Delegate GET requests to doPost
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // Get the quote ID to delete from the request
        String quoteId = request.getParameter("quoteid");

        // Check if the quote ID is provided
        if (quoteId == null || quoteId.isEmpty()) {
            out.println("<script>alert('Error: No lead ID provided!'); window.location='leadmanagement.jsp';</script>");
            return;
        }

        // Validate session and company_id
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id");
        Integer companyId = null;

        if (companyIdStr == null || companyIdStr.trim().isEmpty()) {
            out.println(
                    "<script>alert('Error: Invalid session. Please log in again.'); window.location='login1.jsp';</script>");
            return;
        }

        try {
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            out.println("<script>alert('Error: Invalid company ID.'); window.location='login1.jsp';</script>");
            return;
        }

        // Database connection parameters
     
        String host = System.getenv("DB_HOST");
        String port = System.getenv("DB_PORT");
        String dbName = System.getenv("DB_NAME");
        String dbUser = System.getenv("DB_USER");
        String dbPassword = System.getenv("DB_PASS");

        String dbUrl = "jdbc:mysql://" + host + ":" + port + "/" + dbName;

        try {
            // Load MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Connect to the database
            try (Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
                // Check if the lead_id exists in the qualified table and belongs to the company
                String checkSql = "SELECT 1 FROM qualified q JOIN leads l ON q.lead_id = l.lead_id WHERE q.lead_id = ? AND l.company_id = ?";
                try (PreparedStatement checkStmt = con.prepareStatement(checkSql)) {
                    checkStmt.setInt(1, Integer.parseInt(quoteId));
                    checkStmt.setInt(2, companyId);
                    try (ResultSet rs = checkStmt.executeQuery()) {
                        if (!rs.next()) {
                            out.println(
                                    "<script>alert('No Project found with the given ID for your company.'); window.location='leadmanagement.jsp';</script>");
                            return;
                        }
                    }
                }

                // SQL query to delete the record from qualified
                String deleteSql = "DELETE FROM qualified WHERE lead_id = ?";
                try (PreparedStatement stmt = con.prepareStatement(deleteSql)) {
                    stmt.setInt(1, Integer.parseInt(quoteId));

                    // Execute the delete query
                    int rowsAffected = stmt.executeUpdate();
                    if (rowsAffected > 0) {
                        // Update leads table to mark delete_qualified as TRUE
                        String updateLeadsSql = "UPDATE leads SET delete_qualified = TRUE WHERE lead_id = ?";
                        try (PreparedStatement updateStmt = con.prepareStatement(updateLeadsSql)) {
                            updateStmt.setInt(1, Integer.parseInt(quoteId));
                            updateStmt.executeUpdate();
                        }
                        out.println(
                                "<script>alert('Project deleted successfully!'); window.location='leadmanagement.jsp';</script>");
                    } else {
                        out.println(
                                "<script>alert('No Project found with the given ID.'); window.location='leadmanagement.jsp';</script>");
                    }
                }
            }
        } catch (ClassNotFoundException e) {
            out.println(
                    "<script>alert('Error: Unable to load database driver!'); window.location='leadmanagement.jsp';</script>");
            e.printStackTrace(out);
        } catch (SQLException e) {
            out.println("<script>alert('Error: Database operation failed! " + e.getMessage().replace("'", "\\'")
                    + "'); window.location='leadmanagement.jsp';</script>");
            e.printStackTrace(out);
        } catch (NumberFormatException e) {
            out.println(
                    "<script>alert('Error: Invalid lead ID format!'); window.location='leadmanagement.jsp';</script>");
            e.printStackTrace(out);
        }
    }
}