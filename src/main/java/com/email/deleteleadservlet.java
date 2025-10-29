package com.email;

import java.io.IOException;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/deleteleadservlet")
public class deleteleadservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String leadId = request.getParameter("leadid");

        if (leadId == null || leadId.isEmpty()) {
            response.getWriter().write("Error: No Lead ID provided!");
            return;
        }

        // Retrieve company_id from session
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

        // If company_id is null, redirect to login page
        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        Connection con = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Disable foreign key checks
            Statement disableFK = con.createStatement();
            disableFK.execute("SET FOREIGN_KEY_CHECKS=0");

            // Delete related data ONLY for the given company_id
            String[] tables = {"leadscontact", "financemanagement", "connected", "proposalsent", "qualified", 
                               "quotation", "project", "leads", "testertable"};
            for (String table : tables) {
                String sql = "DELETE FROM " + table + " WHERE lead_id = ? AND company_id = ?";
                stmt = con.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(leadId));
                stmt.setInt(2, companyId);
                stmt.executeUpdate();
            }

            // Reset AUTO_INCREMENT for leads and quotation tables if they are empty
            Statement resetAutoIncrement = con.createStatement();
            resetAutoIncrement.executeUpdate("ALTER TABLE quotation AUTO_INCREMENT = 1");
            resetAutoIncrement.executeUpdate("ALTER TABLE leads AUTO_INCREMENT = 1");
            resetAutoIncrement.close();

            // Enable foreign key checks
            Statement enableFK = con.createStatement();
            enableFK.execute("SET FOREIGN_KEY_CHECKS=1");

            response.getWriter().write("Lead deleted successfully");

        } catch (ClassNotFoundException e) {
            response.getWriter().write("Error: Unable to load database driver!");
            e.printStackTrace();
        } catch (SQLException e) {
            response.getWriter().write("Error: Database operation failed!");
            e.printStackTrace();
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}