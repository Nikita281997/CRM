<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
    <title>OTP Verification</title>
</head>
<body>
    <form action="verifyOtp" method="post">
        <h3>OTP has been sent to your email</h3>
        <label>Enter OTP:</label>
        <input type="text" name="otp">
        <button type="submit">Verify</button>
    </form>
</body>
</html>
