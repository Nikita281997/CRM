package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

public class Insert_tester extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PreparedStatement ps = null;
        PreparedStatement ps1 = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

            // Fetch data from "project" table where percent = 100
            ps = con.prepareStatement("SELECT lead_id, project_name, due_date, customer_name FROM project WHERE percent = 100");
            rs = ps.executeQuery();

            // Insert data into "testertable"
            ps1 = con.prepareStatement("INSERT INTO testertable (lead_id, project_name, due_date, customer_name, approved) VALUES (?, ?, ?, ?, 1)");

            while (rs.next()) {
                ps1.setInt(1, rs.getInt("lead_id"));
                ps1.setString(2, rs.getString("project_name"));
                ps1.setDate(3, rs.getDate("due_date"));
                ps1.setString(4, rs.getString("customer_name"));
                ps1.executeUpdate();
            }

            // Redirect to projects.jsp after insertion
            response.sendRedirect("projects.jsp");
            
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('Error: " + e.getMessage() + "'); window.location.href='projects.jsp';</script>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (ps1 != null) ps1.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
