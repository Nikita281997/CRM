package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/DraftServlet")
public class DraftServlet extends HttpServlet {


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        StringBuilder draftList = new StringBuilder();
        
        // Start of the HTML structure
        draftList.append("<html><head><style>")
                .append("body { font-family: Arial, sans-serif; background-color: #f4f7fc; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; }")
                .append(".container { background-color: #fff; padding: 30px; width: 60%; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); }")
                .append("h1 { color: #333; text-align: center; }")
                .append("ul { list-style-type: none; padding: 0; }")
                .append("li { background-color: #f9f9f9; margin: 10px 0; padding: 12px; border-radius: 6px; border: 1px solid #ddd; }")
                .append("li:hover { background-color: #e9e9e9; }")
                .append(".back-btn { display: inline-block; margin-top: 20px; padding: 10px 20px; background-color: #3a8dff; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; text-align: center; }")
                .append(".back-btn:hover { background-color: #3178d5; }")
                .append("</style></head><body>");

        draftList.append("<div class='container'>");
        draftList.append("<h1>Draft Messages</h1><ul>");

        try {
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, pass);

            String query = "SELECT recipient, subject, message FROM drafts";
            try (PreparedStatement ps = conn.prepareStatement(query);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    draftList.append("<li>")
                            .append("<strong>To:</strong> ").append(rs.getString("recipient")).append("<br>")
                            .append("<strong>Subject:</strong> ").append(rs.getString("subject")).append("<br>")
                            .append("<strong>Message:</strong> ").append(rs.getString("message"))
                            .append("</li><hr>");
                }
            }
        } catch (Exception e) {
            draftList.append("<li>Error: ").append(e.getMessage()).append("</li>");
        }

        draftList.append("</ul>");

        // Back button to email.jsp
        draftList.append("<button class='back-btn' onclick='window.location.href=\"email.jsp\";'>Back to Compose</button>");
        draftList.append("</div>");
        draftList.append("</body></html>");

        response.getWriter().println(draftList.toString());
    }
}
