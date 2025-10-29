package com.email;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

public class DeleteIntegrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("text/html");

        // Retrieve integration ID and company ID from request/session
        String idStr = request.getParameter("id");
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id"); // Get company_id as String

        // Validate input
        if (idStr == null || companyIdStr == null) {
            response.getWriter().println("<script>alert('Error: Invalid request parameters!'); window.history.back();</script>");
            return;
        }

        int id, companyId;
        try {
            id = Integer.parseInt(idStr);
            companyId = Integer.parseInt(companyIdStr); // Convert company_id from String to Integer
        } catch (NumberFormatException e) {
            response.getWriter().println("<script>alert('Error: Invalid ID format!'); window.history.back();</script>");
            return;
        }

        // Database connection and deletion
        String sql = "DELETE FROM integrations WHERE id = ? AND company_id = ?";
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            stmt.setInt(2, companyId);
            int rowsDeleted = stmt.executeUpdate();

            if (rowsDeleted > 0) {
                response.sendRedirect("integration.jsp");
            } else {
                response.getWriter().println("<script>alert('Error: Integration not found or does not belong to your company!'); window.history.back();</script>");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('Error: Database operation failed!'); window.history.back();</script>");
        }
    }
}
