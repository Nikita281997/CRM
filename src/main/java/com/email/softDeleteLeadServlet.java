package com.email;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

//@WebServlet("/softDeleteLeadServlet")
public class softDeleteLeadServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String leadId = request.getParameter("leadid");

        if (leadId == null || leadId.isEmpty()) {
            response.getWriter().write("Error: No Lead ID provided!");
            return;
        }

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

        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        Connection con = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
            
            String sql = "UPDATE leads SET yesno_status = 'no', created_updated_at = CURRENT_TIMESTAMP WHERE lead_id = ? AND company_id = ?";
            stmt = con.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(leadId));
            stmt.setInt(2, companyId);
            stmt.executeUpdate();
            
            response.getWriter().write("Lead deleted successfully");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error deleting lead");
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