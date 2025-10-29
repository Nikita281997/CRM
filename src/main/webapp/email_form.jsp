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
                    Class.forName("com.mysql.cj.jdbc.Driver");//"jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI"
                    Connection conn = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb?useSSL=false&serverTimezone=UTC", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
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
