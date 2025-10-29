<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.temporal.ChronoUnit" %>

<%
    Connection con = null;
    PreparedStatement pstmtSelect = null;
    PreparedStatement pstmtDelete = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

        // Select leads with status 'NO'
        String selectQuery = "SELECT lead_id, company_id, status_updated_at FROM leads WHERE status = 'NO'";
        pstmtSelect = con.prepareStatement(selectQuery);
        rs = pstmtSelect.executeQuery();

        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        while (rs.next()) {
            int leadId = rs.getInt("lead_id");
            int companyId = rs.getInt("company_id");
            String statusUpdatedAtStr = rs.getString("status_updated_at");

            if (statusUpdatedAtStr != null) {
                LocalDateTime statusUpdatedAt = LocalDateTime.parse(statusUpdatedAtStr, formatter);
                long daysSinceUpdate = ChronoUnit.DAYS.between(statusUpdatedAt, now);

                if (daysSinceUpdate >= 30) {
                    // Disable foreign key checks
                    Statement disableFK = con.createStatement();
                    disableFK.execute("SET FOREIGN_KEY_CHECKS=0");

                    // Delete related data for the lead
                    String[] tables = {"leadscontact", "financemanagement", "connected", "proposalsent", "qualified", 
                                       "quotation", "project", "leads", "testertable"};
                    for (String table : tables) {
                        String deleteQuery = "DELETE FROM " + table + " WHERE lead_id = ? AND company_id = ?";
                        pstmtDelete = con.prepareStatement(deleteQuery);
                        pstmtDelete.setInt(1, leadId);
                        pstmtDelete.setInt(2, companyId);
                        pstmtDelete.executeUpdate();
                    }

                    // Enable foreign key checks
                    Statement enableFK = con.createStatement();
                    enableFK.execute("SET FOREIGN_KEY_CHECKS=1");
                }
            }
        }

        // Reset AUTO_INCREMENT for leads and quotation tables if they are empty
        Statement resetAutoIncrement = con.createStatement();
        resetAutoIncrement.executeUpdate("ALTER TABLE quotation AUTO_INCREMENT = 1");
        resetAutoIncrement.executeUpdate("ALTER TABLE leads AUTO_INCREMENT = 1");
        resetAutoIncrement.close();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmtSelect != null) try { pstmtSelect.close(); } catch (SQLException e) {}
        if (pstmtDelete != null) try { pstmtDelete.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>