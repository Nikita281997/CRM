package com.email;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

//@WebServlet("/deleteempservlet")
public class deleteempservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // Retrieve parameters - fix parameter name to match what's passed from JSP
        String empIdStr = request.getParameter("leadid"); // Changed from "empid" to "leadid"
        
        // Get company ID from session instead of request parameter
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id");

        System.out.println("Received empid: " + empIdStr + ", companyid: " + companyIdStr); // Debugging log

        // Validate inputs
        if (empIdStr == null || empIdStr.isEmpty() || companyIdStr == null || companyIdStr.isEmpty()) {
            String errorMessage = "Error: Missing Employee ID or Company ID!";
            response.sendRedirect("emp.jsp?errorMessage=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));
            return;
        }

        int empId, companyId;
        try {
            empId = Integer.parseInt(empIdStr);
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            String errorMessage = "Error: Invalid Employee ID or Company ID!";
            response.sendRedirect("emp.jsp?errorMessage=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));
            return;
        }

        Connection con = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
           
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

            // Check if the employee exists and belongs to the company
            String checkSql = "SELECT COUNT(*) FROM emp WHERE emp_id = ? AND company_id = ?";
            stmt = con.prepareStatement(checkSql);
            stmt.setInt(1, empId);
            stmt.setInt(2, companyId);
            rs = stmt.executeQuery();

            if (rs.next() && rs.getInt(1) == 0) {
                String errorMessage = "Error: Employee not found or does not belong to the company!";
                response.sendRedirect("emp.jsp?errorMessage=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));
                return;
            }

            // Close previous statement
            rs.close();
            stmt.close();

            // Delete the employee record
            String deleteSql = "DELETE FROM emp WHERE emp_id = ? AND company_id = ?";
            stmt = con.prepareStatement(deleteSql);
            stmt.setInt(1, empId);
            stmt.setInt(2, companyId);
            int rowsDeleted = stmt.executeUpdate();
            stmt.close();

            if (rowsDeleted > 0) {
                System.out.println("Employee with ID " + empId + " deleted successfully.");

                // Check if the table is empty
                String countSql = "SELECT COUNT(*) FROM emp";
                stmt = con.prepareStatement(countSql);
                rs = stmt.executeQuery();

                if (rs.next() && rs.getInt(1) == 0) {
                    System.out.println("No employees left. Resetting auto-increment.");
                    
                    // Reset auto-increment value properly
                    stmt.close();
                    stmt = con.prepareStatement("ALTER TABLE emp AUTO_INCREMENT = 1");
                    stmt.execute();
                }

                response.sendRedirect("emp.jsp?successMessage=Employee+removed+successfully!");
            } else {
                String errorMessage = "Error: Deletion failed!";
                response.sendRedirect("emp.jsp?errorMessage=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));
            }

        } catch (ClassNotFoundException e) {
            String errorMessage = "Error: Unable to load database driver!";
            response.sendRedirect("emp.jsp?errorMessage=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));
            e.printStackTrace();
        } catch (SQLException e) {
            String errorMessage = "Error: Database operation failed!";
            response.sendRedirect("emp.jsp?errorMessage=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}