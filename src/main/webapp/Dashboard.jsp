<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.Arrays" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRM Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
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
            display: none;
        }

        .dashboard-container {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 25px;
        }

        .card {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            padding: 25px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        .card h2 {
            font-size: 1.3rem;
            margin-bottom: 20px;
            color: var(--text-color);
            position: relative;
            padding-bottom: 10px;
            display: flex;
            align-items: center;
            font-weight: 500;
        }

        .card h2 i {
            margin-right: 10px;
            color: var(--accent);
        }

        .card h2:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 50px;
            height: 3px;
            background: var(--accent);
            border-radius: 3px;
        }

        .chart-container {
            position: relative;
            height: 200px;
            width: 100%;
            margin: 15px 0;
        }

        .task-stats {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            margin-top: 15px;
        }

        .task-stats div {
            text-align: center;
            flex: 1;
        }

        .task-stats div span {
            font-weight: 500;
            font-size: 1.2rem;
            display: block;
            margin-bottom: 5px;
        }

        .task-stats div small {
            display: block;
            color: var(--text-color);
            font-size: 0.8rem;
        }

        .expenses-table {
            width: 100%;
            overflow-x: auto;
            text-align: center;
        }

        .expenses-table table {
            width: 100%;
            border-collapse: collapse;
        }

        .expenses-table th, .expenses-table td {
            padding: 12px 15px;
            border-bottom: none;
        }

        .expenses-table th {
            background: transparent;
            font-weight: 500;
            color: var(--text-color);
            text-transform: capitalize;
            font-size: 0.9rem;
        }

        .expenses-table td {
            font-size: 1.2rem;
            font-weight: 500;
            color: var(--text-color);
        }

        .profit-analysis {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-top: 20px;
        }

        .profit-analysis .profit-item {
            flex: 1;
            min-width: 120px;
            text-align: center;
        }

        .profit-analysis .profit-item .label {
            font-size: 0.9rem;
            color: var(--text-color);
            margin-bottom: 5px;
        }

        .profit-analysis .profit-item .value {
            font-size: 1.2rem;
            font-weight: 500;
        }

        .profit-analysis .divider {
            width: 1px;
            height: 60px;
            background: #eee;
            margin: 0 10px;
        }

        .profit-chart-container {
            width: 100%;
            height: 120px;
            margin-top: 20px;
        }

        .graph-container {
            display: flex;
            gap: 20px;
        }

        .graph-container .chart-container {
            flex: 1;
            height: 150px;
            margin-top: 20px;
        }

        .meetings-table {
            width: 100%;
            overflow-x: auto;
        }

        .meetings-table table {
            width: 100%;
            border-collapse: collapse;
        }

        .meetings-table th, .meetings-table td {
            padding: 12px 15px;
            border-bottom: 1px solid rgba(0,0,0,0.1);
            text-align: left;
            font-size: 0.9rem;
        }

        .meetings-table th {
            background: var(--secondary);
            font-weight: 500;
            color: var(--text-color);
        }

        .meetings-table td {
            color: var(--text-color);
        }

        .meetings-table td.clickable {
            cursor: pointer;
            color: var(--accent);
        }

        .meetings-table td.clickable:hover {
            text-decoration: underline;
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

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            width: 90%;
            max-width: 800px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }

        .modal-header h3 {
            margin: 0;
            font-size: 1.2rem;
            color: var(--text-color);
        }

        .modal-body {
            padding: 20px;
        }

        .modal-body table {
            width: 100%;
            border-collapse: collapse;
        }

        .modal-body th, .modal-body td {
            padding: 10px;
            border-bottom: 1px solid rgba(0,0,0,0.1);
            text-align: left;
            font-size: 0.9rem;
        }

        .modal-body th {
            background: var(--secondary);
            font-weight: 500;
        }

        .modal-body input[type="text"],
        .modal-body input[type="date"],
        .modal-body input[type="time"] {
            width: 100%;
            padding: 8px;
            margin: 5px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .modal-footer {
            padding: 15px 20px;
            border-top: 1px solid rgba(0,0,0,0.1);
            text-align: right;
        }

        .btn {
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: var(--accent);
            color: white;
            border: none;
        }

        .btn-primary:hover {
            background: #1a91da;
        }

        .btn-outline {
            background: none;
            border: none;
            font-size: 1.2rem;
            color: var(--text-color);
        }

        .btn-outline:hover {
            color: var(--accent);
        }

        @media (max-width: 1200px) {
            .dashboard-container {
                grid-template-columns: repeat(2, 1fr);
            }
            .profit-analysis {
                flex-direction: column;
                gap: 10px;
            }
            .profit-analysis .divider {
                display: none;
            }
            .graph-container {
                flex-direction: column;
            }
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
        }

        @media (max-width: 768px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .card {
                padding: 20px;
            }

            .profit-analysis {
                flex-direction: column;
                gap: 10px;
            }
            .profit-analysis .divider {
                display: none;
            }
            .graph-container {
                flex-direction: column;
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
    <%
        HttpSession sessionVar = request.getSession();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String fullName = "User";
        String imgPath = "https://via.placeholder.com/40";
        Integer companyId = null;

        String companyIdStr = (String) sessionVar.getAttribute("company_id");
        if (companyIdStr != null && !companyIdStr.trim().isEmpty()) {
            try {
                companyId = Integer.parseInt(companyIdStr);
            } catch (NumberFormatException e) {
                out.println("<!-- Debug: Invalid company_id format: " + companyIdStr + " -->");
                response.sendRedirect("login1.jsp");
                return;
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

            // Fetch profile data
            String profileQuery = "SELECT full_name, img FROM company_registration1 WHERE company_id = ?";
            pstmt = con.prepareStatement(profileQuery);
            pstmt.setInt(1, companyId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                fullName = rs.getString("full_name") != null ? rs.getString("full_name") : "User";
                imgPath = rs.getString("img");
                if (imgPath == null || imgPath.isEmpty()) {
                    imgPath = "images/default-profile.jpg";
                }
            }
            rs.close();
            pstmt.close();
        } catch (ClassNotFoundException e) {
            out.println("<!-- Debug: Driver not found: " + e.getMessage() + " -->");
            out.println("<div class='error'>Error: Database driver not found.</div>");
        } catch (SQLException e) {
            out.println("<!-- Debug: SQL Error: " + e.getMessage() + " -->");
            out.println("<div class='error'>Error fetching profile data: " + e.getMessage() + "</div>");
        } catch (Exception e) {
            out.println("<!-- Debug: General Error: " + e.getMessage() + " -->");
            out.println("<div class='error'>Unexpected error: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing ResultSet: " + e.getMessage() + " -->"); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing PreparedStatement: " + e.getMessage() + " -->"); }
            if (con != null) try { con.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing Connection: " + e.getMessage() + " -->"); }
        }
    %>
    <div class="container">
        <div class="sidebar">
            <button class="sidebar-close" id="sidebarClose">×</button>
            <img src="<%= request.getContextPath() %>/images/TARS.jpg?t=<%= System.currentTimeMillis() %>" alt="TARS CRM Logo" class="logo">
            
            <div class="sidebar-menu">
                <ul>
                    <li class="active"><a href="#"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
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
                    <li><a href="integration.jsp"><i class="fas fa-plug"></i> Integration</a></li>
                    <li><a href="delivered.jsp"><i class="fas fa-truck"></i> Delivered</a></li>
                    <li><a href="fetch_meetings_all.jsp"><i class="fas fa-calendar-alt"></i> Calendar</a></li>
                    <li><a href="profile1.jsp"><i class="fas fa-user"></i> Profile</a></li>
                </ul>
            </div>
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
                <h1>Dashboard</h1>
                <div class="user-profile" onclick="window.location.href='profile1.jsp'">
                    <img src="<%= imgPath %>" alt="User Profile">
                    <span><%= fullName %></span>
                </div>
            </div>
            
            <div class="dashboard-container">
                <div class="card slide-up" style="animation-delay: 0s; grid-column: span 3;">
                    <h2><i class="fas fa-chart-bar"></i>Previous Year Analytics</h2>
                    <%
                        con = null;
                        pstmt = null;
                        rs = null;
                        double currentYearProfit = 0.0;
                        double previousYearProfit = 0.0;
                        int selectedYear = Integer.parseInt(request.getParameter("year") != null ? request.getParameter("year") : String.valueOf(LocalDate.now().getYear()));
                        int previousYear = selectedYear - 1;

                        try {
                            
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

                            // Calculate selected year's profit
                            PreparedStatement psSalary = con.prepareStatement("SELECT SUM(salary) AS totalSalary FROM emp WHERE company_id = ? AND YEAR(created_at) = ?");
                            PreparedStatement psServiceCost = con.prepareStatement("SELECT SUM(cost) AS totalCost FROM integrations WHERE company_id = ? AND YEAR(buy_date) = ?");
                            PreparedStatement psRenewalCost = con.prepareStatement("SELECT SUM(renewal_charge) AS totalRenewal FROM integrations WHERE company_id = ? AND YEAR(renewal_date) = ?");
                            PreparedStatement psMoneyReceived = con.prepareStatement("SELECT SUM(total) AS money_received FROM financemanagement WHERE company_id = ? AND total IS NOT NULL AND YEAR(due_date) = ?");

                            // Selected year calculations
                            psSalary.setInt(1, companyId);
                            psSalary.setInt(2, selectedYear);
                            psServiceCost.setInt(1, companyId);
                            psServiceCost.setInt(2, selectedYear);
                            psRenewalCost.setInt(1, companyId);
                            psRenewalCost.setInt(2, selectedYear);
                            psMoneyReceived.setInt(1, companyId);
                            psMoneyReceived.setInt(2, selectedYear);

                            ResultSet rsSalary = psSalary.executeQuery();
                            ResultSet rsServiceCost = psServiceCost.executeQuery();
                            ResultSet rsRenewalCost = psRenewalCost.executeQuery();
                            ResultSet rsMoneyReceived = psMoneyReceived.executeQuery();

                            double totalSalary = 0, totalServiceCost = 0, totalRenewalCost = 0, moneyReceived = 0;

                            if (rsSalary.next()) {
                                totalSalary = rsSalary.getDouble("totalSalary");
                            }
                            if (rsServiceCost.next()) {
                                totalServiceCost = rsServiceCost.getDouble("totalCost");
                            }
                            if (rsRenewalCost.next()) {
                                totalRenewalCost = rsRenewalCost.getDouble("totalRenewal");
                            }
                            if (rsMoneyReceived.next()) {
                                moneyReceived = rsMoneyReceived.getDouble("money_received");
                            }

                            double grandTotal = totalSalary + totalServiceCost + totalRenewalCost;
                            currentYearProfit = moneyReceived - grandTotal;

                            rsSalary.close();
                            rsServiceCost.close();
                            rsRenewalCost.close();
                            rsMoneyReceived.close();

                            // Previous year calculations
                            psSalary.setInt(2, previousYear);
                            psServiceCost.setInt(2, previousYear);
                            psRenewalCost.setInt(2, previousYear);
                            psMoneyReceived.setInt(2, previousYear);

                            rsSalary = psSalary.executeQuery();
                            rsServiceCost = psServiceCost.executeQuery();
                            rsRenewalCost = psRenewalCost.executeQuery();
                            rsMoneyReceived = psMoneyReceived.executeQuery();

                            totalSalary = 0;
                            totalServiceCost = 0;
                            totalRenewalCost = 0;
                            moneyReceived = 0;

                            if (rsSalary.next()) {
                                totalSalary = rsSalary.getDouble("totalSalary");
                            }
                            if (rsServiceCost.next()) {
                                totalServiceCost = rsServiceCost.getDouble("totalCost");
                            }
                            if (rsRenewalCost.next()) {
                                totalRenewalCost = rsRenewalCost.getDouble("totalRenewal");
                            }
                            if (rsMoneyReceived.next()) {
                                moneyReceived = rsMoneyReceived.getDouble("money_received");
                            }

                            grandTotal = totalSalary + totalServiceCost + totalRenewalCost;
                            previousYearProfit = moneyReceived - grandTotal;

                            String currentYearColor = currentYearProfit >= 0 ? "var(--success)" : "var(--danger)";
                            String previousYearColor = previousYearProfit >= 0 ? "var(--success)" : "var(--danger)";
                            String profitStatus = currentYearProfit >= previousYearProfit ? "In Profit" : "In Loss";
                            double profitDifference = currentYearProfit - previousYearProfit;
                            String profitColor = profitDifference >= 0 ? "var(--success)" : "var(--danger)";

                            out.println("<!-- Debug: Current Year (" + selectedYear + ") Profit: " + currentYearProfit + ", Previous Year (" + previousYear + ") Profit: " + previousYearProfit + ", Profit Status: " + profitStatus + " -->");
                    %>
                    <div style="display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
                        <span style="font-size: 0.9rem; color: var(--text-color);">Account Open at (<%= selectedYear %>): <span style="color: <%= currentYearColor %>; font-weight: 500;"><%= String.format("%,.2f", currentYearProfit) %></span></span>
                        <span style="font-size: 0.9rem; color: var(--text-color);">Account Closed at (<%= previousYear %>): <span style="color: <%= previousYearColor %>; font-weight: 500;"><%= String.format("%,.2f", previousYearProfit) %></span></span>
                        <span style="font-size: 0.9rem; color: var(--text-color);">Performance (<%= selectedYear %> vs <%= previousYear %>): <span style="color: <%= profitColor %>; font-weight: 500;"><%= profitStatus %> (<%= String.format("%+,.2f", profitDifference) %>)</span></span>
                        <select id="yearFilter" onchange="filterByYear(this.value)" style="padding: 8px; border-radius: 5px; border: 1px solid #ddd;">
                            <%
                                HashSet<Integer> allYears = new HashSet<>();

                                // Fetch years from financemanagement
                                pstmt = con.prepareStatement("SELECT DISTINCT YEAR(due_date) AS year FROM financemanagement WHERE company_id = ? AND due_date IS NOT NULL");
                                pstmt.setInt(1, companyId);
                                rs = pstmt.executeQuery();
                                while (rs.next()) allYears.add(rs.getInt("year"));
                                rs.close(); pstmt.close();

                                // Fetch years from new_calendar_events
                                pstmt = con.prepareStatement("SELECT DISTINCT YEAR(start_date) AS year FROM new_calendar_events WHERE company_id = ? AND start_date IS NOT NULL");
                                pstmt.setInt(1, companyId);
                                rs = pstmt.executeQuery();
                                while (rs.next()) allYears.add(rs.getInt("year"));
                                rs.close(); pstmt.close();

                                // Add current year if not present
                                int currentYear = LocalDate.now().getYear();
                                if (!allYears.contains(currentYear)) {
                                    allYears.add(currentYear);
                                }

                                // Sort and populate dropdown
                                Integer[] yearsArray = allYears.toArray(new Integer[0]);
                                Arrays.sort(yearsArray);
                                for (int year : yearsArray) {
                                    out.println("<option value='" + year + "'" + (year == selectedYear ? " selected" : "") + ">" + year + "</option>");
                                }
                            %>
                        </select>
                    </div>
                    <div class="chart-container" style="height: 150px; margin-top: 20px;">
                        <canvas id="yearComparisonChart"></canvas>
                    </div>
                    <script>
                        try {
                            const yearComparisonCtx = document.getElementById('yearComparisonChart');
                            if (!yearComparisonCtx) {
                                console.error('Canvas element yearComparisonChart not found');
                            } else {
                                new Chart(yearComparisonCtx, {
                                    type: 'bar',
                                    data: {
                                        labels: ['<%= previousYear %>', '<%= selectedYear %>'],
                                        datasets: [{
                                            label: 'Profit',
                                            data: [<%= previousYearProfit %>, <%= currentYearProfit %>],
                                            backgroundColor: [
                                                '<%= previousYearProfit >= 0 ? "rgba(0, 196, 180, 0.7)" : "rgba(255, 99, 132, 0.7)" %>',
                                                '<%= currentYearProfit >= 0 ? "rgba(0, 196, 180, 0.7)" : "rgba(255, 99, 132, 0.7)" %>'
                                            ],
                                            borderColor: [
                                                '<%= previousYearProfit >= 0 ? "rgba(0, 196, 180, 1)" : "rgba(255, 99, 132, 1)" %>',
                                                '<%= currentYearProfit >= 0 ? "rgba(0, 196, 180, 1)" : "rgba(255, 99, 132, 1)" %>'
                                            ],
                                            borderWidth: 1
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {
                                                display: false
                                            },
                                            tooltip: {
                                                callbacks: {
                                                    label: function(context) {
                                                        let value = context.raw;
                                                        return 'Profit: ' + (value >= 0 ? '+' : '') + value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                                                    }
                                                }
                                            }
                                        },
                                        scales: {
                                            y: {
                                                beginAtZero: true,
                                                title: {
                                                    display: true,
                                                    text: 'Profit'
                                                },
                                                ticks: {
                                                    callback: function(value) {
                                                        return value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                                                    }
                                                }
                                            },
                                            x: {
                                                title: {
                                                    display: true,
                                                    text: 'Year'
                                                }
                                            }
                                        }
                                    }
                                });
                                console.log('Year comparison histogram rendered successfully');
                            }
                        } catch (e) {
                            console.error('Error rendering year comparison chart:', e);
                        }
                    </script>
                    <%
                        } catch (Exception e) {
                            out.println("<div class='error'>Error loading previous year analytics: " + e.getMessage() + "</div>");
                            out.println("<!-- Debug: Error in previous year analytics: " + e.getMessage() + " -->");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing ResultSet: " + e.getMessage() + " -->"); }
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing PreparedStatement: " + e.getMessage() + " -->"); }
                            if (con != null) try { con.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing Connection: " + e.getMessage() + " -->"); }
                        }
                    %>
                </div>

                <div class="card slide-up" style="animation-delay: 0.1s;">
                    <h2><i class="fas fa-tasks"></i>My Open Tasks</h2>
                    <%
                        con = null;
                        pstmt = null;
                        rs = null;
                        int open = 0, progress = 0, todo = 0, completed = 0;

                        try {
                             
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

                            pstmt = con.prepareStatement("SELECT COUNT(*) FROM open_tasks WHERE company_id = ? AND YEAR(dead_line) = ?");
                            pstmt.setInt(1, companyId);
                            pstmt.setInt(2, selectedYear);
                            rs = pstmt.executeQuery();
                            if (rs.next()) open = rs.getInt(1);
                            rs.close(); pstmt.close();

                            pstmt = con.prepareStatement("SELECT COUNT(*) FROM in_progress_tasks WHERE company_id = ? AND YEAR(dead_line) = ?");
                            pstmt.setInt(1, companyId);
                            pstmt.setInt(2, selectedYear);
                            rs = pstmt.executeQuery();
                            if (rs.next()) progress = rs.getInt(1);
                            rs.close(); pstmt.close();

                            pstmt = con.prepareStatement("SELECT COUNT(*) FROM todo_tasks WHERE company_id = ? AND YEAR(dead_line) = ?");
                            pstmt.setInt(1, companyId);
                            pstmt.setInt(2, selectedYear);
                            rs = pstmt.executeQuery();
                            if (rs.next()) todo = rs.getInt(1);
                            rs.close(); pstmt.close();

                            pstmt = con.prepareStatement("SELECT COUNT(*) FROM completed_tasks WHERE company_id = ? AND YEAR(dead_line) = ?");
                            pstmt.setInt(1, companyId);
                            pstmt.setInt(2, selectedYear);
                            rs = pstmt.executeQuery();
                            if (rs.next()) completed = rs.getInt(1);
                            rs.close(); pstmt.close();

                            out.println("<!-- Debug: Task Data - Open: " + open + ", In Progress: " + progress + ", Completed: " + completed + " -->");
                    %>

                    <div class="chart-container">
                        <canvas id="taskPieChart"></canvas>
                    </div>

                    <div class="task-stats">
                        <div>
                            <span style="color: var(--danger);"><%= open %></span>
                            <small>Open</small>
                        </div>
                        <div>
                            <span style="color: var(--info);"><%= progress %></span>
                            <small>In Progress</small>
                        </div>
                        <div>
                            <span style="color: var(--success);"><%= completed %></span>
                            <small>Completed</small>
                        </div>
                    </div>

                    <script>
                        try {
                            const pieCtx = document.getElementById('taskPieChart');
                            if (!pieCtx) {
                                console.error('Canvas element taskPieChart not found');
                            } else {
                                new Chart(pieCtx, {
                                    type: 'doughnut',
                                    data: {
                                        labels: ['Open', 'In Progress', 'Completed'],
                                        datasets: [{
                                            data: [<%= open %>, <%= progress %>, <%= completed %>],
                                            backgroundColor: [
                                                'rgba(255, 99, 132, 0.7)',
                                                'rgba(54, 162, 235, 0.7)',
                                                'rgba(75, 192, 192, 0.7)'
                                            ],
                                            borderColor: [
                                                'rgba(255, 99, 132, 1)',
                                                'rgba(54, 162, 235, 1)',
                                                'rgba(75, 192, 192, 1)'
                                            ],
                                            borderWidth: 1
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {
                                                display: false
                                            }
                                        },
                                        cutout: '70%'
                                    }
                                });
                                console.log('Task pie chart rendered successfully');
                            }
                        } catch (e) {
                            console.error('Error rendering task pie chart:', e);
                        }
                    </script>

                    <%
                        } catch (Exception e) {
                            out.println("<div class='error'>Error loading task data: " + e.getMessage() + "</div>");
                            out.println("<!-- Debug: Error in task section: " + e.getMessage() + " -->");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing ResultSet: " + e.getMessage() + " -->"); }
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing PreparedStatement: " + e.getMessage() + " -->"); }
                            if (con != null) try { con.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing Connection: " + e.getMessage() + " -->"); }
                        }
                    %>
                </div>

                <div class="card slide-up" style="animation-delay: 0.2s;">
                    <h2><i class="fas fa-chart-bar"></i>Yearly Revenue and Sales</h2>
                    <%
                        con = null;
                        pstmt = null;
                        rs = null;
                        StringBuilder years = new StringBuilder();
                        StringBuilder productsSoldData = new StringBuilder();
                        StringBuilder revenueData = new StringBuilder();
                        int selectedYearRevenue = Integer.parseInt(request.getParameter("year") != null ? request.getParameter("year") : String.valueOf(LocalDate.now().getYear()));

                        try {
                             
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
                            
                            String query = "SELECT COALESCE(YEAR(f.due_date), 'Unknown') AS year, " +
                                          "COUNT(CASE WHEN t.status = 'delivered' THEN t.lead_id END) AS products_sold, " +
                                          "SUM(f.total) AS total_revenue " +
                                          "FROM financemanagement f " +
                                          "LEFT JOIN testertable t ON f.lead_id = t.lead_id AND f.company_id = t.company_id " +
                                          "WHERE f.company_id = ? AND YEAR(f.due_date) = ? " +
                                          "GROUP BY year " +
                                          "ORDER BY year";

                            pstmt = con.prepareStatement(query);
                            pstmt.setInt(1, companyId);
                            pstmt.setInt(2, selectedYearRevenue);
                            rs = pstmt.executeQuery();

                            while (rs.next()) {
                                if (years.length() > 0) years.append(",");
                                if (productsSoldData.length() > 0) productsSoldData.append(",");
                                if (revenueData.length() > 0) revenueData.append(",");

                                years.append("'").append(rs.getString("year")).append("'");
                                productsSoldData.append(rs.getInt("products_sold"));
                                revenueData.append(rs.getDouble("total_revenue"));
                            }

                            if (years.length() == 0) {
                                years.append("'No Data'");
                                productsSoldData.append("0");
                                revenueData.append("0");
                            }

                            out.println("<!-- Debug: Revenue Data - Years: " + years + ", Products Sold: " + productsSoldData + ", Revenue: " + revenueData + " -->");
                    %>

                    <div class="chart-container">
                        <canvas id="revenueChart"></canvas>
                    </div>

                    <div id="leadModal" class="modal">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h3>Lead Information</h3>
                                <button class="modal-close btn btn-outline">×</button>
                            </div>
                            <div class="modal-body">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Lead ID</th>
                                            <th>Project Name</th>
                                            <th>Customer Name</th>
                                            <th>Status</th>
                                            <th>Total Amount</th>
                                        </tr>
                                    </thead>
                                    <tbody id="leadTableBody">
                                    </tbody>
                                </table>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-primary modal-close">Close</button>
                            </div>
                        </div>
                    </div>

                    <script>
                        try {
                            const barCtx = document.getElementById('revenueChart');
                            if (!barCtx) {
                                console.error('Canvas element revenueChart not found');
                            } else {
                                const revenueChart = new Chart(barCtx, {
                                    type: 'bar',
                                    data: {
                                        labels: [<%= years.toString() %>],
                                        datasets: [
                                            {
                                                label: 'Products Sold (Delivered)',
                                                data: [<%= productsSoldData.toString() %>],
                                                backgroundColor: 'rgba(54, 162, 235, 0.7)',
                                                borderColor: 'rgba(54, 162, 235, 1)',
                                                borderWidth: 1
                                            },
                                            {
                                                label: 'Total Revenue',
                                                data: [<%= revenueData.toString() %>],
                                                backgroundColor: 'rgba(75, 192, 192, 0.7)',
                                                borderColor: 'rgba(75, 192, 192, 1)',
                                                borderWidth: 1
                                            }
                                        ]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {
                                                position: 'top',
                                                labels: {
                                                    padding: 20,
                                                    usePointStyle: true
                                                }
                                            },
                                            tooltip: {
                                                mode: 'index',
                                                intersect: false,
                                            }
                                        },
                                        scales: {
                                            x: {
                                                grid: {
                                                    display: false
                                                }
                                            },
                                            y: {
                                                beginAtZero: true,
                                                grid: {
                                                    borderDash: [5]
                                                }
                                            }
                                        }
                                    }
                                });
                                console.log('Revenue bar chart rendered successfully');

                                barCtx.addEventListener('click', function (event) {
                                    const activePoints = revenueChart.getElementsAtEventForMode(event, 'nearest', { intersect: true }, true);
                                    if (activePoints.length > 0) {
                                        const index = activePoints[0].index;
                                        const selectedYear = revenueChart.data.labels[index];
                                        fetchDataForYear(selectedYear);
                                    }
                                });
                            }

                            const modal = document.getElementById('leadModal');
                            const modalCloseBtns = document.querySelectorAll('.modal-close');
                            const leadTableBody = document.getElementById('leadTableBody');

                            modalCloseBtns.forEach(btn => {
                                btn.addEventListener('click', () => {
                                    modal.classList.remove('active');
                                });
                            });

                            modal.addEventListener('click', (e) => {
                                if (e.target === modal) {
                                    modal.classList.remove('active');
                                }
                            });

                            function fetchDataForYear(year) {
                                fetch('fetch_leads_data.jsp?year=' + year)
                                    .then(response => {
                                        if (!response.ok) {
                                            throw new Error('Network response was not ok: ' + response.statusText);
                                        }
                                        return response.text();
                                    })
                                    .then(text => {
                                        try {
                                            const data = JSON.parse(text);
                                            if (!data.success) {
                                                throw new Error(data.error || 'Unknown error in response');
                                            }
                                            leadTableBody.innerHTML = '';
                                            data.data.forEach(lead => {
                                                const row = document.createElement('tr');
                                                row.innerHTML = `
                                                    <td>${lead.lead_id}</td>
                                                    <td>${lead.project_name}</td>
                                                    <td>${lead.customer_name}</td>
                                                    <td>${lead.status}</td>
                                                    <td>${lead.total_amount}</td>
                                                `;
                                                leadTableBody.appendChild(row);
                                            });
                                            
                                            document.querySelector('.modal-header h3').textContent = `Delivered Projects for ${year}`;
                                            modal.classList.add('active');
                                            console.log('Lead data fetched and modal opened for year:', year);
                                        } catch (e) {
                                            console.error('Error parsing JSON:', e);
                                            console.error('Raw response:', text);
                                            alert('Error fetching data: ' + e.message);
                                        }
                                    })
                                    .catch(error => {
                                        console.error('Error fetching lead data:', error);
                                        alert('Error fetching data: ' + error.message);
                                    });
                            }
                        } catch (e) {
                            console.error('Error rendering revenue chart:', e);
                        }
                    </script>

                    <%
                        } catch (Exception e) {
                            out.println("<div class='error'>Error loading revenue data: " + e.getMessage() + "</div>");
                            out.println("<!-- Debug: Error in revenue section: " + e.getMessage() + " -->");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing ResultSet: " + e.getMessage() + " -->"); }
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing PreparedStatement: " + e.getMessage() + " -->"); }
                            if (con != null) try { con.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing Connection: " + e.getMessage() + " -->"); }
                        }
                    %>
                </div>

                <div class="card slide-up" style="animation-delay: 0.3s;">
                    <h2><i class="fas fa-money-bill-wave"></i>Yearly Expenses</h2>
                    <div class="expenses-table">
                        <table>
                            <thead>
                                <tr>
                                    <th>Employee Salary</th>
                                    <th>Services Cost</th>
                                    <th>Services Renewal Cost</th>
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

                                        PreparedStatement psSalary = con.prepareStatement("SELECT SUM(salary) AS totalSalary FROM emp WHERE company_id = ? AND YEAR(created_at) = ?");
                                        PreparedStatement psServiceCost = con.prepareStatement("SELECT SUM(cost) AS totalCost FROM integrations WHERE company_id = ? AND YEAR(buy_date) = ?");
                                        PreparedStatement psRenewalCost = con.prepareStatement("SELECT SUM(renewal_charge) AS totalRenewal FROM integrations WHERE company_id = ? AND YEAR(renewal_date) = ?");
                                        psSalary.setInt(1, companyId);
                                        psSalary.setInt(2, selectedYear);
                                        psServiceCost.setInt(1, companyId);
                                        psServiceCost.setInt(2, selectedYear);
                                        psRenewalCost.setInt(1, companyId);
                                        psRenewalCost.setInt(2, selectedYear);
                                        ResultSet rsSalary = psSalary.executeQuery();
                                        ResultSet rsServiceCost = psServiceCost.executeQuery();
                                        ResultSet rsRenewalCost = psRenewalCost.executeQuery();

                                        double totalSalary = 0, totalServiceCost = 0, totalRenewalCost = 0, grandTotal = 0;

                                        if (rsSalary.next()) {
                                            totalSalary = rsSalary.getDouble("totalSalary");
                                        }
                                        if (rsServiceCost.next()) {
                                            totalServiceCost = rsServiceCost.getDouble("totalCost");
                                        }
                                        if (rsRenewalCost.next()) {
                                            totalRenewalCost = rsRenewalCost.getDouble("totalRenewal");
                                        }

                                        grandTotal = totalSalary + totalServiceCost + totalRenewalCost;
                                        
                                        out.println("<!-- Debug: Expenses - Salary: " + totalSalary + ", Service Cost: " + totalServiceCost + ", Renewal Cost: " + totalRenewalCost + " -->");
                                %>
                                <tr>
                                    <td><%= String.format("%,.2f", totalSalary) %></td>
                                    <td><%= String.format("%,.2f", totalServiceCost) %></td>
                                    <td><%= String.format("%,.2f", totalRenewalCost) %></td>
                                </tr>
                                <%
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='3' class='error'>Error loading expense data</td></tr>");
                                        out.println("<!-- Debug: Error in expenses section: " + e.getMessage() + " -->");
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing ResultSet: " + e.getMessage() + " -->"); }
                                        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing PreparedStatement: " + e.getMessage() + " -->"); }
                                        if (con != null) try { con.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing Connection: " + e.getMessage() + " -->"); }
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div style="margin-top: 25px;"></div>

           <div class="card slide-up" style="animation-delay: 0.4s; grid-column: span 3;">
        <h2><i class="fas fa-chart-line"></i>Yearly Profit Analysis</h2>
        <%
            int selectedYearProfit = Integer.parseInt(request.getParameter("year") != null ? request.getParameter("year") : String.valueOf(LocalDate.now().getYear()));
            try {
               
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

                PreparedStatement psSalary = con.prepareStatement("SELECT SUM(salary) AS totalSalary FROM emp WHERE company_id = ? AND YEAR(created_at) = ?");
                PreparedStatement psServiceCost = con.prepareStatement("SELECT SUM(cost) AS totalCost FROM integrations WHERE company_id = ? AND YEAR(buy_date) = ?");
                PreparedStatement psRenewalCost = con.prepareStatement("SELECT SUM(renewal_charge) AS totalRenewal FROM integrations WHERE company_id = ? AND YEAR(renewal_date) = ?");
                
                String query = "SELECT SUM(orgamt) AS total_revenue " +
                              "FROM financemanagement " +
                              "WHERE company_id = ? " +
                              "AND lead_id IN (SELECT lead_id FROM project) AND YEAR(due_date) = ?";
                pstmt = con.prepareStatement(query);

                PreparedStatement psMoneyReceived = con.prepareStatement(
                    "SELECT SUM(total) AS money_received FROM financemanagement WHERE company_id = ? AND total IS NOT NULL AND YEAR(due_date) = ?");
                PreparedStatement psMoneyNotReceived = con.prepareStatement(
                    "SELECT SUM(orgamt) - SUM(COALESCE(total, 0)) AS money_not_received FROM financemanagement WHERE company_id = ? AND YEAR(due_date) = ?");
                PreparedStatement psMoneyReceivedByMonth = con.prepareStatement(
                    "SELECT MONTH(due_date) AS month, SUM(total) AS money_received " +
                    "FROM financemanagement " +
                    "WHERE company_id = ? AND total IS NOT NULL AND YEAR(due_date) = ? " +
                    "GROUP BY MONTH(due_date) " +
                    "ORDER BY MONTH(due_date)");
                PreparedStatement psMoneyReceivedInstallment1 = con.prepareStatement(
                    "SELECT MONTH(date1) AS month, SUM(installment1) AS money_received " +
                    "FROM financemanagement " +
                    "WHERE company_id = ? AND installment1 IS NOT NULL AND YEAR(date1) = ? " +
                    "GROUP BY MONTH(date1) " +
                    "ORDER BY MONTH(date1)");
                PreparedStatement psMoneyReceivedInstallment2 = con.prepareStatement(
                    "SELECT MONTH(date2) AS month, SUM(installment2) AS money_received " +
                    "FROM financemanagement " +
                    "WHERE company_id = ? AND installment2 IS NOT NULL AND YEAR(date2) = ? " +
                    "GROUP BY MONTH(date2) " +
                    "ORDER BY MONTH(date2)");
                PreparedStatement psMoneyReceivedAmount = con.prepareStatement(
                    "SELECT MONTH(date3) AS month, SUM(amount) AS money_received " +
                    "FROM installment3_logs " +
                    "WHERE company_id = ? AND amount IS NOT NULL AND YEAR(date3) = ? " +
                    "GROUP BY MONTH(date3) " +
                    "ORDER BY MONTH(date3)");

                psSalary.setInt(1, companyId);
                psSalary.setInt(2, selectedYearProfit);
                psServiceCost.setInt(1, companyId);
                psServiceCost.setInt(2, selectedYearProfit);
                psRenewalCost.setInt(1, companyId);
                psRenewalCost.setInt(2, selectedYearProfit);
                pstmt.setInt(1, companyId);
                pstmt.setInt(2, selectedYearProfit);
                psMoneyReceived.setInt(1, companyId);
                psMoneyReceived.setInt(2, selectedYearProfit);
                psMoneyNotReceived.setInt(1, companyId);
                psMoneyNotReceived.setInt(2, selectedYearProfit);
                psMoneyReceivedByMonth.setInt(1, companyId);
                psMoneyReceivedByMonth.setInt(2, selectedYearProfit);
                psMoneyReceivedInstallment1.setInt(1, companyId);
                psMoneyReceivedInstallment1.setInt(2, selectedYearProfit);
                psMoneyReceivedInstallment2.setInt(1, companyId);
                psMoneyReceivedInstallment2.setInt(2, selectedYearProfit);
                psMoneyReceivedAmount.setInt(1, companyId);
                psMoneyReceivedAmount.setInt(2, selectedYearProfit);

                ResultSet rsSalary = psSalary.executeQuery();
                ResultSet rsServiceCost = psServiceCost.executeQuery();
                ResultSet rsRenewalCost = psRenewalCost.executeQuery();
                rs = pstmt.executeQuery();
                ResultSet rsMoneyReceived = psMoneyReceived.executeQuery();
                ResultSet rsMoneyNotReceived = psMoneyNotReceived.executeQuery();
                ResultSet rsMoneyReceivedByMonth = psMoneyReceivedByMonth.executeQuery();
                ResultSet rsMoneyReceivedInstallment1 = psMoneyReceivedInstallment1.executeQuery();
                ResultSet rsMoneyReceivedInstallment2 = psMoneyReceivedInstallment2.executeQuery();
                ResultSet rsMoneyReceivedAmount = psMoneyReceivedAmount.executeQuery();
                
                double totalSalary = 0, totalServiceCost = 0, totalRenewalCost = 0, grandTotal = 0, totalRevenue = 0;
                double moneyReceived = 0, moneyNotReceived = 0;
                double[] moneyReceivedByMonth = new double[12];
                double[] moneyReceivedInstallment1 = new double[12];
                double[] moneyReceivedInstallment2 = new double[12];
                double[] moneyReceivedAmount = new double[12];
                for (int i = 0; i < 12; i++) {
                    moneyReceivedByMonth[i] = 0.0;
                    moneyReceivedInstallment1[i] = 0.0;
                    moneyReceivedInstallment2[i] = 0.0;
                    moneyReceivedAmount[i] = 0.0;
                }

                if (rsSalary.next()) {
                    totalSalary = rsSalary.getDouble("totalSalary");
                }
                if (rsServiceCost.next()) {
                    totalServiceCost = rsServiceCost.getDouble("totalCost");
                }
                if (rsRenewalCost.next()) {
                    totalRenewalCost = rsRenewalCost.getDouble("totalRenewal");
                }
                if (rs.next()) {
                    totalRevenue = rs.getDouble("total_revenue");
                }
                if (rsMoneyReceived.next()) {
                    moneyReceived = rsMoneyReceived.getDouble("money_received");
                }
                if (rsMoneyNotReceived.next()) {
                    moneyNotReceived = rsMoneyNotReceived.getDouble("money_not_received");
                }
                while (rsMoneyReceivedByMonth.next()) {
                    int month = rsMoneyReceivedByMonth.getInt("month");
                    double amount = rsMoneyReceivedByMonth.getDouble("money_received");
                    if (month >= 1 && month <= 12) {
                        moneyReceivedByMonth[month - 1] = amount;
                    }
                }
                while (rsMoneyReceivedInstallment1.next()) {
                    int month = rsMoneyReceivedInstallment1.getInt("month");
                    double amount = rsMoneyReceivedInstallment1.getDouble("money_received");
                    if (month >= 1 && month <= 12) {
                        moneyReceivedInstallment1[month - 1] = amount;
                    }
                }
                while (rsMoneyReceivedInstallment2.next()) {
                    int month = rsMoneyReceivedInstallment2.getInt("month");
                    double amount = rsMoneyReceivedInstallment2.getDouble("money_received");
                    if (month >= 1 && month <= 12) {
                        moneyReceivedInstallment2[month - 1] = amount;
                    }
                }
                while (rsMoneyReceivedAmount.next()) {
                    int month = rsMoneyReceivedAmount.getInt("month");
                    double amount = rsMoneyReceivedAmount.getDouble("money_received");
                    if (month >= 1 && month <= 12) {
                        moneyReceivedAmount[month - 1] = amount;
                    }
                }

                grandTotal = (totalSalary + totalServiceCost + totalRenewalCost);

                double yearProfit = moneyReceived - grandTotal;
                double profitPercentage = (moneyReceived != 0) ? (yearProfit / moneyReceived) * 100 : 0;
                
                String profitColor = yearProfit >= 0 ? "var(--success)" : "var(--danger)";
                String percentageColor = profitPercentage >= 0 ? "var(--success)" : "var(--danger)";
                
                StringBuilder moneyReceivedByMonthData = new StringBuilder();
                StringBuilder moneyReceivedInstallment1Data = new StringBuilder();
                StringBuilder moneyReceivedInstallment2Data = new StringBuilder();
                StringBuilder moneyReceivedAmountData = new StringBuilder();
                for (int i = 0; i < 12; i++) {
                    if (i > 0) {
                        moneyReceivedByMonthData.append(",");
                        moneyReceivedInstallment1Data.append(",");
                        moneyReceivedInstallment2Data.append(",");
                        moneyReceivedAmountData.append(",");
                    }
                    moneyReceivedByMonthData.append(moneyReceivedByMonth[i]);
                    moneyReceivedInstallment1Data.append(moneyReceivedInstallment1[i]);
                    moneyReceivedInstallment2Data.append(moneyReceivedInstallment2[i]);
                    moneyReceivedAmountData.append(moneyReceivedAmount[i]);
                }

                out.println("<!-- Debug: Profit Data - Revenue: " + totalRevenue + ", Received: " + moneyReceived + ", Not Received: " + moneyNotReceived + ", Expenses: " + grandTotal + ", Profit: " + yearProfit + ", Money Received by Month: " + moneyReceivedByMonthData + ", Installment1: " + moneyReceivedInstallment1Data + ", Installment2: " + moneyReceivedInstallment2Data + ", Amount: " + moneyReceivedAmountData + " -->");
        %>
        
        <div class="profit-analysis">
            <div class="profit-item">
                <span class="label">Quotes Amount</span>
                <span class="value"><%= String.format("%,.2f", totalRevenue) %></span>
            </div>
            <div class="divider"></div>
            <div class="profit-item">
                <span class="label">Money Received</span>
                <span class="value" style="color: var(--success);"><%= String.format("%,.2f", moneyReceived) %></span>
            </div>
            <div class="divider"></div>
            <div class="profit-item">
                <span class="label">Money Not Received</span>
                <span class="value" style="color: var(--danger);"><%= String.format(moneyNotReceived >= 0 ? "%,.2f" : "%+,.2f", moneyNotReceived) %></span>
            </div>
            <div class="divider"></div>
            <div class="profit-item">
                <span class="label">Total Expenses</span>
                <span class="value" style="color: var(--danger);"><%= String.format("%,.2f", grandTotal) %></span>
            </div>
            <div class="divider"></div>
            <div class="profit-item">
                <span class="label">Year Profit</span>
                <span class="value" style="font-weight: 600; color: <%= profitColor %>;"><%= String.format("%,.2f", yearProfit) %></span>
            </div>
            <div class="divider"></div>
            <div class="profit-item">
                <span class="label">Profit Percentage</span>
                <span class="value" style="font-weight: 600; color: <%= percentageColor %>;"><%= String.format("%.2f", profitPercentage) %>%</span>
            </div>
        </div>
        
        <div class="graph-container">
            <div class="chart-container">
                <canvas id="moneyReceivedBarChart"></canvas>
            </div>
            <div class="chart-container">
                <canvas id="profitChart"></canvas>
            </div>
        </div>
        
        <script>
            try {
                const moneyReceivedBarCtx = document.getElementById('moneyReceivedBarChart');
                if (!moneyReceivedBarCtx) {
                    console.error('Canvas element moneyReceivedBarChart not found');
                } else {
                    new Chart(moneyReceivedBarCtx, {
                        type: 'bar',
                        data: {
                            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                            datasets: [
                                {
                                    label: 'Installment 1',
                                    data: [<%= moneyReceivedInstallment1Data %>],
                                    backgroundColor: 'rgba(54, 162, 235, 0.7)',
                                    borderColor: 'rgba(54, 162, 235, 1)',
                                    borderWidth: 1
                                },
                                {
                                    label: 'Installment 2',
                                    data: [<%= moneyReceivedInstallment2Data %>],
                                    backgroundColor: 'rgba(75, 192, 192, 0.7)',
                                    borderColor: 'rgba(75, 192, 192, 1)',
                                    borderWidth: 1
                                },
                                {
                                    label: 'Amount',
                                    data: [<%= moneyReceivedAmountData %>],
                                    backgroundColor: 'rgba(255, 205, 86, 0.7)',
                                    borderColor: 'rgba(255, 205, 86, 1)',
                                    borderWidth: 1
                                }
                            ]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    display: true,
                                    position: 'top'
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function(context) {
                                            let value = context.raw;
                                            return context.dataset.label + ': ' + value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                                        }
                                    }
                                }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    title: {
                                        display: true,
                                        text: 'Amount'
                                    },
                                    ticks: {
                                        callback: function(value) {
                                            return value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                                        }
                                    }
                                },
                                x: {
                                    title: {
                                        display: true,
                                        text: 'Month'
                                    }
                                }
                            }
                        }
                    });
                    console.log('Money received bar chart rendered successfully');
                }

                const profitCtx = document.getElementById('profitChart');
                if (!profitCtx) {
                    console.error('Canvas element profitChart not found');
                } else {
                    new Chart(profitCtx, {
                        type: 'line',
                        data: {
                            labels: ['Revenue', 'Received', 'Not Received', 'Expenses', 'Profit'],
                            datasets: [{
                                data: [<%= totalRevenue %>, <%= moneyReceived %>, <%= moneyNotReceived %>, <%= grandTotal %>, <%= yearProfit %>],
                                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                                borderColor: 'rgba(75, 192, 192, 1)',
                                borderWidth: 2,
                                fill: true,
                                tension: 0.4
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    display: false
                                }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true
                                }
                            }
                        }
                    });
                    console.log('Profit line chart rendered successfully');
                }
            } catch (e) {
                console.error('Error rendering charts:', e);
            }
        </script>

        <%
            } catch (Exception e) {
                out.println("<div class='error'>Error loading profit data: " + e.getMessage() + "</div>");
                out.println("<!-- Debug: Error in profit section: " + e.getMessage() + " -->");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing ResultSet: " + e.getMessage() + " -->"); }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing PreparedStatement: " + e.getMessage() + " -->"); }
                if (con != null) try { con.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing Connection: " + e.getMessage() + " -->"); }
            }
        %>
    </div>

            <div style="margin-top: 25px;"></div>

            <div class="card slide-up" style="animation-delay: 0.5s;">
                <h2><i class="fas fa-calendar-alt"></i>Scheduled Meetings</h2>
                <div class="meetings-table">
                    <table>
                        <thead>
                            <tr>
                                <th>Event Name</th>
                                <th>Start Date</th>
                                <th>Start Time</th>
                                <th>End Date</th>
                                <th>End Time</th>
                                <th>Location</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                con = null;
                                pstmt = null;
                                rs = null;
                                ArrayList<Map<String, String>> meetings = new ArrayList<>();
                                int selectedYearMeetings = Integer.parseInt(request.getParameter("year") != null ? request.getParameter("year") : String.valueOf(LocalDate.now().getYear()));

                                try {
                                     
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

                                    LocalDate currentDate = LocalDate.now();

                                    String query = "SELECT event_id, event_name, start_date, start_time, end_date, end_time, location " +
                                                  "FROM new_calendar_events " +
                                                  "WHERE company_id = ? AND start_date >= ? AND YEAR(start_date) = ? " +
                                                  "ORDER BY start_date, start_time";
                                    pstmt = con.prepareStatement(query);
                                    pstmt.setInt(1, companyId);
                                    pstmt.setDate(2, java.sql.Date.valueOf(currentDate));
                                    pstmt.setInt(3, selectedYearMeetings);
                                    rs = pstmt.executeQuery();

                                    while (rs.next()) {
                                        Map<String, String> meeting = new HashMap<>();
                                        meeting.put("event_id", rs.getString("event_id"));
                                        meeting.put("event_name", rs.getString("event_name") != null ? rs.getString("event_name") : "Untitled");
                                        meeting.put("start_date", rs.getString("start_date"));
                                        meeting.put("start_time", rs.getString("start_time"));
                                        meeting.put("end_date", rs.getString("end_date"));
                                        meeting.put("end_time", rs.getString("end_time"));
                                        meeting.put("location", rs.getString("location") != null ? rs.getString("location") : "Not specified");
                                        meetings.add(meeting);
                                    }

                                    out.println("<!-- Debug: Meetings Count: " + meetings.size() + " -->");
                            %>
                            <% 
                                for (Map<String, String> meeting : meetings) { 
                            %>
                            <tr>
                                <td class="clickable" onclick="openEditModal(<%= meeting.get("event_id") %>, '<%= meeting.get("event_name") %>', '<%= meeting.get("start_date") %>', '<%= meeting.get("start_time") %>', '<%= meeting.get("end_date") %>', '<%= meeting.get("end_time") %>', '<%= meeting.get("location") %>')"><%= meeting.get("event_name") %></td>
                                <td><%= meeting.get("start_date") != null ? meeting.get("start_date") : "N/A" %></td>
                                <td><%= meeting.get("start_time") != null ? meeting.get("start_time") : "N/A" %></td>
                                <td><%= meeting.get("end_date") != null ? meeting.get("end_date") : "N/A" %></td>
                                <td><%= meeting.get("end_time") != null ? meeting.get("end_time") : "N/A" %></td>
                                <td><%= meeting.get("location") %></td>
                            </tr>
                            <% 
                                } 
                                if (meetings.isEmpty()) { 
                            %>
                            <tr>
                                <td colspan="6" style="text-align: center;">No upcoming meetings found.</td>
                            </tr>
                            <% 
                                }
                            %>
                            <%
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='6' class='error'>Error loading meetings data: " + e.getMessage() + "</td></tr>");
                                    out.println("<!-- Debug: Error in meetings section: " + e.getMessage() + " -->");
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing ResultSet: " + e.getMessage() + " -->"); }
                                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing PreparedStatement: " + e.getMessage() + " -->"); }
                                    if (con != null) try { con.close(); } catch (SQLException e) { out.println("<!-- Debug: Error closing Connection: " + e.getMessage() + " -->"); }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div id="editMeetingModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Edit Meeting</h3>
                <button class="modal-close btn btn-outline" onclick="closeEditModal()">×</button>
            </div>
            <div class="modal-body">
                <form id="editMeetingForm" action="update_meeting.jsp" method="post">
                    <input type="hidden" id="editEventId" name="event_id">
                    <table>
                        <tr>
                            <th>Event Name</th>
                            <td><input type="text" id="editEventName" name="event_name" required></td>
                        </tr>
                        <tr>
                            <th>Start Date</th>
                            <td><input type="date" id="editStartDate" name="start_date" required></td>
                        </tr>
                        <tr>
                            <th>Start Time</th>
                            <td><input type="time" id="editStartTime" name="start_time" required></td>
                        </tr>
                        <tr>
                            <th>End Date</th>
                            <td><input type="date" id="editEndDate" name="end_date" required></td>
                        </tr>
                        <tr>
                            <th>End Time</th>
                            <td><input type="time" id="editEndTime" name="end_time" required></td>
                        </tr>
                        <tr>
                            <th>Location</th>
                            <td><input type="text" id="editLocation" name="location" required></td>
                        </tr>
                    </table>
                </form>
            </div>
            <div class="modal-footer">
                <button type="submit" form="editMeetingForm" class="btn btn-primary">Save Changes</button>
                <button class="btn btn-outline" onclick="closeEditModal()">Cancel</button>
            </div>
        </div>
    </div>

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

        function openEditModal(eventId, eventName, startDate, startTime, endDate, endTime, location) {
            document.getElementById('editEventId').value = eventId;
            document.getElementById('editEventName').value = eventName;
            document.getElementById('editStartDate').value = startDate;
            document.getElementById('editStartTime').value = startTime;
            document.getElementById('editEndDate').value = endDate;
            document.getElementById('editEndTime').value = endTime;
            document.getElementById('editLocation').value = location;
            document.getElementById('editMeetingModal').classList.add('active');
            console.log('Edit meeting modal opened for event ID:', eventId);
        }

        function closeEditModal() {
            document.getElementById('editMeetingModal').classList.remove('active');
            console.log('Edit meeting modal closed');
        }

        function filterByYear(year) {
            console.log('Filtering by year:', year);
            window.location.href = 'Dashboard.jsp?year=' + year;
        }
    </script>
</body>
</html>