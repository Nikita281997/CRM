<%@ page import="java.sql.*" %>
<%
    String year = request.getParameter("year");
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    StringBuilder jsonResponse = new StringBuilder();
    try {
       String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
            

        // Modify query to use COALESCE to get finalvalue if available, otherwise quotes_values
        String query = "SELECT lead_id, status, COALESCE(finalvalue, quotes_values) AS amount FROM financemanagement WHERE YEAR(due_date) = ?";
        pst = con.prepareStatement(query);
        pst.setString(1, year);
        rs = pst.executeQuery();

        jsonResponse.append("{\"success\": true, \"data\": [");

        boolean first = true;
        while (rs.next()) {
            if (!first) {
                jsonResponse.append(",");
            }
            jsonResponse.append("{");
            jsonResponse.append("\"lead_id\": \"" + rs.getInt("lead_id") + "\", ");
            jsonResponse.append("\"status\": \"" + rs.getString("status") + "\", ");
            jsonResponse.append("\"amount\": \"" + rs.getDouble("amount") + "\"");
            jsonResponse.append("}");
            first = false;
        }

        jsonResponse.append("]}");

        out.print(jsonResponse.toString());
    } catch (Exception e) {
        out.println("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
    } finally {
        if (rs != null) rs.close();
        if (pst != null) pst.close();
        if (con != null) con.close();
    }
%>
