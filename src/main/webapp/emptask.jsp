<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tasks | CRMSPOT</title>
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
            margin: 0;
            width: 100vw;
            overflow-x: hidden;
        }

        .container {
            flex: 1;
            width: 100%;
            padding: 0 20px;
        }

        /* Page Header */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            gap: 10px;
            padding: 15px 20px;
            background: var(--card-bg);
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .page-title {
            font-size: 1.8rem;
            color: var(--dark);
            font-weight: 600;
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

        .btn-sm {
            padding: 6px 12px;
            font-size: 14px;
        }

        .btn i {
            margin-right: 8px;
        }

        /* Table container */
        .table-container {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            padding: 25px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            margin: 0 20px;
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
        .action-buttons {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        /* Priority badges */
        .priority-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .priority-badge.low {
            background-color: #d1fae5;
            color: #065f46;
        }

        .priority-badge.medium {
            background-color: #bfdbfe;
            color: #1e40af;
        }

        .priority-badge.high {
            background-color: #fde68a;
            color: #92400e;
        }

        .priority-badge.urgent {
            background-color: #fecaca;
            color: #991b1b;
        }

        /* Form controls */
        select.form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #ddd;
            border-radius: 10px;
            font-size: 1rem;
            background: #fff;
            transition: all 0.3s ease;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        select.form-control:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(0, 196, 180, 0.1);
            outline: none;
        }

        /* Tabs */
        .tabs {
            display: flex;
            gap: 10px;
            margin: 20px 20px 20px 20px;
            overflow-x: auto;
            padding-bottom: 5px;
        }

        .tab {
            padding: 10px 20px;
            background-color: #e5e7eb;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
            white-space: nowrap;
        }

        .tab:hover {
            background-color: #d1d5db;
        }

        .tab.active {
            background-color: var(--accent);
            color: white;
        }

        /* Tab Content */
        .tab-content {
            display: none;
            animation: fadeIn 0.3s ease;
        }

        .tab-content.active {
            display: block;
        }

        /* Status colors */
        .expired {
            color: var(--danger);
            font-weight: 500;
        }

        /* Employee Details */
        .employee-details {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            padding: 15px;
            background: var(--secondary);
            border-radius: 8px;
            font-size: 16px;
            font-weight: 500;
            margin: 0 20px;
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

        /* Responsive Design */
        @media (max-width: 768px) {
            .employee-details {
                flex-direction: column;
                gap: 10px;
            }

            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
                padding: 15px 10px;
            }

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
                flex-direction: column;
                align-items: stretch;
            }

            .action-buttons select,
            .action-buttons button {
                width: 100%;
                margin: 5px 0;
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

            .tabs {
                flex-direction: column;
                align-items: flex-start;
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
    </style>
</head>
<body>
    <%
        HttpSession sessionVar = request.getSession(false);
        if (sessionVar == null) {
            response.sendRedirect("login1.jsp");
            return;
        }

        String companyIdStr = (String) sessionVar.getAttribute("company_id");
        String uniqueId = (String) sessionVar.getAttribute("unique_id");

        Integer companyId = null;
        try {
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("login1.jsp");
            return;
        }
    %>
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">Task Management</h1>
            <div class="button-group" style="display: flex; gap: 10px;">
                <a href="dashmanager.jsp" class="btn btn-primary"><i class="fas fa-project-diagram"></i> Projects</a>
                <a href="addDashemp.jsp" class="btn btn-primary"><i class="fas fa-user-plus"></i> Add Employee</a>
                <a href="emptask.jsp" class="btn btn-primary"><i class="fas fa-tasks"></i> Tasks</a>
                <form action="LogoutServlet" method="post" style="display: inline;">
                    <button type="submit" class="btn btn-danger">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </button>
                </form>
            </div>
        </div>

        <!-- Employee Details -->
        <div class="employee-details">
            <%
                Connection conProfile = null;
                PreparedStatement pstmtProfile = null;
                ResultSet rsProfile = null;
                String fullName = "Manager";
                try {
                    String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                    conProfile = DriverManager.getConnection(url, user, pass);
                    String query = "SELECT emp_name FROM emp WHERE unique_id = ?";
                    pstmtProfile = conProfile.prepareStatement(query);
                    pstmtProfile.setString(1, uniqueId);
                    rsProfile = pstmtProfile.executeQuery();

                    if (rsProfile.next()) {
                        fullName = rsProfile.getString("emp_name");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rsProfile != null) try { rsProfile.close(); } catch (SQLException e) {}
                    if (pstmtProfile != null) try { pstmtProfile.close(); } catch (SQLException e) {}
                    if (conProfile != null) try { conProfile.close(); } catch (SQLException e) {}
                }
            %>
            <span><i class="fas fa-id-card"></i> Emp ID: <%= uniqueId %></span>
            <span><i class="fas fa-user"></i> Emp Name: <%= fullName %></span>
        </div>

        <!-- Tabs for Sections -->
        <div class="tabs">
            <div class="tab active" id="open-tab">To Do</div>
            <div class="tab" id="in-progress-tab">In Progress</div>
            <div class="tab" id="completed-tab">Completed</div>
        </div>

        <!-- Open Tasks Section -->
        <div class="tab-content active" id="open-section">
            <div class="table-container slide-up">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Task Name</th>
                                <th>Assigned To</th>
                                <th>Description</th>
                                <th>Deadline</th>
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
                                    String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection(url, user, pass);
                                    String query = "SELECT * FROM open_tasks WHERE unique_id = ?";
                                    pst = con.prepareStatement(query);
                                    pst.setString(1, uniqueId);
                                    rs = pst.executeQuery();
                                    
                                    while (rs.next()) {
                            %>
                                <tr>
                                    <td data-title="Task Name"><%= rs.getString("task_name") %></td>
                                    <td data-title="Assigned To"><%= rs.getString("emp_name") %></td>
                                    <td data-title="Description"><%= rs.getString("description") %></td>
                                    <td data-title="Deadline" class="<%= (rs.getString("dead_line") != null && rs.getDate("dead_line").before(new java.util.Date())) ? "expired" : "" %>">
                                        <%= rs.getDate("dead_line") != null ? rs.getDate("dead_line").toString() : "N/A" %>
                                    </td>
                                    <td data-title="Priority">
                                        <span class="priority-badge <%= rs.getString("priority") %>">
                                            <%= rs.getString("priority") != null ? rs.getString("priority").toUpperCase() : "N/A" %>
                                        </span>
                                    </td>
                                    <td data-title="Actions">
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
                                    </td>
                                </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='6' style='text-align:center;'>Error fetching tasks: " + e.getMessage() + "</td></tr>");
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

        <!-- In Progress Section -->
        <div class="tab-content" id="in-progress-section">
            <div class="table-container slide-up">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Task Name</th>
                                <th>Assigned To</th>
                                <th>Description</th>
                                <th>Deadline</th>
                                <th>Priority</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                   String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection(url, user, pass);
                                    String query = "SELECT * FROM in_progress_tasks WHERE unique_id = ?";
                                    pst = con.prepareStatement(query);
                                    pst.setString(1, uniqueId);
                                    rs = pst.executeQuery();
                                    
                                    while (rs.next()) {
                            %>
                                <tr>
                                    <td data-title="Task Name"><%= rs.getString("task_name") %></td>
                                    <td data-title="Assigned To"><%= rs.getString("emp_name") %></td>
                                    <td data-title="Description"><%= rs.getString("description") %></td>
                                    <td data-title="Deadline" class="<%= (rs.getString("dead_line") != null && rs.getDate("dead_line").before(new java.util.Date())) ? "expired" : "" %>">
                                        <%= rs.getDate("dead_line") != null ? rs.getDate("dead_line").toString() : "N/A" %>
                                    </td>
                                    <td data-title="Priority">
                                        <span class="priority-badge <%= rs.getString("priority") %>">
                                            <%= rs.getString("priority") != null ? rs.getString("priority").toUpperCase() : "N/A" %>
                                        </span>
                                    </td>
                                    <td data-title="Actions">
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
                                    </td>
                                </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='6' style='text-align:center;'>Error fetching tasks: " + e.getMessage() + "</td></tr>");
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

        <!-- Completed Section -->
        <div class="tab-content" id="completed-section">
            <div class="table-container slide-up">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Task Name</th>
                                <th>Assigned To</th>
                                <th>Description</th>
                                <th>Deadline</th>
                                <th>Priority</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                   String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection(url, user, pass);
                                    String query = "SELECT * FROM completed_tasks WHERE unique_id = ?";
                                    pst = con.prepareStatement(query);
                                    pst.setString(1, uniqueId);
                                    rs = pst.executeQuery();
                                    
                                    while (rs.next()) {
                            %>
                                <tr>
                                    <td data-title="Task Name"><%= rs.getString("task_name") %></td>
                                    <td data-title="Assigned To"><%= rs.getString("emp_name") %></td>
                                    <td data-title="Description"><%= rs.getString("description") %></td>
                                    <td data-title="Deadline" class="<%= (rs.getString("dead_line") != null && rs.getDate("dead_line").before(new java.util.Date())) ? "expired" : "" %>">
                                        <%= rs.getDate("dead_line") != null ? rs.getDate("dead_line").toString() : "N/A" %>
                                    </td>
                                    <td data-title="Priority">
                                        <span class="priority-badge <%= rs.getString("priority") %>">
                                            <%= rs.getString("priority") != null ? rs.getString("priority").toUpperCase() : "N/A" %>
                                        </span>
                                    </td>
                                    <td data-title="Actions">
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
                                    </td>
                                </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='6' style='text-align:center;'>Error fetching tasks: " + e.getMessage() + "</td></tr>");
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

        <!-- Popup Message Modal -->
        <%
            String popupMessage = (String) sessionVar.getAttribute("popupMessage");
            String popupType = (String) sessionVar.getAttribute("popupType");
            if (popupMessage != null) {
        %>
        <div class="modal active" id="messageModal">
            <div class="modal-content confirmation-modal-content">
                <div class="modal-header" style="background-color: <%= "success".equals(popupType) ? "var(--success)" : "var(--danger)" %>;">
                    <h2><%= "success".equals(popupType) ? "Success" : "Error" %></h2>
                </div>
                <p><%= popupMessage %></p>
                <div class="confirmation-buttons">
                    <button class="btn btn-primary" onclick="closeMessageModal()">OK</button>
                </div>
            </div>
        </div>
        <%
                sessionVar.removeAttribute("popupMessage");
                sessionVar.removeAttribute("popupType");
            }
        %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Tab switching functionality
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', function() {
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(tc => tc.classList.remove('active'));
                this.classList.add('active');
                const tabId = this.id.replace('-tab', '');
                document.getElementById(tabId + '-section').classList.add('active');
            });
        });

        function closeMessageModal() {
            const modal = document.getElementById('messageModal');
            if (modal) modal.classList.remove('active');
            window.location.href = 'emptask.jsp';
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
            if (event.key === 'Escape') {
                const modals = document.querySelectorAll('.modal.active');
                modals.forEach(modal => {
                    modal.classList.remove('active');
                });
            }
        });

        document.addEventListener('DOMContentLoaded', () => {
            const animatedElements = document.querySelectorAll('.slide-up, .fade-in');
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = 1;
                        entry.target.style.transform = 'translateY(0)';
                    }
                });
            }, { threshold: 0.1 });
            animatedElements.forEach(element => observer.observe(element));
        });
    </script>
</body>
</html>