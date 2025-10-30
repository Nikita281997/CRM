<%@ page import="java.sql.*" %>
<%
    String leadId = request.getParameter("lead_id");
    String newStatus = request.getParameter("status");

    try {
        String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(url, user, pass);
        PreparedStatement ps = con.prepareStatement("UPDATE leads SET status = ? WHERE lead_id = ?");
        ps.setString(1, newStatus);
        ps.setInt(2, Integer.parseInt(leadId));

        int rowsUpdated = ps.executeUpdate();
        if (rowsUpdated > 0) {
            out.println("Status updated successfully!");
        } else {
            out.println("Error updating status!");
        }

        ps.close();
        con.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Redirect back to the main page
    response.sendRedirect("leads.jsp"); // Replace with your main JSP page
%>
