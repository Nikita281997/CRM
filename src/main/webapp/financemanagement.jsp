<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.Set, java.util.HashSet" %>
<%@ page import="java.math.BigDecimal" %>

<%
HttpSession sessionVar = request.getSession(false);
Integer companyId = null;

if (sessionVar != null) {
    Object companyIdObj = sessionVar.getAttribute("company_id");
    if (companyIdObj != null) {
        try {
            companyId = Integer.parseInt(companyIdObj.toString());
        } catch (NumberFormatException e) {
            response.sendRedirect("login1.jsp");
            return;
        }
    }
}

if (companyId == null) {
    response.sendRedirect("login1.jsp");
    return;
}

// Variables for card data
BigDecimal totalRevenue = BigDecimal.ZERO;
BigDecimal totalBalance = BigDecimal.ZERO;
int completedPayments = 0;
int activeClients = 0;

try {
    String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(url, user, pass);
    
    String query = "SELECT fm.lead_id, " +
                  "COALESCE(CAST(fm.installment1 AS CHAR), '0') AS installment1, " +
                  "COALESCE(CAST(fm.installment2 AS CHAR), '0') AS installment2, " +
                  "COALESCE(CAST(fm.installment3 AS CHAR), '0') AS installment3, " +
                  "COALESCE(CAST(fm.balance AS CHAR), '0') AS balance " +
                  "FROM financemanagement fm " +
                  "JOIN project p ON p.lead_id = fm.lead_id " +
                  "WHERE p.company_id = ? AND fm.yesno_status = 'yes'";
    
    PreparedStatement ps = conn.prepareStatement(query);
    ps.setInt(1, companyId);
    ResultSet rs = ps.executeQuery();
    
    while (rs.next()) {
        BigDecimal installment1 = new BigDecimal(rs.getString("installment1"));
        BigDecimal installment2 = new BigDecimal(rs.getString("installment2"));
        BigDecimal installment3 = new BigDecimal(rs.getString("installment3"));
        BigDecimal balance = new BigDecimal(rs.getString("balance"));
        
        // Calculate total revenue (sum of all installments)
        totalRevenue = totalRevenue.add(installment1).add(installment2).add(installment3);
        
        // Calculate total balance
        totalBalance = totalBalance.add(balance);
        
        // Count completed payments (balance = 0)
        if (balance.compareTo(BigDecimal.ZERO) == 0) {
            completedPayments++;
        } else {
            // Count active clients (balance > 0)
            activeClients++;
        }
    }
    
    rs.close();
    ps.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Finance Management</title>
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

        .profile {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 15px;
            margin-top: auto;
            cursor: pointer;
        }

        .profile img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
        }

        .profile span {
            font-size: 0.9rem;
            color: var(--text-color);
            font-weight: 500;
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
            justify-content: flex-start;
            align-items: center;
            margin-bottom: 25px;
        }

        .page-header {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            margin-bottom: 20px;
            margin-top: -53px;
        }

        /* Cards Section */
        .cards-container {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 25px;
        }

        .card {
            background: linear-gradient(135deg, #b3c9e6, #a3d8e0);
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            text-align: center;
            color: #333;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .card .card-content h3 {
            font-size: 1.2rem;
            color: #333;
            margin-bottom: 5px;
        }

        .card .card-content p {
            font-size: 1.5rem;
            font-weight: 600;
            color: #333;
        }

        /* Table Container */
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
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            white-space: nowrap;
            margin: 0;
        }

        .action-btn i {
            margin-right: 5px;
        }

        .action-btn:hover {
            transform: scale(1.05);
            opacity: 0.9;
        }

        .action-btn.edit {
            background: #1da1f2; /* Green */
            color: white;
        }

        .action-btn.delete {
            background: #e24728; /* Orange */
            color: white;
        }

        .action-btn.bill {
            background: #6b7280; /* Purple */
            color: white;
        }

        .action-btn.restore {
            background: #28a745; /* Green */
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
            max-width: 600px;
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

        textarea.form-control {
            min-height: 100px;
            resize: vertical;
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
            background: #ff851b;
            color: white;
        }

        .btn-danger:hover {
            background: #e57717;
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
                padding: 6px 8px;
                font-size: 12px;
            }
            
            table {
                display: block;
                overflow-x: auto;
                white-space: nowrap;
            }

            .confirmation-buttons {
                flex-direction: column;
                gap: 10px;
            }

            .confirmation-buttons .btn {
                width: 100%;
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

        .project-popup {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 80%;
            max-width: 700px;
            max-height: 80vh;
            background: var(--card-bg);
            border-radius: 10px;
            box-shadow: 0 5px 30px rgba(0,0,0,0.3);
            z-index: 3000;
            padding: 25px;
            display: none;
            overflow-y: auto;
        }

        .project-popup.active {
            display: block;
        }

        .popup-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }

        .popup-header h2 {
            font-size: 1.5rem;
            color: var(--text-color);
        }

        .popup-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #6b7280;
            transition: all 0.3s ease;
        }

        .popup-close:hover {
            color: var(--accent);
        }

        .popup-content {
            width: 100%;
        }

        .popup-section {
            margin-bottom: 20px;
        }

        .popup-section h3 {
            margin-bottom: 10px;
            color: var(--primary);
        }

        .popup-section p {
            margin-bottom: 8px;
            word-wrap: break-word;
            white-space: pre-line;
        }

        .popup-section strong {
            color: var(--text-color);
        }

        .popup-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 2000;
            display: none;
        }

        .popup-overlay.active {
            display: block;
        }

        .long-text {
            white-space: pre-line;
            word-break: break-word;
            max-width: 100%;
            display: inline-block;
        }

        .advance-payment {
            color: purple !important;
            font-weight: 500;
        }

        .mid-payment {
            color: orange !important;
            font-weight: 500;
        }

        .final-payment {
            color: green !important;
            font-weight: 500;
        }

        .balance {
            color: red !important;
            font-weight: 500;
        }

        /* Exceed Modal */
        .exceed-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 3000;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }

        .exceed-modal.active {
            opacity: 1;
            visibility: visible;
        }

        .exceed-modal-content {
            background: var(--card-bg);
            border-radius: 10px;
            width: 90%;
            max-width: 400px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 5px 30px rgba(0,0,0,0.2);
            transform: translateY(-20px);
            transition: all 0.3s ease;
        }

        .exceed-modal.active .exceed-modal-content {
            transform: translateY(0);
        }

        .exceed-modal .close-btn {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #6b7280;
            position: absolute;
            top: 10px;
            right: 10px;
        }

        .exceed-modal .close-btn:hover {
            color: var(--accent);
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
            <div class="page-title">Finance Management</div>
            <div class="sidebar-menu">
                <ul>
                    <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li><a href="leads.jsp"><i class="fas fa-users"></i> Leads</a></li>
                    <li><a href="leadmanagement.jsp"><i class="fas fa-tasks"></i> Lead Management</a></li>
                    <li><a href="projects.jsp"><i class="fas fa-project-diagram"></i> Projects</a></li>
                    <li><a href="quotes.jsp"><i class="fas fa-file-invoice-dollar"></i> Quotes</a></li>
                    <li class="active"><a href="#"><i class="fas fa-money-bill-wave"></i> Finance Management</a></li>
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
                    String companyIdStr = (String) session.getAttribute("company_id");
                    Integer companyIdNav = null;

                    if (companyIdStr == null || companyIdStr.trim().isEmpty()) {
                        response.sendRedirect("login1.jsp");
                        return;
                    }

                    try {
                        companyIdNav = Integer.parseInt(companyIdStr);
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

            <%
                // Check if we need to show deleted finance records
                String viewMode = request.getParameter("viewMode");
                boolean showDeleted = "deleted".equals(viewMode);
            %>
            <div class="page-header">
                <% if (!showDeleted) { %>
                    <button class="btn btn-secondary" onclick="window.location.href='financemanagement.jsp?viewMode=deleted'" style="margin-left: auto;">
                        <i class="fas fa-trash"></i> Deleted Items
                    </button>
                <% } else { %>
                    <button class="btn btn-primary" onclick="window.location.href='financemanagement.jsp'" style="margin-left: auto;">
                        <i class="fas fa-arrow-left"></i> Back to Finance Records
                    </button>
                <% } %>
            </div>

            <!-- Cards Section -->
            <div class="cards-container slide-up">
                <div class="card">
                    <div class="card-content">
                        <h3>Total Revenue</h3>
                        <p><%= String.format("₹%,.2f", totalRevenue) %></p>
                    </div>
                </div>
                <div class="card">
                    <div class="card-content">
                        <h3>Balance</h3>
                        <p><%= String.format("₹%,.2f", totalBalance) %></p>
                    </div>
                </div>
                <div class="card">
                    <div class="card-content">
                        <h3>Complete Payment</h3>
                        <p><%= completedPayments %></p>
                    </div>
                </div>
                <div class="card">
                    <div class="card-content">
                        <h3>Active Clients</h3>
                        <p><%= activeClients %></p>
                    </div>
                </div>
            </div>
            
            <div class="table-container slide-up">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Project Name</th>
                                <th>Advance Payment</th>
                                <th>Mid Payment</th>
                                <th>Final Payment</th>
                                <th>Final Value</th>
                                <th>Balance</th>
                                <th>Status</th>
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
                                    Connection conn = DriverManager.getConnection(url, user, pass);
                                    
                                    String query = "SELECT q.quote_id, fm.lead_id, fm.orgamt, fm.total, fm.project_name, " + 
                                                  "p.due_date, fm.customer_name, " +
                                                  "COALESCE(CAST(q.amount AS CHAR), '0') AS quote_amount, " +
                                                  "COALESCE(CAST(q.addiamt AS CHAR), '0') AS quote_addiamt, " +
                                                  "COALESCE(CAST(fm.quotes_values AS CHAR), '0') AS quotes_values, " + 
                                                  "COALESCE(CAST(fm.installment1 AS CHAR), '0') AS installment1, " +
                                                  "COALESCE(CAST(fm.installment2 AS CHAR), '0') AS installment2, " +
                                                  "COALESCE(CAST(fm.installment3 AS CHAR), '0') AS installment3, " +
                                                  "COALESCE(CAST(fm.balance AS CHAR), '0') AS balance, " +
                                                  "fm.status, fm.addirequirement, " + 
                                                  "fm.addifeature, fm.finalvalue, " + 
                                                  "q.requirement AS quote_requirement, q.feature AS quote_feature, " +
                                                  "fm.date1, fm.date2, " +
                                                  "(SELECT MAX(date3) FROM installment3_logs WHERE finance_id = fm.lead_id) AS latest_date3 " +
                                                  "FROM project p " +
                                                  "JOIN financemanagement fm ON p.lead_id = fm.lead_id " + 
                                                  "LEFT JOIN quotation q ON q.lead_id = fm.lead_id AND q.company_id = p.company_id " + 
                                                  "WHERE p.company_id = ? AND fm.yesno_status = ?";
                                    
                                    PreparedStatement ps = conn.prepareStatement(query);
                                    ps.setInt(1, companyId);
                                    ps.setString(2, showDeleted ? "no" : "yes");

                                    ResultSet rsTable = ps.executeQuery();
                                    Set<Integer> displayedLeads = new HashSet<>();
                                    int rowCounter = 0;

                                    while (rsTable.next()) {
                                        int leadId = rsTable.getInt("lead_id");
                                        if (!displayedLeads.contains(leadId)) {
                                            displayedLeads.add(leadId);
                                            rowCounter++;
                                            
                                            String quoteRequirement = rsTable.getString("quote_requirement") != null ? rsTable.getString("quote_requirement") : "N/A";
                                            String quoteFeature = rsTable.getString("quote_feature") != null ? rsTable.getString("quote_feature") : "N/A";
                                            String addiRequirement = rsTable.getString("addirequirement") != null ? rsTable.getString("addirequirement") : "N/A";
                                            String addiFeature = rsTable.getString("addifeature") != null ? rsTable.getString("addifeature") : "N/A";
                                            
                                            String quoteAmountStr = rsTable.getString("quote_amount");
                                            BigDecimal quoteAmount = (quoteAmountStr != null && !quoteAmountStr.isEmpty()) ? new BigDecimal(quoteAmountStr) : BigDecimal.ZERO;

                                            String addiAmountStr = rsTable.getString("quote_addiamt");
                                            BigDecimal addiAmount = (addiAmountStr != null && !addiAmountStr.isEmpty()) ? new BigDecimal(addiAmountStr) : BigDecimal.ZERO;

                                            String quotesValueStr = rsTable.getString("quotes_values");
                                            BigDecimal quotesValue = (quotesValueStr != null && !quotesValueStr.isEmpty()) ? new BigDecimal(quotesValueStr) : BigDecimal.ZERO;

                                            String totalStr = rsTable.getString("total");
                                            BigDecimal total = (totalStr != null && !totalStr.isEmpty()) ? new BigDecimal(totalStr) : BigDecimal.ZERO;

                                            String installment1Str = rsTable.getString("installment1");
                                            BigDecimal installment1 = (installment1Str != null && !installment1Str.isEmpty()) ? new BigDecimal(installment1Str) : BigDecimal.ZERO;

                                            String installment2Str = rsTable.getString("installment2");
                                            BigDecimal installment2 = (installment2Str != null && !installment2Str.isEmpty()) ? new BigDecimal(installment2Str) : BigDecimal.ZERO;

                                            String installment3Str = rsTable.getString("installment3");
                                            BigDecimal installment3 = (installment3Str != null && !installment3Str.isEmpty()) ? new BigDecimal(installment3Str) : BigDecimal.ZERO;

                                            BigDecimal sumOfInstallments = installment1.add(installment2).add(installment3);

                                            String finalValueStr = rsTable.getString("orgamt");
                                            BigDecimal finalValue = (finalValueStr != null && !finalValueStr.isEmpty()) ? new BigDecimal(finalValueStr) : BigDecimal.ZERO;
                                            BigDecimal calculatedBalance = finalValue.subtract(sumOfInstallments);
                                            String formattedBalance = String.format("%,.2f", calculatedBalance);

                                            String displayStatus = calculatedBalance.compareTo(BigDecimal.ZERO) == 0 ? "Completed" : "Pending";

                                            boolean showExceedPopup = total.compareTo(quotesValue) > 0;

                                            String formattedQuoteAmount = String.format("%,.2f", quoteAmount);
                                            String formattedAddiAmount = String.format("%,.2f", addiAmount);
                                            String formattedInstallment1 = String.format("%,.2f", installment1);
                                            String formattedInstallment2 = String.format("%,.2f", installment2);
                                            String formattedInstallment3 = String.format("%,.2f", installment3);
                                            String date1 = rsTable.getString("date1") != null ? rsTable.getString("date1") : "";
                                            String date2 = rsTable.getString("date2") != null ? rsTable.getString("date2") : "";
                                            String latestDate3 = rsTable.getString("latest_date3") != null ? rsTable.getString("latest_date3") : "";
                                        
                            %>
                            <tr onclick="showProjectDetails('<%= leadId %>', '<%= rsTable.getString("project_name") != null ? rsTable.getString("project_name").replace("'", "\\'") : "N/A" %>', 
                                                          '<%= rsTable.getString("customer_name") != null ? rsTable.getString("customer_name").replace("'", "\\'") : "N/A" %>',
                                                          '<%= rsTable.getString("due_date") != null ? rsTable.getString("due_date") : "N/A" %>',
                                                          '<%= formattedInstallment1 %>',
                                                          '<%= formattedInstallment2 %>',
                                                          '<%= formattedInstallment3 %>',
                                                          '<%= formattedQuoteAmount %>',
                                                          '<%= rsTable.getString("orgamt") != null ? String.format("%,.2f", new BigDecimal(rsTable.getString("orgamt"))) : "0.00" %>',
                                                          '<%= formattedBalance %>',
                                                          '<%= displayStatus %>', <%= showExceedPopup ? "true" : "false" %>)">
                                <td><%= rsTable.getString("project_name") != null ? rsTable.getString("project_name") : "N/A" %></td>
                                <td class="advance-payment"><%= formattedInstallment1 %></td>
                                <td class="mid-payment"><%= formattedInstallment2 %></td>
                                <td class="final-payment"><%= formattedInstallment3 %></td>
                                <td><%= rsTable.getString("orgamt") != null ? String.format("%,.2f", new BigDecimal(rsTable.getString("orgamt"))) : "0.00" %></td>
                                <td class="balance"><%= formattedBalance %></td>
                                <td><%= displayStatus %></td>
                                <td>
                                    <div class="action-buttons-container" style="display: flex; gap: 5px; flex-wrap: nowrap;">
                                        <% if (!showDeleted) { %>
                                            <button class="action-btn edit" onclick="event.stopPropagation(); openEditPopup('<%= leadId %>', '<%= formattedInstallment1 %>', '<%= formattedInstallment2 %>', '<%= rsTable.getString("due_date") %>', '<%= date1 %>', '<%= date2 %>', '<%= latestDate3 %>')">
                                                <i class="fas fa-edit"></i> Edit
                                            </button>
                                            <button class="action-btn delete" onclick="event.stopPropagation(); showConfirmationModal('softDelete', <%= leadId %>)">
                                                <i class="fas fa-trash"></i> Delete
                                            </button>
                                            <button class="action-btn bill" onclick="event.stopPropagation(); window.location.href='BillServlet?leadId=<%= leadId %>&balance=<%= formattedBalance.replace(",", "") %>'">
                                                <i class="fas fa-file-invoice-dollar"></i> Bill
                                            </button>
                                        <% } else { %>
                                            <button class="action-btn delete" onclick="event.stopPropagation(); showConfirmationModal('permanentDelete', <%= leadId %>)">
                                                <i class="fas fa-trash-alt"></i> Permanent Delete
                                            </button>
                                            <button class="action-btn restore" onclick="event.stopPropagation(); showConfirmationModal('restore', <%= leadId %>)">
                                                <i class="fas fa-undo"></i> Restore
                                            </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%
                                        }
                                    }
                                    
                                    if (rowCounter == 0) {
                                        out.println("<tr><td colspan='8' style='text-align:center;'>No finance records found</td></tr>");
                                    }
                                    
                                    rsTable.close();
                                    ps.close();
                                    conn.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    out.println("<tr><td colspan='8' class='error-message'>Error loading data: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="popup-overlay" id="projectPopupOverlay"></div>
    <div class="project-popup" id="projectPopup">
        <div class="popup-header">
            <h2>Finance Details</h2>
            <button class="popup-close" onclick="closeProjectPopup()">×</button>
        </div>
        <div class="popup-content">
            <div class="popup-section">
                <h3>Basic Information</h3>
                <p><strong>Lead Id:</strong> <span id="popupLeadId"></span></p>
                <p><strong>Project Name:</strong> <span id="popupProjectName"></span></p>
                <p><strong>Customer Name:</strong> <span id="popupCustomerName"></span></p>
                <p><strong>Due Date:</strong> <span id="popupDueDate"></span></p>
            </div>
            <div class="popup-section">
                <h3>Payment Details</h3>
                <p><strong>Advance Payment:</strong> <span id="popupAdvancePayment" class="advance-payment"></span></p>
                <p><strong>Mid Payment:</strong> <span id="popupMidPayment" class="mid-payment"></span></p>
                <p><strong>Final Payment:</strong> <span id="popupFinalPayment" class="final-payment"></span></p>
                <p><strong>Quotes Amount:</strong> <span id="popupQuotesAmount"></span></p>
                <p><strong>Final Value:</strong> <span id="popupFinalValue"></span></p>
                <p><strong>Balance:</strong> <span id="popupBalance" class="balance"></span></p>
                <p><strong>Status:</strong> <span id="popupStatus"></span></p>
            </div>
        </div>
    </div>

    <div class="modal" id="editdata">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Update Installment</h2>
                <button class="close-btn" onclick="closeedit()">×</button>
            </div>
            <form action="editfinance" method="post">
                <div class="form-group">
                    <label for="popup-lead-id">Quote ID</label>
                    <input type="text" class="form-control" name="quoteid" id="popup-lead-id" readonly>
                </div>
                <div class="form-group">
                    <label for="installment">Installment Type</label>
                    <select class="form-control" name="installment" id="installment" required>
                        <option value="installment1">Installment 1</option>
                        <option value="installment2">Installment 2</option>
                        <option value="installment3">Installment 3</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="value">Amount</label>
                    <input type="text" class="form-control" id="value" name="value" required placeholder="Enter installment value">
                </div>
                <div class="form-group">
                    <label for="date">Date</label>
                    <input type="date" class="form-control" id="date" name="date" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Update Installment
                </button>
            </form>
        </div>
    </div>

    <!-- Confirmation Modal for Delete/Restore and Date Validation -->
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

    <div class="exceed-modal" id="exceedModal">
        <div class="exceed-modal-content">
            <h2>Warning</h2>
            <p>Total value cannot exceed Quotes Value!</p>
            <button class="close-btn" onclick="closeExceedModal()">×</button>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
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

        const editModal = document.getElementById('editdata');
        const projectPopup = document.getElementById('projectPopup');
        const projectPopupOverlay = document.getElementById('projectPopupOverlay');
        const exceedModal = document.getElementById('exceedModal');
        
        function openEditPopup(leadId, installment1, installment2, dueDate, date1, date2, latestDate3) {
            document.getElementById('popup-lead-id').value = leadId;
            const installmentSelect = document.getElementById('installment');
            const dateInput = document.getElementById('date');
            
            installmentSelect.innerHTML = '';
            
            if (parseFloat(installment1.replace(/,/g, '')) > 0 && parseFloat(installment2.replace(/,/g, '')) > 0) {
                installmentSelect.innerHTML = '<option value="installment3">Installment 3</option>';
            } else {
                if (parseFloat(installment1.replace(/,/g, '')) <= 0) {
                    installmentSelect.innerHTML += '<option value="installment1">Installment 1</option>';
                }
                if (parseFloat(installment2.replace(/,/g, '')) <= 0) {
                    installmentSelect.innerHTML += '<option value="installment2">Installment 2</option>';
                }
                installmentSelect.innerHTML += '<option value="installment3">Installment 3</option>';
            }
            
            // No date restriction, set default to due date or current date
            dateInput.value = dueDate || new Date().toISOString().split('T')[0];
            editModal.classList.add('active');
        }

        function closeedit() {
            editModal.classList.remove('active');
        }

        function showProjectDetails(leadId, projectName, customerName, dueDate, advancePayment, midPayment, finalPayment, quotesAmount, finalValue, balance, status, showExceed) {
            document.getElementById('popupLeadId').textContent = leadId;
            document.getElementById('popupProjectName').textContent = projectName;
            document.getElementById('popupCustomerName').textContent = customerName;
            document.getElementById('popupDueDate').textContent = dueDate;
            document.getElementById('popupAdvancePayment').textContent = advancePayment;
            document.getElementById('popupMidPayment').textContent = midPayment;
            document.getElementById('popupFinalPayment').textContent = finalPayment;
            document.getElementById('popupQuotesAmount').textContent = quotesAmount;
            document.getElementById('popupFinalValue').textContent = finalValue;
            document.getElementById('popupBalance').textContent = balance;
            document.getElementById('popupStatus').textContent = status;
            
            projectPopup.classList.add('active');
            projectPopupOverlay.classList.add('active');

            if (showExceed) {
                exceedModal.classList.add('active');
            }
        }

        function closeProjectPopup() {
            projectPopup.classList.remove('active');
            projectPopupOverlay.classList.remove('active');
            closeExceedModal();
        }

        function closeExceedModal() {
            exceedModal.classList.remove('active');
        }

        // Confirmation Modal Functions
        let currentAction = null;
        let currentLeadId = null;

        function showConfirmationModal(action, leadId, message) {
            currentAction = action;
            currentLeadId = leadId;
            const modal = document.getElementById('confirmationModal');
            const title = document.getElementById('confirmationTitle');
            const messageElement = document.getElementById('confirmationMessage');
            const confirmButton = document.getElementById('confirmActionButton');

            if (action === 'softDelete') {
                title.textContent = 'Delete Finance Record';
                messageElement.textContent = 'Are you sure you want to delete this finance record? It can be restored later.';
                confirmButton.textContent = 'Delete';
                confirmButton.className = 'btn btn-danger';
                confirmButton.onclick = () => confirmAction();
            } else if (action === 'permanentDelete') {
                title.textContent = 'Permanent Delete Finance Record';
                messageElement.textContent = 'Are you sure you want to permanently delete this finance record? This action cannot be undone.';
                confirmButton.textContent = 'Permanent Delete';
                confirmButton.className = 'btn btn-danger';
                confirmButton.onclick = () => confirmAction();
            } else if (action === 'restore') {
                title.textContent = 'Restore Finance Record';
                messageElement.textContent = 'Are you sure you want to restore this finance record?';
                confirmButton.textContent = 'Restore';
                confirmButton.className = 'btn btn-success';
                confirmButton.onclick = () => confirmAction();
            } else if (action === 'dateValidation') {
                title.textContent = 'Date Validation Error';
                messageElement.textContent = message || 'The selected date must be after the latest previous installment date!';
                confirmButton.textContent = 'OK';
                confirmButton.className = 'btn btn-secondary';
                confirmButton.onclick = () => closeConfirmationModal();
            }

            modal.classList.add('active');
        }

        function closeConfirmationModal() {
            const modal = document.getElementById('confirmationModal');
            modal.classList.remove('active');
            currentAction = null;
            currentLeadId = null;
            // Reopen edit modal after closing confirmation if it was a date validation
            if (document.referrer.includes('editfinance')) {
                const editModal = document.getElementById('editdata');
                editModal.classList.add('active');
            }
        }

        function confirmAction() {
            if (!currentLeadId || !currentAction) return;

            if (currentAction === 'softDelete') {
                fetch('deletefinance?action=softDelete', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'leadid=' + currentLeadId
                })
                .then(response => response.text())
                .then(data => {
                    closeConfirmationModal();
                    window.location.reload();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error deleting finance record');
                    closeConfirmationModal();
                });
            } else if (currentAction === 'permanentDelete') {
                fetch('deletefinance?action=permanentDelete', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'leadid=' + currentLeadId
                })
                .then(response => response.text())
                .then(data => {
                    closeConfirmationModal();
                    window.location.reload();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error permanently deleting finance record');
                    closeConfirmationModal();
                });
            } else if (currentAction === 'restore') {
                fetch('deletefinance?action=restore', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'leadid=' + currentLeadId
                })
                .then(response => response.text())
                .then(data => {
                    closeConfirmationModal();
                    window.location.reload();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error restoring finance record');
                    closeConfirmationModal();
                });
            }
        }

        // Handle servlet response for date validation
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            const error = urlParams.get('error');
            if (error === 'dateValidation') {
                const message = urlParams.get('message') || 'The selected date must be after the latest previous installment date!';
                showConfirmationModal('dateValidation', null, message);
            }
        };

        editModal.addEventListener('click', function(event) {
            if (event.target === editModal) {
                closeedit();
            }
        });

        projectPopupOverlay.addEventListener('click', function() {
            closeProjectPopup();
        });

        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                if (editModal.classList.contains('active')) closeedit();
                if (projectPopup.classList.contains('active')) closeProjectPopup();
                if (exceedModal.classList.contains('active')) closeExceedModal();
                if (document.getElementById('confirmationModal').classList.contains('active')) closeConfirmationModal();
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