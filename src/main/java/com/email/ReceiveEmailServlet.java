package com.email;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.mail.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;

@WebServlet("/ReceiveEmailServlet")
public class ReceiveEmailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String imapHost = "imap.hostinger.com";
        // String username = "rohan@tars.co.in";
        // String password = "Tars@2322";

        Properties properties = new Properties();
        properties.put("mail.imap.host", imapHost);
        properties.put("mail.imap.port", "993");
        properties.put("mail.imap.ssl.enable", "true");

        try {
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);
            String fetchquery = "SELECT email, password FROM register";
            PreparedStatement ps = con.prepareStatement(fetchquery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String email = rs.getString("email");
                String password = rs.getString("password");

                Session session = Session.getInstance(properties);
                Store store = session.getStore("imap");
                store.connect(email, password);

                Folder inbox = store.getFolder("INBOX");
                inbox.open(Folder.READ_ONLY);

                Message[] messages = inbox.getMessages();
                StringBuilder emailList = new StringBuilder();
                
                // Start of the HTML structure
                emailList.append("<html><head><style>")
                        .append("body { font-family: Arial, sans-serif; background-color: #f4f7fc; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; }")
                        .append(".container { background-color: #fff; padding: 30px; width: 60%; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); }")
                        .append("h1 { color: #333; text-align: center; }")
                        .append("ul { list-style-type: none; padding: 0; }")
                        .append("li { background-color: #f9f9f9; margin: 10px 0; padding: 12px; border-radius: 6px; border: 1px solid #ddd; }")
                        .append("li:hover { background-color: #e9e9e9; }")
                        .append("a { color: #3a8dff; text-decoration: none; font-weight: bold; }")
                        .append("a:hover { text-decoration: underline; }")
                        .append(".back-btn { display: inline-block; margin-top: 20px; padding: 10px 20px; background-color: #3a8dff; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; text-align: center; }")
                        .append(".back-btn:hover { background-color: #3178d5; }")
                        .append("</style></head><body>");
                
                emailList.append("<div class='container'>");
                emailList.append("<h1>Inbox</h1><ul>");
                for (Message message : messages) {
                    emailList.append("<li>")
                            .append("From: ").append(message.getFrom()[0])
                            .append("<br>Subject: ").append(message.getSubject())
                            .append("</li>");
                }
                emailList.append("</ul>");
                
                // Back button to wmail.jsp
                emailList.append("<button class='back-btn' onclick='window.location.href=\"email.jsp\";'>Back to Compose</button>");
                
                emailList.append("</div>");
                emailList.append("</body></html>");
                
                response.getWriter().println(emailList.toString());

                inbox.close(false);
                store.close();
            }
        } catch (Exception e) {
            response.getWriter().println("Error fetching emails: " + e.getMessage());
        }
    }
}
