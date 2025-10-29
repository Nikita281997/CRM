package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/addtaskservlet")
public class addtaskservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String taskTitle = request.getParameter("taskTitle");
        String taskInfo = request.getParameter("taskInfo");
        // String dueDate = request.getParameter("date");
        String empname = request.getParameter("name");

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            // Database connection details
            Class.forName("com.mysql.cj.jdbc.Driver");
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;

            conn = DriverManager.getConnection(url, user, pass);
            // Load MySQL driver

            // Establish connection

            // SQL insert query
            String sql = "INSERT INTO open_tasks (task_name, description,employee_name) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);

            // Set parameters
            pstmt.setString(1, taskTitle);
            pstmt.setString(2, taskInfo);
            pstmt.setString(3, empname);

            // Execute query
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                response.getWriter().println(
                        "<script type='text/javascript'>"
                                + "alert('Task added successfully!');" + "window.location.href = 'tasks.jsp';"
                                + "</script>");
            } else {
                response.getWriter().println("Failed to add task.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        } finally {
            try {
                if (pstmt != null)
                    pstmt.close();
                if (conn != null)
                    conn.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}
