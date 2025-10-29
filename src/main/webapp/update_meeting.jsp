<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>

<%
    Connection con = null;
    PreparedStatement pstmt = null;
    PreparedStatement pstmtSelect = null;
    ResultSet rs = null;
    String eventId = request.getParameter("event_id");
    String eventName = request.getParameter("event_name");
    String startDate = request.getParameter("start_date");
    String startTime = request.getParameter("start_time");
    String endDate = request.getParameter("end_date");
    String endTime = request.getParameter("end_time");
    String location = request.getParameter("location");

    HttpSession sessionVar = request.getSession();
    String companyIdStr = (String) sessionVar.getAttribute("company_id");
    Integer companyId = Integer.parseInt(companyIdStr);

    // Fetch current time values from the database if not updated
    String currentStartTime = "00:00:00";
    String currentEndTime = "00:00:00";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

        // Query to get existing time values
        String selectQuery = "SELECT start_time, end_time FROM new_calendar_events WHERE event_id = ? AND company_id = ?";
        pstmtSelect = con.prepareStatement(selectQuery);
        pstmtSelect.setInt(1, Integer.parseInt(eventId));
        pstmtSelect.setInt(2, companyId);
        rs = pstmtSelect.executeQuery();
        
        if (rs.next()) {
            currentStartTime = rs.getString("start_time") != null ? rs.getString("start_time") : "00:00:00";
            currentEndTime = rs.getString("end_time") != null ? rs.getString("end_time") : "00:00:00";
        }

        // Use submitted time if provided, otherwise keep current time
        startTime = (startTime != null && !startTime.isEmpty() && startTime.matches("\\d{2}:\\d{2}")) ? startTime + ":00" : currentStartTime;
        endTime = (endTime != null && !endTime.isEmpty() && endTime.matches("\\d{2}:\\d{2}")) ? endTime + ":00" : currentEndTime;

        String query = "UPDATE new_calendar_events SET event_name = ?, start_date = ?, start_time = ?, end_date = ?, end_time = ?, location = ? WHERE event_id = ? AND company_id = ?";
        pstmt = con.prepareStatement(query);
        pstmt.setString(1, eventName);
        pstmt.setDate(2, java.sql.Date.valueOf(startDate));
        pstmt.setTime(3, java.sql.Time.valueOf(startTime));
        pstmt.setDate(4, java.sql.Date.valueOf(endDate));
        pstmt.setTime(5, java.sql.Time.valueOf(endTime));
        pstmt.setString(6, location);
        pstmt.setInt(7, Integer.parseInt(eventId));
        pstmt.setInt(8, companyId);

        int rowsAffected = pstmt.executeUpdate();
        if (rowsAffected > 0) {
            response.sendRedirect("Dashboard.jsp");
        } else {
            out.println("<h3>Failed to update meeting.</h3>");
        }
    } catch (IllegalArgumentException e) {
        out.println("<h3>Error: Invalid time format - " + e.getMessage() + "</h3>");
    } catch (Exception e) {
        out.println("<h3>Error: " + e.getMessage() + "</h3>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmtSelect != null) try { pstmtSelect.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>