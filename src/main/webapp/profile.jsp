<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRM Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .container {
            display: flex;
            min-height: 100vh;
            background: #f8f9fa;
        }
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
            display: flex;
        }
        .sidebar {
            width: 15%;
            background: #0c022d;
            color: #fff;
            padding: 20px;
            height: 100vh;
        }
        .sidebar h2 span {
            color: #ff2e63;
        }
        .sidebar ul {
            list-style: none;
            padding: 0;
        }
        .sidebar li {
            margin: 10px 0;
            padding: 5px;
            cursor: pointer;
        }
        .sidebar li:hover {
            background: #25204a;
            transform: translateX(5px);
        }
        .sidebar .active {
            color: #ff2e63;
            font-weight: bold;
        }
        .sidebar:hover {
            background: #140a42;
        }
        a {
            color: white;
            text-decoration: none;
        }
        .content {
            flex: 1;
            padding: 25px;
            margin-left: 167px;
            margin-top: 4px;
        }
        .buttons {
            display: flex;
            justify-content: flex-end;
   
            align-items: center;
            margin-bottom: 20px;
        }
        .buttons a {
            margin-left: 10px;
            padding: 10px 15px;
            background-color: #374;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .buttons a:hover {
            background-color: #ff2e63;
        }
        .userprofile {
            display: flex;
            align-items: center;
            margin-top: 60px;
            background: #fff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
            width: 500px;
            transition: transform 0.3s ease-in-out;
        }
        .userprofile:hover {
            transform: scale(1.05);
        }
        .userprofile img {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            margin-right: 20px;
            border: 3px solid #ff2e63;
        }
        .user-details {
            flex: 1;
        }
        .user-details p {
            margin: 5px 0;
            font-size: 14px;
            color: #333;
        }
        .user-details span {
            font-weight: bold;
            color: #ff2e63;
        }
    </style>
</head>
<body>
<div class="sidebar">
    <h2>CRM<span>SPOT</span></h2>
    <ul>
        <li class="active">Dashboard</li>
        <li><a href="leads.jsp">Leads</a></li>
        <li><a href="leadmanagement.jsp">Lead Management</a></li>
        <li><a href="projects.jsp">Projects</a></li>
        <li><a href="quotes.jsp">Quotes</a></li>
        <li><a href="financemanagement.jsp">Finance Management</a></li>
        <li><a href="contacts.jsp">Contacts</a></li>
        <li><a href="tasks.jsp">Tasks</a></li>
        <li><a href="emp.jsp">Employees</a></li>
        <li><a href="email.jsp">Email</a></li>
        <li><a href="Organizations.jsp">Organizations</a></li>
        <li><a href="integration.jsp">Integration</a></li>
        <li><a href="delivered.jsp">Delivered</a></li>
    </ul>
</div>
<div class="container">
    <div class="content">
        <div class="buttons">
            <a href="Dashboard.jsp">Home</a>
            <a href="notification.jsp">Notification</a>
        </div>
        <% 
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM register");
                while (rs.next()) {
        %>
        <div class="userprofile">
            <img src="<%= rs.getString("profile_image") != null ? "profile_images/" + rs.getString("profile_image") : "default.jpg" %>" alt="User Image">
            <div class="user-details">
                <p><span>Username:</span> <br><%= rs.getString("username") %></p>
                <p><span>Email:</span> <br><%= rs.getString("email") %></p>
                <p><span>Contact:</span> <br><%= rs.getString("contact") %></p>
                <p><span>Full Name:</span><br> <%= rs.getString("fullname") %></p>
                <p><span>Address:</span><br> <%= rs.getString("address") %></p>
                <p><span>City:</span><br> <%= rs.getString("city") %></p>
                <p><span>State:</span><br> <%= rs.getString("state") %></p>
                <p><span>Country:</span><br> <%= rs.getString("country") %></p>
                <p><span>Zip Code:</span><br> <%= rs.getString("zipcode") %></p>
                <p><span>Gender:</span><br> <%= rs.getString("gender") %></p>
                <p><span>Date of Birth:</span> <br><%= rs.getString("dob") %></p>
            </div>
        </div>
        <% 
                }
                con.close();
            } catch (Exception e) {
                out.println("Error: " + e.getMessage());
            }
        %>
    </div>
</div>
</body>
</html>