<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --primary: #0c022d;
            --secondary: #e6f0fa;
            --accent: #1DA1F2;
            --light: #f8f9fa;
            --dark: #2c3e50;
            --success: #00c4b4;
            --info: #36a2eb;
            --warning: #ffcd56;
            --danger: #ff6384;
            --sidebar-bg: #ffffff;
            --text-color: #666;
            --card-bg: #ffffff;
            --border-radius: 15px;
            --table-header-bg: #f5f7fa;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background: #f5f7fa;
            color: var(--dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .container {
            display: flex;
            flex: 1;
            position: relative;
        }

        .sidebar {
            width: 240px;
            background: var(--sidebar-bg);
            color: var(--text-color);
            padding: 20px;
            position: fixed;
            height: 100vh;
            transition: all 0.3s ease;
            z-index: 1000;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            box-shadow: 2px 0 10px rgba(0,0,0,0.05);
        }

        .sidebar .logo {
            display: block;
            width: 100%;
            height: auto;
            margin-bottom: 20px;
        }

        .sidebar-menu {
            flex: 1;
            overflow-y: auto;
            margin-bottom: 20px;
            scrollbar-width: none;
            -ms-overflow-style: none;
        }

        .sidebar-menu::-webkit-scrollbar {
            display: none;
        }

        .sidebar ul {
            list-style: none;
            padding: 0;
        }

        .sidebar li {
            margin: 5px 0;
            border-radius: 5px;
            transition: all 0.3s ease;
        }

        .sidebar li:hover {
            background: var(--secondary);
        }

        .sidebar a {
            color: var(--text-color);
            text-decoration: none;
            display: flex;
            align-items: center;
            padding: 10px 15px;
            font-size: 0.9rem;
        }

        .sidebar i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
            font-size: 1.1rem;
            color: var(--text-color);
        }

        .sidebar .active {
            background: var(--accent);
        }

        .sidebar .active a, .sidebar .active i {
            color: white;
        }

        .sidebar-close {
            display: none;
            position: absolute;
            top: 10px;
            right: 10px;
            background: none;
            border: none;
            color: var(--text-color);
            font-size: 1.5rem;
            cursor: pointer;
        }

        .content {
            flex: 1;
            margin-left: 240px;
            padding: 20px;
            transition: margin-left 0.3s ease;
        }

        .navbar {
            background: transparent;
            padding: 15px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .page-header {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            margin-bottom: 20px;
            gap: 10px;
        }

        .page-title {
            font-size: 1.8rem;
            color: var(--text-color);
            font-weight: 500;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            display: inline-flex;
            align-items: center;
        }

        .btn-primary {
            background: var(--accent);
            color: white;
        }

        .btn-primary:hover {
            background: #1a91da;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .task-column {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 15px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            flex: 1;
            min-height: 300px;
            transition: all 0.3s ease;
        }

        .task-column h1 {
            text-align: center;
            color: var(--text-color);
            font-weight: 500;
        }

        .task-column img {
            width: 400px;
            height: 300px;
            margin: 20px auto;
            display: block;
            opacity: 0.8;
        }

        .menu-toggle {
            display: none;
            background: var(--accent);
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
            margin-right: 15px;
            font-size: 1.2rem;
        }

        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-100%);
                width: 240px;
            }

            .sidebar.active {
                transform: translateX(0);
            }

            .content {
                margin-left: 0;
            }

            .menu-toggle {
                display: block;
            }

            .sidebar-close {
                display: block;
            }
        }
    </style>
</head>
<body>
<%
    // Session validation
    HttpSession sessionVar = request.getSession(false);
    if (sessionVar == null || sessionVar.getAttribute("company_id") == null) {
        response.sendRedirect("login1.jsp");
        return;
    }

    String companyIdStr = (String) sessionVar.getAttribute("company_id");
    int companyId = Integer.parseInt(companyIdStr);
%>

<div class="container">
    <div class="sidebar">
        <button class="sidebar-close" id="sidebarClose">×</button>

        <!-- ✅ Fixed JSP image with cache-busting timestamp -->
        <img src="<%= request.getContextPath() %>/images/TARS.jpg?t=<%= System.currentTimeMillis() %>"
             alt="TARS CRM Logo" class="logo"
             onerror="this.src='https://via.placeholder.com/200x60?text=Logo+Not+Found';">

        <div class="sidebar-menu">
            <ul>
                <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="leads.jsp"><i class="fas fa-users"></i> Leads</a></li>
                <li><a href="leadmanagement.jsp"><i class="fas fa-tasks"></i> Lead Management</a></li>
                <li><a href="projects.jsp"><i class="fas fa-project-diagram"></i> Projects</a></li>
                <li><a href="quotes.jsp"><i class="fas fa-file-invoice-dollar"></i> Quotes</a></li>
                <li><a href="financemanagement.jsp"><i class="fas fa-money-bill-wave"></i> Finance</a></li>
                <li><a href="contacts.jsp"><i class="fas fa-address-book"></i> Contacts</a></li>
                <li><a href="tasks.jsp"><i class="fas fa-check-circle"></i> Tasks</a></li>
                <li><a href="emp.jsp"><i class="fas fa-user-tie"></i> Employees</a></li>
                <li class="active"><a href="email.jsp"><i class="fas fa-envelope"></i> Email</a></li>
                <li><a href="Organizations.jsp"><i class="fas fa-building"></i> Organizations</a></li>
                <li><a href="integration.jsp"><i class="fas fa-plug"></i> Integration</a></li>
                <li><a href="delivered.jsp"><i class="fas fa-truck"></i> Delivered</a></li>
                <li><a href="fetch_meetings_all.jsp"><i class="fas fa-calendar-alt"></i> Calendar</a></li>
            </ul>
        </div>

        <%
            // Profile info
            String fullName = "User";
            String imgPath = "images/default-profile.jpg";

            try {
                String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(
                    url, user, pass
                );

                PreparedStatement pstmt = con.prepareStatement(
                    "SELECT full_name, img FROM company_registration1 WHERE company_id = ?"
                );
                pstmt.setInt(1, companyId);
                ResultSet rs = pstmt.executeQuery();

                if (rs.next()) {
                    fullName = rs.getString("full_name");
                    imgPath = rs.getString("img") != null ? rs.getString("img") : "images/default-profile.jpg";
                }

                rs.close();
                pstmt.close();
                con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>

        <div class="profile" onclick="window.location.href='profile1.jsp'">
            <img src="<%= imgPath %>" alt="User Profile" width="40" height="40" style="border-radius:50%;">
            <span><%= fullName %></span>
        </div>
    </div>

    <div class="content">
        <div class="navbar">
            <button class="menu-toggle" id="menuToggle">
                <i class="fas fa-bars"></i>
            </button>
        </div>

        <div class="task-column">
            <h1>Welcome to the Email Dashboard</h1>
            <img src="gmail.webp" alt="Email Icon">
        </div>

        <div class="navbar">
            <a href="composeEmail.jsp">Compose Email</a>
            <a href="ReceiveEmailServlet">Inbox</a>
            <a href="drafts.jsp">Drafts</a>
            <a href="sent.jsp">Sent</a>
        </div>
    </div>
</div>

<script>
    const menuToggle = document.getElementById('menuToggle');
    const sidebar = document.querySelector('.sidebar');
    const sidebarClose = document.getElementById('sidebarClose');

    menuToggle.addEventListener('click', () => {
        sidebar.classList.toggle('active');
    });

    sidebarClose.addEventListener('click', () => {
        sidebar.classList.remove('active');
    });
</script>
</body>
</html>
