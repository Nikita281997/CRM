<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.time.*, java.util.*, java.time.temporal.ChronoUnit" %>

<%
// Session check must be at the top before any output
HttpSession sessionVar = request.getSession();
String companyIdStr = (String) sessionVar.getAttribute("company_id");
Integer companyId = null;
if (companyIdStr != null) {
    try {
        companyId = Integer.parseInt(companyIdStr);
    } catch (NumberFormatException e) {
        out.println("Error parsing companyId: " + e.getMessage());
        e.printStackTrace();
    }
}
if (companyId == null) {
    response.sendRedirect("login1.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tasks</title>
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

        .button-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
                margin-top: -45px;
        }

        .tabs-group {
            display: flex;
            gap: 5px;
        }

        .tab {
            padding: 10px 20px;
            background-color: #f3f4f6;
            border-radius: 8px;
            cursor: pointer;
            transition: var(--transition);
            font-weight: 500;
            white-space: nowrap;
            border: none;
        }

        .tab.active {
            background-color: var(--accent);
            color: white;
        }

        .tab:hover {
            background-color: #d1d5db;
            transform: translateY(-2px);
        }

        .tab-content {
            display: none;
            animation: fadeIn 0.5s ease-out;
        }

        .tab-content.active {
            display: block;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: var(--transition);
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

        .btn-danger {
            background-color: #e24728;
                        color: white;
        }

        .btn-danger:hover {
            background-color: #e55776;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn-sm {
            padding: 8px 12px;
            font-size: 14px;
        }

        .btn i {
            margin-right: 8px;
        }

        .action-buttons {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }

        .table-container {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            padding: 25px;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }

        .table-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        .scroll-container {
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
            min-width: 600px;
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

        tbody tr {
            transition: var(--transition);
        }

        tbody tr:hover {
            background: #f0faff;
            transform: scale(1.01);
        }

        select {
            padding: 12px 15px;
            border: 2px solid #ddd;
            border-radius: 10px;
            font-size: 1rem;
            background: #fff;
            transition: var(--transition);
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            cursor: pointer;
        }

        select:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(29, 161, 242, 0.1);
            outline: none;
        }

        .modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 2000;
            opacity: 0;
            visibility: hidden;
            transition: var(--transition);
        }

        .modal.active {
            display: flex;
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
            transition: var(--transition);
            padding: 25px;
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
            transition: var(--transition);
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
            transition: var(--transition);
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }

        .form-control:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(29, 161, 242, 0.1);
            outline: none;
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
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 0.8rem;
            cursor: pointer;
            transition: var(--transition);
            border: none;
        }

        .notification-btn.deny {
            background-color: var(--danger);
            color: white;
        }

        .notification-btn.deny:hover {
            background-color: #e55776;
        }

        .notification-btn.ok {
            background-color: var(--success);
            color: white;
        }

        .notification-btn.ok:hover {
            background-color: #00a89a;
        }

        .notification-btn.cancel {
            background-color: #6b7280;
            color: white;
        }

        .notification-btn.cancel:hover {
            background-color: #5a6268;
        }

        .priority-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .priority-badge.low { background-color: #d1fae5; color: #065f46; }
        .priority-badge.medium { background-color: #bfdbfe; color: #1e40af; }
        .priority-badge.high { background-color: #fef9c3; color: #92400e; }
        .priority-badge.urgent { background-color: #fee2e2; color: #991b1b; }

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

            .button-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
        }

        @media (max-width: 768px) {
            .action-buttons {
                flex-direction: column;
                gap: 10px;
            }
            
            .btn-sm {
                width: 100%;
                justify-content: center;
                padding: 6px 8px;
                font-size: 12px;
            }
            
            .scroll-container {
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

            .notification {
                bottom: 10px;
                right: 10px;
                max-width: 90%;
                width: auto;
            }
        }

        @media (max-width: 576px) {
            th, td {
                padding: 10px 8px;
                font-size: 0.8rem;
            }

            .notification {
                padding: 10px;
            }

            .notification-btn {
                padding: 5px 10px;
                font-size: 0.7rem;
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
        <div class="page-title">Tasks</div>
        <div class="sidebar-menu">
            <ul>
                <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="leads.jsp"><i class="fas fa-users"></i> Leads</a></li>
                <li><a href="leadmanagement.jsp"><i class="fas fa-tasks"></i> Lead Management</a></li>
                <li><a href="projects.jsp"><i class="fas fa-project-diagram"></i> Projects</a></li>
                <li><a href="quotes.jsp"><i class="fas fa-file-invoice-dollar"></i> Quotes</a></li>
                <li><a href="financemanagement.jsp"><i class="fas fa-money-bill-wave"></i> Finance Management</a></li>
                <li><a href="contacts.jsp"><i class="fas fa-address-book"></i> Contacts</a></li>
                <li class="active"><a href="#"><i class="fas fa-check-circle"></i> Tasks</a></li>
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
                Class.forName("com.mysql.cj.jdbc.Driver");
                conNav = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

                String query = "SELECT full_name, img FROM company_registration1 WHERE company_id = ?";
                pstmtNav = conNav.prepareStatement(query);
                pstmtNav.setInt(1, companyId);
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

    <!-- Main Content -->
    <div class="content">
        <!-- Navbar -->
        <div class="navbar slide-up">
            <button class="menu-toggle" id="menuToggle">
                <i class="fas fa-bars"></i>
            </button>
        </div>

        <!-- Button Row with Tabs on Left and Add Task on Right -->
        <div class="button-row">
            <div class="tabs-group">
                <div class="tab active" id="open-tab">To Do</div>
                <div class="tab" id="in-progress-tab">In Progress</div>
                <div class="tab" id="completed-tab">Completed</div>
            </div>
            <button class="btn btn-primary" onclick="document.getElementById('add-task-modal').classList.add('active')">
                <i class="fas fa-plus"></i> Add Task
            </button>
        </div>

        <div class="tab-content active" id="open-section">
            <div class="table-container slide-up">
                <div class="scroll-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Task Name</th>
                                <th>Assigned To</th>
                                <th>Description</th>
                                <th>Deadline</th>
                                <th>Days Left</th>
                                <th>Priority</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection con = null;
                                PreparedStatement pst = null;
                                ResultSet rs = null;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
                                    String query = "SELECT * FROM open_tasks WHERE company_id = ?";
                                    pst = con.prepareStatement(query);
                                    pst.setInt(1, companyId);
                                    rs = pst.executeQuery();
                                    LocalDate today = LocalDate.now();
                                    while (rs.next()) {
                                        java.sql.Date deadline = rs.getDate("dead_line");
                                        String daysLeftStr = "N/A";
                                        if (deadline != null) {
                                            LocalDate deadlineDate = deadline.toLocalDate();
                                            long daysLeft = ChronoUnit.DAYS.between(today, deadlineDate);
                                            daysLeftStr = String.valueOf(daysLeft);
                                        }
                            %>
                            <tr>
                                <td data-title="Task Name"><%= rs.getString("task_name") != null ? rs.getString("task_name") : "N/A" %></td>
                                <td data-title="Assigned To"><%= rs.getString("emp_name") != null ? rs.getString("emp_name") : "N/A" %></td>
                                <td data-title="Description"><%= rs.getString("description") != null ? rs.getString("description") : "N/A" %></td>
                                <td data-title="Deadline"><%= deadline != null ? deadline.toString() : "N/A" %></td>
                                <td data-title="Days Left"><%= daysLeftStr %></td>
                                <td data-title="Priority">
                                    <span class="priority-badge <%= rs.getString("priority") %>">
                                        <%= rs.getString("priority") != null ? rs.getString("priority").toUpperCase() : "N/A" %>
                                    </span>
                                </td>
                                <td data-title="Actions">
                                    <div class="action-buttons">
                                        <form action="MoveTaskServlet" method="post" class="action-buttons">
                                            <input type="hidden" name="source" value="open">
                                            <input type="hidden" name="task_id" value="<%= rs.getInt("task_id") %>">
                                            <select name="category" class="form-control" required>
                                                <option value="">Move to...</option>
                                                <option value="in_progress">In Progress</option>
                                                <option value="completed">Completed</option>
                                            </select>
                                            <button type="submit" class="btn btn-sm btn-primary">
                                                <i class="fas fa-arrow-right"></i> Move
                                            </button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/DeleteTaskServlet" method="post" onsubmit="return confirm('Are you sure you want to delete this task?');">
                                            <input type="hidden" name="source" value="open">
                                            <input type="hidden" name="task_id" value="<%= rs.getInt("task_id") %>">
                                            <button type="submit" class="btn btn-sm btn-danger">
                                                <i class="fas fa-trash"></i> Delete
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("Error fetching open tasks: " + e.getMessage());
                                    e.printStackTrace();
                                } finally {
                                    try {
                                        if (rs != null) rs.close();
                                        if (pst != null) pst.close();
                                        if (con != null) con.close();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="tab-content" id="in-progress-section">
            <div class="table-container slide-up">
                <div class="scroll-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Task Name</th>
                                <th>Assigned To</th>
                                <th>Description</th>
                                <th>Deadline</th>
                                <th>Days Left</th>
                                <th>Priority</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                con = null;
                                pst = null;
                                rs = null;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
                                    String query = "SELECT * FROM in_progress_tasks WHERE company_id = ?";
                                    pst = con.prepareStatement(query);
                                    pst.setInt(1, companyId);
                                    rs = pst.executeQuery();
                                    LocalDate today = LocalDate.now();
                                    while (rs.next()) {
                                        java.sql.Date deadline = rs.getDate("dead_line");
                                        String daysLeftStr = "N/A";
                                        if (deadline != null) {
                                            LocalDate deadlineDate = deadline.toLocalDate();
                                            long daysLeft = ChronoUnit.DAYS.between(today, deadlineDate);
                                            daysLeftStr = String.valueOf(daysLeft);
                                        }
                            %>
                            <tr>
                                <td data-title="Task Name"><%= rs.getString("task_name") != null ? rs.getString("task_name") : "N/A" %></td>
                                <td data-title="Assigned To"><%= rs.getString("emp_name") != null ? rs.getString("emp_name") : "N/A" %></td>
                                <td data-title="Description"><%= rs.getString("description") != null ? rs.getString("description") : "N/A" %></td>
                                <td data-title="Deadline"><%= deadline != null ? deadline.toString() : "N/A" %></td>
                                <td data-title="Days Left"><%= daysLeftStr %></td>
                                <td data-title="Priority">
                                    <span class="priority-badge <%= rs.getString("priority") %>">
                                        <%= rs.getString("priority") != null ? rs.getString("priority").toUpperCase() : "N/A" %>
                                    </span>
                                </td>
                                <td data-title="Actions">
                                    <div class="action-buttons">
                                        <form action="MoveTaskServlet" method="post" class="action-buttons">
                                            <input type="hidden" name="source" value="in_progress">
                                            <input type="hidden" name="task_id" value="<%= rs.getInt("task_id") %>">
                                            <select name="category" class="form-control" required>
                                                <option value="">Move to...</option>
                                                <option value="open">To Do</option>
                                                <option value="completed">Completed</option>
                                            </select>
                                            <button type="submit" class="btn btn-sm btn-primary">
                                                <i class="fas fa-arrow-right"></i> Move
                                            </button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/DeleteTaskServlet" method="post" onsubmit="return confirm('Are you sure you want to delete this task?');">
                                            <input type="hidden" name="source" value="in_progress">
                                            <input type="hidden" name="task_id" value="<%= rs.getInt("task_id") %>">
                                            <button type="submit" class="btn btn-sm btn-danger">
                                                <i class="fas fa-trash"></i> Delete
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("Error fetching in-progress tasks: " + e.getMessage());
                                    e.printStackTrace();
                                } finally {
                                    try {
                                        if (rs != null) rs.close();
                                        if (pst != null) pst.close();
                                        if (con != null) con.close();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="tab-content" id="completed-section">
            <div class="table-container slide-up">
                <div class="scroll-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Task Name</th>
                                <th>Assigned To</th>
                                <th>Description</th>
                                <th>Deadline</th>
                                <th>Days Left</th>
                                <th>Priority</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                con = null;
                                pst = null;
                                rs = null;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
                                    String query = "SELECT * FROM completed_tasks WHERE company_id = ?";
                                    pst = con.prepareStatement(query);
                                    pst.setInt(1, companyId);
                                    rs = pst.executeQuery();
                                    LocalDate today = LocalDate.now();
                                    while (rs.next()) {
                                        java.sql.Date deadline = rs.getDate("dead_line");
                                        String daysLeftStr = "N/A";
                                        if (deadline != null) {
                                            LocalDate deadlineDate = deadline.toLocalDate();
                                            long daysLeft = ChronoUnit.DAYS.between(today, deadlineDate);
                                            daysLeftStr = String.valueOf(daysLeft);
                                        }
                            %>
                            <tr>
                                <td data-title="Task Name"><%= rs.getString("task_name") != null ? rs.getString("task_name") : "N/A" %></td>
                                <td data-title="Assigned To"><%= rs.getString("emp_name") != null ? rs.getString("emp_name") : "N/A" %></td>
                                <td data-title="Description"><%= rs.getString("description") != null ? rs.getString("description") : "N/A" %></td>
                                <td data-title="Deadline"><%= deadline != null ? deadline.toString() : "N/A" %></td>
                                <td data-title="Days Left"><%= daysLeftStr %></td>
                                <td data-title="Priority">
                                    <span class="priority-badge <%= rs.getString("priority") %>">
                                        <%= rs.getString("priority") != null ? rs.getString("priority").toUpperCase() : "N/A" %>
                                    </span>
                                </td>
                                <td data-title="Actions">
                                    <div class="action-buttons">
                                        <form action="MoveTaskServlet" method="post" class="action-buttons">
                                            <input type="hidden" name="source" value="completed">
                                            <input type="hidden" name="task_id" value="<%= rs.getInt("task_id") %>">
                                            <select name="category" class="form-control" required>
                                                <option value="">Move to...</option>
                                                <option value="open">To Do</option>
                                                <option value="in_progress">In Progress</option>
                                            </select>
                                            <button type="submit" class="btn btn-sm btn-primary">
                                                <i class="fas fa-arrow-right"></i> Move
                                            </button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/DeleteTaskServlet" method="post" onsubmit="return confirm('Are you sure you want to delete this task?');">
                                            <input type="hidden" name="source" value="completed">
                                            <input type="hidden" name="task_id" value="<%= rs.getInt("task_id") %>">
                                            <button type="submit" class="btn btn-sm btn-danger">
                                                <i class="fas fa-trash"></i> Delete
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("Error fetching completed tasks: " + e.getMessage());
                                    e.printStackTrace();
                                } finally {
                                    try {
                                        if (rs != null) rs.close();
                                        if (pst != null) pst.close();
                                        if (con != null) con.close();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add Task Modal -->
<div class="modal" id="add-task-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Add New Task</h2>
            <button class="close-btn" id="close-modal-btn">×</button>
        </div>
        <form action="TaskServlet" method="post" onsubmit="return validateTaskForm()">
            <div class="form-group">
                <label for="task_name">Task Name *</label>
                <input type="text" id="task_name" name="task_name" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="emp_unique_id">Assign To *</label>
                <select id="emp_unique_id" name="emp_unique_id" class="form-control" required>
                    <option value="">-- Select Employee --</option>
                    <%
                        Connection empCon = null;
                        PreparedStatement empPst = null;
                        ResultSet empRs = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            empCon = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
                            String empQuery = "SELECT unique_id, emp_name, position FROM emp WHERE company_id = ? ORDER BY emp_name";
                            empPst = empCon.prepareStatement(empQuery);
                            empPst.setInt(1, companyId);
                            empRs = empPst.executeQuery();
                            while (empRs.next()) {
                                String empName = empRs.getString("emp_name");
                                String position = empRs.getString("position");
                                String displayText = empName + (position != null && !position.trim().isEmpty() ? " (" + position + ")" : "");
                    %>
                    <option value="<%= empRs.getString("unique_id") %>"><%= displayText %></option>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("Error loading employees: " + e.getMessage());
                            e.printStackTrace();
                        } finally {
                            try {
                                if (empRs != null) empRs.close();
                                if (empPst != null) empPst.close();
                                if (empCon != null) con.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                    %>
                </select>
            </div>
            <div class="form-group">
                <label for="description">Description *</label>
                <textarea id="description" name="description" class="form-control" rows="4" required></textarea>
            </div>
            <div class="form-group">
                <label for="dead_line">Deadline *</label>
                <input type="date" id="dead_line" name="dead_line" class="form-control" min="<%= LocalDate.now() %>" required>
            </div>
            <div class="form-group">
                <label for="priority">Priority *</label>
                <select id="priority" name="priority" class="form-control" required>
                    <option value="">-- Select Priority --</option>
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="urgent">Urgent</option>
                </select>
            </div>
            <input type="hidden" name="company_id" value="<%= companyId %>">
            <div class="form-group" style="margin-top: 20px;">
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-plus"></i> Create Task
                </button>
                <button type="button" class="btn btn-danger" id="cancel-task-btn" style="margin-top: 10px; width: 100%;">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Notifications -->
<%
// Use unique variable names for this section to avoid conflicts
List<Map<String, Object>> tasksNearingDeadline = new ArrayList<>();
Connection conNotif = null;
PreparedStatement pstNotif = null;
ResultSet rsNotif = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conNotif = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
    
    String query = "SELECT task_id, task_name, emp_name, dead_line FROM open_tasks WHERE company_id = ? AND dead_line IS NOT NULL " +
                  "UNION " +
                  "SELECT task_id, task_name, emp_name, dead_line FROM in_progress_tasks WHERE company_id = ? AND dead_line IS NOT NULL";
    pstNotif = conNotif.prepareStatement(query);
    pstNotif.setInt(1, companyId);
    pstNotif.setInt(2, companyId);
    rsNotif = pstNotif.executeQuery();

    LocalDate today = LocalDate.now();
    while (rsNotif.next()) {
        java.sql.Date deadline = rsNotif.getDate("dead_line");
        if (deadline != null) {
            LocalDate deadlineDate = deadline.toLocalDate();
            long daysLeft = ChronoUnit.DAYS.between(today, deadlineDate);
            if (daysLeft >= 0 && daysLeft <= 5) {
                Map<String, Object> task = new HashMap<>();
                task.put("task_id", rsNotif.getInt("task_id"));
                task.put("task_name", rsNotif.getString("task_name"));
                task.put("emp_name", rsNotif.getString("emp_name"));
                task.put("dead_line", deadline.toString());
                task.put("days_left", daysLeft);
                tasksNearingDeadline.add(task);
            }
        }
    }
} catch (Exception e) {
    out.println("Error fetching notifications: " + e.getMessage());
    e.printStackTrace();
} finally {
    try {
        if (rsNotif != null) rsNotif.close();
        if (pstNotif != null) pstNotif.close();
        if (conNotif != null) conNotif.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}

// Generate notifications for tasks nearing deadline
for (Map<String, Object> task : tasksNearingDeadline) {
    String deniedNotification = (String) session.getAttribute("denied_notification_" + task.get("task_id"));
    if (deniedNotification == null) {
%>
<div class="notification" id="taskNotification_<%= task.get("task_id") %>">
    <div class="notification-header">
        <div class="notification-title">
            <i class="fas fa-exclamation-triangle" style="color: var(--warning); margin-right: 8px;"></i>
            Task Deadline Approaching
        </div>
        <button class="notification-close" onclick="closeNotification(<%= task.get("task_id") %>)">×</button>
    </div>
    <div class="notification-body">
        Your task <strong><%= task.get("task_name") != null ? task.get("task_name") : "N/A" %></strong> 
        assigned to <strong><%= task.get("emp_name") != null ? task.get("emp_name") : "N/A" %></strong> 
        will be due on <strong><%= task.get("dead_line") != null ? task.get("dead_line") : "N/A" %></strong>. 
        Days left: <strong><%= task.get("days_left") != null ? task.get("days_left") : "N/A" %></strong>.
    </div>
    <div class="notification-footer">
        <button class="notification-btn deny" onclick="handleNotificationResponse('deny', <%= task.get("task_id") %>)">Deny</button>
        <button class="notification-btn cancel" onclick="closeNotification(<%= task.get("task_id") %>)">Cancel</button>
        <button class="notification-btn ok" onclick="handleNotificationResponse('ok', <%= task.get("task_id") %>)">OK</button>
    </div>
</div>
<%
    }
}
%>

<div class="notification-container" id="notification-container"></div>

<script>
    const sidebar = document.querySelector('.sidebar');
    const menuToggle = document.getElementById('menuToggle');
    const sidebarClose = document.getElementById('sidebarClose');
    const addTaskModal = document.getElementById('add-task-modal');
    const closeModalBtn = document.getElementById('close-modal-btn');
    const notificationContainer = document.getElementById('notification-container');

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
        if (window.innerWidth <= 768 && !sidebar.contains(e.target) && !menuToggle.contains(e.target)) {
            sidebar.classList.remove('active');
        }
    });

    // Tab switching
    document.querySelectorAll('.tab').forEach(tab => {
        tab.addEventListener('click', function() {
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(tc => tc.classList.remove('active'));
            this.classList.add('active');
            const tabId = this.id.replace('-tab', '');
            document.getElementById(tabId + '-section').classList.add('active');
        });
    });

    // Modal handling
    closeModalBtn.addEventListener('click', () => {
        addTaskModal.classList.remove('active');
    });

    window.addEventListener('click', (e) => {
        if (e.target === addTaskModal) {
            addTaskModal.classList.remove('active');
        }
    });

    // Form validation
    function validateTaskForm() {
        const deadline = document.getElementById('dead_line').value;
        if (new Date(deadline) < new Date()) {
            alert('Deadline cannot be in the past');
            return false;
        }
        return true;
    }

    document.getElementById('cancel-task-btn').addEventListener('click', () => {
        document.getElementById('add-task-modal').classList.remove('active');
    });

    // Show notifications and auto-scroll sidebar on page load
    window.onload = function() {
        // Show notifications
        setTimeout(() => {
            <%
                for (Map<String, Object> task : tasksNearingDeadline) {
                    int taskId = (int) task.get("task_id");
            %>
            const notification<%= taskId %> = document.getElementById('taskNotification_<%= taskId %>');
            if (notification<%= taskId %>) {
                notification<%= taskId %>.classList.add('show');
            }
            <%
                }
            %>
        }, 1000);

        // Auto-scroll sidebar to center the active item
        const activeItem = document.querySelector('.sidebar-menu li.active');
        const sidebarMenu = document.querySelector('.sidebar-menu');
        if (activeItem && sidebarMenu) {
            const itemRect = activeItem.getBoundingClientRect();
            const menuRect = sidebarMenu.getBoundingClientRect();
            const offset = itemRect.top - menuRect.top - (menuRect.height / 2) + (itemRect.height / 2);
            sidebarMenu.scrollTop += offset;
        }
    };

    // Notification functions
    function closeNotification(taskId) {
        const notification = document.getElementById('taskNotification_' + taskId);
        if (notification) {
            notification.classList.remove('show');
            setTimeout(() => {
                notification.style.display = 'none';
            }, 500);
        }
    }

    function handleNotificationResponse(action, taskId) {
        if (action === 'deny') {
            fetch('SetNotificationPreferenceServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `action=deny&taskId=${taskId}`
            }).then(response => {
                if (response.ok) {
                    sessionStorage.setItem('denied_notification_' + taskId, 'true');
                }
            });
        } else if (action === 'ok') {
            // Optionally open a task management modal or redirect
        }
        closeNotification(taskId);
    }

    // Close modal on Escape key
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            if (addTaskModal.classList.contains('active')) {
                addTaskModal.classList.remove('active');
            }
        }
    });
</script>
</body>
</html>