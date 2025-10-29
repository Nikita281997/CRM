<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leads</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --primary: #0c022d;
            --secondary: #e6f0fa;
            --accent: #00c4b4;
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
            --table-header-bg: #f5f7fa; /* Matches quotes.jsp */
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

        /* Sidebar Styles */
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
            width: 150px;
            height: 150px;
            max-height: 150px;
            min-height: 150px;
            margin-bottom: 30px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(0,0,0,0.1);
            display: block;
            margin-left: auto;
            margin-right: auto;
            object-fit: contain;
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
            background: #00b0a3;
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

        .logout-btn {
            background: var(--accent);
            color: white;
            border: none;
            padding: 12px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-top: auto;
        }

        .logout-btn:hover {
            background: #00b0a3;
            transform: translateY(-2px);
        }

        .logout-btn i {
            margin-right: 8px;
        }

        /* Main Content */
        .content {
            flex: 1;
            margin-left: 240px;
            padding: 20px;
            transition: margin-left 0.3s ease;
        }

        /* Navbar */
        .navbar {
            background: transparent;
            padding: 15px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .navbar h1 {
            font-size: 1.5rem;
            font-weight: 500;
            color: var(--text-color);
        }

        .navbar .user-profile {
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
        }

        .navbar .user-profile img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
        }

        .navbar .user-profile span {
            font-size: 0.9rem;
            color: var(--text-color);
            font-weight: 500;
        }

        /* Page Header */
        .page-header {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            margin-bottom: 20px;
            gap: 10px; /* Added gap between buttons */
        }

        .page-title {
            font-size: 1.8rem;
            color: var(--text-color);
            font-weight: 500;
        }

        /* Buttons */
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

        .btn-secondary {
            background: var(--warning);
            color: white;
        }

        .btn-secondary:hover {
            background: #e6b800;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn i {
            margin-right: 8px;
        }

        /* Table Container */
        .table-container {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            padding: 25px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .table-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        /* Table Wrapper */
        .table-wrapper {
            max-height: 560px;
            overflow-y: auto;
            border-radius: 8px;
            width: 100%;
            margin-top: 20px;
        }

        /* Table Styling */
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

        /* Action Buttons */
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

        .action-btn.status {
            background: #36a2eb;
            color: white;
        }

        .action-btn.status.connected {
            background: #28a745;
        }

        .action-btn.edit {
            background: #ffcd56;
            color: white;
        }

        .action-btn.delete {
            background: #ff6384;
            color: white;
        }

        .action-btn.restore {
            background: #28a745;
            color: white;
        }

        /* Modal Styles */
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
            border-radius: var(--border-radius);
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

        /* Mobile Menu Toggle */
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

        /* Responsive Design */
        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-100%);
                width: 280px;
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
            
            .page-title {
                font-size: 1.5rem;
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
            
            .action-buttons {
                display: flex;
                flex-direction: column;
                gap: 10px;
            }
            
            .action-btn {
                width: 100%;
                justify-content: center;
                margin: 5px 0;
            }

            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
        }

        /* Animation Classes */
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

        /* Notification Styles */
        .notification {
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 350px;
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            padding: 20px;
            z-index: 1100;
            transform: translateX(120%);
            transition: transform 0.5s cubic-bezier(0.68, -0.55, 0.27, 1.55);
            border-left: 4px solid var(--warning);
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
            color: var(--text-color);
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
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 0.8rem;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
        }

        .notification-btn.ok {
            background-color: var(--success);
            color: white;
        }

        .notification-btn.ok:hover {
            background-color: #00b0a3;
        }

        @media (max-width: 768px) {
            .notification {
                bottom: 10px;
                right: 10px;
                max-width: 90%;
                width: auto;
            }
        }
    </style>
</head>
<body>
    <%!
        // Helper method to escape JavaScript strings
        public String escapeJavaScript(String input) {
            if (input == null) {
                return "";
            }
            return input.replace("'", "\\'").replace("\n", "\\n").replace("\r", "\\r");
        }
    %>
    <%
        // Define sessionVar at the top to be accessible throughout the JSP
        HttpSession sessionVar = request.getSession();
        // Check for the view parameter to determine which leads to show
        String view = request.getParameter("view");
        if (view == null) {
            view = "active"; // Default to active leads
        }
    %>
    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <button class="sidebar-close" id="sidebarClose">×</button>
            <img src="${pageContext.request.contextPath}/images/TARS.jpg" alt="Tars Logo" class="logo" 
                 onerror="console.error('Failed to load logo'); this.src='https://via.placeholder.com/150?text=Logo+Not+Found';">
            <div class="sidebar-menu">
                <ul>
                    <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li class="active"><a href="#"><i class="fas fa-users"></i> Leads</a></li>
                    <li><a href="leadmanagement.jsp"><i class="fas fa-tasks"></i> Lead Management</a></li>
                    <li><a href="projects.jsp"><i class="fas fa-project-diagram"></i> Projects</a></li>
                    <li><a href="quotes.jsp"><i class="fas fa-file-invoice-dollar"></i> Quotes</a></li>
                    <li><a href="financemanagement.jsp"><i class="fas fa-money-bill-wave"></i> Finance Management</a></li>
                    <li><a href="contacts.jsp"><i class="fas fa-address-book"></i> Contacts</a></li>
                    <li><a href="tasks.jsp"><i class="fas fa-check-circle"></i> Tasks</a></li>
                    <li><a href="emp.jsp"><i class="fas fa-user-tie"></i> Employees</a></li>
                    <li><a href="email.jsp"><i class="fas fa-envelope"></i> Email</a></li>
                    <li><a href="Organizations.jsp"><i class="fas fa-building"></i> Organizations</a></li>
                    <li><a href="integration.jsp"><i class="fas fa-plug"></i> Integration</a></li>
                    <li><a href="delivered.jsp"><i class="fas fa-truck"></i> Delivered</a></li>
                </ul>
            </div>
            <form action="LogoutServlet" method="post">
                <button type="submit" class="logout-btn">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </form>
        </div>

        <!-- Main Content -->
        <div class="content">
            <!-- Navbar -->
            <div class="navbar slide-up">
                <button class="menu-toggle" id="menuToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <h1>Leads</h1>
                <%
                    Connection con = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    String fullName = "User";
                    String imgPath = "https://via.placeholder.com/40";

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

                        String companyIdStr = (String) sessionVar.getAttribute("company_id");
                        Integer companyId = null;

                        if (companyIdStr == null || companyIdStr.trim().isEmpty()) {
                            response.sendRedirect("login1.jsp");
                            return;
                        }

                        try {
                            companyId = Integer.parseInt(companyIdStr);
                        } catch (NumberFormatException e) {
                            response.sendRedirect("login1.jsp");
                            return;
                        }

                        String query = "SELECT full_name, img FROM company_registration1 WHERE company_id = ?";
                        pstmt = con.prepareStatement(query);
                        pstmt.setInt(1, companyId);
                        rs = pstmt.executeQuery();

                        if (rs.next()) {
                            fullName = rs.getString("full_name");
                            imgPath = rs.getString("img");
                            if (imgPath == null || imgPath.isEmpty()) {
                                imgPath = "https://via.placeholder.com/40";
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                        if (con != null) try { con.close(); } catch (SQLException e) {}
                    }
                %>
                <div class="user-profile" onclick="window.location.href='profile1.jsp'">
                    <img src="<%= imgPath %>" alt="User Profile">
                    <span><%= fullName %></span>
                </div>
            </div>
            
            <!-- Page Content -->
            <div class="page-header">
                <% if (view.equals("active")) { %>
                    <button class="btn btn-primary" onclick="openModal()">
                        <i class="fas fa-plus"></i> Add Lead
                    </button>
                    <button class="btn btn-secondary" onclick="window.location.href='leads.jsp?view=deleted'">
                        <i class="fas fa-trash-alt"></i> Deleted Items
                    </button>
                <% } else { %>
                    <button class="btn btn-secondary" onclick="window.location.href='leads.jsp?view=active'">
                        <i class="fas fa-arrow-left"></i> Back to Active Leads
                    </button>
                <% } %>
            </div>
            
            <div class="table-container slide-up">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Lead Id</th>
                                <th>Project Name</th>
                                <th>Firm</th>
                                <th>In Date</th>
                                <th>Customer Name</th>
                                <th>Email</th>
                                <th>Contact</th>
                                <th>Address</th>
                                <th>Organizations</th>
                                <th>Added By</th>
                                <% if (view.equals("deleted")) { %>
                                    <th>Days Left to Delete Permanently</th>
                                <% } %>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            Connection conTable = null;
                            PreparedStatement psTable = null;
                            ResultSet rsTable = null;
                            try {
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
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conTable = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
                                // Modify query to filter based on view
                                String query = "SELECT * FROM leads WHERE company_id=? AND status=? ORDER BY created_at DESC";
                                psTable = conTable.prepareStatement(query);
                                psTable.setInt(1, companyId);
                                psTable.setString(2, view.equals("active") ? "YES" : "NO");

                                rsTable = psTable.executeQuery();

                                LocalDateTime now = LocalDateTime.now();
                                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

                                while (rsTable.next()) {
                                    int leadId = rsTable.getInt("lead_id");
                                    String projectName = escapeJavaScript(rsTable.getString("project_name"));
                                    String firm = escapeJavaScript(rsTable.getString("firm"));
                                    String inDate = escapeJavaScript(rsTable.getString("in_date"));
                                    String customerName = escapeJavaScript(rsTable.getString("customer_name"));
                                    String email = escapeJavaScript(rsTable.getString("email"));
                                    String contact = escapeJavaScript(rsTable.getString("contact"));
                                    String address = escapeJavaScript(rsTable.getString("address"));
                                    String status = escapeJavaScript(rsTable.getString("status"));
                                    String org = escapeJavaScript(rsTable.getString("org") != null ? rsTable.getString("org") : "");
                                    String statusUpdatedAtStr = rsTable.getString("status_updated_at");

                                    String daysLeftDisplay = "N/A";
                                    if (view.equals("deleted") && statusUpdatedAtStr != null) {
                                        LocalDateTime statusUpdatedAt = LocalDateTime.parse(statusUpdatedAtStr, formatter);
                                        long daysSinceUpdate = ChronoUnit.DAYS.between(statusUpdatedAt, now);
                                        long daysLeft = 30 - daysSinceUpdate;
                                        if (daysLeft < 0) {
                                            daysLeft = 0;
                                        }
                                        daysLeftDisplay = daysLeft + " days";
                                    }
                        %>
                        <tr>
                            <td data-title="Lead ID"><%= leadId %></td>
                            <td data-title="Project Name"><%= rsTable.getString("project_name") %></td>
                            <td data-title="Firm"><%= rsTable.getString("firm") %></td>
                            <td data-title="In Date"><%= rsTable.getString("in_date") %></td>
                            <td data-title="Customer Name"><%= rsTable.getString("customer_name") %></td>
                            <td data-title="Email"><%= rsTable.getString("email") %></td>
                            <td data-title="Contact"><%= rsTable.getString("contact") %></td>
                            <td data-title="Address"><%= rsTable.getString("address") %></td>
                            <td data-title="Organizations"><%= (rsTable.getString("org") != null && !rsTable.getString("org").isEmpty()) ? rsTable.getString("org") : "---" %></td>
                            <td data-title="Added By"><%= rsTable.getString("emp_name") != null ? rsTable.getString("emp_name") : "Admin" %></td>
                            <% if (view.equals("deleted")) { %>
                                <td data-title="Days Left to Delete Permanently">
                                    <%= daysLeftDisplay %>
                                </td>
                            <% } %>
                        </tr>
                        <tr>
                            <td colspan="<%= view.equals("deleted") ? 11 : 10 %>">
                                <div style="display: flex; justify-content: flex-end;">
                                    <% if (view.equals("active")) { %>
                                        <!-- Remove the status button as we're repurposing the status column -->
                                        <button class="action-btn edit" onclick="openEditPopup(<%= leadId %>, '<%= projectName %>', '<%= firm %>', '<%= inDate %>', '<%= customerName %>', '<%= email %>', '<%= contact %>', '<%= address %>', '<%= status %>', '<%= org %>')">
                                            <i class="fas fa-edit"></i> Edit
                                        </button>
                                        <button class="action-btn delete" onclick="softDeleteLead(<%= leadId %>)">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                    <% } else { %>
                                        <button class="action-btn restore" onclick="restoreLead(<%= leadId %>)">
                                            <i class="fas fa-undo"></i> Restore
                                        </button>
                                        <button class="action-btn delete" onclick="deleteLead(<%= leadId %>)">
                                            <i class="fas fa-trash-alt"></i> Permanently Delete
                                        </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
                                if (rsTable != null) rsTable.close();
                                if (psTable != null) psTable.close();
                                if (conTable != null) conTable.close();
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal for Add Lead -->
    <div class="modal" id="addContactModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Add Lead</h2>
                <button class="close-btn" onclick="closeModal()">×</button>
            </div>
            <form id="addLeadForm" action="addleadservlet" method="post">
                <div class="form-group">
                    <input type="text" class="form-control" name="proname" placeholder="Project Name" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="firmname" placeholder="Firm" required>
                </div>
                <div class="form-group">
                    <input type="date" class="form-control" name="indate" id="indate" placeholder="In date" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="customer" placeholder="Customer Name" required>
                </div>
                <div class="form-group">
                    <input type="email" class="form-control" name="email" id="leadEmail" placeholder="Email" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="phone" id="leadPhone" placeholder="Phone" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="address" placeholder="Address" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="org" placeholder="Organization (optional)">
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Save Lead
                </button>
            </form>
        </div>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <script type="text/javascript">
            alert("<%= request.getAttribute("error") %>");
        </script>
    <% } %>

    <!-- Modal for Edit Lead -->
    <div class="modal" id="editdata">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Lead</h2>
                <button class="close-btn" onclick="closeedit()">×</button>
            </div>
            <form id="editLeadForm" action="Editleadservlet" method="post">
                <input type="hidden" name="sourcePage" value="leads.jsp">
                <input type="hidden" name="leadid" id="popup-lead-id">
                
                <div class="form-group">
                    <input type="text" class="form-control" name="proname" id="popup-project-name" placeholder="Project Name" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="firmname" id="popup-firm-name" placeholder="Firm" required>
                </div>
                <div class="form-group">
                    <input type="date" class="form-control" name="indate" id="popup-in-date" placeholder="In date" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="customer" id="popup-customer-name" placeholder="Customer Name" required>
                </div>
                <div class="form-group">
                    <input type="email" class="form-control" name="email" id="popup-email" placeholder="Email" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="phone" id="popup-phone" placeholder="Phone" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="address" id="popup-address" placeholder="Address" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="org" id="popup-org" placeholder="Organization (optional)">
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Update Lead
                </button>
            </form>
        </div>
    </div>

    <%
        // Fetch leads nearing their In Date (within 5 days) for notifications
        String companyIdStr = (String) sessionVar.getAttribute("company_id");
        Integer companyId = null;
        if (companyIdStr != null) {
            try {
                companyId = Integer.parseInt(companyIdStr);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        List<Map<String, Object>> leadsNearingInDate = new ArrayList<>();
        Connection conNotify = null;
        PreparedStatement pstNotify = null;
        ResultSet rsNotify = null;
        try {
            if (companyId != null) {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conNotify = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
                PreparedStatement psNotify = conNotify.prepareStatement("SELECT lead_id, project_name, emp_name, in_date, status FROM leads WHERE company_id = ? AND in_date IS NOT NULL");
                psNotify.setInt(1, companyId);
                rsNotify = psNotify.executeQuery();

                LocalDate today = LocalDate.now();
                while (rsNotify.next()) {
                    String inDateStr = rsNotify.getString("in_date");
                    String status = rsNotify.getString("status");
                    if (inDateStr != null && status != null && status.equals("YES")) {
                        LocalDate inDate = LocalDate.parse(inDateStr);
                        long daysLeft = ChronoUnit.DAYS.between(today, inDate);
                        if (daysLeft >= 0 && daysLeft <= 5) {
                            Map<String, Object> lead = new HashMap<>();
                            lead.put("lead_id", rsNotify.getInt("lead_id"));
                            lead.put("project_name", rsNotify.getString("project_name"));
                            lead.put("emp_name", rsNotify.getString("emp_name") != null ? rsNotify.getString("emp_name") : "Admin");
                            lead.put("in_date", inDateStr);
                            lead.put("days_left", daysLeft);
                            leadsNearingInDate.add(lead);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rsNotify != null) rsNotify.close();
                if (pstNotify != null) pstNotify.close();
                if (conNotify != null) conNotify.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // Generate notifications for leads added within 5 days
        for (Map<String, Object> lead : leadsNearingInDate) {
            String dismissedNotification = (String) session.getAttribute("dismissed_notification_" + lead.get("lead_id"));
            if (dismissedNotification == null) {
    %>
    <div class="notification" id="leadNotification_<%= lead.get("lead_id") %>">
        <div class="notification-header">
            <div class="notification-title">
                <i class="fas fa-exclamation-triangle" style="color: var(--warning); margin-right: 8px;"></i>
                Lead Added Notification
            </div>
            <button class="notification-close" onclick="closeNotification(<%= lead.get("lead_id") %>)">×</button>
        </div>
        <div class="notification-body">
            Lead <strong><%= lead.get("project_name") != null ? lead.get("project_name") : "N/A" %></strong> 
            (ID: <strong><%= lead.get("lead_id") %></strong>) added by <strong><%= lead.get("emp_name") %></strong> 
            was added on <strong><%= lead.get("in_date") != null ? lead.get("in_date") : "N/A" %></strong>.
        </div>
        <div class="notification-footer">
            <button class="notification-btn ok" onclick="handleNotificationResponse(<%= lead.get("lead_id") %>)">OK</button>
        </div>
    </div>
    <%
            }
        }
    %>

    <script>
    // Mobile menu toggle functionality
    const menuToggle = document.getElementById('menuToggle');
    const sidebar = document.querySelector('.sidebar');
    const sidebarClose = document.getElementById('sidebarClose');
    
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

    // Set today's date as default for date inputs
    window.onload = function() {
        var today = new Date();
        var day = ("0" + today.getDate()).slice(-2);
        var month = ("0" + (today.getMonth() + 1)).slice(-2);
        var year = today.getFullYear();
        var dateString = year + "-" + month + "-" + day;

        document.getElementById("indate").value = dateString;

        // Show notifications after page loads, checking sessionStorage
        setTimeout(() => {
            <%
                for (Map<String, Object> lead : leadsNearingInDate) {
                    int leadId = (int) lead.get("lead_id");
            %>
            const notification<%= leadId %> = document.getElementById('leadNotification_<%= leadId %>');
            if (notification<%= leadId %> && sessionStorage.getItem("dismissed_notification_<%= leadId %>") == null) {
                notification<%= leadId %>.classList.add('show');
            }
            <%
                }
            %>
        }, 1000);
    };

    // Email validation for add lead form
    document.getElementById("addLeadForm").addEventListener("submit", function(e) {
        let emailInput = document.getElementById("leadEmail");
        let email = emailInput.value.trim();
        const gmailPattern = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
        
        let phoneInput = document.getElementById("leadPhone");
        let phone = phoneInput.value.trim();
        const phonePattern = /^\d{10}$/;

        if (!gmailPattern.test(email)) {
            alert("Please enter a valid Gmail address (e.g., yourname@gmail.com).");
            emailInput.focus();
            e.preventDefault();
            return false;
        }
        
        if (!phonePattern.test(phone)) {
            alert("Please enter a valid 10-digit phone number.");
            phoneInput.focus();
            e.preventDefault();
            return false;
        }
    });

    // Email and phone validation for edit lead form
    document.getElementById("editLeadForm").addEventListener("submit", function(e) {
        let emailInput = document.getElementById("popup-email");
        let email = emailInput.value.trim();
        const gmailPattern = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
        
        let phoneInput = document.getElementById("popup-phone");
        let phone = phoneInput.value.trim();
        const phonePattern = /^\d{10}$/;

        if (!gmailPattern.test(email)) {
            alert("Please enter a valid Gmail address (e.g., yourname@gmail.com).");
            emailInput.focus();
            e.preventDefault();
            return false;
        }
        
        if (!phonePattern.test(phone)) {
            alert("Please enter a valid 10-digit phone number.");
            phoneInput.focus();
            e.preventDefault();
            return false;
        }
    });

    function softDeleteLead(leadId) {
        if (confirm('Are you sure you want to move this lead to deleted items?')) {
            // Create a form to submit the soft delete request
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'softDeleteLead.jsp';
            
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'lead_id';
            input.value = leadId;
            
            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }
    }

    function restoreLead(leadId) {
        if (confirm('Are you sure you want to restore this lead?')) {
            // Create a form to submit the restore request
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'restoreLead.jsp';
            
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'lead_id';
            input.value = leadId;
            
            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }
    }

    function deleteLead(leadId) {
        if (confirm('Are you sure you want to permanently delete this lead? This action cannot be undone.')) {
            window.location.href = "deleteleadservlet?leadid=" + leadId;
        }
    }

    function openEditPopup(leadId, projectName, firmName, inDate, customerName, email, phone, address, status, org) {
        document.getElementById('popup-lead-id').value = leadId;
        document.getElementById('popup-project-name').value = projectName;
        document.getElementById('popup-firm-name').value = firmName;
        document.getElementById('popup-in-date').value = inDate;
        document.getElementById('popup-customer-name').value = customerName;
        document.getElementById('popup-email').value = email;
        document.getElementById('popup-phone').value = phone;
        document.getElementById('popup-address').value = address;
        document.getElementById('popup-org').value = org || '';
        
        document.getElementById('editdata').classList.add('active');
    }

    function closeedit() {
        document.getElementById('editdata').classList.remove('active');
    }

    const amodal = document.getElementById('addContactModal');
    function openModal() {
        amodal.classList.add('active');
    }
    function closeModal() {
        amodal.classList.remove('active');
    }

    // Notification functions
    function closeNotification(leadId) {
        const notification = document.getElementById('leadNotification_' + leadId);
        if (notification) {
            notification.classList.remove('show');
            setTimeout(() => {
                notification.style.display = 'none';
            }, 500);
        }
    }

    function handleNotificationResponse(leadId) {
        sessionStorage.setItem("dismissed_notification_" + leadId, "true");
        closeNotification(leadId);
    }
    </script>
</body>
</html>