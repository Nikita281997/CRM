<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.time.LocalDate,java.time.temporal.ChronoUnit,java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leads</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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
            margin: 0; /* Ensure no default browser margins */
            width: 100vw; /* Full viewport width */
            overflow-x: hidden; /* Prevent horizontal scroll */
        }

        .container {
            display: flex;
            flex: 1;
            position: relative;
            width: 100%; /* Full width of parent */
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
            left: 0; /* Ensure sidebar is flush with left edge */
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

        /* Main Content */
        .content {
            flex: 1;
            margin-left: 240px; /* Matches sidebar width */
            padding: 0; /* Remove padding to eliminate gaps */
            width: calc(100vw - 240px); /* Full width minus sidebar */
            transition: margin-left 0.3s ease;
                margin-left: 191px;
        }

        /* Navbar */
        .navbar {
            background: transparent;
            padding: 15px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
                margin-top: 21px;
        }

        /* Page Header */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            gap: 10px;
            margin-top: -53px;
            padding: 0 20px; /* Add padding inside header for content */
        }

        /* Dropdown Styling */
        .filter-dropdown {
            padding: 10px;
            border-radius: 8px;
            border: 2px solid #ddd;
            font-size: 1rem;
            background: #fff;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .filter-dropdown:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(0, 196, 180, 0.1);
            outline: none;
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
            background: #1a91da;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn-secondary {
            background: #6b7280;
            color: white;
        }

        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn-danger {
            background: var(--danger);
            color: white;
        }

        .btn-danger:hover {
            background: #e55776;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn-success {
            background: #28a745;
            color: white;
        }

        .btn-success:hover {
            background: #218838;
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
            margin: 0 20px; /* Add margin to prevent content from touching edges */
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
            max-width: 600px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            transform: translateY(-20px);
            transition: all 0.3s ease;
            padding: 25px;
            position: relative;
            background: linear-gradient(135deg, #ffffff 0%, #f0faff 100%);
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
            background-color: var(--table-header-bg);
            border-radius: 10px 10px 0 0;
            padding: 15px;
        }

        .modal-header h2 {
            font-size: 1.8rem;
            color: var(--text-color);
            font-weight: 600;
            text-transform: uppercase;
        }

        .close-btn {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #6b7280;
            transition: all 0.3s ease;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .close-btn:hover {
            color: var(--accent);
            background-color: #e0e7ff;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--dark);
            font-size: 1.1rem;
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #ddd;
            border-radius: 10px;
            font-size: 1rem;
            background: #fff;
            transition: all 0.3s ease;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .form-control:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(0, 196, 180, 0.1);
            outline: none;
        }

        /* Lead Details Popup Grid Layout */
        .popup-grid {
            display: grid;
            gap: 15px;
            margin-bottom: 20px;
        }

        .row-1 {
            grid-template-columns: repeat(3, 1fr);
            column-gap: 15px;
        }

        .row-2, .row-3, .row-4 {
            grid-template-columns: repeat(2, 1fr);
            column-gap: 15px;
        }

        .address-container {
            grid-column: 1 / -1;
            max-height: 100px;
            overflow-y: auto;
        }

        .address-container .form-control {
            min-height: 80px;
            resize: none;
        }

        /* Confirmation Modal Specific Styles */
        .confirmation-modal-content {
            max-width: 400px;
            text-align: center;
        }

        .confirmation-modal-content .modal-header {
            justify-content: center;
            border-bottom: none;
            padding-bottom: 0;
        }

        .confirmation-modal-content p {
            color: var(--text-color);
            margin-bottom: 20px;
            font-size: 1rem;
        }

        .confirmation-buttons {
            display: flex;
            justify-content: center;
            gap: 10px;
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
                width: 240px;
            }
            
            .sidebar.active {
                transform: translateX(0);
            }
            
            .content {
                margin-left: 0;
                width: 100vw; /* Full viewport width on mobile */
                padding: 0;
            }
            
            .menu-toggle {
                display: block;
            }

            .sidebar-close {
                display: block;
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
                padding: 0 10px; /* Adjusted padding for mobile */
            }

            .confirmation-buttons {
                flex-direction: column;
                gap: 10px;
            }

            .confirmation-buttons .btn {
                width: 100%;
            }

            .popup-grid {
                grid-template-columns: 1fr;
            }

            .button-group {
                width: 100%;
                display: flex;
                flex-direction: column;
                align-items: stretch;
            }

            .button-group .btn {
                width: 100%;
                margin-bottom: 10px;
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
        // Check if we need to show deleted leads
        String viewMode = request.getParameter("viewMode");
        boolean showDeleted = "deleted".equals(viewMode);
        // Get filter parameter
        String filter = request.getParameter("filter");
        if (filter == null) filter = "all";
        // Get success/error message from request
        String errorMessage = (String) request.getAttribute("error");
        String successMessage = (String) request.getAttribute("success");
    %>
    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <button class="sidebar-close" id="sidebarClose">×</button>
            <img src="${pageContext.request.contextPath}/images/TARS.jpg?t=${System.currentTimeMillis()}" alt="TARS CRM Logo" class="logo">
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
                    <li><a href="fetch_meetings_all.jsp"><i class="fas fa-calendar-alt"></i> Calendar</a></li>
                    <li><a href="profile1.jsp"><i class="fas fa-user"></i> Profile</a></li>
                </ul>
            </div>
            <div class="profile" onclick="window.location.href='profile1.jsp'">
                <%
                    Connection con = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
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
                        con = DriverManager.getConnection(url, user, pass);

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
                        pstmt = con.prepareStatement(query);
                        pstmt.setInt(1, companyIdNav);
                        rs = pstmt.executeQuery();

                        if (rs.next()) {
                            fullName = rs.getString("full_name");
                            imgPath = rs.getString("img");
                           
                            if (imgPath == null || imgPath.isEmpty()) {
                                imgPath = "images/default-profile.jpg";
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
            
            <!-- Page Content -->
            <div class="page-header">
                <select class="filter-dropdown" id="leadFilter" onchange="filterLeads()">
                    <option value="all" <%= "all".equals(filter) ? "selected" : "" %>>All Leads</option>
                    <option value="connected" <%= "connected".equals(filter) ? "selected" : "" %>>Connected Leads</option>
                    <option value="not_connected" <%= "not_connected".equals(filter) ? "selected" : "" %>>Not Connected Leads</option>
                </select>
                <div class="button-group" style="display: flex; gap: 10px;">
                    <% if (!showDeleted) { %>
                        <button class="btn btn-primary" onclick="openModal()">
                            <i class="fas fa-plus"></i> Add Lead
                        </button>
                        <button class="btn btn-secondary" onclick="window.location.href='leads.jsp?viewMode=deleted'">
                            <i class="fas fa-trash"></i> Deleted Items
                        </button>
                        <button id="connectToggleBtn" class="action-btn status" onclick="toggleConnect()" disabled>
                            <i class="fas fa-check"></i> Connect
                        </button>
                        <button id="editBtn" class="action-btn edit" onclick="openEditPopupWithSelectedLead()" disabled>
                            <i class="fas fa-edit"></i> Edit
                        </button>
                        <button id="deleteBtn" class="action-btn delete" onclick="showConfirmationModalWithSelectedLead('softDelete')" disabled>
                            <i class="fas fa-trash"></i> Delete
                        </button>
                    <% } else { %>
                        <button class="btn btn-primary" onclick="window.location.href='leads.jsp'">
                            <i class="fas fa-arrow-left"></i> Back to Leads
                        </button>
                        <button id="permanentDeleteBtn" class="action-btn delete" onclick="showConfirmationModalWithSelectedLead('permanentDelete')" disabled>
                            <i class="fas fa-trash-alt"></i> Permanent Delete
                        </button>
                        <button id="restoreBtn" class="action-btn restore" onclick="showConfirmationModalWithSelectedLead('restore')" disabled>
                            <i class="fas fa-undo"></i> Restore
                        </button>
                    <% } %>
                </div>
            </div>
            
            <div class="table-container slide-up">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Select</th>
                                <th>Lead Id</th>
                                <th>Project Name</th>
                                <th>Customer Name</th>
                                <th>Added By</th>
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
                                String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                                conTable = DriverManager.getConnection(url, user, pass);
                                String query;
                                if (showDeleted) {
                                    query = "SELECT * FROM leads WHERE company_id=? AND yesno_status='no' ORDER BY lead_id ASC";
                                    psTable = conTable.prepareStatement(query);
                                    psTable.setInt(1, companyId);
                                } else {
                                    if ("connected".equals(filter)) {
                                        query = "SELECT * FROM leads WHERE company_id=? AND yesno_status='yes' AND status='Connected' ORDER BY lead_id ASC";
                                        psTable = conTable.prepareStatement(query);
                                        psTable.setInt(1, companyId);
                                    } else if ("not_connected".equals(filter)) {
                                        query = "SELECT * FROM leads WHERE company_id=? AND yesno_status='yes' AND status='Not Connected' ORDER BY lead_id ASC";
                                        psTable = conTable.prepareStatement(query);
                                        psTable.setInt(1, companyId);
                                    } else {
                                        query = "SELECT * FROM leads WHERE company_id=? AND yesno_status='yes' ORDER BY lead_id ASC";
                                        psTable = conTable.prepareStatement(query);
                                        psTable.setInt(1, companyId);
                                    }
                                }

                                rsTable = psTable.executeQuery();
                                List<Map<String, Object>> leads = new ArrayList<>();
                                while (rsTable.next()) {
                                    Map<String, Object> lead = new HashMap<>();
                                    lead.put("lead_id", rsTable.getInt("lead_id"));
                                    lead.put("project_name", escapeJavaScript(rsTable.getString("project_name")));
                                    lead.put("firm", escapeJavaScript(rsTable.getString("firm")));
                                    lead.put("in_date", escapeJavaScript(rsTable.getString("in_date")));
                                    lead.put("customer_name", escapeJavaScript(rsTable.getString("customer_name")));
                                    lead.put("email", escapeJavaScript(rsTable.getString("email")));
                                    lead.put("contact", escapeJavaScript(rsTable.getString("contact")));
                                    lead.put("address", escapeJavaScript(rsTable.getString("address")));
                                    lead.put("status", escapeJavaScript(rsTable.getString("status")));
                                    lead.put("org", escapeJavaScript(rsTable.getString("org") != null ? rsTable.getString("org") : ""));
                                    lead.put("emp_name", rsTable.getString("emp_name") != null ? rsTable.getString("emp_name") : "Admin");
                                    leads.add(lead);
                                }

                                // Display leads in order of lead_id
                                for (Map<String, Object> lead : leads) {
                                    int leadId = (int) lead.get("lead_id");
                        %>
                        <tr onclick="selectLead(<%= leadId %>, '<%= lead.get("project_name") %>', '<%= lead.get("firm") %>', '<%= lead.get("in_date") %>', '<%= lead.get("customer_name") %>', '<%= lead.get("email") %>', '<%= lead.get("contact") %>', '<%= lead.get("address") %>', '<%= lead.get("org") %>', '<%= lead.get("emp_name") %>', '<%= lead.get("status") %>')">
                            <td data-title="Select"><input type="radio" name="leadRadio" value="<%= leadId %>" onchange="updateSelectedLead(<%= leadId %>, '<%= lead.get("status") %>')"></td>
                            <td data-title="Lead ID"><%= leadId %></td>
                            <td data-title="Project Name"><%= lead.get("project_name") %></td>
                            <td data-title="Customer Name"><%= lead.get("customer_name") %></td>
                            <td data-title="Added By"><%= lead.get("emp_name") %></td>
                        </tr>
                        <tr>
                            <td colspan="5"></td>
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

    <!-- Popup Modal for Lead Details -->
    <div class="modal" id="leadPopupModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Lead Details</h2>
                <button class="close-btn" onclick="closePopup()">×</button>
            </div>
            <div class="popup-grid">
                <!-- First Row: Lead ID, In Date, Contact -->
                <div class="form-group row-1" style="display: grid;">
                    <div>
                        <label>Lead ID</label>
                        <input type="text" class="form-control" id="popup-lead-id-display" readonly>
                    </div>
                    <div>
                        <label>In Date</label>
                        <input type="text" class="form-control" id="popup-in-date-display" readonly>
                    </div>
                    <div>
                        <label>Contact</label>
                        <input type="text" class="form-control" id="popup-contact-display" readonly>
                    </div>
                </div>
                <!-- Second Row: Firm, Customer Name -->
                <div class="form-group row-2" style="display: grid;">
                    <div>
                        <label>Firm</label>
                        <input type="text" class="form-control" id="popup-firm-name-display" readonly>
                    </div>
                    <div>
                        <label>Customer Name</label>
                        <input type="text" class="form-control" id="popup-customer-name-display" readonly>
                    </div>
                </div>
                <!-- Third Row: Project, Email -->
                <div class="form-group row-3" style="display: grid;">
                    <div>
                        <label>Project Name</label>
                        <input type="text" class="form-control" id="popup-project-name-display" readonly>
                    </div>
                    <div>
                        <label>Email</label>
                        <input type="text" class="form-control" id="popup-email-display" readonly>
                    </div>
                </div>
                <!-- Fourth Row: Organization, Added By -->
                <div class="form-group row-4" style="display: grid;">
                    <div>
                        <label>Organization</label>
                        <input type="text" class="form-control" id="popup-org-display" readonly>
                    </div>
                    <div>
                        <label>Added By</label>
                        <input type="text" class="form-control" id="popup-added-by-display" readonly>
                    </div>
                </div>
                <!-- Address: Full-width with Scrollbar -->
                <div class="form-group address-container">
                    <label>Address</label>
                    <textarea class="form-control" id="popup-address-display" readonly></textarea>
                </div>
            </div>
        </div>
    </div>

    <!-- Confirmation Modal for Delete/Restore -->
    <div class="modal" id="confirmationModal">
        <div class="modal-content confirmation-modal-content">
            <div class="modal-header">
                <h2 id="confirmationTitle"></h2>
            </div>
            <p id="confirmationMessage"></p>
            <div class="confirmation-buttons">
                <button class="btn btn-secondary" onclick="closeConfirmationModal()">Cancel</button>
                <button id="confirmActionButton" class="btn"></button>
            </div>
        </div>
    </div>

    <!-- Success/Error Modal -->
    <div class="modal" id="messageModal">
        <div class="modal-content confirmation-modal-content">
            <div class="modal-header">
                <h2 id="messageModalTitle"></h2>
            </div>
            <p id="messageModalText"></p>
            <div class="confirmation-buttons">
                <button class="btn btn-primary" onclick="closeMessageModal()">OK</button>
            </div>
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
                String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                conNotify = DriverManager.getConnection(url, user, pass);
                PreparedStatement psNotify = conNotify.prepareStatement("SELECT lead_id, project_name, emp_name, in_date, status FROM leads WHERE company_id = ? AND in_date IS NOT NULL AND yesno_status = 'yes'");
                psNotify.setInt(1, companyId);
                rsNotify = psNotify.executeQuery();

                LocalDate today = LocalDate.now();
                while (rsNotify.next()) {
                    String inDateStr = rsNotify.getString("in_date");
                    String status = rsNotify.getString("status");
                    if (inDateStr != null && status != null && status.equals("Not Connected")) {
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
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

        // Show success/error modal if message exists
        <% if (errorMessage != null) { %>
            showMessageModal('Error', '<%= escapeJavaScript(errorMessage) %>', 'error');
        <% } else if (successMessage != null) { %>
            showMessageModal('Success', '<%= escapeJavaScript(successMessage) %>', 'success');
        <% } %>

        // Initial button state
        updateButtonStates();
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
            e.preventDefault();
            showMessageModal('Error', 'Please enter a valid Gmail address (e.g., yourname@gmail.com).', 'error');
            emailInput.focus();
            return false;
        }
        
        if (!phonePattern.test(phone)) {
            e.preventDefault();
            showMessageModal('Error', 'Please enter a valid 10-digit phone number.', 'error');
            phoneInput.focus();
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
            e.preventDefault();
            showMessageModal('Error', 'Please enter a valid Gmail address (e.g., yourname@gmail.com).', 'error');
            emailInput.focus();
            return false;
        }
        
        if (!phonePattern.test(phone)) {
            e.preventDefault();
            showMessageModal('Error', 'Please enter a valid 10-digit phone number.', 'error');
            phoneInput.focus();
            return false;
        }
    });

    // Filter leads based on dropdown selection
    function filterLeads() {
        const filter = document.getElementById('leadFilter').value;
        const viewMode = '<%= viewMode != null ? viewMode : "" %>';
        let url = 'leads.jsp';
        if (viewMode) {
            url += '?viewMode=' + viewMode;
            if (filter !== 'all') {
                url += '&filter=' + filter;
            }
        } else if (filter !== 'all') {
            url += '?filter=' + filter;
        }
        window.location.href = url;
    }

    // Message Modal Functions
    function showMessageModal(title, message, type) {
        const modal = document.getElementById('messageModal');
        const modalTitle = document.getElementById('messageModalTitle');
        const modalText = document.getElementById('messageModalText');
        modalTitle.textContent = title;
        modalText.textContent = message;
        modal.classList.add('active');
        if (type === 'success') {
            modal.querySelector('.modal-header').style.backgroundColor = 'var(--success)';
        } else {
            modal.querySelector('.modal-header').style.backgroundColor = 'var(--danger)';
        }
    }

    function closeMessageModal() {
        const modal = document.getElementById('messageModal');
        modal.classList.remove('active');
        window.location.href = 'leads.jsp'; // Refresh page after closing
    }

    // Confirmation Modal Functions
    let currentAction = null;
    let currentLeadId = null;

    function showConfirmationModal(action, leadId) {
        currentAction = action;
        currentLeadId = leadId;
        const modal = document.getElementById('confirmationModal');
        const title = document.getElementById('confirmationTitle');
        const message = document.getElementById('confirmationMessage');
        const confirmButton = document.getElementById('confirmActionButton');

        if (action === 'softDelete') {
            title.textContent = 'Delete Lead';
            message.textContent = 'Are you sure you want to delete this lead? It can be restored later.';
            confirmButton.textContent = 'Delete';
            confirmButton.className = 'btn btn-danger';
            confirmButton.onclick = () => confirmAction();
        } else if (action === 'permanentDelete') {
            title.textContent = 'Permanent Delete Lead';
            message.textContent = 'Are you sure you want to permanently delete this lead? This action cannot be undone.';
            confirmButton.textContent = 'Permanent Delete';
            confirmButton.className = 'btn btn-danger';
            confirmButton.onclick = () => confirmAction();
        } else if (action === 'restore') {
            title.textContent = 'Restore Lead';
            message.textContent = 'Are you sure you want to restore this lead?';
            confirmButton.textContent = 'Restore';
            confirmButton.className = 'btn btn-success';
            confirmButton.onclick = () => confirmAction();
        }

        modal.classList.add('active');
    }

    function closeConfirmationModal() {
        const modal = document.getElementById('confirmationModal');
        modal.classList.remove('active');
        currentAction = null;
        currentLeadId = null;
    }

    function confirmAction() {
        if (!currentLeadId || !currentAction) return;

        if (currentAction === 'softDelete') {
            fetch('softDeleteLeadServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'leadid=' + currentLeadId
            })
            .then(response => response.text())
            .then(data => {
                closeConfirmationModal();
                showMessageModal('Success', 'Lead deleted successfully', 'success');
            })
            .catch(error => {
                console.error('Error:', error);
                showMessageModal('Error', 'Error deleting lead', 'error');
            });
        } else if (currentAction === 'permanentDelete') {
            fetch('deleteleadservlet?leadid=' + currentLeadId, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                }
            })
            .then(response => response.text())
            .then(data => {
                closeConfirmationModal();
                showMessageModal('Success', 'Lead permanently deleted', 'success');
            })
            .catch(error => {
                console.error('Error:', error);
                showMessageModal('Error', 'Error permanently deleting lead', 'error');
            });
        } else if (currentAction === 'restore') {
            fetch('restoreLeadServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'leadid=' + currentLeadId
            })
            .then(response => response.text())
            .then(data => {
                closeConfirmationModal();
                showMessageModal('Success', 'Lead restored successfully', 'success');
            })
            .catch(error => {
                console.error('Error:', error);
                showMessageModal('Error', 'Error restoring lead', 'error');
            });
        }
    }

    function openEditPopup(leadId, projectName, firmName, inDate, customerName, email, phone, address, org) {
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

    // Popup Modal Functions
    const popupModal = document.getElementById('leadPopupModal');
    function openPopup(leadId, projectName, firmName, inDate, customerName, email, contact, address, org, addedBy) {
        document.getElementById('popup-lead-id-display').value = leadId;
        document.getElementById('popup-project-name-display').value = projectName;
        document.getElementById('popup-firm-name-display').value = firmName;
        document.getElementById('popup-in-date-display').value = inDate;
        document.getElementById('popup-customer-name-display').value = customerName;
        document.getElementById('popup-email-display').value = email;
        document.getElementById('popup-contact-display').value = contact;
        document.getElementById('popup-address-display').value = address;
        document.getElementById('popup-org-display').value = org || '';
        document.getElementById('popup-added-by-display').value = addedBy;

        popupModal.classList.add('active');
    }

    function closePopup() {
        popupModal.classList.remove('active');
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

    // Radio button and action handling
    let selectedLeadId = null;
    let selectedStatus = null;
    let selectedLeadData = null;

    function selectLead(leadId, projectName, firmName, inDate, customerName, email, contact, address, org, addedBy, status) {
        selectedLeadId = leadId;
        selectedStatus = status;
        selectedLeadData = {
            leadId: leadId,
            projectName: projectName,
            firmName: firmName,
            inDate: inDate,
            customerName: customerName,
            email: email,
            contact: contact,
            address: address,
            org: org,
            addedBy: addedBy,
            status: status
        };
        updateSelectedLead(leadId, status);
        openPopup(leadId, projectName, firmName, inDate, customerName, email, contact, address, org, addedBy);
    }

    function updateSelectedLead(leadId, status) {
        selectedLeadId = leadId;
        selectedStatus = status;
        updateButtonStates();
    }

    function updateButtonStates() {
        const connectToggleBtn = document.getElementById('connectToggleBtn');
        const editBtn = document.getElementById('editBtn');
        const deleteBtn = document.getElementById('deleteBtn');
        const permanentDeleteBtn = document.getElementById('permanentDeleteBtn');
        const restoreBtn = document.getElementById('restoreBtn');

        if (selectedLeadId) {
            if (connectToggleBtn) {
                connectToggleBtn.className = 'action-btn status ' + (selectedStatus === 'Connected' ? 'connected' : '');
                connectToggleBtn.innerHTML = '<i class="fas fa-' + (selectedStatus === 'Connected' ? 'check' : 'times') + '"></i> ' + (selectedStatus === 'Connected' ? 'Connected' : 'Not Connected');
                connectToggleBtn.disabled = false;
            }
            if (editBtn) editBtn.disabled = false;
            if (deleteBtn) deleteBtn.disabled = false;
            if (permanentDeleteBtn) permanentDeleteBtn.disabled = false;
            if (restoreBtn) restoreBtn.disabled = false;
        } else {
            if (connectToggleBtn) {
                connectToggleBtn.className = 'action-btn status';
                connectToggleBtn.innerHTML = '<i class="fas fa-check"></i> Connect';
                connectToggleBtn.disabled = true;
            }
            if (editBtn) editBtn.disabled = true;
            if (deleteBtn) deleteBtn.disabled = true;
            if (permanentDeleteBtn) permanentDeleteBtn.disabled = true;
            if (restoreBtn) restoreBtn.disabled = true;
        }
    }

    function toggleConnect() {
        if (!selectedLeadId) {
            showMessageModal('Error', 'Please select a lead first.', 'error');
            return;
        }

        fetch('updateStatus.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'lead_id=' + selectedLeadId + '&status=' + (selectedStatus === 'Connected' ? 'Not Connected' : 'Connected')
        })
        .then(response => response.text())
        .then(data => {
            selectedStatus = selectedStatus === 'Connected' ? 'Not Connected' : 'Connected';
            updateButtonStates();
            showMessageModal('Success', 'Status updated successfully', 'success');
        })
        .catch(error => {
            console.error('Error:', error);
            showMessageModal('Error', 'Error updating status', 'error');
        });
    }

    function openEditPopupWithSelectedLead() {
        if (!selectedLeadId || !selectedLeadData) {
            showMessageModal('Error', 'Please select a lead first.', 'error');
            return;
        }

        openEditPopup(
            selectedLeadData.leadId,
            selectedLeadData.projectName,
            selectedLeadData.firmName,
            selectedLeadData.inDate,
            selectedLeadData.customerName,
            selectedLeadData.email,
            selectedLeadData.contact,
            selectedLeadData.address,
            selectedLeadData.org
        );
    }

    function showConfirmationModalWithSelectedLead(action) {
        if (!selectedLeadId) {
            showMessageModal('Error', 'Please select a lead first.', 'error');
            return;
        }
        showConfirmationModal(action, selectedLeadId);
    }
    </script>
</body>
</html>