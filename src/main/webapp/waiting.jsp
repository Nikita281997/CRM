<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Waiting Projects</title>
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

        .sidebar .page-title {
            font-size: 1.2rem;
            color: var(--text-color);
            font-weight: 500;
            margin-bottom: 20px;
            text-align: center;
            display: none;
        }

        .sidebar .active .page-title {
            display: block;
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

        .sidebar .active:hover {
            background: #1a91da;
        }

        .sidebar .profile {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 15px;
            margin-top: auto;
            cursor: pointer;
        }

        .sidebar .profile img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
        }

        .sidebar .profile span {
            font-size: 0.9rem;
            color: var(--text-color);
            font-weight: 500;
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
            justify-content: flex-start;
            align-items: center;
            margin-bottom: 25px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .page-title {
            font-size: 1.8rem;
            color: var(--text-color);
            font-weight: 500;
        }

        .filter-buttons-container {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .filter-btn {
            padding: 8px 15px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            border: 1px solid #e5e7eb;
            background: #f5f7fa;
            color: #000;
            text-decoration: none;
            font-size: 0.9rem;
            opacity: 0.7;
        }

        .filter-btn:hover {
            opacity: 0.9;
            transform: translateY(-2px);
        }

        .filter-btn.active {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
            opacity: 1;
        }

        .stats-container {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 25px;
        }

        .stats-card {
            background: linear-gradient(135deg, #b3c9e6, #a3d8e0);
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            text-align: center;
            color: #333;
        }

        .stats-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .stats-card .stats-info h3 {
            font-size: 1.2rem;
            color: #333;
            margin-bottom: 5px;
        }

        .stats-card .stats-info p {
            font-size: 1.5rem;
            font-weight: 600;
            color: #333;
        }

        .table-container {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            border: 1px solid #e5e7eb;
            padding: 25px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .table-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        .table-wrapper {
            max-height: 560px;
            overflow-y: auto;
            border-radius: 8px;
            width: 100%;
            margin-top: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            text-align: left;
        }

        thead {
            background-color: var(--table-header-bg);
            position: sticky;
            top: 0;
            z-index: 10;
        }

        th, td {
            padding: 12px 15px;
            border-bottom: 1px solid #e5e7eb;
        }

        th {
            font-size: 14px;
            text-transform: uppercase;
            color: #6b7280;
            font-weight: bold;
            white-space: nowrap;
        }

        tr:hover {
            background: #f0faff;
            transform: scale(1.01);
        }

        .action-btn {
            border: none;
            padding: 8px 15px;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            margin: 2px;
            white-space: nowrap;
            background: #00c4b4;
            color: white;
        }

        .action-btn i {
            margin-right: 5px;
        }

        .action-btn:hover {
            transform: scale(1.05);
            opacity: 0.9;
        }

        .message {
            padding: 12px 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            text-align: center;
            font-weight: 500;
            animation: fadeIn 0.5s ease-out;
        }

        .error-message {
            background-color: #ffeded;
            color: #e53e3e;
            border: 1px solid #e53e3e;
        }

        .success-message {
            background-color: #edfff6;
            color: #38a169;
            border: 1px solid #38a169;
        }

        .date-cell {
            white-space: nowrap;
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
            
            .sidebar-close {
                display: block;
            }

            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
        }

        @media (min-width: 992px) {
            .menu-toggle {
                display: none;
            }
        }

        @media (max-width: 768px) {
            .table-wrapper {
                display: block;
                overflow-x: auto;
            }
            
            table {
                display: block;
                width: 100%;
                overflow-x: auto;
            }
            
            thead, tbody, th, td, tr {
                display: block;
            }
            
            thead tr {
                position: absolute;
                top: -9999px;
                left: -9999px;
            }
            
            tr {
                margin-bottom: 15px;
                border: 1px solid #eee;
                border-radius: 8px;
            }
            
            td {
                border: none;
                border-bottom: 1px solid #eee;
                position: relative;
                padding-left: 50%;
                white-space: normal;
                text-align: right;
            }
            
            td:before {
                position: absolute;
                left: 15px;
                width: 45%;
                padding-right: 10px;
                white-space: nowrap;
                text-align: left;
                font-weight: bold;
                content: attr(data-title);
            }
            
            .action-btn {
                width: 100%;
                justify-content: center;
                margin: 5px 0;
            }

            .filter-buttons-container {
                flex-direction: column;
                width: 100%;
            }

            .filter-btn {
                width: 100%;
                text-align: center;
            }
        }

        .fade-in {
            animation: fadeIn 0.5s ease-out;
        }

        .slide-up {
            animation: slideUp 0.5s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideUp {
            from { 
                opacity: 0;
                transform: translateY(20px);
            }
            to { 
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <button class="sidebar-close" id="sidebarClose">×</button>
            <img src="${pageContext.request.contextPath}/images/TARS.jpg" alt="Tars Logo" class="logo" 
                 onerror="console.error('Failed to load logo'); this.src='https://via.placeholder.com/150?text=Logo+Not+Found';">
            <div class="page-title">Projects</div>
            <div class="sidebar-menu">
                <ul>
                    <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li><a href="leads.jsp"><i class="fas fa-users"></i> Leads</a></li>
                    <li><a href="leadmanagement.jsp"><i class="fas fa-tasks"></i> Lead Management</a></li>
                    <li class="active"><a href="#"><i class="fas fa-project-diagram"></i> Projects</a></li>
                    <li><a href="quotes.jsp"><i class="fas fa-file-invoice-dollar"></i> Quotes</a></li>
                    <li><a href="financemanagement.jsp"><i class="fas fa-money-bill-wave"></i> Finance Management</a></li>
                    <li><a href="contacts.jsp"><i class="fas fa-address-book"></i> Contacts</a></li>
                    <li><a href="tasks.jsp"><i class="fas fa-check-circle"></i> Tasks</a></li>
                    <li><a href="emp.jsp"><i class="fas fa-user-tie"></i> Employees</a></li>
                    <li><a href="email.jsp"><i class="fas fa-envelope"></i> Email</a></li>
                    <li><a href="Organizations.jsp"><i class="fas fa-building"></i> Organizations</a></li>
                    <li><a href="integration.jsp"><i class="fas fa-plug"></i> Integration</a></li>
                    <li><a href="delivered.jsp"><i class="fas fa-truck"></i> Delivered</a></li>
                    <li><a href="fetch_meetings_all.jsp"><i class="fas fa-calendar-alt"></i> Calendar</a></li>
                </ul>
            </div>
            <%
                Connection conNav = null;
                PreparedStatement pstmtNav = null;
                ResultSet rsNav = null;
                String fullName = "User";
                String imgPath = "https://via.placeholder.com/40";

                try {
                    String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                    conNav = DriverManager.getConnection(url, user, pass);

                    String companyIdStrNav = (String) session.getAttribute("company_id");
                    Integer companyIdNav = null;

                    if (companyIdStrNav == null || companyIdStrNav.trim().isEmpty()) {
                        response.sendRedirect("login1.jsp");
                        return;
                    }

                    try {
                        companyIdNav = Integer.parseInt(companyIdStrNav);
                    } catch (NumberFormatException e) {
                        response.sendRedirect("login1.jsp");
                        return;
                    }

                    String query = "SELECT full_name, img FROM company_registration1 WHERE company_id = ?";
                    pstmtNav = conNav.prepareStatement(query);
                    pstmtNav.setInt(1, companyIdNav);
                    rsNav = pstmtNav.executeQuery();

                    if (rsNav.next()) {
                        fullName = rsNav.getString("full_name");
                        imgPath = rsNav.getString("img");
                        if (imgPath == null || imgPath.isEmpty()) {
                            imgPath = "https://via.placeholder.com/40";
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rsNav != null) try { rsNav.close(); } catch (SQLException e) {}
                    if (pstmtNav != null) try { pstmtNav.close(); } catch (SQLException e) {}
                    if (conNav != null) try { conNav.close(); } catch (SQLException e) {}
                }
            %>
            <div class="profile" onclick="window.location.href='profile1.jsp'">
                <img src="<%= imgPath %>" alt="User Profile">
                <span><%= fullName %></span>
            </div>
        </div>

        <!-- Main Content -->
        <div class="content">
            <!-- Navbar -->
            <div class="navbar slide-up">
                <button class="menu-toggle" id="menuToggle">
                    <i class="fas fa-bars"></i>
                </button>
            </div>

            <div class="stats-container slide-up">
                <%
                    int totalProjects = 0;
                    int ongoingProjects = 0;
                    int waitingProjects = 0;
                    int testingProjects = 0;
                    Connection statsCon = null;
                    PreparedStatement statsPs = null;
                    ResultSet statsRs = null;

                    try {
                        String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                        statsCon = DriverManager.getConnection(url, user, pass);

                        String companyIdStr = (String) session.getAttribute("company_id");
                        Integer companyId = null;
                        if (companyIdStr != null) {
                            try {
                                companyId = Integer.parseInt(companyIdStr);
                            } catch (NumberFormatException e) {
                                e.printStackTrace();
                            }
                        }

                        if (companyId == null) {
                            response.sendRedirect("login1.jsp");
                            return;
                        }

                        String totalQuery = "SELECT COUNT(*) FROM project WHERE company_id = ?";
                        statsPs = statsCon.prepareStatement(totalQuery);
                        statsPs.setInt(1, companyId);
                        statsRs = statsPs.executeQuery();
                        if (statsRs.next()) {
                            totalProjects = statsRs.getInt(1);
                        }
                        statsRs.close();
                        statsPs.close();

                        String waitingQuery = "SELECT COUNT(*) FROM financemanagement WHERE installment1 IS NULL AND company_id = ? AND project_name IS NOT NULL";
                        statsPs = statsCon.prepareStatement(waitingQuery);
                        statsPs.setInt(1, companyId);
                        statsRs = statsPs.executeQuery();
                        if (statsRs.next()) {
                            waitingProjects = statsRs.getInt(1);
                        }
                        statsRs.close();
                        statsPs.close();

                        String ongoingQuery = "SELECT COUNT(*) FROM financemanagement f JOIN leads l ON f.lead_id = l.lead_id JOIN project p ON l.lead_id = p.lead_id WHERE (f.installment1 IS NOT NULL OR f.installment1 = 0) AND l.company_id = ? AND p.percent < 100";
                        statsPs = statsCon.prepareStatement(ongoingQuery);
                        statsPs.setInt(1, companyId);
                        statsRs = statsPs.executeQuery();
                        if (statsRs.next()) {
                            ongoingProjects = statsRs.getInt(1);
                        }
                        statsRs.close();
                        statsPs.close();

                        String testingQuery = "SELECT COUNT(*) FROM testertable WHERE company_id = ?";
                        statsPs = statsCon.prepareStatement(testingQuery);
                        statsPs.setInt(1, companyId);
                        statsRs = statsPs.executeQuery();
                        if (statsRs.next()) {
                            testingProjects = statsRs.getInt(1);
                        }
                        statsRs.close();
                        statsPs.close();

                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (statsRs != null) try { rsNav.close(); } catch (SQLException e) {}
                        if (statsPs != null) try { statsPs.close(); } catch (SQLException e) {}
                        if (statsCon != null) try { statsCon.close(); } catch (SQLException e) {}
                    }
                %>
                <div class="stats-card">
                    <div class="stats-info">
                        <h3>Total Projects</h3>
                        <p><%= totalProjects %></p>
                    </div>
                </div>
                <div class="stats-card">
                    <div class="stats-info">
                        <h3>On-going</h3>
                        <p><%= ongoingProjects %></p>
                    </div>
                </div>
                <div class="stats-card">
                    <div class="stats-info">
                        <h3>Waiting</h3>
                        <p><%= waitingProjects %></p>
                    </div>
                </div>
                <div class="stats-card">
                    <div class="stats-info">
                        <h3>Testing</h3>
                        <p><%= testingProjects %></p>
                    </div>
                </div>
            </div>

            <div class="page-header slide-up">
                <h1 class="page-title">Waiting Projects</h1>
                <div class="filter-buttons-container slide-up">
                    <a href="projects.jsp" class="filter-btn">All Projects</a>
                    <a href="ongoing.jsp" class="filter-btn">On-going</a>
                    <a href="waiting.jsp" class="filter-btn active">Waiting</a>
                    <a href="testing.jsp" class="filter-btn">Testing</a>
                </div>
            </div>

            <div class="table-container slide-up">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Lead ID</th>
                                <th>Project Name</th>
                                <th>Due Date</th>
                                <th>Customer Name</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection con = null;
                                PreparedStatement ps = null;
                                ResultSet rs = null;

                                try {
                                    HttpSession sessionVar = request.getSession();
                                    String companyIdStr = (String) sessionVar.getAttribute("company_id");
                                    Integer companyId = null;

                                    if (companyIdStr != null) {
                                        try {
                                            companyId = Integer.parseInt(companyIdStr);
                                        } catch (NumberFormatException e) {
                                            e.printStackTrace();
                                        }
                                    }

                                    if (companyId == null) {
                                        response.sendRedirect("login1.jsp");
                                        return;
                                    }

                                    String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection(url, user, pass);

                                    String query = "SELECT * FROM financemanagement WHERE installment1 IS NULL AND company_id = ? AND project_name IS NOT NULL";
                                    ps = con.prepareStatement(query);
                                    ps.setInt(1, companyId);
                                    rs = ps.executeQuery();

                                    boolean hasResults = false;

                                    while (rs.next()) {
                                        hasResults = true;
                            %>
                            <tr>
                                <td data-title="Lead ID"><%= rs.getInt("lead_id") %></td>
                                <td data-title="Project Name"><%= rs.getString("project_name") != null ? rs.getString("project_name") : "N/A" %></td>
                                <td data-title="Due Date" class="date-cell" style="color: var(--danger);"><%= rs.getString("due_date") != null ? rs.getString("due_date") : "Not set" %></td>
                                <td data-title="Customer Name"><%= rs.getString("customer_name") != null ? rs.getString("customer_name") : "N/A" %></td>
                                <td data-title="Actions" style="white-space: nowrap;">
                                    <form action="UpdateInstallmentServlet" method="post">
                                        <input type="hidden" name="lead_id" value="<%= rs.getInt("lead_id") %>">
                                        <button type="submit" class="action-btn">
                                            <i class="fas fa-check-circle"></i> Mark as On-going
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                    }

                                    if (!hasResults) {
                                        out.println("<tr><td colspan='5' style='text-align:center; color:var(--danger);'>No waiting projects found</td></tr>");
                                    }

                                    rs.close();
                                    ps.close();
                                    con.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    out.println("<tr><td colspan='5' style='text-align:center; color:var(--danger);'>Error fetching data</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
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

        document.addEventListener('click', function(event) {
            if (window.innerWidth <= 992) {
                if (!sidebar.contains(event.target) && !menuToggle.contains(event.target)) {
                    sidebar.classList.remove('active');
                }
            }
        });

        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                sidebar.classList.remove('active');
            }
        });

        setTimeout(function() {
            const messages = document.querySelectorAll('.message');
            messages.forEach(function(message) {
                message.style.display = 'none';
            });
        }, 5000);
    </script>
</body>
</html>