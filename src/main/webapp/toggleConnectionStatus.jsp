<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>

<%
    String leadId = request.getParameter("lead_id");
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

    if (companyId == null || leadId == null) {
        response.sendRedirect("login1.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement pstmtSelect = null;
    PreparedStatement pstmtUpdate = null;
    ResultSet rs = null;

    try {
        String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass); 

        // Fetch the current connection_status
        String selectQuery = "SELECT connection_status FROM leads WHERE lead_id = ? AND company_id = ?";
        pstmtSelect = con.prepareStatement(selectQuery);
        pstmtSelect.setInt(1, Integer.parseInt(leadId));
        pstmtSelect.setInt(2, companyId);
        rs = pstmtSelect.executeQuery();

        String currentStatus = null;
        if (rs.next()) {
            currentStatus = rs.getString("connection_status");
        }

        // Toggle the connection_status
        String newStatus = "Connected".equals(currentStatus) ? "Not Connected" : "Connected";
        String updateQuery = "UPDATE leads SET connection_status = ? WHERE lead_id = ? AND company_id = ?";
        pstmtUpdate = con.prepareStatement(updateQuery);
        pstmtUpdate.setString(1, newStatus);
        pstmtUpdate.setInt(2, Integer.parseInt(leadId));
        pstmtUpdate.setInt(3, companyId);
        pstmtUpdate.executeUpdate();

        response.sendRedirect("leads.jsp?view=active");
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmtSelect != null) try { pstmtSelect.close(); } catch (SQLException e) {}
        if (pstmtUpdate != null) try { pstmtUpdate.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>