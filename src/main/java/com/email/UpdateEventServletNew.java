package com.email;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.*;

//@WebServlet("/UpdateEventServletNew")
public class UpdateEventServletNew extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String companyIdStr = (String) session.getAttribute("company_id");
        Integer companyId = null;

        if (companyIdStr == null || companyIdStr.trim().isEmpty()) {
            response.getWriter().write("{\"success\": false, \"error\": \"Session expired\"}");
            return;
        }

        try {
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\": false, \"error\": \"Invalid company ID\"}");
            return;
        }

        String eventId = request.getParameter("event_id");
        String eventName = request.getParameter("event_name");
        String description = request.getParameter("description");
        String startDate = request.getParameter("start_date");
        String endDate = request.getParameter("end_date");
        String startTime = request.getParameter("start_time");
        String endTime = request.getParameter("end_time");
        String location = request.getParameter("location");

        if (eventId == null || eventId.trim().isEmpty()) {
            response.getWriter().write("{\"success\": false, \"error\": \"Event ID is required\"}");
            return;
        }

        Connection con = null;
        PreparedStatement pst = null;

        try {
            
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

            String query = "UPDATE new_calendar_events SET event_name = ?, description = ?, start_date = ?, end_date = ?, start_time = ?, end_time = ?, location = ? WHERE event_id = ? AND company_id = ?";
            pst = con.prepareStatement(query);
            pst.setString(1, eventName);
            pst.setString(2, description);
            pst.setString(3, startDate);
            pst.setString(4, endDate);
            pst.setString(5, startTime);
            pst.setString(6, endTime);
            pst.setString(7, location);
            pst.setString(8, eventId);
            pst.setInt(9, companyId);

            int rowsAffected = pst.executeUpdate();

            if (rowsAffected > 0) {
                response.getWriter().write("{\"success\": true}");
            } else {
                response.getWriter().write("{\"success\": false, \"error\": \"Event not found or update failed\"}");
            }
        } catch (Exception e) {
            response.getWriter().write("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
        } finally {
            if (pst != null) try { pst.close(); } catch (SQLException e) {}
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }
    }
}