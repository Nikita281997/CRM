package com.email;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

public class EditinternServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get form data
        int empid = Integer.parseInt(request.getParameter("empid"));
        String empName = request.getParameter("emp_name");
        String projectName = request.getParameter("project_name");
        String position = request.getParameter("position");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        // Get company_id from session
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

        // If company_id is null, redirect to login page
        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        Connection connection = null;
        PreparedStatement stmt = null;
        PreparedStatement checkEmailStmt = null;
        PreparedStatement checkPhoneStmt = null;
        ResultSet emailRs = null;
        ResultSet phoneRs = null;

        try {
            // Load database driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Establish connection
          //  "jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI"
            String url = "jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb";
            String dbUsername = "atharva";
            String dbPassword = "AVNS_SFoivcl39tz_B7wqssI";
            connection = DriverManager.getConnection(url, dbUsername, dbPassword);

            // Check if email already exists for another employee in the same company
            String emailCheckQuery = "SELECT empid FROM interns WHERE email = ? AND company_id = ? AND empid != ?";
            checkEmailStmt = connection.prepareStatement(emailCheckQuery);
            checkEmailStmt.setString(1, email);
            checkEmailStmt.setInt(2, companyId);
            checkEmailStmt.setInt(3, empid);
            emailRs = checkEmailStmt.executeQuery();

            if (emailRs.next()) {
                session.setAttribute("popupMessage", "Email already exists for another employee in your company");
                session.setAttribute("popupType", "error");
                response.sendRedirect("addDashemp.jsp");
                return;
            }

            // Check if phone already exists for another employee in the same company
            String phoneCheckQuery = "SELECT empid FROM interns WHERE contact = ? AND company_id = ? AND empid != ?";
            checkPhoneStmt = connection.prepareStatement(phoneCheckQuery);
            checkPhoneStmt.setString(1, phone);
            checkPhoneStmt.setInt(2, companyId);
            checkPhoneStmt.setInt(3, empid);
            phoneRs = checkPhoneStmt.executeQuery();

            if (phoneRs.next()) {
                session.setAttribute("popupMessage", "Phone number already exists for another employee in your company");
                session.setAttribute("popupType", "error");
                response.sendRedirect("addDashemp.jsp");
                return;
            }

            // Update query
            String updateQuery = "UPDATE interns SET emp_name = ?, project_name = ?, position = ?, email = ?, contact = ?, address = ? WHERE empid = ? AND company_id = ?";
            stmt = connection.prepareStatement(updateQuery);
            stmt.setString(1, empName);
            stmt.setString(2, projectName);
            stmt.setString(3, position);
            stmt.setString(4, email);
            stmt.setString(5, phone);
            stmt.setString(6, address);
            stmt.setInt(7, empid);
            stmt.setInt(8, companyId);

            int rowsUpdated = stmt.executeUpdate();

            if (rowsUpdated > 0) {
                session.setAttribute("popupMessage", "Employee updated successfully!");
                session.setAttribute("popupType", "success");
                response.sendRedirect("addDashemp.jsp");
            } else {
                session.setAttribute("popupMessage", "Failed to update employee");
                session.setAttribute("popupType", "error");
                response.sendRedirect("addDashemp.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("popupMessage", "Error updating employee: " + e.getMessage());
            session.setAttribute("popupType", "error");
            response.sendRedirect("addDashemp.jsp");
        } finally {
            try {
                if (emailRs != null) emailRs.close();
                if (phoneRs != null) phoneRs.close();
                if (checkEmailStmt != null) checkEmailStmt.close();
                if (checkPhoneStmt != null) checkPhoneStmt.close();
                if (stmt != null) stmt.close();
                if (connection != null) connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}