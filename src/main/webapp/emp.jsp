<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>

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
    <title>Employees</title>
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
        margin-top: -45px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
           
        }

        .button-container {
            display: flex;
            gap: 10px;
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
            width: 200px;
        }

        select:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(29, 161, 242, 0.1);
            outline: none;
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

        .btn-success {
            background: #28a745;
            color: white;
        }

        .btn-success:hover {
            background: #218838;
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

            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
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
            
            .button-container {
                width: 100%;
                justify-content: flex-end;
            }
            
            select {
                width: 100%;
                max-width: 200px;
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
        }

        @media (max-width: 576px) {
            th, td {
                padding: 10px 8px;
                font-size: 0.8rem;
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
        <div class="page-title">Employees</div>
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
                <li class="active"><a href="#"><i class="fas fa-user-tie"></i> Employees</a></li>
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

        <div class="page-header">
            <select id="positionFilter" onchange="filterEmployees()">
                <option value="all">All Positions</option>
                <option value="employee">Employee</option>
                <option value="team lead">Team Lead</option>
                <option value="project manager">Project Manager</option>
            </select>
            <div class="button-container">
                <button class="btn btn-primary" onclick="openModal()">
                    <i class="fas fa-plus"></i> Add Employee
                </button>
            </div>
        </div>

        <div class="table-container slide-up">
            <div class="scroll-container">
                <table>
                    <thead>
                        <tr>
                            <th>Emp ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Department</th>
                            <th class="emp-position">Position</th>
                            <th>Salary</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="employeeTableBody">
                        <%
                            Connection con = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

                                PreparedStatement pstmt = con.prepareStatement("SELECT * FROM emp WHERE company_id = ?");
                                pstmt.setInt(1, companyId);
                                rs = pstmt.executeQuery();

                                while (rs.next()) {
                                    String salary = rs.getString("salary");
                                    if (salary != null && !salary.isEmpty()) {
                                        try {
                                            double salaryValue = Double.parseDouble(salary.replaceAll(",", ""));
                                            salary = String.format("%,.2f", salaryValue);
                                        } catch (NumberFormatException e) {
                                            e.printStackTrace();
                                        }
                                    }
                        %>
                        <tr>
                            <td data-title="Emp ID"><%= rs.getInt("unique_id") %></td>
                            <td data-title="Name"><%= rs.getString("emp_name") != null ? rs.getString("emp_name") : "N/A" %></td>
                            <td data-title="Email"><%= rs.getString("email") != null ? rs.getString("email") : "N/A" %></td>
                            <td data-title="Phone"><%= rs.getString("phone") != null ? rs.getString("phone") : "N/A" %></td>
                            <td data-title="Department"><%= rs.getString("department") != null ? rs.getString("department") : "N/A" %></td>
                            <td data-title="Position" class="emp-position"><%= rs.getString("position") != null ? rs.getString("position") : "N/A" %></td>
                            <td data-title="Salary"><%= salary != null ? salary : "N/A" %></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn btn-sm btn-success" 
                                        onclick="openEditPopup(<%= rs.getInt("emp_id") %>, '<%= rs.getString("emp_name") != null ? rs.getString("emp_name").replace("'", "\\'") : "N/A" %>', '<%= rs.getString("email") != null ? rs.getString("email").replace("'", "\\'") : "N/A" %>', '<%= rs.getString("phone") != null ? rs.getString("phone").replace("'", "\\'") : "N/A" %>', '<%= rs.getString("department") != null ? rs.getString("department").replace("'", "\\'") : "N/A" %>', '<%= rs.getString("position") != null ? rs.getString("position").replace("'", "\\'") : "N/A" %>', '<%= salary != null ? salary.replace("'", "\\'") : "N/A" %>')">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                    <button class="btn btn-sm btn-danger" onclick="deleteEmployee(<%= rs.getInt("emp_id") %>)">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("Error fetching employees: " + e.getMessage());
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                if (con != null) try { con.close(); } catch (SQLException e) {}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Employee Modal -->
<div class="modal" id="addContactModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Add New Employee</h2>
            <button class="close-btn" onclick="closeModal()">×</button>
        </div>
        <form id="addEmployeeForm" action="addempservlet1" method="post" autocomplete="off">
            <div class="form-group">
                <label for="proname">Employee Name *</label>
                <input type="text" id="proname" name="proname" class="form-control" placeholder="Enter employee name" required>
            </div>
            <div class="form-group">
                <label for="empEmail">Email *</label>
                <input type="email" id="empEmail" name="email" class="form-control" placeholder="Enter email" autocomplete="off" required>
            </div>
            <div class="form-group">
                <label for="password">Password *</label>
                <input type="password" id="password" name="password" class="form-control" placeholder="Enter password" autocomplete="new-password" required>
            </div>
            <div class="form-group">
                <label for="empPhone">Phone *</label>
                <input type="text" id="empPhone" name="phone" class="form-control" placeholder="Enter phone number" required>
            </div>
            <div class="form-group">
                <label for="dept">Department *</label>
                <input type="text" id="dept" name="dept" class="form-control" placeholder="Enter department" required>
            </div>
            <div class="form-group">
                <label for="position">Position *</label>
                <select id="position" name="position" class="form-control" required>
                    <option value="">Select Position</option>
                    <option value="team lead">Team Lead</option>
                    <option value="project manager">Project Manager</option>
                    <option value="employee">Employee</option>
                </select>
            </div>
            <div class="form-group">
                <label for="sal">Annual Salary *</label>
                <input type="text" id="sal" name="sal" class="form-control" placeholder="Enter salary" oninput="formatSalary(this)" required>
            </div>
            <input type="hidden" name="company_id" value="<%= companyId %>">
            <div class="form-group" style="margin-top: 20px;">
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-plus"></i> Add Employee
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Employee Modal -->
<div class="modal" id="editEmployeeModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Edit Employee</h2>
            <button class="close-btn" onclick="closeEditModal()">×</button>
        </div>
        <form id="editEmployeeForm" action="Editempservlet" method="post">
            <input type="hidden" name="leadid" id="popup-lead-id">
            <div class="form-group">
                <label for="popup-project-name">Employee Name *</label>
                <input type="text" id="popup-project-name" name="proname" class="form-control" placeholder="Employee name" required>
            </div>
            <div class="form-group">
                <label for="popup-firm-name">Email *</label>
                <input type="email" id="popup-firm-name" name="firmname" class="form-control" placeholder="Email" required>
            </div>
            <div class="form-group">
                <label for="popup-phone">Phone *</label>
                <input type="text" id="popup-phone" name="phone" class="form-control" placeholder="Phone" required>
            </div>
            <div class="form-group">
                <label for="popup-customer-name">Department *</label>
                <input type="text" id="popup-customer-name" name="customer" class="form-control" placeholder="Department" required>
            </div>
            <div class="form-group">
                <label for="popup-email">Position *</label>
                <select id="popup-email" name="email" class="form-control" required>
                    <option value="">Select Position</option>
                    <option value="team lead">Team Lead</option>
                    <option value="project manager">Project Manager</option>
                    <option value="employee">Employee</option>
                </select>
            </div>
            <div class="form-group">
                <label for="popup-sal">Annual Salary *</label>
                <input type="text" id="popup-sal" name="sal" class="form-control" placeholder="Salary" oninput="formatSalary(this)" required>
            </div>
            <input type="hidden" name="company_id" value="<%= companyId %>">
            <div class="form-group" style="margin-top: 20px;">
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Update Employee
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    const sidebar = document.querySelector('.sidebar');
    const menuToggle = document.getElementById('menuToggle');
    const sidebarClose = document.getElementById('sidebarClose');
    const addEmployeeModal = document.getElementById('addContactModal');
    const editEmployeeModal = document.getElementById('editEmployeeModal');

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

    // Filter employees by position using dropdown
    function filterEmployees() {
        let selectedPosition = document.getElementById('positionFilter').value.toLowerCase();
        let tableRows = document.getElementById('employeeTableBody').getElementsByTagName('tr');
        
        for (let row of tableRows) {
            let positionCell = row.querySelector('.emp-position');
            if (positionCell) {
                let position = positionCell.textContent.toLowerCase().trim();
                if (selectedPosition === 'all') {
                    row.style.display = '';
                } else {
                    row.style.display = (position === selectedPosition) ? '' : 'none';
                }
            }
        }
    }

    // Salary formatting function
    function formatSalary(input) {
        let cursorPosition = input.selectionStart;
        let originalLength = input.value.length;

        let value = input.value.replace(/[^0-9.]/g, '');
        let decimalCount = (value.match(/\./g) || []).length;
        if (decimalCount > 1) {
            let firstDecimalIndex = value.indexOf('.');
            value = value.substring(0, firstDecimalIndex + 1) + value.substring(firstDecimalIndex + 1).replace(/\./g, '');
        }

        let parts = value.split('.');
        let integerPart = parts[0] || '0';
        let decimalPart = parts[1] || '';

        if (decimalPart.length > 2) {
            decimalPart = decimalPart.substring(0, 2);
        }

        let num = parseFloat(integerPart) || 0;
        let formattedInteger = num.toLocaleString('en-US', { minimumFractionDigits: 0 });

        let formattedValue = decimalPart ? `${formattedInteger}.${decimalPart}` : formattedInteger;
        input.value = formattedValue;

        let newLength = input.value.length;
        let cursorAdjustment = newLength - originalLength;
        input.setSelectionRange(cursorPosition + cursorAdjustment, cursorPosition + cursorAdjustment);
    }

    // Email and phone validation for add employee form
    document.getElementById("addEmployeeForm").addEventListener("submit", function(e) {
        let emailInput = document.getElementById("empEmail");
        let email = emailInput.value.trim();
        const gmailPattern = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
        
        let phoneInput = document.getElementById("empPhone");
        let phone = phoneInput.value.trim();
        const phonePattern = /^\d{10}$/;

        let salInput = document.getElementById("sal");
        let sal = salInput.value.replace(/,/g, '');
        salInput.value = sal;

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

        if (isNaN(parseFloat(sal)) || sal === '') {
            alert("Please enter a valid salary.");
            salInput.focus();
            e.preventDefault();
            return false;
        }
    });

    // Email and phone validation for edit employee form
    document.getElementById("editEmployeeForm").addEventListener("submit", function(e) {
        let emailInput = document.getElementById("popup-firm-name");
        let email = emailInput.value.trim();
        const gmailPattern = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
        
        let phoneInput = document.getElementById("popup-phone");
        let phone = phoneInput.value.trim();
        const phonePattern = /^\d{10}$/;

        let salInput = document.getElementById("popup-sal");
        let sal = salInput.value.replace(/,/g, '');
        salInput.value = sal;

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

        if (isNaN(parseFloat(sal)) || sal === '') {
            alert("Please enter a valid salary.");
            salInput.focus();
            e.preventDefault();
            return false;
        }
    });

    // Modal functions
    function openModal() {
        addEmployeeModal.classList.add('active');
    }

    function closeModal() {
        addEmployeeModal.classList.remove('active');
    }

    function openEditPopup(leadId, projectName, firmName, phone, customerName, email, sal) {
        document.getElementById('popup-lead-id').value = leadId;
        document.getElementById('popup-project-name').value = projectName;
        document.getElementById('popup-firm-name').value = firmName;
        document.getElementById('popup-phone').value = phone;
        document.getElementById('popup-customer-name').value = customerName;
        
        var positionDropdown = document.getElementById('popup-email');
        positionDropdown.value = email.toLowerCase();
        
        let salValue = sal.replace(/,/g, '');
        document.getElementById('popup-sal').value = parseFloat(salValue).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        
        editEmployeeModal.classList.add('active');
    }

    function closeEditModal() {
        editEmployeeModal.classList.remove('active');
    }

    function deleteEmployee(leadId) {
        if (confirm('Are you sure you want to remove this employee?')) {
            window.location.href = "deleteempservlet?leadid=" + leadId;
        }
    }

    // Close modal on Escape key
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            if (addEmployeeModal.classList.contains('active')) {
                closeModal();
            }
            if (editEmployeeModal.classList.contains('active')) {
                closeEditModal();
            }
        }
    });

    // Handle page load: show error alerts and auto-scroll sidebar
    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        const errorMessage = urlParams.get("errorMessage");
        if (errorMessage) {
            alert(errorMessage);
        }

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
</script>
</body>
</html>