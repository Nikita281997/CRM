<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>


<!DOCTYPE html>
<html>
<head>
    <title>Join Meeting</title>
</head>
<body>
    <h2>Join Your Video Call</h2>
    <% 
        String meetingLink = request.getParameter("meetingLink");
        if (meetingLink != null && !meetingLink.isEmpty()) { 
    %>
        <p>Click <a href="<%= meetingLink %>" target="_blank">here</a> to join the meeting.</p>

        <!-- Embed Jitsi Meet directly into the page -->
        <iframe src="<%= meetingLink %>" width="100%" height="500px" allow="camera; microphone; fullscreen"></iframe>
    <% } else { %>
        <p>Invalid meeting link.</p>
    <% } %>
</body>
</html>
