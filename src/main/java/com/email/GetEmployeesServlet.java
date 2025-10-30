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
import jakarta.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

//@WebServlet("/GetEmployeesServlet")
public class GetEmployeesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
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
        
        // If company_id is null, send empty response
        if (companyId == null) {
            response.getWriter().write("{}");
            return;
        }
        
        // Get project name from request if available
        String projectName = request.getParameter("projectName");
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        PrintWriter out = response.getWriter();
        JSONObject result = new JSONObject();
        JSONArray employeesWithProjects = new JSONArray();
        JSONArray employeesWithoutProjects = new JSONArray();
        
        try {
           String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
            
            // Employees WITH projects (either all or for specific project)
            String queryWithProjects;
            if (projectName != null && !projectName.isEmpty()) {
                queryWithProjects = "SELECT empid, emp_name, project_name FROM interns " +
                                   "WHERE project_name = ? AND company_id = ?";
                ps = con.prepareStatement(queryWithProjects);
                ps.setString(1, projectName);
                ps.setInt(2, companyId);
            } else {
                queryWithProjects = "SELECT empid, emp_name, project_name FROM interns " +
                                   "WHERE project_name IS NOT NULL AND company_id = ?";
                ps = con.prepareStatement(queryWithProjects);
                ps.setInt(1, companyId);
            }
            
            rs = ps.executeQuery();
            while (rs.next()) {
                JSONObject emp = new JSONObject();
                emp.put("id", rs.getInt("empid"));
                emp.put("name", rs.getString("emp_name"));
                emp.put("project", rs.getString("project_name"));
                employeesWithProjects.put(emp);
            }
            rs.close();
            ps.close();
            
            // Employees WITHOUT projects
            String queryWithoutProjects = "SELECT empid, emp_name FROM interns " +
                                         "WHERE (project_name IS NULL OR project_name = '') " +
                                         "AND company_id = ?";
            ps = con.prepareStatement(queryWithoutProjects);
            ps.setInt(1, companyId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                JSONObject emp = new JSONObject();
                emp.put("id", rs.getInt("empid"));
                emp.put("name", rs.getString("emp_name"));
                employeesWithoutProjects.put(emp);
            }
            
            result.put("withProjects", employeesWithProjects);
            result.put("withoutProjects", employeesWithoutProjects);
            
            out.print(result);
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(new JSONObject().put("error", "Failed to fetch employees"));
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}