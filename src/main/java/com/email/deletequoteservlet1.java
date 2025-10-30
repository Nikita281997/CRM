package com.email;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/deletequoteservlet1")
public class deletequoteservlet1 extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String quoteId = request.getParameter("quoteid");
        String action = request.getParameter("action");

        if (quoteId == null || quoteId.isEmpty() || action == null || action.isEmpty()) {
            response.getWriter().write("Error: Invalid parameters!");
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
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

            if ("softDelete".equals(action)) {
                // Soft delete: Set yesno_status to 'no'
                String sql = "UPDATE quotation SET yesno_status = 'no' WHERE quote_id = ? AND company_id = ?";
                stmt = con.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(quoteId));
                stmt.setInt(2, companyId);
                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                    response.getWriter().write("Quote soft deleted successfully");
                } else {
                    response.getWriter().write("Error: Quote not found or already deleted");
                }
            } else if ("permanentDelete".equals(action)) {
                // Permanent delete: Actually remove the quote
                String sql = "DELETE FROM quotation WHERE quote_id = ? AND company_id = ?";
                stmt = con.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(quoteId));
                stmt.setInt(2, companyId);
                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                    response.getWriter().write("Quote permanently deleted successfully");
                } else {
                    response.getWriter().write("Error: Quote not found");
                }
            } else if ("restore".equals(action)) {
                // Restore: Set yesno_status back to 'yes'
                String sql = "UPDATE quotation SET yesno_status = 'yes' WHERE quote_id = ? AND company_id = ?";
                stmt = con.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(quoteId));
                stmt.setInt(2, companyId);
                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                    response.getWriter().write("Quote restored successfully");
                } else {
                    response.getWriter().write("Error: Quote not found or already restored");
                }
            } else {
                response.getWriter().write("Error: Invalid action");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error performing action on quote");
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // For backward compatibility, redirect GET requests to POST
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}