package com.email;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

//@WebServlet("/softDeleteQuoteServlet")
public class softDeleteQuoteServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String quoteId = request.getParameter("quoteId");

        if (quoteId == null || quoteId.isEmpty()) {
            response.getWriter().write("Error: No Quote ID provided!");
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
            
            
            String sql = "UPDATE quotation SET yesno_status = 'no' WHERE quote_id = ? AND company_id = ?";
            stmt = con.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(quoteId));
            stmt.setInt(2, companyId);
            stmt.executeUpdate();
            
            response.getWriter().write("Quote deleted successfully");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error deleting quote");
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