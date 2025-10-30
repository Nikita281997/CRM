<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="jakarta.servlet.*" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Send Email</title>
</head>
<body>
    <h2>Send an Email</h2>
    <form action="SendEmailServlet" method="post">
        <label for="senderEmail">Your Email:</label>
        <select name="senderEmail" required>
            <%
                try {
                    String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(url, user, pass);
                    PreparedStatement ps = conn.prepareStatement("SELECT email FROM users");
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
            %>
            <option value="<%= rs.getString("email") %>"><%= rs.getString("email") %></option>
            <%
                    }
                    rs.close();
                    ps.close();
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
        </select>
        <br><br>
        <label for="recipientEmail">Recipient Email:</label>
        <input type="email" name="recipientEmail" required>
        <br><br>
        <label for="subject">Subject:</label>
        <input type="text" name="subject" required>
        <br><br>
        <label for="message">Message:</label>
        <textarea name="message" required></textarea>
        <br><br>
        <button type="submit">Send Email</button>
    </form>
</body>
</html>
