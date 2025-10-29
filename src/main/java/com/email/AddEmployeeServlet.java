package com.email;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

public class AddEmployeeServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Retrieve form data
        String empName = request.getParameter("proname");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String department = request.getParameter("dept");
        String position = request.getParameter("position").toLowerCase(); // Convert to lowercase to avoid case mismatch
        String salaryStr = request.getParameter("sal");
        // Remove commas from salary
        salaryStr = salaryStr.replaceAll(",", "");

        // Get company_id from session
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

        // If company_id is null, redirect to login page
        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        // JDBC setup to insert the data into the database
        Connection connection = null;
        PreparedStatement stmt = null;
        PreparedStatement checkStmt = null;
        PreparedStatement sizeStmt = null;
        PreparedStatement emailCheckStmt = null;
        PreparedStatement phoneCheckStmt = null;
        ResultSet resultSet = null;
        ResultSet sizeResultSet = null;
        ResultSet emailResultSet = null;
        ResultSet phoneResultSet = null;

        try {
            // Load database driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Establish connection to the database
            String url = "jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb";
            String dbUsername = "atharva";
            String dbPassword = "AVNS_SFoivcl39tz_B7wqssI";
            connection = DriverManager.getConnection(url, dbUsername, dbPassword);

            // Check if email already exists in the same company
            String emailCheckQuery = "SELECT COUNT(*) FROM emp WHERE company_id = ? AND email = ?";
            emailCheckStmt = connection.prepareStatement(emailCheckQuery);
            emailCheckStmt.setInt(1, companyId);
            emailCheckStmt.setString(2, email);
            emailResultSet = emailCheckStmt.executeQuery();
            if (emailResultSet.next() && emailResultSet.getInt(1) > 0) {
                response.sendRedirect("emp.jsp?errorMessage=Email already exists in your company. Please use a different email.");
                return;
            }

            // Check if phone number already exists in the same company
            String phoneCheckQuery = "SELECT COUNT(*) FROM emp WHERE company_id = ? AND phone = ?";
            phoneCheckStmt = connection.prepareStatement(phoneCheckQuery);
            phoneCheckStmt.setInt(1, companyId);
            phoneCheckStmt.setString(2, phone);
            phoneResultSet = phoneCheckStmt.executeQuery();
            if (phoneResultSet.next() && phoneResultSet.getInt(1) > 0) {
                response.sendRedirect("emp.jsp?errorMessage=Phone number already exists in your company. Please use a different phone number.");
                return;
            }

            // Check if the position is "Team Lead" or "Project Manager"
            if (position.equalsIgnoreCase("team lead") || position.equalsIgnoreCase("project manager")) {
                String checkQuery = "SELECT COUNT(*) FROM emp WHERE company_id = ? AND position = ?";
                checkStmt = connection.prepareStatement(checkQuery);
                checkStmt.setInt(1, companyId);
                checkStmt.setString(2, position);
                resultSet = checkStmt.executeQuery();
                if (resultSet.next() && resultSet.getInt(1) >= 1) {
                    response.sendRedirect("emp.jsp?errorMessage=Each company can have only one " + position + ".");
                    return;
                }
            }

            // Check company size and employee count
            String sizeQuery = "SELECT company_size FROM company_registration1 WHERE company_id = ?";
            sizeStmt = connection.prepareStatement(sizeQuery);
            sizeStmt.setInt(1, companyId);
            sizeResultSet = sizeStmt.executeQuery();
            if (sizeResultSet.next()) {
                int companySize = sizeResultSet.getInt("company_size");
                String countQuery = "SELECT COUNT(*) FROM emp WHERE company_id = ?";
                PreparedStatement countStmt = connection.prepareStatement(countQuery);
                countStmt.setInt(1, companyId);
                ResultSet countResultSet = countStmt.executeQuery();
                if (countResultSet.next()) {
                    int employeeCount = countResultSet.getInt(1);
                    if (employeeCount >= companySize) {
                        response.sendRedirect("emp.jsp?errorMessage=Employee limit exceeded. Cannot add more employees.");
                        return;
                    }
                }
            }

            // Generate 4-digit unique ID
            int uniqueId;
            PreparedStatement checkUniqueIdStmt = null;
            ResultSet checkUniqueIdResult = null;
            do {
                uniqueId = 1000 + (int)(Math.random() * 9000); // Generates 1000-9999
                String checkUniqueIdQuery = "SELECT COUNT(*) FROM emp WHERE company_id = ? AND unique_id = ?";
                checkUniqueIdStmt = connection.prepareStatement(checkUniqueIdQuery);
                checkUniqueIdStmt.setInt(1, companyId);
                checkUniqueIdStmt.setInt(2, uniqueId);
                checkUniqueIdResult = checkUniqueIdStmt.executeQuery();
                if (checkUniqueIdResult.next() && checkUniqueIdResult.getInt(1) == 0) {
                    break;
                }
            } while (true);
            if (checkUniqueIdStmt != null) checkUniqueIdStmt.close();
            if (checkUniqueIdResult != null) checkUniqueIdResult.close();

            // SQL query to insert data (including unique_id and company_id)
            String query = "INSERT INTO emp (emp_name, email, password, phone, department, position, salary, company_id, unique_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            stmt = connection.prepareStatement(query);
            stmt.setString(1, empName);
            stmt.setString(2, email);
            stmt.setString(3, password);
            stmt.setString(4, phone);
            stmt.setString(5, department);
            stmt.setString(6, position);
            stmt.setString(7, salaryStr);
            stmt.setInt(8, companyId);
            stmt.setInt(9, uniqueId);

            // Execute the update
            int result = stmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("emp.jsp");
            } else {
                response.sendRedirect("error.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            try {
                if (resultSet != null) resultSet.close();
                if (checkStmt != null) checkStmt.close();
                if (sizeResultSet != null) sizeResultSet.close();
                if (sizeStmt != null) sizeStmt.close();
                if (stmt != null) stmt.close();
                if (connection != null) connection.close();
                if (emailResultSet != null) emailResultSet.close();
                if (phoneResultSet != null) phoneResultSet.close();
                if (emailCheckStmt != null) emailCheckStmt.close();
                if (phoneCheckStmt != null) phoneCheckStmt.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
}