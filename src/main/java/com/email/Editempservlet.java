package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//@WebServlet("/Editempservlet")
public class Editempservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get parameters from the request
        int empId = Integer.parseInt(request.getParameter("leadid"));
        String empName = request.getParameter("proname");
        String email = request.getParameter("firmname");
        String phone = request.getParameter("phone"); // Fixed parameter name from 'indate' to 'phone'
        String department = request.getParameter("customer");
        String position = request.getParameter("email");
        String salaryStr = request.getParameter("sal");
        
        // Remove commas from salary
        salaryStr = salaryStr.replaceAll(",", "");

        // Convert salary to decimal
        double salary = 0.0;
        try {
            salary = Double.parseDouble(salaryStr);
        } catch (NumberFormatException e) {
            // Handle invalid salary format
            response.sendRedirect("emp.jsp?errorMessage=Invalid salary format");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
            
            // Prepare SQL statement to update employee
            String sql = "UPDATE emp SET emp_name=?, email=?, phone=?, department=?, position=?, salary=? WHERE emp_id=?";
            ps = con.prepareStatement(sql);
            
            // Set parameters
            ps.setString(1, empName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, department);
            ps.setString(5, position);
            ps.setDouble(6, salary);
            ps.setInt(7, empId);
            
            // Execute update
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                // Success - redirect back to employees page
                response.sendRedirect("emp.jsp?successMessage=Employee updated successfully");
            } else {
                // No rows affected - employee not found
                response.sendRedirect("emp.jsp?errorMessage=Employee not found");
            }
            
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            // Handle database errors
            response.sendRedirect("emp.jsp?errorMessage=Database error: " + e.getMessage());
        } finally {
            // Close resources
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}