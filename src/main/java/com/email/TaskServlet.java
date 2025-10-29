package com.email;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import java.util.UUID;

public class TaskServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        
        // Get company_id from session
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id");
        if (companyIdStr == null) {
            response.sendRedirect("login1.jsp");
            return;
        }
        int companyId = Integer.parseInt(companyIdStr);

        // Get form parameters
        String taskName = request.getParameter("task_name");
      //  String createdBy = request.getParameter("employee_name");
        String empUniqueId = request.getParameter("emp_unique_id");
        String description = request.getParameter("description");
        String deadLine = request.getParameter("dead_line");
        String priority = request.getParameter("priority");
        String taskUniqueId = "TASK-" + UUID.randomUUID().toString();

        // Validate all required fields
        if (taskName == null || taskName.trim().isEmpty() || 
           // createdBy == null || createdBy.trim().isEmpty() ||
            empUniqueId == null || empUniqueId.trim().isEmpty() ||
            description == null || description.trim().isEmpty() ||
            deadLine == null || deadLine.trim().isEmpty() ||
            priority == null || priority.trim().isEmpty()) {
            
            response.getWriter().println("<script>alert('All fields are required!'); window.history.back();</script>");
            return;
        }

        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
            
            // First, get the employee details
            String empQuery = "SELECT emp_name, unique_id FROM emp WHERE unique_id = ? AND company_id = ?";
            pst = con.prepareStatement(empQuery);
            pst.setString(1, empUniqueId);
            pst.setInt(2, companyId);
            rs = pst.executeQuery();
            
            if (rs.next()) {
                String empName = rs.getString("emp_name");
                String employeeUniqueId = rs.getString("unique_id");
                
                // Now insert the task
                String insertQuery = "INSERT INTO open_tasks (task_name, description,  emp_name, dead_line, priority,  company_id, unique_id) " +
                                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
                
                pst = con.prepareStatement(insertQuery);
                pst.setString(1, taskName.trim());
                pst.setString(2, description.trim());
               // pst.setString(3, createdBy.trim());
                pst.setString(3, empName);
                pst.setString(4, deadLine);
                pst.setString(5, priority);
              
                pst.setInt(6, companyId);
                pst.setString(7, employeeUniqueId);
                
                int rowsAffected = pst.executeUpdate();
                
                if (rowsAffected > 0) {
                    response.sendRedirect("tasks.jsp?success=Task+created+successfully");
                } else {
                    response.getWriter().println("<script>alert('Failed to create task'); window.history.back();</script>");
                }
            } else {
                response.getWriter().println("<script>alert('Employee not found'); window.history.back();</script>");
            }
        } catch (Exception e) {
            response.getWriter().println("<script>alert('Error: " + e.getMessage().replace("'", "\\'") + "'); window.history.back();</script>");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pst != null) pst.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}	