package com.email;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ScheduleMeetingServlet")
public class ScheduleMeetingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int leadId = Integer.parseInt(request.getParameter("lead_id"));
        String meetingDate = request.getParameter("meeting_date");
        String meetingTime = request.getParameter("meeting_time");

        try {
             String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);

            String query = "INSERT INTO meeting (lead_id, meeting_date, meeting_time) VALUES (?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setInt(1, leadId);
            ps.setString(2, meetingDate);
            ps.setString(3, meetingTime);

            int rowsInserted = ps.executeUpdate();
            ps.close();
            con.close();

            if (rowsInserted > 0) {
                response.sendRedirect("contacts.jsp?status=success");
            } else {
                response.sendRedirect("contacts.jsp?status=failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
