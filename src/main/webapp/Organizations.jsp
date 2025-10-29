<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Organizations | CRMSPOT</title>
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
            transition: var(--transition);
            vertical-align: middle;
        }

        tbody tr:hover {
            background-color: #f0faff;
            transform: scale(1.01);
        }

        .action-buttons-container {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }

        .action-btn {
            border: none;
            padding: 8px 15px;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            transition: var(--transition);
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

        .action-btn.email {
            background: var(--info);
            color: white;
        }

        .action-btn.edit {
            background: var(--success);
            color: white;
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
            transition: var(--transition);
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
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: var(--dark);
            font-size: 1.1rem;
        }

        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 2px solid #ddd;
            border-radius: 10px;
            font-size: 1rem;
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

        select.form-control {
            width: 100%;
            padding: 10px 15px;
            border: 2px solid #ddd;
            border-radius: 10px;
            font-size: 1rem;
            transition: var(--transition);
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            background: #fff;
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

        .status-pending {
            color: var(--warning);
            font-weight: 500;
        }

        .status-completed {
            color: var(--success);
            font-weight: 500;
        }

        .status-cancelled {
            color: var(--danger);
            font-weight: 500;
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
        }

        @media (max-width: 768px) {
            .action-buttons-container {
                flex-direction: column;
                gap: 3px;
            }
            
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
        <div class="sidebar">
            <button class="sidebar-close" id="sidebarClose">×</button>
            <img src="${pageContext.request.contextPath}/images/TARS.jpg" alt="Tars Logo" class="logo" 
                 onerror="console.error('Failed to load logo'); this.src='https://via.placeholder.com/150?text=Logo+Not+Found';">
            <div class="page-title">Organizations</div>
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
                    <li class="active"><a href="#"><i class="fas fa-building"></i> Organizations</a></li>
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
            
            <div class="table-container slide-up">
                <div class="scroll-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Organization Name</th>
                                <th>Project Name</th>
                                <th>Total</th>
                                <th>Balance</th>
                                <th>Email</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                HttpSession sessionObj = request.getSession();
                                String companyIdStr = (String) sessionObj.getAttribute("company_id");
                                Integer companyId = null;

                                if (companyIdStr != null && !companyIdStr.isEmpty()) {
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

                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

                                    String query = "SELECT l.lead_id, f.quotes_values, f.status, l.org, l.project_name, l.email, COALESCE(f.balance, 0) AS balance " +
                                               "FROM leads l " +
                                               "LEFT JOIN financemanagement f ON l.lead_id = f.lead_id " +
                                               "WHERE l.org IS NOT NULL AND l.org <> '' AND l.company_id = ?";

                                    PreparedStatement ps = con.prepareStatement(query);
                                    ps.setInt(1, companyId);
                                    
                                    ResultSet rs = ps.executeQuery();

                                    while (rs.next()) {
                                        String status = rs.getString("status");
                                        String statusClass = "";
                                        if (status != null) {
                                            if (status.equalsIgnoreCase("completed")) {
                                                statusClass = "status-completed";
                                            } else if (status.equalsIgnoreCase("pending")) {
                                                statusClass = "status-pending";
                                            } else if (status.equalsIgnoreCase("cancelled")) {
                                                statusClass = "status-cancelled";
                                            }
                                        }
                            %>
                            <tr>
                                <td><%= rs.getString("org") %></td>
                                <td><%= rs.getString("project_name") %></td>
                                <td><%= rs.getString("quotes_values") %></td>
                                <td><%= rs.getInt("balance") %></td>
                                <td><%= rs.getString("email") %></td>
                                <td class="<%= statusClass %>"><%= rs.getString("status") != null ? rs.getString("status") : "---" %></td>
                                <td>
                                    <div class="action-buttons-container">
                                        <form action="composeEmail.jsp" method="get">
                                            <input type="hidden" name="recipient" value="<%= rs.getString("email") %>">
                                            <button type="submit" class="action-btn email">
                                                <i class="fas fa-envelope"></i> Email
                                            </button>
                                        </form>
                                        <button class="action-btn edit" onclick="openEditModal(<%= rs.getInt("lead_id") %>, '<%= rs.getString("org") %>', '<%= rs.getString("project_name") %>', '<%= rs.getString("quotes_values") %>', <%= rs.getInt("balance") %>, '<%= rs.getString("email") %>', '<%= rs.getString("status") %>')">
                                            <i class="fas fa-edit"></i> Edit
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }

                                    rs.close();
                                    ps.close();
                                    con.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Organization Modal -->
    <div class="modal" id="editModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Organization</h2>
                <button class="close-btn" onclick="closeEditModal()">×</button>
            </div>
            <form action="UpdateOrganizationServlet" method="post">
                <input type="hidden" name="lead_id" id="editLeadId">
                <div class="form-group">
                    <label for="editOrgName">Organization Name</label>
                    <input type="text" id="editOrgName" name="org" class="form-control" required>
                </div>
                <div class="form-group">
                    <label for="editProjectName">Project Name</label>
                    <input type="text" id="editProjectName" name="project_name" class="form-control" required>
                </div>
                <div class="form-group">
                    <label for="editTotal">Total</label>
                    <input type="text" id="editTotal" name="quotes_values" class="form-control" required>
                </div>
                <div class="form-group">
                    <label for="editBalance">Balance</label>
                    <input type="number" id="editBalance" name="balance" class="form-control" required>
                </div>
                <div class="form-group">
                    <label for="editEmail">Email</label>
                    <input type="email" id="editEmail" name="email" class="form-control" required>
                </div>
                <div class="form-group">
                    <label for="editStatus">Status</label>
                    <select id="editStatus" name="status" class="form-control" required>
                        <option value="pending">Pending</option>
                        <option value="completed">Completed</option>
                        <option value="cancelled">Cancelled</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Save Changes
                </button>
            </form>
        </div>
    </div>

    <script>
        const sidebar = document.querySelector('.sidebar');
        const menuToggle = document.getElementById('menuToggle');
        const sidebarClose = document.getElementById('sidebarClose');
        const editModal = document.getElementById('editModal');

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

        // Modal Functions
        function openEditModal(leadId, orgName, projectName, total, balance, email, status) {
            document.getElementById('editLeadId').value = leadId;
            document.getElementById('editOrgName').value = orgName;
            document.getElementById('editProjectName').value = projectName;
            document.getElementById('editTotal').value = total;
            document.getElementById('editBalance').value = balance;
            document.getElementById('editEmail').value = email;
            document.getElementById('editStatus').value = status || 'pending';
            editModal.classList.add('active');
        }

        function closeEditModal() {
            editModal.classList.remove('active');
        }

        // Modal click-outside-to-close
        editModal.addEventListener('click', function(event) {
            if (event.target === editModal) {
                closeEditModal();
            }
        });

        // Close modal on Escape key
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && editModal.classList.contains('active')) {
                closeEditModal();
            }
        });

        // Auto-scroll sidebar to center the active item
        window.onload = function() {
            const activeItem = document.querySelector('.sidebar-menu li.active');
            const sidebarMenu = document.querySelector('.sidebar-menu');
            if (activeItem && sidebarMenu) {
                const itemRect = activeItem.getBoundingClientRect();
                const menuRect = sidebarMenu.getBoundingClientRect();
                const offset = itemRect.top - menuRect.top - (menuRect.height / 2) + (itemRect.height / 2);
                sidebarMenu.scrollTop += offset;
            }
        };

        setTimeout(function() {
            const messages = document.querySelectorAll('.message');
            messages.forEach(function(message) {
                message.style.display = 'none';
            });
        }, 5000);
    </script>
</body>
</html>