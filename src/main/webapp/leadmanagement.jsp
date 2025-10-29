<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Lead Management</title>
            <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet"
                href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
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
                    box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);
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

                .sidebar .active a,
                .sidebar .active i {
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
                    margin-left: 240px;
                    padding: 20px;
                    transition: margin-left 0.3s ease;
                }

                /* Navbar */
                .navbar {
                    display: none;
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
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                }

                .btn i {
                    margin-right: 8px;
                }

                /* Tasks Container */
                .tasks-container {
                    display: flex;
                    gap: 20px;
                    margin-top: 20px;
                    flex-wrap: wrap;
                }

                /* Task Column */
                .task-column {
                    background: var(--card-bg);
                    border-radius: var(--border-radius);
                    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
                    padding: 25px;
                    transition: all 0.3s ease;
                    position: relative;
                    overflow: hidden;
                    flex: 1;
                    min-width: 300px;
                    margin-bottom: 20px;
                }

                .task-column:hover {
                    transform: translateY(-5px);
                    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
                }

                .task-column h3 {
                    margin: 0 0 15px 0;
                    padding-bottom: 10px;
                    border-bottom: 1px solid #eee;
                    color: var(--text-color);
                    font-weight: 500;
                }

                .scroll-container {
                    max-height: 500px;
                    overflow-y: auto;
                    padding-right: 10px;
                }

                /* Task Item */
                .task {
                    background: #f9f9f9;
                    margin: 15px 0;
                    padding: 15px;
                    border-radius: 10px;
                    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
                    transition: all 0.3s ease;
                }

                .task:hover {
                    transform: translateY(-3px);
                    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
                }

                .task p {
                    margin: 5px 0;
                    color: var(--dark);
                }

                .task .task-date {
                    color: var(--danger);
                    font-weight: 500;
                    margin-top: 10px;
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
                    margin: 5px 0;
                    white-space: nowrap;
                }

                .action-btn i {
                    margin-right: 5px;
                }

                .action-btn:hover {
                    transform: scale(1.05);
                    opacity: 0.9;
                }

                .action-btn.delete {
                    background: var(--danger);
                    color: white;
                }

                /* Form Styles */
                form {
                    margin: 10px 0;
                }

                form button[type="submit"] {
                    background: #1DA1F2;
                    color: white;
                    width: 50%;
                    margin: 10px 0;
                }

                /* Modal Styles */
                .modal {
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.5);
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
                    max-width: 935px;
                    max-height: 90vh;
                    overflow-y: auto;
                    box-shadow: 0 5px 30px rgba(0, 0, 0, 0.2);
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

                /* Read-only input */
                input[readonly] {
                    background-color: #f0f0f0;
                    cursor: not-allowed;
                    color: #666;
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
                    }

                    .menu-toggle {
                        display: block;
                    }

                    .sidebar-close {
                        display: block;
                    }
                }

                @media (max-width: 768px) {
                    .task {
                        padding: 10px;
                    }

                    .action-btn {
                        width: 100%;
                        justify-content: center;
                        margin: 5px 0;
                    }

                    form button[type="submit"] {
                        width: 100%;
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
                    from {
                        opacity: 0;
                    }

                    to {
                        opacity: 1;
                    }
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

                /* Description Table Styles from Quotes */
                .description-table {
                    width: 100%;
                    margin-bottom: 15px;
                    border-collapse: collapse;
                }

                .description-table th,
                .description-table td {
                    padding: 8px;
                    border: 1px solid #ddd;
                    text-align: left;
                }

                .description-table th {
                    background-color: #f3f4f6;
                    font-weight: 600;
                }

                .description-table input {
                    width: 100%;
                    padding: 5px;
                    border: 1px solid #ddd;
                    border-radius: 4px;
                }

                .description-table .action-cell {
                    text-align: center;
                }

                .description-table .description-input {
                    height: 100px;
                    resize: none;
                    width: 100%;
                    overflow-y: auto;
                }

                .total-amount {
                    font-weight: 600;
                    margin-top: 10px;
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
            </style>
        </head>

        <body>
            <div class="container">
                <!-- Sidebar -->
                <div class="sidebar">
                    <button class="sidebar-close" id="sidebarClose">×</button>
                    <img src="${pageContext.request.contextPath}/images/TARS.jpg?t=${System.currentTimeMillis()}"
                        alt="TARS CRM Logo" class="logo">
                    <div class="sidebar-menu">
                        <ul>
                            <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                            <li><a href="leads.jsp"><i class="fas fa-users"></i> Leads</a></li>
                            <li class="active"><a href="#"><i class="fas fa-tasks"></i> Lead Management</a></li>
                            <li><a href="projects.jsp"><i class="fas fa-project-diagram"></i> Projects</a></li>
                            <li><a href="quotes.jsp"><i class="fas fa-file-invoice-dollar"></i> Quotes</a></li>
                            <li><a href="financemanagement.jsp"><i class="fas fa-money-bill-wave"></i> Finance
                                    Management</a></li>
                            <li><a href="contacts.jsp"><i class="fas fa-address-book"></i> Contacts</a></li>
                            <li><a href="tasks.jsp"><i class="fas fa-check-circle"></i> Tasks</a></li>
                            <li><a href="emp.jsp"><i class="fas fa-user-tie"></i> Employees</a></li>
                            <li><a href="email.jsp"><i class="fas fa-envelope "></i> Email</a></li>
                            <li><a href="Organizations.jsp"><i class="fas fa-building"></i> Organizations</a></li>
                            <li><a href="integration.jsp"><i class="fas fa-plug"></i> Integration</a></li>
                            <li><a href="delivered.jsp"><i class="fas fa-truck"></i> Delivered</a></li>
                            <li><a href="fetch_meetings_all.jsp"><i class="fas fa-calendar-alt"></i> Calendar</a></li>
                            <li><a href="profile1.jsp"><i class="fas fa-user"></i> Profile</a></li>
                        </ul>
                    </div>
                    <div class="profile" onclick="window.location.href='profile1.jsp'">
                        <% Connection con=null; PreparedStatement pstmt=null; ResultSet rs=null; String fullName="User"
                            ; String imgPath="https://via.placeholder.com/40" ; try {
                            Class.forName("com.mysql.cj.jdbc.Driver"); String host=System.getenv("DB_HOST"); String
                            port=System.getenv("DB_PORT"); String dbName=System.getenv("DB_NAME"); String
                            user=System.getenv("DB_USER"); String pass=System.getenv("DB_PASS"); String
                            url="jdbc:mysql://" + host + ":" + port + "/" + dbName; conn=DriverManager.getConnection(url,
                            user, pass); String companyIdStrNav=(String) session.getAttribute("company_id"); Integer
                            companyIdNav=null; if (companyIdStrNav==null || companyIdStrNav.trim().isEmpty()) {
                            response.sendRedirect("login1.jsp"); return; } try {
                            companyIdNav=Integer.parseInt(companyIdStrNav); } catch (NumberFormatException e) {
                            response.sendRedirect("login1.jsp"); return; } String
                            query="SELECT full_name, img FROM company_registration1 WHERE company_id = ?" ;
                            pstmt=con.prepareStatement(query); pstmt.setInt(1, companyIdNav); rs=pstmt.executeQuery();
                            if (rs.next()) { fullName=rs.getString("full_name"); imgPath=rs.getString("img"); if
                            (imgPath==null || imgPath.isEmpty()) { imgPath="images/default-profile.jpg" ; } } } catch
                            (Exception e) { e.printStackTrace(); } finally { if (rs !=null) try { rs.close(); } catch
                            (SQLException e) {} if (pstmt !=null) try { pstmt.close(); } catch (SQLException e) {} if
                            (con !=null) try { con.close(); } catch (SQLException e) {} } %>
                            <img src="<%= imgPath %>" alt="User Profile">
                            <span>
                                <%= fullName %>
                            </span>
                    </div>
                </div>

                <!-- Main Content -->
                <div class="content">
                    <!-- Navbar -->
                    <div class="navbar slide-up">
                        <button class="menu-toggle" id="menuToggle">
                            <i class="fas fa-bars"></i>
                        </button>
                        <h1>Leads Management</h1>
                        <div class="user-profile" onclick="window.location.href='profile1.jsp'">
                            <img src="<%= imgPath %>" alt="User Profile">
                            <span>
                                <%= fullName %>
                            </span>
                        </div>
                    </div>

                    <div class="tasks-container slide-up">
                        <!-- Connected Column -->
                        <div class="task-column" id="connected">
                            <div class="scroll-container">
                                <h3>Connected</h3>
                                <!-- Hidden form for direct move to Proposal -->
                                <form id="moveToProposalForm" action="ProposalsentServlet" method="post">
                                    <input type="hidden" name="action" value="moveWithoutQuote">
                                    <input type="hidden" name="leadid" id="moveLeadId">
                                </form>
                                <% Connection conn=null; PreparedStatement stmt=null; ResultSet rs2=null; // Get
                                    logged-in company's ID from session HttpSession sessionVar=request.getSession();
                                    String companyIdStr=(String) sessionVar.getAttribute("company_id"); Integer
                                    companyId=null; if (companyIdStr !=null && !companyIdStr.trim().isEmpty()) { try {
                                    companyId=Integer.parseInt(companyIdStr); } catch (NumberFormatException e) {
                                    e.printStackTrace(); } } if (companyId==null) { response.sendRedirect("login1.jsp");
                                    // Redirect if not logged in return; } try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                     String host=System.getenv("DB_HOST"); String
                            port=System.getenv("DB_PORT"); String dbName=System.getenv("DB_NAME"); String
                            user=System.getenv("DB_USER"); String pass=System.getenv("DB_PASS"); String
                            url="jdbc:mysql://" + host + ":" + port + "/" + dbName; conn=DriverManager.getConnection(url,
                            user, pass); // Check if lead_id exists, fallback to a default
                                    identifier if not DatabaseMetaData metaData=conn.getMetaData(); ResultSet
                                    columns=metaData.getColumns(null, null, "leads" , "lead_id" ); boolean
                                    hasLeadId=columns.next(); String idColumn=hasLeadId ? "lead_id" : "id" ; // Fallback
                                    to 'id' if lead_id doesn't exist String sql="SELECT " + idColumn
                                    + ", project_name, customer_name "
                                    + "FROM leads WHERE company_id = ? AND status = 'Connected' " + "AND " + idColumn
                                    + " NOT IN (SELECT lead_id FROM proposalsent UNION SELECT lead_id FROM qualified) "
                                    + "AND delete_qualified = FALSE " + "ORDER BY " + idColumn + " ASC" ;
                                    stmt=conn.prepareStatement(sql); stmt.setInt(1, companyId); // Bind the company_id
                                    rs2=stmt.executeQuery(); while (rs2.next()) { int leadId=rs2.getInt(idColumn);
                                    String projectName=rs2.getString("project_name"); String
                                    customerName=rs2.getString("customer_name"); %>
                                    <div class="task">
                                        <button class="btn btn-primary" style="width: 100%;"
                                            onclick="openQuoteModal('<%= leadId %>')">
                                            <i class="fas fa-arrow-right"></i> Move to Proposal
                                        </button>
                                        <p>Lead ID: <%= leadId %>
                                        </p>
                                        <p>Project Name: <%= projectName %>
                                        </p>
                                        <p>Customer Name: <%= customerName %>
                                        </p>

                                        <div class="task-date">
                                            <!-- Add meeting date/time if needed -->
                                        </div>
                                    </div>
                                    <% } } catch (Exception e) { e.printStackTrace(); out.println("<p>Error fetching
                                        connected leads: " + e.getMessage() + "</p>");
                                        } finally {
                                        if (rs2 != null) try { rs2.close(); } catch (SQLException e) {
                                        e.printStackTrace(); }
                                        if (stmt != null) try { stmt.close(); } catch (SQLException e) {
                                        e.printStackTrace(); }
                                        if (conn != null) try { conn.close(); } catch (SQLException e) {
                                        e.printStackTrace(); }
                                        }
                                        %>
                            </div>
                        </div>

                        <!-- Proposal Column -->
                        <div class="task-column" id="in-progress">
                            <div class="scroll-container">
                                <h3>Proposal</h3>
                                <% conn=null; stmt=null; rs2=null; try { // Load the MySQL driver
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    conn=DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva"
                                    , "AVNS_SFoivcl39tz_B7wqssI" ); // Check if lead_id exists DatabaseMetaData
                                    metaData=conn.getMetaData(); ResultSet columns=metaData.getColumns(null,
                                    null, "leads" , "lead_id" ); boolean hasLeadId=columns.next(); String
                                    idColumn=hasLeadId ? "leads.lead_id" : "leads.id" ; // SQL query to fetch only leads
                                    belonging to the logged-in company, sorted by lead_id String sql="SELECT " +
                                    idColumn
                                    + ", leads.project_name, leads.customer_name, quotation.amount, proposalsent.meeting_date, proposalsent.meeting_time "
                                    + "FROM leads " + "JOIN quotation ON leads.lead_id = quotation.lead_id "
                                    + "JOIN proposalsent ON leads.lead_id = proposalsent.lead_id "
                                    + "WHERE leads.company_id = ? " + "AND leads.delete_qualified = FALSE "
                                    + "ORDER BY " + idColumn + " ASC" ; stmt=conn.prepareStatement(sql); stmt.setInt(1,
                                    companyId); // Bind the company_id rs2=stmt.executeQuery(); while (rs2.next()) { int
                                    taskId=rs2.getInt(idColumn); String projectTitle=rs2.getString("project_name");
                                    String customername=rs2.getString("customer_name"); String
                                    amt=rs2.getString("amount"); String date=rs2.getString("meeting_date"); String
                                    time=rs2.getString("meeting_time"); // Format amount with commas String
                                    formattedAmt=amt.replaceAll("\\B(?=(\\d{3})+(?!\\d))", "," ); %>
                                    <div class="task">
                                        <form action="qualifiedsent" method="post">
                                            <input type="hidden" name="leadId" value="<%= taskId %>" />
                                            <button type="submit" class="btn btn-primary" style="width: 100%;">
                                                <i class="fas fa-arrow-right"></i> Move to Qualified
                                            </button>
                                        </form>
                                        <p><strong>Lead ID:</strong>
                                            <%= taskId %>
                                        </p>
                                        <p><strong>Project Name:</strong>
                                            <%= projectTitle %>
                                        </p>
                                        <p><strong>Client Name:</strong>
                                            <%= customername %>
                                        </p>

                                        <p><strong>Amount:</strong>
                                            <%= formattedAmt %>
                                        </p>

                                    </div>
                                    <% } } catch (Exception e) { e.printStackTrace(); out.println("<p>Error fetching
                                        proposal leads: " + e.getMessage() + "</p>");
                                        } finally {
                                        try {
                                        if (rs2 != null) rs2.close();
                                        if (stmt != null) stmt.close();
                                        if (conn != null) conn.close();
                                        } catch (Exception ex) {
                                        ex.printStackTrace();
                                        }
                                        }
                                        %>
                            </div>
                        </div>

                        <!-- Qualified Column -->
                        <div class="task-column" id="to-do">
                            <div class="scroll-container">
                                <h3>Qualified</h3>
                                <% conn=null; stmt=null; rs2=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
                                     String host=System.getenv("DB_HOST"); String
                            port=System.getenv("DB_PORT"); String dbName=System.getenv("DB_NAME"); String
                            user=System.getenv("DB_USER"); String pass=System.getenv("DB_PASS"); String
                            url="jdbc:mysql://" + host + ":" + port + "/" + dbName; conn=DriverManager.getConnection(url,
                            user, pass);// Check if lead_id exists DatabaseMetaData
                                    metaData=conn.getMetaData(); ResultSet columns=metaData.getColumns(null,
                                    null, "leads" , "lead_id" ); boolean hasLeadId=columns.next(); String
                                    idColumn=hasLeadId ? "leads.lead_id" : "leads.id" ; // Fetch leads from
                                    the 'qualified' table, sorted by lead_id String sql="SELECT " + idColumn
                                    + ", leads.project_name, leads.customer_name " + "FROM leads "
                                    + "JOIN qualified ON leads.lead_id = qualified.lead_id "
                                    + "WHERE leads.company_id = ? " + "AND leads.delete_qualified = FALSE "
                                    + "ORDER BY " + idColumn + " ASC" ; stmt=conn.prepareStatement(sql); stmt.setInt(1,
                                    companyId); // Bind companyId safely rs2=stmt.executeQuery(); int rowCount=0; //
                                    Count fetched rows while (rs2.next()) { rowCount++; int leadId=rs2.getInt(idColumn);
                                    String projectName=rs2.getString("project_name"); String
                                    customerName=rs2.getString("customer_name"); %>
                                    <div class="task" id="lead-<%= leadId %>">
                                        <p><strong>Lead ID:</strong>
                                            <%= leadId %>
                                        </p>
                                        <p><strong>Project Name:</strong>
                                            <%= projectName %>
                                        </p>
                                        <p><strong>Customer Name:</strong>
                                            <%= customerName %>
                                        </p>
                                        <button class="action-btn delete" onclick="deleteLead(<%= leadId %>)">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                    </div>
                                    <% } if (rowCount==0) { out.println("<p>No qualified leads found</p>");
                                        }
                                        } catch (Exception e) {
                                        e.printStackTrace();
                                        out.println("<p>Error fetching qualified leads: " + e.getMessage() + "</p>");
                                        } finally {
                                        if (rs2 != null) rs2.close();
                                        if (stmt != null) stmt.close();
                                        if (conn != null) conn.close();
                                        }
                                        %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Add Quote Modal -->
            <div class="modal" id="addContactModal">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2>Add Quote</h2>
                        <button class="close-btn" onclick="closeQuoteModal()">×</button>
                    </div>
                    <form action="ProposalsentServlet" method="post" onsubmit="return validateSrNoSequence(event)">
                        <input type="hidden" name="action" value="addQuoteAndMove">
                        <div class="form-row">
                            <div class="form-group">
                                <label for="leadid">Lead ID</label>
                                <input type="text" class="form-control" name="leadid" id="leadid" readonly required>
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
                                        <td><input type="number" name="srNo[]" value="1" min="1" class="sr-no-input"
                                                required></td>
                                        <td><textarea name="description[]" placeholder="Enter description"
                                                class="description-input" required></textarea></td>
                                        <td><input type="number" name="price[]" placeholder="Enter price" step="0.01"
                                                min="0" required oninput="calculateTotal()"></td>
                                        <td class="action-cell">
                                            <button type="button" class="action-btn delete" onclick="removeRow(this)">
                                                <i class="fas fa-minus"></i>
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
                            <label>Total Amount:</label>
                            <span class="total-amount" id="totalAmount">0.00</span>
                            <input type="hidden" name="amount" id="amountInput">
                        </div>
                        <button type="submit" class="btn btn-primary" style="width: 100%;">
                            <i class="fas fa-save"></i> Save Quote & Move to Proposal
                        </button>
                    </form>
                </div>
            </div>

            <!-- Delete Modal -->
            <div class="modal" id="deletedata">
                <div class="modal-content">
                    <button class="close-btn" onclick="closedelete()">×</button>
                    <h2>Delete Qualified</h2>
                    <form action="deletequalified" method="post">
                        <div class="form-group">
                            <label for="quoteid">Enter Lead ID:</label>
                            <input type="text" class="form-control" name="quoteid" id="quoteid" required>
                        </div>
                        <button type="submit" class="btn btn-primary" style="background-color: var(--danger);">
                            <i class="fas fa-trash"></i> Delete Qualified
                        </button>
                    </form>
                </div>
            </div>

            <!-- Include jQuery for AJAX -->
            <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
            <script>
                // Mobile menu toggle functionality
                const menuToggle = document.getElementById('menuToggle');
                const sidebar = document.querySelector('.sidebar');
                const sidebarClose = document.getElementById('sidebarClose');

                menuToggle.addEventListener('click', () => {
                    sidebar.classList.toggle('active');
                });

                sidebarClose.addEventListener('click', () => {
                    sidebar.classList.remove('active');
                });

                // Function to format number with commas
                function formatNumber(input) {
                    let value = input.value.replace(/[^0-9]/g, '');
                    value = value.replace(/\B(?=(\d{3})+(?!\\d))/g, ',');
                    input.value = value;
                }

                // Quote modal functions
                function openQuoteModal(leadId) {
                    $.ajax({
                        url: 'CheckQuoteServlet',
                        type: 'POST',
                        data: { leadId: leadId },
                        dataType: 'json',
                        success: function (response) {
                            if (response.hasQuote) {
                                document.getElementById('moveLeadId').value = leadId;
                                document.getElementById('moveToProposalForm').submit();
                            } else {
                                document.getElementById('leadid').value = leadId;
                                const tbody = document.getElementById('descriptionRows');
                                tbody.innerHTML = `
                            <tr>
                                <td><input type="number" name="srNo[]" value="1" min="1" class="sr-no-input" required></td>
                                <td><textarea name="description[]" placeholder="Enter description" class="description-input" required></textarea></td>
                                <td><input type="number" name="price[]" placeholder="Enter price" step="0.01" min="0" required oninput="calculateTotal()"></td>
                                <td class="action-cell">
                                    <button type="button" class="action-btn delete" onclick="removeRow(this)">
                                        <i class="fas fa-minus"></i>
                                    </button>
                                </td>
                            </tr>
                        `;
                                calculateTotal();
                                document.getElementById('addContactModal').classList.add('active');
                                updateRowNumbers(); // Update row numbers when modal opens
                            }
                        },
                        error: function (xhr, status, error) {
                            alert('Error checking quote status: ' + error);
                        }
                    });
                }

                function closeQuoteModal() {
                    document.getElementById('addContactModal').classList.remove('active');
                }

                const omeet = document.getElementById('meeting');
                const omeets = document.getElementById('meetings');

                function meetings(taskId) {
                    document.getElementById('popup-lead-id').value = taskId;
                    omeet.classList.add('active');
                }

                function closemeetings() {
                    omeets.classList.remove('active');
                }

                function meetingss(leadId) {
                    document.getElementById('popup-leads-id').value = leadId;
                    omeets.classList.add('active');
                }

                function closemeeting() {
                    omeet.classList.remove('active');
                }

                function closedelete() {
                    document.getElementById('deletedata').classList.remove('active');
                }

                function opendelete() {
                    document.getElementById('deletedata').classList.add('active');
                }

                function deleteLead(leadId) {
                    if (confirm('Are you sure you want to delete this lead?')) {
                        window.location.href = "deletequalified?quoteid=" + leadId;
                    }
                }

                window.onload = function () {
                    var today = new Date();
                    var day = ("0" + today.getDate()).slice(-2);
                    var month = ("0" + (today.getMonth() + 1)).slice(-2);
                    var year = today.getFullYear();
                    var dateString = year + "-" + month + "-" + day;

                    var dateInputs = document.querySelectorAll("input[type='date']");
                    dateInputs.forEach(function (input) {
                        input.value = dateString;
                    });
                };

                function updateRowNumbers() {
                    const tbody = document.getElementById('descriptionRows');
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
                        <i class="fas fa-minus"></i>
                    </button>
                </td>
            `;
                    tbody.appendChild(newRow);
                    updateRowNumbers(); // Update all row numbers after adding
                    calculateTotal();
                }

                function removeRow(button) {
                    const tbody = document.getElementById('descriptionRows');
                    const rows = tbody.querySelectorAll('tr');

                    if (rows.length > 1) {
                        const rowToRemove = button.closest('tr');
                        rowToRemove.remove();
                        updateRowNumbers(); // Update all row numbers after removing
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

                const quoteModal = document.getElementById('addContactModal');
                quoteModal.addEventListener('click', function (event) {
                    if (event.target === quoteModal) {
                        closeQuoteModal();
                    }
                });

                document.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape' && quoteModal.classList.contains('active')) {
                        closeQuoteModal();
                    }
                });
            </script>
        </body>

        </html>