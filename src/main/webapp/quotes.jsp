<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quotes</title>
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
            margin-top: -53px;
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
            background: #1da1f2;
            color: white;
        }

        .action-btn.delete {
            background: #e24728;
            color: white;
        }

        .action-btn.generate {
            background: #6b7280;
            color: white;
        }

        .action-btn.restore {
            background: #28a745;
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
            border-radius: var(--border-radius);
            width: 90%;
            max-width: 1082px;
            height: 90vh;
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

        .description-table {
            width: 100%;
            margin-bottom: 15px;
            border-collapse: collapse;
        }

        .description-table th, .description-table td {
            padding: 8px;
            border: 1px solid #ddd;
            text-align: left;
        }

        .description-table th {
            background-color: #f3f4f6;
            font-weight: 600;
        }

        .description-table input, .description-table textarea {
            width: 100%;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .description-table textarea {
            height: 100px;
            resize: none;
            overflow-y: auto;
        }

        .description-table .action-cell {
            text-align: center;
        }

        .total-amount-label {
            font-weight: 600;
            color: var(--text-color);
        }

        .total-amount {
            font-weight: 600;
            color: var(--accent);
        }

        .form-row {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }

        .form-row .form-group {
            flex: 1;
            min-width: 200px;
        }

        .confirmation-modal-content {
            max-width: 400px;
            text-align: center;
            height: 32vh;
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

            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
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

            .confirmation-buttons {
                flex-direction: column;
                gap: 10px;
            }

            .confirmation-buttons .btn {
                width: 100%;
            }

            .form-row {
                flex-direction: column;
            }

            .form-row .form-group {
                min-width: 100%;
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
            <img src="${pageContext.request.contextPath}/images/TARS.jpg?t=${System.currentTimeMillis()}" alt="TARS CRM Logo" class="logo">
            <div class="page-title">Quotes</div>
            <div class="sidebar-menu">
                <ul>
                    <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li><a href="leads.jsp"><i class="fas fa-users"></i> Leads</a></li>
                    <li><a href="leadmanagement.jsp"><i class="fas fa-tasks"></i> Lead Management</a></li>
                    <li><a href="projects.jsp"><i class="fas fa-project-diagram"></i> Projects</a></li>
                    <li class="active"><a href="#"><i class="fas fa-file-invoice-dollar"></i> Quotes</a></li>
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
            
            <%
                // Check if we need to show deleted quotes
                String viewMode = request.getParameter("viewMode");
                boolean showDeleted = "deleted".equals(viewMode);
            %>
            <div class="page-header">
                <% if (!showDeleted) { %>
                    <button class="btn btn-primary" onclick="openModal()">
                        <i class="fas fa-plus"></i> Add Quote
                    </button>
                    <button class="btn btn-secondary" onclick="window.location.href='quotes.jsp?viewMode=deleted'">
                        <i class="fas fa-trash"></i> Deleted Items
                    </button>
                <% } else { %>
                    <button class="btn btn-primary" onclick="window.location.href='quotes.jsp'">
                        <i class="fas fa-arrow-left"></i> Back to Quotes
                    </button>
                <% } %>
            </div>
            
            <div class="table-container slide-up">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Lead ID</th>
                                <th>Description Count</th>
                                <th>Quotation Date</th>
                                <th>Client Name</th>
                                <th>Firm</th>
                                <th>Final Amount</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%! 
                                public String truncateText(String text, int maxWords) {
                                    if (text == null || text.trim().isEmpty()) {
                                        return "";
                                    }
                                    String[] words = text.split("\\s+");
                                    if (words.length <= maxWords) {
                                        return text;
                                    }
                                    StringBuilder sb = new StringBuilder();
                                    for (int i = 0; i < maxWords; i++) {
                                        sb.append(words[i]).append(" ");
                                    }
                                    return sb.toString().trim() + "...";
                                }
                            %>
                            <%
                                Connection con = null;
                                PreparedStatement ps = null;
                                ResultSet rs = null;

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

                                try {
                                    String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection(url, user, pass);
                                    String sql = "SELECT quotation.quote_id, leads.lead_id, quotation.quotation_date, quotation.orgamt, " +
                                                "leads.customer_name, leads.firm, quotation.amount " +
                                                "FROM leads " +
                                                "JOIN quotation ON leads.lead_id = quotation.lead_id " +
                                                "WHERE leads.company_id = ? AND quotation.yesno_status = ? AND leads.yesno_status = 'yes'";
                                    ps = con.prepareStatement(sql);
                                    ps.setInt(1, companyId);
                                    ps.setString(2, showDeleted ? "no" : "yes");
                                    rs = ps.executeQuery();

                                    while (rs.next()) {
                                        int quoteId = rs.getInt("quote_id");
                                        int leadId = rs.getInt("lead_id");
                                        String amount = rs.getString("amount");
                                        String orgamt = rs.getString("orgamt");
                                        // Count descriptions for this lead
                                        PreparedStatement descCountPs = con.prepareStatement(
                                            "SELECT COUNT(*) FROM description WHERE lead_id = ? AND company_id = ?"
                                        );
                                        descCountPs.setInt(1, leadId);
                                        descCountPs.setInt(2, companyId);
                                        ResultSet descCountRs = descCountPs.executeQuery();
                                        int descCount = 0;
                                        if (descCountRs.next()) {
                                            descCount = descCountRs.getInt(1);
                                        }
                                        descCountRs.close();
                                        descCountPs.close();
                            %>
                            <tr>
                                <td data-title="Lead ID"><%= leadId %></td>
                                <td data-title="Description Count"><%= descCount %></td>
                                <td data-title="Quotation Date"><%= rs.getString("quotation_date") %></td>
                                <td data-title="Client Name"><%= rs.getString("customer_name") %></td>
                                <td data-title="Firm"><%= rs.getString("firm") %></td>
                                <td data-title="Final Amount"><%= orgamt %></td>
                                <td>
                                    <div style="display: flex; justify-content: flex-end;">
                                        <% if (!showDeleted) { %>
                                            <button class="action-btn edit" onclick="openEditPopup('<%= quoteId %>', '<%= leadId %>')">
                                                <i class="fas fa-edit"></i> Edit
                                            </button>
                                            <button class="action-btn delete" onclick="showConfirmationModal('softDelete', <%= quoteId %>)">
                                                <i class="fas fa-trash"></i> Delete
                                            </button>
                                            <button class="action-btn generate" onclick="generatePDF(<%= quoteId %>)">
                                                <i class="fas fa-file-pdf"></i> PDF
                                            </button>
                                        <% } else { %>
                                            <button class="action-btn delete" onclick="showConfirmationModal('permanentDelete', <%= quoteId %>)">
                                                <i class="fas fa-trash-alt"></i> Permanent Delete
                                            </button>
                                            <button class="action-btn restore" onclick="showConfirmationModal('restore', <%= quoteId %>)">
                                                <i class="fas fa-undo"></i> Restore
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
                                    try {
                                        if (rs != null) rs.close();
                                        if (ps != null) ps.close();
                                        if (con != null) con.close();
                                    } catch (Exception ex) {
                                        ex.printStackTrace();
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Quote Modal -->
    <div class="modal" id="addContactModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Add Quote</h2>
                <button class="close-btn" onclick="closeModal()">×</button>
            </div>
            <form action="quoteservlet" method="post" onsubmit="return validateSrNoSequence(event)">
                <div class="form-row">
                    <div class="form-group">
                        <label for="leadid">Lead ID</label>
                        <input type="text" class="form-control" name="leadid" id="leadid" placeholder="Lead ID" required>
                    </div>
                    <div class="form-group">
                        <label for="date">Quotation Date</label>
                        <input type="date" class="form-control" name="date" id="date" required>
                    </div>
                </div>
                <div class="form-group">
                    <h3>Descriptions</h3>
                    <table class="description-table" id="descriptionTable">
                        <thead>
                            <tr>
                                <th style="width: 10%;">Sr. No</th>
                                <th style="width: 60%;">Description</th>
                                <th style="width: 20%;">Price</th>
                                <th style="width: 10%;">Action</th>
                            </tr>
                        </thead>
                        <tbody id="descriptionRows">
                            <tr>
                                <td><input type="number" name="srNo[]" value="" min="1" class="sr-no-input" required></td>
                                <td><textarea name="description[]" placeholder="Enter description" class="description-input" required></textarea></td>
                                <td><input type="number" name="price[]" placeholder="Enter price" step="0.01" min="0" required oninput="calculateTotal()"></td>
                                <td class="action-cell">
                                    <button type="button" class="action-btn delete" onclick="removeRow(this)">
                                        <i class="fas fa-minus"></i> Delete
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <button type="button" class="btn btn-primary" onclick="addNewRow()">
                        <i class="fas fa-plus"></i> Add Row
                    </button>
                </div>
                <div class="form-group">
                    <label class="total-amount-label">Total Amount:</label>
                    <span class="total-amount" id="totalAmount">0.00</span>
                    <input type="hidden" name="amount" id="amountInput">
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Save Quote
                </button>
            </form>
        </div>
    </div>

    <!-- Edit Quote Modal -->
    <div class="modal" id="editdata">
        <div class="modal-content" id="editModalContent">
            <!-- Content will be loaded dynamically -->
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

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        function updateRowNumbers(tbodyId) {
            const tbody = document.getElementById(tbodyId);
            const srNoInputs = tbody.querySelectorAll('input[name="srNo[]"]');
            srNoInputs.forEach((input, index) => {
                input.value = index + 1;
            });
        }

        function addNewRow() {
            const tbody = document.getElementById('descriptionRows');
            const newRow = document.createElement('tr');
            newRow.innerHTML = `
                <td><input type="number" name="srNo[]" value="" min="1" class="sr-no-input" required></td>
                <td><textarea name="description[]" placeholder="Enter description" class="description-input" required></textarea></td>
                <td><input type="number" name="price[]" placeholder="Enter price" step="0.01" min="0" required oninput="calculateTotal()"></td>
                <td class="action-cell">
                    <button type="button" class="action-btn delete" onclick="removeRow(this)">
                        <i class="fas fa-minus"></i> Delete
                    </button>
                </td>
            `;
            tbody.appendChild(newRow);
            updateRowNumbers('descriptionRows');
            calculateTotal();
        }

        function removeRow(button) {
            const tbody = document.getElementById('descriptionRows');
            const rows = tbody.querySelectorAll('tr');
            
            if (rows.length > 1) {
                const rowToRemove = button.closest('tr');
                rowToRemove.remove();
                updateRowNumbers('descriptionRows');
                calculateTotal();
            } else {
                alert("You must have at least one row.");
            }
        }

        function calculateTotal() {
            let total = 0;
            const priceInputs = document.querySelectorAll('input[name="price[]"]');
            priceInputs.forEach(input => {
                const value = parseFloat(input.value) || 0;
                total += value;
            });
            document.getElementById('totalAmount').textContent = total.toFixed(2);
            document.getElementById('amountInput').value = total.toFixed(2);
        }

        function validateSrNoSequence(event) {
            const srNoInputs = document.querySelectorAll('input[name="srNo[]"]');
            const srNos = Array.from(srNoInputs).map(input => parseInt(input.value) || 0).filter(num => num > 0);
            
            if (srNos.length !== new Set(srNos).size) {
                alert("Duplicate Sr. No. values are not allowed. Please ensure each Sr. No. is unique.");
                event.preventDefault();
                return false;
            }

            srNos.sort((a, b) => a - b);
            for (let i = 0; i < srNos.length; i++) {
                if (srNos[i] !== i + 1) {
                    alert("Sr. No. values must be in sequence (1, 2, 3, ...). Please correct the sequence.");
                    event.preventDefault();
                    return false;
                }
            }

            if (srNos.length > 0 && srNos[0] !== 1) {
                alert("Sr. No. sequence must start from 1. Please correct the first Sr. No.");
                event.preventDefault();
                return false;
            }

            return true;
        }

        const menuToggle = document.getElementById('menuToggle');
        const sidebar = document.querySelector('.sidebar');
        const sidebarClose = document.getElementById('sidebarClose');
        
        menuToggle.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });

        sidebarClose.addEventListener('click', () => {
            sidebar.classList.remove('active');
        });

        const amodal = document.getElementById('addContactModal');
        const emodal = document.getElementById('editdata');
        const nmodal = document.getElementById('negotiationModal');
        
        function openModal() {
            const tbody = document.getElementById('descriptionRows');
            tbody.innerHTML = `
                <tr>
                    <td><input type="number" name="srNo[]" value="" min="1" class="sr-no-input" required></td>
                    <td><textarea name="description[]" placeholder="Enter description" class="description-input" required></textarea></td>
                    <td><input type="number" name="price[]" placeholder="Enter price" step="0.01" min="0" required oninput="calculateTotal()"></td>
                    <td class="action-cell">
                        <button type="button" class="action-btn delete" onclick="removeRow(this)">
                            <i class="fas fa-minus"></i> Delete
                        </button>
                    </td>
                </tr>
            `;
            updateRowNumbers('descriptionRows');
            calculateTotal();
            amodal.classList.add('active');
        }

        function closeModal() {
            amodal.classList.remove('active');
        }

        // Confirmation Modal Functions
        let currentAction = null;
        let currentQuoteId = null;

        function showConfirmationModal(action, quoteId) {
            currentAction = action;
            currentQuoteId = quoteId;
            const modal = document.getElementById('confirmationModal');
            const title = document.getElementById('confirmationTitle');
            const message = document.getElementById('confirmationMessage');
            const confirmButton = document.getElementById('confirmActionButton');

            if (action === 'softDelete') {
                title.textContent = 'Delete Quote';
                message.textContent = 'Are you sure you want to delete this quote? It can be restored later.';
                confirmButton.textContent = 'Delete';
                confirmButton.className = 'btn btn-danger';
                confirmButton.onclick = () => confirmAction();
            } else if (action === 'permanentDelete') {
                title.textContent = 'Permanent Delete Quote';
                message.textContent = 'Are you sure you want to permanently delete this quote? This action cannot be undone.';
                confirmButton.textContent = 'Permanent Delete';
                confirmButton.className = 'btn btn-danger';
                confirmButton.onclick = () => confirmAction();
            } else if (action === 'restore') {
                title.textContent = 'Restore Quote';
                message.textContent = 'Are you sure you want to restore this quote?';
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
            currentQuoteId = null;
        }

        function confirmAction() {
            if (!currentQuoteId || !currentAction) return;

            if (currentAction === 'softDelete') {
                fetch('deletequoteservlet1?action=softDelete', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'quoteid=' + currentQuoteId
                })
                .then(response => response.text())
                .then(data => {
                    closeConfirmationModal();
                    window.location.reload();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error deleting quote');
                    closeConfirmationModal();
                });
            } else if (currentAction === 'permanentDelete') {
                fetch('deletequoteservlet1?action=permanentDelete', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'quoteid=' + currentQuoteId
                })
                .then(response => response.text())
                .then(data => {
                    closeConfirmationModal();
                    window.location.reload();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error permanently deleting quote');
                    closeConfirmationModal();
                });
            } else if (currentAction === 'restore') {
                fetch('deletequoteservlet1?action=restore', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'quoteid=' + currentQuoteId
                })
                .then(response => response.text())
                .then(data => {
                    closeConfirmationModal();
                    window.location.reload();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error restoring quote');
                    closeConfirmationModal();
                });
            }
        }
        
        function openEditPopup(quoteId, leadId) {
            $.ajax({
                url: 'edit.jsp',
                type: 'GET',
                data: { quoteId: quoteId, leadId: leadId },
                success: function(response) {
                    document.getElementById('editModalContent').innerHTML = response;
                    emodal.classList.add('active');
                    
                    // Attach event handlers for dynamically loaded content
                    document.getElementById('editModalContent').addEventListener('click', function(e) {
                        if (e.target && e.target.closest('#addEditRowBtn')) {
                            addNewEditRow();
                        }
                        if (e.target && e.target.closest('.action-btn.delete')) {
                            removeEditRow(e.target.closest('.action-btn.delete'));
                        }
                    });
                    
                    // Update row numbers for edit modal
                    updateRowNumbers('editDescriptionRows');
                    calculateEditTotal();
                },
                error: function(xhr, status, error) {
                    console.error("Error loading edit popup: ", error);
                    alert("Error loading edit popup. Please try again.");
                }
            });
        }

        function closeedit() {
            emodal.classList.remove('active');
        }

        function generatePDF(quoteId) {
            window.open('generateQuotationPDF?quoteId=' + quoteId, '_blank');
        }

        function openNegotiationModal(quoteId, currentAmount) {
            document.getElementById('negotiation-quote-id').value = quoteId;
            document.getElementById('newAmount').value = currentAmount;
            nmodal.classList.add('active');
        }

        function closeNegotiationModal() {
            nmodal.classList.remove('active');
        }

        // Functions for edit modal
        function addNewEditRow() {
            const tbody = document.getElementById('editDescriptionRows');
            if (!tbody) return;
            
            const rows = tbody.querySelectorAll('tr');
            const newRow = document.createElement('tr');
            newRow.innerHTML = `
                <td><input type="number" name="srNo[]" value="" min="1" class="sr-no-input" required></td>
                <td><input type="text" name="description[]" placeholder="Enter description" required></td>
                <td><input type="number" name="price[]" placeholder="Enter price" step="0.01" min="0" required oninput="calculateEditTotal()"></td>
                <td class="action-cell">
                    <input type="hidden" name="descId[]" value="">
                    <button type="button" class="action-btn delete">
                        <i class="fas fa-minus"></i> Delete
                    </button>
                </td>
            `;
            tbody.appendChild(newRow);
            updateRowNumbers('editDescriptionRows');
            calculateEditTotal();
        }

        function removeEditRow(button) {
            const row = button.closest('tr');
            if (row) {
                const tbody = row.parentNode;
                if (tbody.querySelectorAll('tr').length > 1) {
                    row.remove();
                    updateRowNumbers('editDescriptionRows');
                    calculateEditTotal();
                }
            }
        }

        function calculateEditTotal() {
            let total = 0;
            const priceInputs = document.querySelectorAll('#editDescriptionTable input[name="price[]"]');
            priceInputs.forEach(input => {
                const value = parseFloat(input.value) || 0;
                total += value;
            });
            
            const previousTotalElement = document.querySelector('.total-amount');
            const previousTotal = previousTotalElement ? parseFloat(previousTotalElement.textContent) || 0 : 0;
            const newAdditional = total - previousTotal;
            const updatedTotal = total;
            
            const additionalAmountElement = document.getElementById('editAdditionalAmount');
            const totalAmountElement = document.getElementById('editTotalAmount');
            const amountInputElement = document.getElementById('editAmountInput');
            
            if (additionalAmountElement) additionalAmountElement.textContent = newAdditional.toFixed(2);
            if (totalAmountElement) totalAmountElement.textContent = updatedTotal.toFixed(2);
            if (amountInputElement) amountInputElement.value = updatedTotal.toFixed(2);
        }

        [amodal, emodal, nmodal].forEach(modal => {
            if (modal) {
                modal.addEventListener('click', function(event) {
                    if (event.target === modal) {
                        if (modal === amodal) closeModal();
                        if (modal === emodal) closeedit();
                        if (modal === nmodal) closeNegotiationModal();
                    }
                });
            }
        });

        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                if (amodal && amodal.classList.contains('active')) closeModal();
                if (emodal && emodal.classList.contains('active')) closeedit();
                if (nmodal && nmodal.classList.contains('active')) closeNegotiationModal();
                if (document.getElementById('confirmationModal').classList.contains('active')) closeConfirmationModal();
            }
        });

        setTimeout(function() {
            const messages = document.querySelectorAll('.message');
            messages.forEach(function(message) {
                message.style.display = 'none';
            });
        }, 5000);

        // Set today's date as default for date inputs
        window.onload = function() {
            var today = new Date();
            var day = ("0" + today.getDate()).slice(-2);
            var month = ("0" + (today.getMonth() + 1)).slice(-2);
            var year = today.getFullYear();
            var dateString = year + "-" + month + "-" + day;

            var dateInputs = document.querySelectorAll("input[type='date']");
            dateInputs.forEach(function(input) {
                input.value = dateString;
            });
        };
    </script>
</body>
</html>