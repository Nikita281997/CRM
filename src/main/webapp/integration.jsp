<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Integration Management | CRMSPOT</title>
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
            --sidebar-width: 240px;
            --transition: all 0.3s ease;
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
            width: var(--sidebar-width);
            background: var(--sidebar-bg);
            color: var(--text-color);
            padding: 20px;
            position: fixed;
            height: 100vh;
            transition: var(--transition);
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
            transition: var(--transition);
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
            margin-left: var(--sidebar-width);
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
            justify-content: flex-end;
            align-items: center;
            margin-bottom: 20px;
            margin-top: -47px;
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
            background: #00b0a3;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn i {
            margin-right: 8px;
        }

        .table-container {
            background: var(--card-bg);
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            padding: 25px;
            transition: all 0.3s ease;
            margin-bottom: 20px;
        }

        .table-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        .table-wrapper {
            max-height: 500px;
            overflow-y: auto;
            border-radius: 8px;
            width: 100%;
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

        thead th {
            padding: 15px;
            font-size: 14px;
            text-transform: uppercase;
            color: #6b7280;
            font-weight: 600;
            border-bottom: 2px solid #e5e7eb;
            white-space: nowrap;
        }

        tbody td {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
            transition: all 0.3s ease;
        }

        tbody tr:hover {
            background-color: #f0faff;
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
        }

        .action-btn i {
            margin-right: 5px;
        }

        .action-btn:hover {
            transform: scale(1.05);
            opacity: 0.9;
        }

        .action-btn.renew {
            background: #1da1f2;
            color: white;
        }

        .action-btn.delete {
            background: #e24728;
            color: white;
        }

        .modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 2000;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }

        .modal.active {
            opacity: 1;
            visibility: visible;
        }

        .modal-content {
            background: var(--card-bg);
            border-radius: 10px;
            width: 90%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 5px 30px rgba(0,0,0,0.2);
            transform: translateY(-20px);
            transition: all 0.3s ease;
            padding: 25px;
            position: relative;
        }

        .modal.active .modal-content {
            transform: translateY(0);
        }

        .modal-header {
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h2 {
            font-size: 1.5rem;
            color: var(--text-color);
        }

        .close-btn {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #6b7280;
            transition: all 0.3s ease;
        }

        .close-btn:hover {
            color: var(--accent);
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: var(--text-color);
        }

        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(0, 196, 180, 0.1);
            outline: none;
        }

        select.form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background-color: white;
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

        .notification {
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 350px;
            background: var(--card-bg);
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            padding: 20px;
            z-index: 3000;
            transform: translateX(120%);
            transition: transform 0.5s cubic-bezier(0.68, -0.55, 0.27, 1.55);
            border-left: 5px solid var(--warning);
        }

        .notification.show {
            transform: translateX(0);
        }

        .notification-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .notification-title {
            font-weight: 600;
            color: var(--text-color);
            font-size: 1.1rem;
        }

        .notification-close {
            background: none;
            border: none;
            color: #6b7280;
            cursor: pointer;
            font-size: 1.2rem;
        }

        .notification-body {
            margin-bottom: 15px;
            color: #4b5563;
        }

        .notification-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .notification-btn {
            padding: 8px 15px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
        }

        .notification-btn.deny {
            background-color: #f3f4f6;
            color: var(--text-color);
        }

        .notification-btn.ok {
            background-color: var(--success);
            color: white;
        }

        .notification-btn.cancel {
            background-color: var(--danger);
            color: white;
        }

        .notification-btn:hover {
            opacity: 0.9;
            transform: translateY(-2px);
        }

        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-100%);
                width: var(--sidebar-width);
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
            
            .navbar {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .page-header {
                justify-content: center;
            }
        }

        @media (max-width: 768px) {
            .action-btn {
                width: 100%;
                justify-content: center;
                margin: 5px 0;
            }
            
            table {
                display: block;
                overflow-x: auto;
                white-space: nowrap;
            }

            .notification {
                width: 90%;
                right: 5%;
                left: 5%;
            }

            .page-header {
                flex-direction: column;
                gap: 10px;
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

        .expired {
            color: var(--danger);
            font-weight: 500;
        }

        .active {
            color: var(--success);
            font-weight: 500;
        }

        .pending {
            color: var(--warning);
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="sidebar">
            <button class="sidebar-close" id="sidebarClose">×</button>
            <img src="${pageContext.request.contextPath}/images/TARS.jpg" alt="Tars Logo" class="logo" 
                 onerror="console.error('Failed to load logo'); this.src='https://via.placeholder.com/150?text=Logo+Not+Found';">
            <div class="page-title">Integration</div>
            <div class="sidebar-menu">
                <ul>
                    <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li><a href="leads.jsp"><i class="fas fa-users"></i> Leads</a></li>
                    <li><a href="leadmanagement.jsp"><i class="fas fa-tasks"></i> Lead Management</a></li>
                    <li><a href="projects.jsp"><i class="fas fa-project-diagram"></i> Projects</a></li>
                    <li><a href="quotes.jsp"><i class="fas fa-file-invoice-dollar"></i> Quotes</a></li>
                    <li><a href="financemanagement.jsp"><i class="fas fa-money-bill-wave"></i> Finance Management</a></li>
                    <li><a href="contacts.jsp"><i class="fas fa-address-book"></i> Contacts</a></li>
                    <li><a href="tasks.jsp"><i class="fas fa-check-circle"></i> Tasks</a></li>
                    <li><a href="emp.jsp"><i class="fas fa-user-tie"></i> Employees</a></li>
                    <li><a href="email.jsp"><i class="fas fa-envelope"></i> Email</a></li>
                    <li><a href="Organizations.jsp"><i class="fas fa-building"></i> Organizations</a></li>
                    <li class="active"><a href="#"><i class="fas fa-plug"></i> Integration</a></li>
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
                            imgPath = "images/default-profile.jpg";
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

        <div class="content">
            <div class="navbar slide-up">
                <button class="menu-toggle" id="menuToggle">
                    <i class="fas fa-bars"></i>
                </button>
            </div>
            
            <div class="page-header">
                <button class="btn btn-primary" onclick="openModal('integrationModal')">
                    <i class="fas fa-plus"></i> Add Integration
                </button>
            </div>
            
            <div class="table-container slide-up">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Service Provider</th>
                                <th>Service Name</th>
                                <th>Buy Date</th>
                                <th>Renew Date</th>
                                <th>Renew Charge</th>
                                <th>Expiry Date</th>
                                <th>Cost</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                PreparedStatement stmt = null;
                                ResultSet rs = null;

                                String companyIdStr = (String) session.getAttribute("company_id"); 
                                Integer companyId = (companyIdStr != null) ? Integer.parseInt(companyIdStr) : null;

                                List<String[]> expiringIntegrations = new ArrayList<>();

                                if (companyId == null) {
                                    out.println("<tr><td colspan='8' class='error-message'>Error: Company ID is missing. Please log in again.</td></tr>");
                                } else {
                                    try {
                                        String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                                        conn = DriverManager.getConnection(url, user, pass);

                                        String query = "SELECT * FROM integrations WHERE company_id = ?";
                                        stmt = conn.prepareStatement(query);
                                        stmt.setInt(1, companyId);
                                        rs = stmt.executeQuery();

                                        boolean hasData = false;
                                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                                        
                                        while (rs.next()) {
                                            hasData = true;
                                            Timestamp buyTimestamp = rs.getTimestamp("buy_date");
                                            Date renewalDate = rs.getDate("renewal_date");
                                            Date expiryDate = rs.getDate("expiry_date");
                                            
                                            if (expiryDate != null) {
                                                Calendar calendar = Calendar.getInstance();
                                                calendar.setTime(expiryDate);
                                                calendar.add(Calendar.DAY_OF_YEAR, -5);
                                                Date fiveDaysBefore = calendar.getTime();
                                                
                                                Date today = new Date();
                                                
                                                if (today.after(fiveDaysBefore) && !today.after(expiryDate)) {
                                                    String deniedNotification = (String) session.getAttribute("denied_notification_" + rs.getInt("id"));
                                                    if (deniedNotification == null) {
                                                        String[] integrationInfo = new String[4];
                                                        integrationInfo[0] = rs.getString("provider");
                                                        integrationInfo[1] = rs.getString("service_name");
                                                        integrationInfo[2] = dateFormat.format(expiryDate);
                                                        integrationInfo[3] = String.valueOf(rs.getInt("id"));
                                                        expiringIntegrations.add(integrationInfo);
                                                    }
                                                }
                                            }
                                            
                                            String statusClass = "";
                                            if (expiryDate != null) {
                                                java.util.Date today = new java.util.Date();
                                                if (expiryDate.before(today)) {
                                                    statusClass = "expired";
                                                } else {
                                                    statusClass = "active";
                                                }
                                            }
                            %>
                            <tr>
                                <td><%= rs.getString("provider") %></td>
                                <td><%= rs.getString("service_name") %></td>
                                <td><%= buyTimestamp != null ? dateFormat.format(buyTimestamp) : "N/A" %></td>
                                <td><%= renewalDate != null ? dateFormat.format(renewalDate) : "N/A" %></td>
                                <td><%= rs.getObject("renewal_charge") != null ? rs.getDouble("renewal_charge") : "N/A" %></td>
                                <td class="<%= statusClass %>">
                                    <%= expiryDate != null ? dateFormat.format(expiryDate) : "N/A" %>
                                </td>
                                <td><%= rs.getDouble("cost") %></td>
                                <td>
                                    <button class="action-btn renew" onclick="openModal('renewModal', <%= rs.getInt("id") %>)">
                                        <i class="fas fa-sync-alt"></i> Renew
                                    </button>
                                    <form action="DeleteIntegrationServlet" method="post" style="display:inline;"> 
                                        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                                        <button type="submit" class="action-btn delete">
                                            <i class="fas fa-trash-alt"></i> Delete
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                        }
                                        if (!hasData) {
                                            out.println("<tr><td colspan='8' style='text-align:center;'>No integrations found for your company.</td></tr>");
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                        out.println("<tr><td colspan='8' class='error-message'>Error fetching data!</td></tr>");
                                    } finally {
                                        if (rs != null) rs.close();
                                        if (stmt != null) stmt.close();
                                        if (conn != null) conn.close();
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="modal" id="renewModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Renew Integration</h2>
                <button class="close-btn" onclick="closeModal('renewModal')">×</button>
            </div>
            <form action="RenewIntegrationServlet" method="post">
                <input type="hidden" name="id" id="renewId">
                <div class="form-group">
                    <label for="renewBuyDate">Buy Date</label>
                    <input type="date" class="form-control" id="renewBuyDate" name="buyDate" required>
                </div>
                <div class="form-group">
                    <label for="renewDuration">Duration (months)</label>
                    <input type="number" class="form-control" id="renewDuration" name="duration" required min="1">
                </div>
                <div class="form-group">
                    <label for="renewCost">New Cost</label>
                    <input type="number" class="form-control" id="renewCost" name="cost" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Renew Integration
                </button>
            </form>
        </div>
    </div>

    <div class="modal" id="integrationModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Add Integration</h2>
                <button class="close-btn" onclick="closeModal('integrationModal')">×</button>
            </div>
            <form action="AddIntegrationServlet" method="post">
                <div class="form-group">
                    <label for="provider">Service Provider</label>
                    <input type="text" class="form-control" id="provider" name="provider" required>
                </div>
                <div class="form-group">
                    <label for="serviceName">Service Name</label>
                    <input type="text" class="form-control" id="serviceName" name="serviceName" required>
                </div>
                <div class="form-group">
                    <label for="buyDate">Buy Date</label>
                    <input type="date" class="form-control" id="buyDate" name="buyDate" required>
                </div>
                <div class="form-group">
                    <label for="duration">Duration (months)</label>
                    <input type="number" class="form-control" id="duration" name="duration" required min="1">
                </div>
                <div class="form-group">
                    <label for="cost">Cost</label>
                    <input type="number" class="form-control" id="cost" name="cost" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Save Integration
                </button>
            </form>
        </div>
    </div>

    <% if (!expiringIntegrations.isEmpty()) { 
        for (String[] integration : expiringIntegrations) { 
            String provider = integration[0];
            String serviceName = integration[1];
            String expiryDate = integration[2];
            int integrationId = Integer.parseInt(integration[3]);
    %>
    <div class="notification" id="expiryNotification_<%= integrationId %>">
        <div class="notification-header">
            <div class="notification-title">
                <i class="fas fa-exclamation-triangle" style="color: var(--warning); margin-right: 8px;"></i>
                Subscription Expiring Soon!
            </div>
            <button class="notification-close" onclick="closeNotification(<%= integrationId %>)">×</button>
        </div>
        <div class="notification-body">
            Your integration with <strong><%= provider %></strong> (<%= serviceName %>) 
            will expire on <strong><%= expiryDate %></strong>. Please renew to avoid service interruption.
        </div>
        <div class="notification-footer">
            <button class="notification-btn deny" onclick="handleNotificationResponse('deny', <%= integrationId %>)">Deny</button>
            <button class="notification-btn cancel" onclick="closeNotification(<%= integrationId %>)">Cancel</button>
            <button class="notification-btn ok" onclick="handleNotificationResponse('ok', <%= integrationId %>)">OK</button>
        </div>
    </div>
    <% } 
    } %>

    <script>
        const sidebar = document.querySelector('.sidebar');
        const menuToggle = document.getElementById('menuToggle');
        const sidebarClose = document.getElementById('sidebarClose');
        
        // Toggle sidebar on mobile
        if (menuToggle) {
            menuToggle.addEventListener('click', () => {
                sidebar.classList.toggle('active');
            });
        }

        if (sidebarClose) {
            sidebarClose.addEventListener('click', () => {
                sidebar.classList.remove('active');
            });
        }

        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', (e) => {
            if (window.innerWidth <= 992 && !sidebar.contains(e.target) && !menuToggle.contains(e.target)) {
                sidebar.classList.remove('active');
            }
        });

        function openModal(modalId, integrationId = null) {
            const modal = document.getElementById(modalId);
            if (integrationId && modalId === 'renewModal') {
                document.getElementById('renewId').value = integrationId;
            }
            modal.classList.add('active');
        }

        function closeModal(modalId) {
            const modal = document.getElementById(modalId);
            modal.classList.remove('active');
        }

        document.addEventListener('click', function(event) {
            const modals = document.querySelectorAll('.modal.active');
            modals.forEach(modal => {
                if (event.target === modal) {
                    modal.classList.remove('active');
                }
            });
        });

        document.addEventListener('keydown', function(event) {
            const modals = document.querySelectorAll('.modal.active');
            if (event.key === 'Escape' && modals.length > 0) {
                modals.forEach(modal => {
                    modal.classList.remove('active');
                });
            }
        });

        window.onload = function() {
            var message = "<%= request.getAttribute("message") != null ? request.getAttribute("message") : "" %>";
            var expiryDate = "<%= request.getAttribute("expiryDate") != null ? request.getAttribute("expiryDate") : "" %>";
            
            if (message.trim() !== "") {
                if (expiryDate.trim() !== "") {
                    alert(message + "\nExpiry Date: " + expiryDate);
                } else {
                    alert(message);
                }
            }

            // Scroll sidebar to bottom on page load
            const sidebarMenu = document.querySelector('.sidebar-menu');
            if (sidebarMenu) {
                sidebarMenu.scrollTop = sidebarMenu.scrollHeight;
            }

            setTimeout(() => {
                <% for (String[] integration : expiringIntegrations) { 
                    int integrationId = Integer.parseInt(integration[3]); %>
                    const notification<%= integrationId %> = document.getElementById('expiryNotification_<%= integrationId %>');
                    if (notification<%= integrationId %>) {
                        notification<%= integrationId %>.classList.add('show');
                    }
                <% } %>
            }, 1000);
        };

        function closeNotification(integrationId) {
            const notification = document.getElementById('expiryNotification_' + integrationId);
            if (notification) {
                notification.classList.remove('show');
                setTimeout(() => {
                    notification.style.display = 'none';
                }, 500);
            }
        }

        function handleNotificationResponse(action, integrationId) {
            if (action === 'deny') {
                fetch('SetNotificationPreferenceServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `action=deny&integrationId=${integrationId}`
                });
            } else if (action === 'ok') {
                openModal('renewModal', integrationId);
            }
            
            closeNotification(integrationId);
        }
    </script>
</body>
</html>