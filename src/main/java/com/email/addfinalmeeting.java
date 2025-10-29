package com.email;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;

@WebServlet("/addfinalmeeting")
public class addfinalmeeting extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            // Retrieve in_date and meeting_date from the leads table
            String fetchQuery = "SELECT in_date, meeting_date FROM leads WHERE lead_id = ? AND company_id = ?";
            PreparedStatement fetchPs = con.prepareStatement(fetchQuery);
            fetchPs.setString(1, leadID);
            fetchPs.setInt(2, companyId);
            
            ResultSet rs = fetchPs.executeQuery();
            
            if (rs.next()) {
                String inDate = rs.getString("in_date");
                String meetingDate = rs.getString("meeting_date");

                // Check if the new date is before in_date or meeting_date
                if ((inDate != null && date.compareTo(inDate) < 0) || 
                    (meetingDate != null && !meetingDate.isEmpty() && date.compareTo(meetingDate) < 0)) {
                    
                    String alertMessage = "";
                    if (inDate != null && date.compareTo(inDate) < 0) {
                        alertMessage = "You cannot add the date before in_date (" + inDate + ").";
                    } else if (meetingDate != null && !meetingDate.isEmpty() && date.compareTo(meetingDate) < 0) {
                        alertMessage = "You cannot add the date before meeting_date (" + meetingDate + ").";
                    }

                    response.getWriter().println(
                        "<script type='text/javascript'>"
                        + "alert('" + alertMessage + "');"
                        + "window.location.href = 'leadmanagement.jsp';"
                        + "</script>");
                    return;
                }
            }

            // Update statement to update meeting_date and meeting_time for the specific lead_id
            String sql = "UPDATE proposalsent SET meeting_date = ?, meeting_time = ? WHERE lead_id = ? AND company_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, date);
            ps.setString(2, time);
            ps.setString(3, leadID);
            ps.setInt(4, companyId);

            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated > 0) {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('Meeting updated successfully!');"
                    + "window.location.href = 'leadmanagement.jsp';"
                    + "</script>");
            } else {
                response.getWriter().println(
                    "<script type='text/javascript'>"
                    + "alert('No lead found with the given ID!');"
                    + "window.location.href = 'leads.jsp';"
                    + "</script>");
            }

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }
}
