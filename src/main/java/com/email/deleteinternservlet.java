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

//@WebServlet("/deleteinternservlet")
public class deleteinternservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // Retrieve parameters
        String empIdStr = request.getParameter("empid");

        // Get company_id from session
        HttpSession session = request.getSession(false);
        String companyIdStr = (String) session.getAttribute("company_id");
        Integer companyId = null;

        // Validate session and company_id
        if (session == null || companyIdStr == null) {
            session.setAttribute("popupMessage", "Session expired. Please log in again.");
            session.setAttribute("popupType", "error");
            response.sendRedirect("login1.jsp");
            return;
        }

        try {
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            session.setAttribute("popupMessage", "Invalid company ID!");
            session.setAttribute("popupType", "error");
            response.sendRedirect("addDashemp.jsp");
            return;
        }

        // Validate inputs
        if (empIdStr == null || empIdStr.isEmpty()) {
            session.setAttribute("popupMessage", "Missing Employee ID!");
            session.setAttribute("popupType", "error");
            response.sendRedirect("addDashemp.jsp");
            return;
        }

        int empId;
        try {
            empId = Integer.parseInt(empIdStr);
        } catch (NumberFormatException e) {
            session.setAttribute("popupMessage", "Invalid Employee ID!");
            session.setAttribute("popupType", "error");
            response.sendRedirect("addDashemp.jsp");
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
            String checkSql = "SELECT COUNT(*) FROM interns WHERE empid = ? AND company_id = ?";
            stmt = con.prepareStatement(checkSql);
            stmt.setInt(1, empId);
            stmt.setInt(2, companyId);
            rs = stmt.executeQuery();

            if (rs.next() && rs.getInt(1) == 0) {
                session.setAttribute("popupMessage", "Employee not found or does not belong to the company!");
                session.setAttribute("popupType", "error");
                response.sendRedirect("addDashemp.jsp");
                return;
            }

            // Close previous statement
            rs.close();
            stmt.close();

            // Delete the employee record
            String deleteSql = "DELETE FROM interns WHERE empid = ? AND company_id = ?";
            stmt = con.prepareStatement(deleteSql);
            stmt.setInt(1, empId);
            stmt.setInt(2, companyId);
            int rowsDeleted = stmt.executeUpdate();
            stmt.close();

            if (rowsDeleted > 0) {
                // Check if the table is empty
                String countSql = "SELECT COUNT(*) FROM interns";
                stmt = con.prepareStatement(countSql);
                rs = stmt.executeQuery();

                if (rs.next() && rs.getInt(1) == 0) {
                    // Reset auto-increment value
                    stmt.close();
                    stmt = con.prepareStatement("ALTER TABLE interns AUTO_INCREMENT = 1");
                    stmt.execute();
                }

                session.setAttribute("popupMessage", "Employee removed successfully!");
                session.setAttribute("popupType", "success");
                response.sendRedirect("addDashemp.jsp");
            } else {
                session.setAttribute("popupMessage", "Deletion failed!");
                session.setAttribute("popupType", "error");
                response.sendRedirect("addDashemp.jsp");
            }

        } catch (ClassNotFoundException e) {
            session.setAttribute("popupMessage", "Unable to load database driver!");
            session.setAttribute("popupType", "error");
            response.sendRedirect("addDashemp.jsp");
            e.printStackTrace();
        } catch (SQLException e) {
            session.setAttribute("popupMessage", "Database operation failed: " + e.getMessage());
            session.setAttribute("popupType", "error");
            response.sendRedirect("addDashemp.jsp");
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