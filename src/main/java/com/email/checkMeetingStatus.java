package com.email;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

public class checkMeetingStatus extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int leadId = Integer.parseInt(request.getParameter("lead_id"));
        try {
             String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);
            PreparedStatement ps = con.prepareStatement("SELECT * FROM meeting WHERE lead_id = ?");
            ps.setInt(1, leadId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                response.getWriter().write("scheduled");  // Meeting is already scheduled
            } else {
                response.getWriter().write("not_scheduled");  // No meeting scheduled
            }

            rs.close();
            ps.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error checking meeting status.");
        }
    }
}
