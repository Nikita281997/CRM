package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.regex.Pattern;

//@WebServlet("/addinternservlet")
public class addinternservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String emp_name = request.getParameter("emp_name");
        String project_name = request.getParameter("project_name");
        String position = request.getParameter("position");
        String email = request.getParameter("email");
        String contact = request.getParameter("phone");
        String address = request.getParameter("address");
        
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
        // Validate email format using regex
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        boolean isValidEmail = Pattern.matches(emailRegex, email);
        if (!isValidEmail) {
            sessionVar.setAttribute("popupMessage", "Invalid Email Format!");
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("addDashemp.jsp");
            return;
        }
        
        Connection con = null;
        PreparedStatement psCheck = null;
        PreparedStatement psInsert = null;
        ResultSet rsCheck = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
            
            // Check for existing email or contact in the same company
            String checkQuery = "SELECT COUNT(*) FROM interns WHERE (email = ? OR contact = ?) AND company_id = ?";
            psCheck = con.prepareStatement(checkQuery);
            psCheck.setString(1, email);
            psCheck.setString(2, contact);
            psCheck.setInt(3, companyId);
            
            rsCheck = psCheck.executeQuery();
            
            if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                // Duplicate found, set error popup
                sessionVar.setAttribute("popupMessage", "Employee with this email or contact already exists!");
                sessionVar.setAttribute("popupType", "error");
                response.sendRedirect("addDashemp.jsp");
                return;
            }
            
            // Prepare insert statement
            String insertQuery = "INSERT INTO interns(emp_name, project_name, position, email, contact, address, company_id) " +
                                 "VALUES(?, ?, ?, ?, ?, ?, ?)";
            psInsert = con.prepareStatement(insertQuery);
            
            psInsert.setString(1, emp_name);
            // If project_name is empty, set it to null in database
            if (project_name == null || project_name.trim().isEmpty()) {
                psInsert.setNull(2, java.sql.Types.VARCHAR);
            } else {
                psInsert.setString(2, project_name);
            }
            psInsert.setString(3, position);
            psInsert.setString(4, email);
            psInsert.setString(5, contact);
            psInsert.setString(6, address);
            psInsert.setInt(7, companyId);
            
            int count = psInsert.executeUpdate();
            if (count >= 1) {
                sessionVar.setAttribute("popupMessage", "Employee added successfully!");
                sessionVar.setAttribute("popupType", "success");
                response.sendRedirect("addDashemp.jsp");
            } else {
                sessionVar.setAttribute("popupMessage", "Failed to add employee");
                sessionVar.setAttribute("popupType", "error");
                response.sendRedirect("addDashemp.jsp");
            }
            
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            sessionVar.setAttribute("popupMessage", "Database error");
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("addDashemp.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            sessionVar.setAttribute("popupMessage", "Database error: " + e.getMessage());
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("addDashemp.jsp");
        } finally {
            // Close resources
            try { if (rsCheck != null) rsCheck.close(); } catch (Exception e) {}
            try { if (psCheck != null) psCheck.close(); } catch (Exception e) {}
            try { if (psInsert != null) psInsert.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}