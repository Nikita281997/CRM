<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.LocalDate, java.time.temporal.ChronoUnit" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRM Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        /* Main Layout */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
            display: flex;
        }
        .container {
            display: flex;
            flex: 1;
            min-height: 100vh;
            background: #f8f9fa;
        }
        .sidebar {
            width: 250px;
            background: #0c022d;
            color: #fff;
            padding: 20px;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            overflow-y: auto;
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
            padding: 10px;
            cursor: pointer;
            border-radius: 5px;
            transition: all 0.3s ease;
        }
        .sidebar li:hover {
            background: #25204a;
            transform: translateX(5px);
        }
        .sidebar .active {
            color: #ff2e63;
            font-weight: bold;
        }
        .sidebar a {
            color: white;
            text-decoration: none;
            display: block;
        }
        .content {
            margin-left: 270px;
            flex: 1;
            padding: 25px;
        }
        .button-container {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            position: absolute;
            top: 20px;
            right: 25px;
        }
        .button-container button {
            background: #28a745;
            color: white;
            border: none;
            padding: 10px 15px;
            margin: 5px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .button-container button:hover {
            background: #ff2e63;
        }

        /* Notifications */
        .notifications {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            width: 350px;
            max-height: 300px;
            overflow-y: auto;
            position: fixed;
            top: 254px;
            right: 20px;
            left:680px;
            
            z-index: 1000;
        }
        .notifications h3 {
            margin-top: 0;
            font-size: 18px;
            color: #333;
            border-bottom: 2px solid #ff2e63;
            padding-bottom: 8px;
        }
        .notifications ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .notifications li {
            background: #f8f8f8;
            padding: 10px;
            margin: 8px 0;
            border-radius: 5px;
            font-size: 14px;
            color: #333;
            box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.1);
        }
        @media screen and (max-width: 1024px) {
    .sidebar {
        width: 220px;
    }
    .content {
        margin-left: 240px;
    }
    .notifications {
        left: auto;
        right: 10px;
        width: 320px;
    }
}

@media screen and (max-width: 768px) {
    .sidebar {
        width: 0;
        position: fixed;
        height: 100vh;
        left: -250px;
        transition: left 0.3s ease-in-out;
    }
    .sidebar.show {
        left: 0;
    }
    .content {
        margin-left: 0;
        width: 100%;
    }
    .notifications {
        width: 90%;
        left: 5%;
        right: 5%;
        top: auto;
        bottom: 10px;
        position: fixed;
    }
}

@media screen and (max-width: 480px) {
    .button-container {
        position: relative;
        top: auto;
        right: auto;
        justify-content: center;
    }
    .notifications {
        width: 83%;
        left: 2.5%;
    }
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
            <div class="button-container">
                <button onclick="window.location.href='Dashboard.jsp'">Home</button>
                <button onclick="window.location.href='profile.jsp'">Profile</button>
            </div>

            <%
                int notificationCount = 0;
                StringBuilder notifications = new StringBuilder();

                try (Connection conn = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
                     Statement stmt = conn.createStatement()) {

                    Class.forName("com.mysql.cj.jdbc.Driver");
                    LocalDate today = LocalDate.now();

                    // Fetching integrations expiry notifications
                    try (ResultSet rs = stmt.executeQuery("SELECT service_name, expiry_date FROM integrations")) {
                        while (rs.next()) {
                            String serviceName = rs.getString("service_name");
                            LocalDate expiryDate = LocalDate.parse(rs.getString("expiry_date"));
                            long daysRemaining = ChronoUnit.DAYS.between(today, expiryDate);

                            if (daysRemaining <= 364 && daysRemaining % 2 == 0) {
                                notificationCount++;
                                notifications.append("<li>Service <b>").append(serviceName).append("</b> is expiring soon! (Expiry in ")
                                        .append(daysRemaining).append(" days)</li>");
                            }
                        }
                    }

                    // Fetching project due date notifications
                    try (ResultSet rs = stmt.executeQuery("SELECT project_name, due_date FROM project")) {
                        while (rs.next()) {
                            String projectName = rs.getString("project_name");
                            LocalDate dueDate = LocalDate.parse(rs.getString("due_date"));
                            long daysUntilDue = ChronoUnit.DAYS.between(today, dueDate);

                            if (daysUntilDue == 2) {
                                notificationCount++;
                                notifications.append("<li>Project <b>").append(projectName).append("</b> is due in 2 days!</li>");
                            }
                        }
                    }

                    session.setAttribute("notificationCount", notificationCount);
                    session.setAttribute("notifications", notifications.toString());

                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>

            <div class="notifications">
                <h3>📢 Notifications</h3>
                <ul>
                    <%= session.getAttribute("notifications") %>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>