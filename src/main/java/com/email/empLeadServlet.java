package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.http.HttpSession;

public class empLeadServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int companyId = Integer.parseInt(request.getParameter("company_id"));
        int empId = Integer.parseInt(request.getParameter("emp_id"));
        String projectName = request.getParameter("project_name");
        String firm = request.getParameter("firm");
        String inDate = request.getParameter("in_date");
        String customerName = request.getParameter("customer_name");
        String email = request.getParameter("email");
        String contact = request.getParameter("contact");
        String address = request.getParameter("address");
        String org = request.getParameter("org");

        String empName = null; // Variable to store emp_name

        try {
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);

            // Fetch emp_name from emp table using emp_id
            PreparedStatement ps1 = con.prepareStatement("SELECT emp_name FROM emp WHERE unique_id = ?");
            ps1.setInt(1, empId);
            ResultSet rs1 = ps1.executeQuery();
            
            if (rs1.next()) {
                empName = rs1.getString("emp_name");
            } else {
                response.getWriter().print("Error: Employee not found!");
                return;
            }

            // Generate next lead_id based on existing sequence
            PreparedStatement psMax = con.prepareStatement("SELECT MAX(lead_id) AS max_lead FROM leads WHERE company_id = ?");
            psMax.setInt(1, companyId);
            ResultSet rsMax = psMax.executeQuery();
            int newLeadId = 1;
            if (rsMax.next()) {
                int maxLeadId = rsMax.getInt("max_lead");
                if (!rsMax.wasNull()) {
                    newLeadId = maxLeadId + 1;
                }
            }
            rsMax.close();
            psMax.close();

            // Insert data into leads table including emp_name and generated lead_id
            PreparedStatement ps2 = con.prepareStatement("INSERT INTO leads (lead_id, company_id, unique_id, emp_name, project_name, firm, in_date, customer_name, email, contact, address, org) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            ps2.setInt(1, newLeadId);
            ps2.setInt(2, companyId);
            ps2.setInt(3, empId);
            ps2.setString(4, empName);
            ps2.setString(5, projectName);
            ps2.setString(6, firm);
            ps2.setString(7, inDate);
            ps2.setString(8, customerName);
            ps2.setString(9, email);
            ps2.setString(10, contact);
            ps2.setString(11, address);
            ps2.setString(12, org);
            ps2.executeUpdate();

            HttpSession sessionVar = request.getSession();
            sessionVar.setAttribute("popupMessage", "Lead added successfully!");
            sessionVar.setAttribute("popupType", "success");
            response.sendRedirect("empdashboared.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession sessionVar = request.getSession();
            sessionVar.setAttribute("popupMessage", "Failed to add lead: " + e.getMessage());
            sessionVar.setAttribute("popupType", "error");
            response.sendRedirect("empdashboared.jsp");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            int leadId = Integer.parseInt(request.getParameter("lead_id"));

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crmpro2", "root", "pass@123");
                PreparedStatement ps = con.prepareStatement("DELETE FROM leads WHERE lead_id = ?");
                ps.setInt(1, leadId);
                ps.executeUpdate();

                HttpSession sessionVar = request.getSession();
                sessionVar.setAttribute("popupMessage", "Lead deleted successfully!");
                sessionVar.setAttribute("popupType", "success");
                response.sendRedirect("empdashboared.jsp");
            } catch (Exception e) {
                e.printStackTrace();
                HttpSession sessionVar = request.getSession();
                sessionVar.setAttribute("popupMessage", "Error deleting lead: " + e.getMessage());
                sessionVar.setAttribute("popupType", "error");
                response.sendRedirect("empdashboared.jsp");
            }
        }
    }
}