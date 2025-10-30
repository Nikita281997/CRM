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
import jakarta.servlet.http.HttpSession;


public class UpdateInstallmentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");

        // ✅ Get session variable for company_id
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

        // ✅ Redirect to login if company_id is missing
        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        // ✅ Get the lead ID from the request
        String leadId = request.getParameter("lead_id");

        if (leadId == null || leadId.isEmpty()) {
            response.getWriter().println("<script>alert('Error: Lead ID is required!'); window.location.href='waiting.jsp';</script>");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;

        try {
             
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
            // ✅ SQL query to update installment only if company_id matches
            String query = "UPDATE financemanagement SET installment1 = 0 WHERE lead_id = ? AND company_id = ?";
            ps = con.prepareStatement(query);
            ps.setInt(1, Integer.parseInt(leadId));
            ps.setInt(2, companyId);

            int rowsUpdated = ps.executeUpdate();

            if (rowsUpdated > 0) {
                System.out.println("✅ Installment updated successfully!");
            } else {
                response.getWriter().println("<script>alert('Error: No matching record found for the given Lead ID and Company ID.'); window.location.href='waiting.jsp';</script>");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('Error: Database operation failed!'); window.location.href='waiting.jsp';</script>");
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
        }

        response.sendRedirect("waiting.jsp"); // ✅ Redirect to the JSP page
    }
}
