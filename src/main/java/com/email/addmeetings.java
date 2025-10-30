package com.email;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/**
 * 
 * Servlet implementation class addmeetings
 */@WebServlet("/addmeetings")
public class addmeetings extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	 // Retrieve session variable for company_id
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

        // Redirect to login if company_id is missing
        if (companyId == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

    	String leadID = request.getParameter("quoteid");
        String date = request.getParameter("date");
        String time = request.getParameter("time");

        try {
             String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
          
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);
           
            // First, retrieve the in_date from the leads table
            String inDateQuery = "SELECT in_date FROM leads WHERE lead_id = ? AND company_id = ?";
            LocalDate inDate = null;
            
            try (PreparedStatement psInDate = con.prepareStatement(inDateQuery)) {
                psInDate.setString(1, leadID);
                psInDate.setInt(2, companyId);
                
                try (ResultSet rs = psInDate.executeQuery()) {
                    if (rs.next()) {
                        String inDateStr = rs.getString("in_date");
                        if (inDateStr != null && !inDateStr.trim().isEmpty()) {
                            inDate = LocalDate.parse(inDateStr);
                        } else {
                            response.sendRedirect("leadmanagement.jsp?errorMessage=In date not found for this lead.");
                            return;
                        }
                    } else {
                        response.sendRedirect("leadmanagement.jsp?errorMessage=Lead not found.");
                        return;
                    }
                }
            }
            
            // Validate that due date is not older than in_date
            LocalDate dueDateObj;
            try {
                dueDateObj = LocalDate.parse(date);
            } catch (DateTimeParseException e) {
                response.sendRedirect("leadmanagement.jsp?errorMessage=Invalid date format.");
                return;
            }
            
            if (dueDateObj.isBefore(inDate)) {
            	response.getWriter().println(
                        "<script type='text/javascript'>"
                        + "alert('Meeting date cannot be earlier than the lead date ');" + "window.location.href = 'leadmanagement.jsp';"
                        + "</script>");
            	return;
            }
            // Update statement to update meeting_date and meeting_time for the specific lead_id
            String sql = "UPDATE leads SET meeting_date = ?, meeting_time = ? WHERE lead_id = ? and company_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, date);
            ps.setString(2, time);
            ps.setString(3, leadID);
            ps.setInt(4, companyId);

            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated > 0) {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('Meeting updated successfully!');" + "window.location.href = 'leadmanagement.jsp';"
                    + "</script>");
            } else {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('No lead found with the given ID!');" + "window.location.href = 'leadmanagement.jsp';"
                    + "</script>");
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
