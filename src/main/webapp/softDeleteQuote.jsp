<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>

<%
    String leadIdStr = request.getParameter("lead_id");
    String action = request.getParameter("action"); // "restore" for restoring, null for soft delete
    HttpSession sessionVar = request.getSession();
    String companyIdStr = (String) sessionVar.getAttribute("company_id");

    Integer companyId = null;
    if (companyIdStr != null) {
        try {
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
    }

    if (companyId == null || leadIdStr == null) {
        response.sendRedirect("login1.jsp");
        return;
    }

    int leadId;
    try {
        leadId = Integer.parseInt(leadIdStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("leads.jsp?error=Invalid Lead ID");
        return;
    }

    Connection con = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

        String newStatus = "restore".equals(action) ? "yes" : "no";
        String sql = "UPDATE leads SET yesno_status = ? WHERE lead_id = ? AND company_id = ?";
        pstmt = con.prepareStatement(sql);
        pstmt.setString(1, newStatus);
        pstmt.setInt(2, leadId);
        pstmt.setInt(3, companyId);

        int rowsAffected = pstmt.executeUpdate();
        if (rowsAffected > 0) {
            response.sendRedirect("leads.jsp");
        } else {
            response.sendRedirect("leads.jsp?error=Failed to update lead status");
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("leads.jsp?error=Database error occurred");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>