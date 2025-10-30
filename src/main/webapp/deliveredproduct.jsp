<%@ page import="java.sql.*, jakarta.servlet.http.*" %>
<%
    HttpSession sessionObj = request.getSession();
    String companyIdStr = (String) sessionObj.getAttribute("company_id");

    Integer companyId = null;
    if (companyIdStr != null && !companyIdStr.isEmpty()) {
        try {
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            out.println("Error: Invalid company_id format.");
            return;
        }
    }

    if (companyId == null) {
        response.sendRedirect("login1.jsp");
        return;
    }

    String leadId = request.getParameter("lead_id");
    String newStatus = request.getParameter("status");

    if (leadId == null || leadId.isEmpty() || newStatus == null || newStatus.isEmpty()) {
        out.println("<script>alert('Error: Lead ID and Status are required!'); window.location.href='testing.jsp';</script>");
        return;
    }

    try {
        C 
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);

        // ✅ Debugging Statements
        out.println("Updating lead_id: " + leadId + " with status: " + newStatus + " for company_id: " + companyId);

        String query = "UPDATE testertable SET status = ? WHERE lead_id = ? AND company_id = ?";
        PreparedStatement ps = con.prepareStatement(query);
        ps.setString(1, newStatus);
        ps.setInt(2, Integer.parseInt(leadId));
        ps.setInt(3, companyId);

        int rowsUpdated = ps.executeUpdate();

        if (rowsUpdated > 0) {
            out.println("<script>alert('Status updated successfully!'); window.location.href='testing.jsp';</script>");
        } else {
            out.println("<script>alert('Error: No matching record found.'); window.location.href='testing.jsp';</script>");
        }

        ps.close();
        con.close();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('Database Error: " + e.getMessage() + "'); window.location.href='testing.jsp';</script>");
    }
%>
