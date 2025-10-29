<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>

<%
    String quoteId = request.getParameter("quote_id");
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

    if (companyId == null || quoteId == null) {
        response.sendRedirect("login1.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
        
        String query = "UPDATE quotation SET status = 'YES', status_updated_at = NULL WHERE quote_id = ? AND lead_id IN (SELECT lead_id FROM leads WHERE company_id = ?)";
        pstmt = con.prepareStatement(query);
        pstmt.setInt(1, Integer.parseInt(quoteId));
        pstmt.setInt(2, companyId);
        pstmt.executeUpdate();

        response.sendRedirect("quotes.jsp?view=deleted");
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>