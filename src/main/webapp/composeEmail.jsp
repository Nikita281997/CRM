<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Send Email</title>
</head>
<body>
    <h2>Send Email</h2>
    <form action="SendEmailServlet" method="post">
        <label for="recipient">Recipient Email:</label>
        <input type="email" name="recipient" required>
        <br><br>
        
        <label for="subject">Subject:</label>
        <input type="text" name="subject" required>
        <br><br>
        
        <label for="message">Message:</label>
        <textarea name="message" rows="5" required></textarea>
        <br><br>
        
        <input type="submit" value="Send Email">
    </form>
</body>
</html>
