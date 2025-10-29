package com.email;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

//@WebServlet("/ChangePasswordServlet")
public class ChangePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        try {
            // Get parameters from request
            String companyIdStr = request.getParameter("company_id");
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
            
            // Validate inputs
            if (companyIdStr == null || companyIdStr.trim().isEmpty() || 
                oldPassword == null || oldPassword.trim().isEmpty() || 
                newPassword == null || newPassword.trim().isEmpty() ||
                confirmPassword == null || confirmPassword.trim().isEmpty()) {
                
                jsonResponse.put("success", false);
                jsonResponse.put("message", "All fields are required");
                out.print(jsonResponse.toString());
                return;
            }
            
            // Additional validation
            if (!newPassword.equals(confirmPassword)) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "New password and confirm password do not match");
                out.print(jsonResponse.toString());
                return;
            }
            
            if (newPassword.length() < 6) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Password must be at least 6 characters");
                out.print(jsonResponse.toString());
                return;
            }
            
            if (newPassword.equals(oldPassword)) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "New password must be different from old password");
                out.print(jsonResponse.toString());
                return;
            }
            
            int companyId = Integer.parseInt(companyIdStr);
            
            // Load JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Database connection
            try (Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI")) {
                
                // Verify old password
                String checkQuery = "SELECT password FROM company_registration1 WHERE company_id = ?";
                try (PreparedStatement checkStmt = con.prepareStatement(checkQuery)) {
                    checkStmt.setInt(1, companyId);
                    
                    ResultSet rs = checkStmt.executeQuery();
                    if (rs.next()) {
                        String currentDbPassword = rs.getString("password");
                        
                        if (!currentDbPassword.equals(oldPassword)) {
                            jsonResponse.put("success", false);
                            jsonResponse.put("message", "Old password is incorrect");
                            out.print(jsonResponse.toString());
                            return;
                        }
                    } else {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "Company not found");
                        out.print(jsonResponse.toString());
                        return;
                    }
                }
                
                // Update password
                String updateQuery = "UPDATE company_registration1 SET password = ? WHERE company_id = ?";
                try (PreparedStatement updateStmt = con.prepareStatement(updateQuery)) {
                    updateStmt.setString(1, newPassword);
                    updateStmt.setInt(2, companyId);
                    
                    int rowsAffected = updateStmt.executeUpdate();
                    jsonResponse.put("success", rowsAffected > 0);
                    jsonResponse.put("message", rowsAffected > 0 ? "Password changed successfully" : "Failed to update password");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "An error occurred: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }
}