<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.json.JSONObject" %>

<%
    response.setContentType("application/json");
    JSONObject jsonResponse = new JSONObject();

    Connection con = null;
    PreparedStatement pst = null;

    try {
        // Retrieve company_id from session
        HttpSession sessionVar = request.getSession();
        String companyIdStr = (String) sessionVar.getAttribute("company_id");
        Integer companyId = null;

        if (companyIdStr != null) {
            companyId = Integer.parseInt(companyIdStr);
        }

        if (companyId == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("error", "User not logged in or company_id not found in session");
            out.print(jsonResponse.toString());
            return;
        }

        // Read the JSON payload from the request
        StringBuilder sb = new StringBuilder();
        String line;
        BufferedReader reader = request.getReader();
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        String jsonString = sb.toString();
        JSONObject data = new JSONObject(jsonString);

        String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

        // Prepare the SQL query to insert into the new table, excluding event_id and created_at
        String query = "INSERT INTO new_calendar_events (company_id, event_name, description, start_date, end_date, start_time, end_time, location) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        pst = con.prepareStatement(query);
        pst.setInt(1, companyId);

        // Set parameters, allowing null if fields are not provided
        pst.setString(2, data.has("event_name") ? data.getString("event_name") : null);
        pst.setString(3, data.has("description") ? data.getString("description") : null);
        pst.setString(4, data.has("start_date") ? data.getString("start_date") : null);
        pst.setString(5, data.has("end_date") ? data.getString("end_date") : null);
        pst.setString(6, data.has("start_time") ? data.getString("start_time") + ":00" : null); // Append seconds if needed
        pst.setString(7, data.has("end_time") ? data.getString("end_time") + ":00" : null);
        pst.setString(8, data.has("location") ? data.getString("location") : null);

        int rowsAffected = pst.executeUpdate();
        if (rowsAffected > 0) {
            jsonResponse.put("success", true);
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("error", "Failed to save event");
        }

    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("error", e.getMessage());
    } finally {
        if (pst != null) try { pst.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }

    out.print(jsonResponse.toString());
%>