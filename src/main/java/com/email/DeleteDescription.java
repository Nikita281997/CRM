package com.email;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

public class DeleteDescription extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res) 
            throws ServletException, IOException {
        res.setContentType("application/json");
        PrintWriter out = res.getWriter();
        Connection con = null;
        PreparedStatement psCheck = null;
        PreparedStatement psDelete = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psDebug = null;
        ResultSet rs = null;

        try {
            // 1. Get all required parameters
            int leadId = Integer.parseInt(req.getParameter("leadId"));
            int srNo = Integer.parseInt(req.getParameter("srNo"));
            System.out.println("Received parameters - leadId: " + leadId + ", srNo: " + srNo);

            // Get companyId from session
            HttpSession sessionVar = req.getSession();
            String companyIdStr = (String) sessionVar.getAttribute("company_id");
            Integer companyId = null;
            if (companyIdStr != null && !companyIdStr.trim().isEmpty()) {
                companyId = Integer.parseInt(companyIdStr);
            }
            System.out.println("Session companyIdStr: " + companyIdStr + ", Parsed companyId: " + companyId);
            if (companyId == null) {
                out.println("{\"success\":false, \"message\":\"Company ID not found or invalid in session\"}");
                return;
            }

            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
            con.setAutoCommit(false);

            // Debug: Verify the record exists
            String debugQuery = "SELECT * FROM description WHERE lead_id = ? AND company_id = ? AND sr_no = ?";
            psDebug = con.prepareStatement(debugQuery);
            psDebug.setInt(1, leadId);
            psDebug.setInt(2, companyId);
            psDebug.setInt(3, srNo);
            rs = psDebug.executeQuery();
            System.out.println("Debug query executed for leadId: " + leadId + ", companyId: " + companyId + ", srNo: " + srNo);
            if (!rs.next()) {
                System.out.println("No matching record found in debug query");
                out.println("{\"success\":false, \"message\":\"No record found with leadId: " + leadId + ", companyId: " + companyId + ", srNo: " + srNo + "\"}");
                con.rollback();
                return;
            }
            rs.close();
            psDebug.close();

            // 3. Delete the specific record
            String deleteQuery = "DELETE FROM description WHERE lead_id = ? AND company_id = ? AND sr_no = ?";
            psDelete = con.prepareStatement(deleteQuery);
            psDelete.setInt(1, leadId);
            psDelete.setInt(2, companyId);
            psDelete.setInt(3, srNo);
            int rowsDeleted = psDelete.executeUpdate();
            System.out.println("Deleted rows: " + rowsDeleted + " for leadId=" + leadId + ", companyId=" + companyId + ", srNo=" + srNo);

            if (rowsDeleted == 0) {
                out.println("{\"success\":false, \"message\":\"Deletion failed for leadId: " + leadId + ", companyId: " + companyId + ", srNo: " + srNo + "\"}");
                con.rollback();
                return;
            }

            // 4. Update the sequence for remaining records
            String updateQuery = "UPDATE description SET sr_no = sr_no - 1 WHERE lead_id = ? AND company_id = ? AND sr_no > ?";
            psUpdate = con.prepareStatement(updateQuery);
            psUpdate.setInt(1, leadId);
            psUpdate.setInt(2, companyId);
            psUpdate.setInt(3, srNo);
            int rowsUpdated = psUpdate.executeUpdate();
            System.out.println("Updated rows: " + rowsUpdated + " for leadId=" + leadId + ", companyId=" + companyId);

            con.commit();
            out.println("{\"success\":true, \"message\":\"Record deleted and sequence updated\"}");
        } catch (ClassNotFoundException e) {
            out.println("{\"success\":false, \"message\":\"JDBC Driver not found: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } catch (SQLException e) {
            out.println("{\"success\":false, \"message\":\"Database error: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } catch (NumberFormatException e) {
            out.println("{\"success\":false, \"message\":\"Invalid parameters: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            out.println("{\"success\":false, \"message\":\"Unexpected error: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (psCheck != null) psCheck.close();
                if (psDelete != null) psDelete.close();
                if (psUpdate != null) psUpdate.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}