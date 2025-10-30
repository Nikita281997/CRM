package com.email;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class MoveTaskServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("text/html");

        // Retrieve session and company_id
        HttpSession sessionVar = request.getSession();
        String companyIdStr = (String) sessionVar.getAttribute("company_id");
        String uniqueId = (String) sessionVar.getAttribute("unique_id"); // Get unique_id from session

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

        // Retrieve parameters from the request
        String sourceParam = request.getParameter("source");
        String categoryParam = request.getParameter("category");
        String taskIdStr = request.getParameter("task_id");
        String referer = request.getHeader("referer"); // Get the referring page URL

        // Determine the redirect page based on the referer
        String redirectPage = "tasks.jsp"; // default
        if (referer != null) {
            if (referer.contains("leademptask.jsp")) {
                redirectPage = "leademptask.jsp";
            } else if (referer.contains("emptask.jsp")) {
                redirectPage = "emptask.jsp";
            } else if (referer.contains("tasks.jsp")) {
                redirectPage = "tasks.jsp";
            }
        }

        // Validate input parameters
        if (sourceParam == null || categoryParam == null || taskIdStr == null) {
            response.getWriter().println("<script>alert('Error: Missing required parameters!'); window.location='" + redirectPage + "';</script>");
            return;
        }

        int taskId;
        try {
            taskId = Integer.parseInt(taskIdStr);
        } catch (NumberFormatException e) {
            response.getWriter().println("<script>alert('Error: Invalid Task ID!'); window.location='" + redirectPage + "';</script>");
            return;
        }

        // Ensure correct table names
        String sourceTable = sourceParam + "_tasks";
        String destTable = categoryParam + "_tasks";

        Connection con = null;
        PreparedStatement pstCheck = null, pstMove = null, pstDelete = null;
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

            // Check if the task exists in the source table for the specific company
            String queryCheck = "SELECT * FROM " + sourceTable + " WHERE task_id = ? AND company_id = ?";
            pstCheck = con.prepareStatement(queryCheck);
            pstCheck.setInt(1, taskId);
            pstCheck.setInt(2, companyId);
            rs = pstCheck.executeQuery();

            if (rs.next()) {
                // Move the task to the destination table within the same company
                String queryMove = "INSERT INTO " + destTable + " (task_id, task_name, description, emp_name, dead_line, priority, unique_id, company_id) "
                                 + "SELECT task_id, task_name, description, emp_name, dead_line, priority, unique_id, company_id FROM " + sourceTable 
                                 + " WHERE task_id = ? AND company_id = ?";
                pstMove = con.prepareStatement(queryMove);
                pstMove.setInt(1, taskId);
                pstMove.setInt(2, companyId);
                pstMove.executeUpdate();

                // Delete the task from the source table after moving
                String queryDelete = "DELETE FROM " + sourceTable + " WHERE task_id = ? AND company_id = ?";
                pstDelete = con.prepareStatement(queryDelete);
                pstDelete.setInt(1, taskId);
                pstDelete.setInt(2, companyId);
                pstDelete.executeUpdate();

                // Redirect to the appropriate page
                response.sendRedirect(redirectPage);
            } else {
                response.getWriter().println("<script>alert('Error: Task not found in the source table!'); window.location='" + redirectPage + "';</script>");
            }
        } catch (ClassNotFoundException e) {
            response.getWriter().println("<script>alert('Error: Database driver not found!'); window.location='" + redirectPage + "';</script>");
            e.printStackTrace();
        } catch (SQLException e) {
            response.getWriter().println("<script>alert('Error: Database operation failed!'); window.location='" + redirectPage + "';</script>");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstCheck != null) pstCheck.close();
                if (pstMove != null) pstMove.close();
                if (pstDelete != null) pstDelete.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
