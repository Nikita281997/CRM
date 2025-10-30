<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leads | CRMSPOT</title>
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

        /* Navbar */
        .navbar {
            background: var(--card-bg);
            padding: 15px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .navbar-brand img {
            height: 40px;
        }

        .navbar-nav {
            display: flex;
            gap: 15px;
        }

        .navbar-nav a {
            color: var(--text-color);
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            padding: 8px 15px;
            border-radius: 5px;
            transition: all 0.3s ease;
        }

        .navbar-nav a:hover {
            background: var(--secondary);
            color: var(--accent);
        }

        .navbar-nav a.active {
            background: var(--accent);
            color: white;
        }

        /* Page Header */
        .page-header {
            margin-top: 3%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            gap: 10px;
            padding: 0 20px;
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

        .btn-danger {
            background: var(--danger);
            color: white;
        }

        .btn-danger:hover {
            background: #e55a74;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
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

        .action-btn.edit {
            background: #ffcd56;
            color: white;
        }

        .action-btn.delete {
            background: #ff6384;
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
            background: #f5f5f5;
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
        }

        .confirmation-modal-content {
            background: #f5f5f5;
            width: 397px;
            display: flex;
            flex-direction: column;
            min-height: 200px;
            padding: 20px;
            animation: fadeInScale 0.3s ease-out;
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
            background: linear-gradient(135deg, var(--table-header-bg) 0%, #e0e7ff 100%);
            border-radius: 10px 10px 0 0;
            padding: 15px;
        }

        .modal-header h2 {
            font-size: 1.8rem;
            color: var(--dark);
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

        /* Confirmation Modal Button */
        .confirmation-buttons {
            margin-top: auto;
            display: flex;
            justify-content: flex-end;
            padding-top: 20px;
            gap: 10px;
        }

        .confirmation-message {
            font-size: 1.2rem;
            font-weight: 500;
            color: var(--dark);
            text-align: center;
            margin: 20px 0;
        }

        /* Error Messages */
        .error-message {
            color: var(--danger);
            font-size: 12px;
            margin-top: 5px;
            display: none;
        }

        .invalid-input {
            border: 2px solid var(--danger);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .employee-details {
                flex-direction: column;
                gap: 10px;
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
                padding: 0 10px;
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

            .navbar-nav {
                flex-direction: column;
                width: 100%;
                align-items: stretch;
            }

            .navbar-nav a {
                width: 100%;
                text-align: center;
            }

            .confirmation-modal-content {
                width: 90%;
                min-height: 150px;
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

        @keyframes fadeInScale {
            from {
                opacity: 0;
                transform: scale(0.95);
            }
            to {
                opacity: 1;
                transform: scale(1);
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
        String empIdStr = (String) sessionVar.getAttribute("unique_id");
        
        if (companyIdStr == null || empIdStr == null) {
            response.sendRedirect("login1.jsp");
            return;
        }
        
        Integer companyId = null;
        Integer empId = null;
        try {
            companyId = Integer.parseInt(companyIdStr);
            empId = Integer.parseInt(empIdStr);
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("login1.jsp");
            return;
        }
    %>
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">Leads Management</h1>
            <div class="button-group" style="display: flex; gap: 10px;">
                <button class="btn btn-primary" onclick="openModal('addContactModal')">
                    <i class="fas fa-plus"></i> Add Lead
                </button>
                <a href="leademptask.jsp" class="btn btn-primary"><i class="fas fa-tasks"></i> Tasks</a>
                <button class="btn btn-danger" onclick="openLogoutConfirmModal()">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </div>
        </div>
        
        <!-- Employee Details -->
        <div class="employee-details">
            <%
                Connection conProfile = null;
                PreparedStatement pstmtProfile = null;
                ResultSet rsProfile = null;
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
                    conProfile = DriverManager.getConnection(url, user, pass);
                    String query = "SELECT emp_name FROM emp WHERE unique_id = ?";
                    pstmtProfile = conProfile.prepareStatement(query);
                    pstmtProfile.setInt(1, empId);
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
            <span><i class="fas fa-id-card"></i> Emp ID: <%= empId %></span>
            <span><i class="fas fa-user"></i> Emp Name: <%= fullName %></span>
        </div>

        <!-- Leads Table -->
        <div class="table-container slide-up">
            <%
                Connection con = null;
                PreparedStatement ps = null;
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
                    ps = con.prepareStatement("SELECT * FROM leads WHERE company_id=? and unique_id=? ");
                    ps.setInt(1, companyId);
                    ps.setInt(2, empId);
                    rs = ps.executeQuery();
            %>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Lead ID</th>
                            <th>Project Name</th>
                            <th>Firm</th>
                            <th>In Date</th>
                            <th>Customer Name</th>
                            <th>Email</th>
                            <th>Contact</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                        while (rs.next()) {
                            int leadId = rs.getInt("lead_id");
                            String projectName = rs.getString("project_name");
                            String firm = rs.getString("firm");
                            java.sql.Date inDate = rs.getDate("in_date");
                            String inDateStr = (inDate != null) ? dateFormat.format(inDate) : "---";
                            String customerName = rs.getString("customer_name");
                            String email = rs.getString("email");
                            String contact = rs.getString("contact");
                            String address = rs.getString("address");
                            String org = rs.getString("org") != null ? rs.getString("org") : "---";
                        %>
                        <tr>
                            <td data-title="Lead ID"><%= leadId %></td>
                            <td data-title="Project Name"><%= StringEscapeUtils.escapeXml10(projectName) %></td>
                            <td data-title="Firm"><%= StringEscapeUtils.escapeXml10(firm) %></td>
                            <td data-title="In Date"><%= inDateStr %></td>
                            <td data-title="Customer Name"><%= StringEscapeUtils.escapeXml10(customerName) %></td>
                            <td data-title="Email"><%= StringEscapeUtils.escapeXml10(email) %></td>
                            <td data-title="Contact"><%= StringEscapeUtils.escapeXml10(contact) %></td>
                            <td data-title="Actions">
                                <button class="action-btn edit"
                                    onclick="openEditPopup(<%= leadId %>, 
                                               '<%= StringEscapeUtils.escapeXml10(projectName) %>', 
                                               '<%= StringEscapeUtils.escapeXml10(firm) %>', 
                                               '<%= inDateStr %>', 
                                               '<%= StringEscapeUtils.escapeXml10(customerName) %>', 
                                               '<%= StringEscapeUtils.escapeXml10(email) %>', 
                                               '<%= StringEscapeUtils.escapeXml10(contact) %>', 
                                               '<%= StringEscapeUtils.escapeXml10(address) %>', 
                                               '<%= StringEscapeUtils.escapeXml10(org) %>')">
                                    <i class="fas fa-edit"></i> Edit
                                </button>
                               <!--  <button class="action-btn delete" onclick="openDeleteConfirmModal(<%= leadId %>)">
                                    <i class="fas fa-trash-alt"></i> Delete
                                </button>
                             --></td>
                        </tr>
                        <%
                        }
                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.print("<tr><td colspan='8' style='text-align:center;'>Error fetching data!</td></tr>");
                    }
                %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Add Lead Modal -->
        <div class="modal" id="addContactModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>Add New Lead</h2>
                    <button class="close-btn" onclick="closeModal('addContactModal')">×</button>
                </div>
                <form id="addLeadForm" action="empLeadServlet" method="post" onsubmit="return validateAddForm()">
                    <input type="hidden" name="emp_id" value="<%= empId %>">
                    <input type="hidden" name="company_id" value="<%= companyId %>">
                    
                    <div class="form-group">
                        <label>Project Name:</label>
                        <input type="text" class="form-control" name="project_name" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Firm:</label>
                        <input type="text" class="form-control" name="firm" required>
                    </div>
                    
                    <div class="form-group">
                        <label>In Date:</label>
                        <input type="date" class="form-control" name="in_date" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Customer Name:</label>
                        <input type="text" class="form-control" name="customer_name" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Email:</label>
                        <input type="email" class="form-control" name="email" id="addEmail" required>
                        <div id="addEmailError" class="error-message">Please enter a valid Gmail address (e.g., user@gmail.com)</div>
                    </div>
                    
                    <div class="form-group">
                        <label>Contact:</label>
                        <input type="text" class="form-control" name="contact" id="addContact" required>
                        <div id="addContactError" class="error-message">Please enter a valid 10-digit phone number</div>
                    </div>
                    
                    <div class="form-group">
                        <label>Address:</label>
                        <input type="text" class="form-control" name="address" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Organization:</label>
                        <input type="text" class="form-control" name="org">
                    </div>
                    
                    <button type="submit" class="btn btn-primary" style="width: 100%;">
                        <i class="fas fa-save"></i> Add Lead
                    </button>
                </form>
            </div>
        </div>

        <!-- Edit Lead Modal -->
        <div class="modal" id="editdata">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>Edit Lead</h2>
                    <button class="close-btn" onclick="closeModal('editdata')">×</button>
                </div>
                <form id="editLeadForm" action="Editleadservlet" method="post" onsubmit="return validateEditForm()">
                    <input type="hidden" name="sourcePage" value="empdashboared.jsp">
                    <input type="hidden" name="leadid" id="popup-lead-id">
                    
                    <div class="form-group">
                        <label>Project Name:</label>
                        <input type="text" class="form-control" name="proname" id="popup-project-name" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Firm:</label>
                        <input type="text" class="form-control" name="firmname" id="popup-firm-name" required>
                    </div>
                    
                    <div class="form-group">
                        <label>In Date:</label>
                        <input type="date" class="form-control" name="indate" id="popup-in-date" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Customer Name:</label>
                        <input type="text" class="form-control" name="customer" id="popup-customer-name" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Email:</label>
                        <input type="email" class="form-control" name="email" id="popup-email" required>
                        <div id="editEmailError" class="error-message">Please enter a valid Gmail address (e.g., user@gmail.com)</div>
                    </div>
                    
                    <div class="form-group">
                        <label>Phone:</label>
                        <input type="text" class="form-control" name="phone" id="popup-phone" required>
                        <div id="editPhoneError" class="error-message">Please enter a valid 10-digit phone number</div>
                    </div>
                    
                    <div class="form-group">
                        <label>Address:</label>
                        <input type="text" class="form-control" name="address" id="popup-address" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Organization:</label>
                        <input type="text" class="form-control" name="org" id="popup-org">
                    </div>
                    
                    <button type="submit" class="btn btn-primary" style="width: 100%;">
                        <i class="fas fa-save"></i> Update Lead
                    </button>
                </form>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div class="modal" id="deleteConfirmModal">
            <div class="modal-content confirmation-modal-content">
                <div class="modal-header" style="background: linear-gradient(135deg, var(--warning) 0%, #ffeb99 100%);">
                    <h2>Confirm Deletion</h2>
                </div>
                <p class="confirmation-message"><i class="fas fa-exclamation-triangle" style="color: var(--warning); margin-right: 8px;"></i>Are you sure you want to delete this lead?</p>
                <div class="confirmation-buttons">
                    <button class="btn btn-danger" onclick="cancelDelete()"><i class="fas fa-times"></i> Cancel</button>
                    <button class="btn btn-primary" id="confirmDeleteBtn"><i class="fas fa-check"></i> Confirm</button>
                </div>
            </div>
        </div>

        <!-- Logout Confirmation Modal -->
        <div class="modal" id="logoutConfirmModal">
            <div class="modal-content confirmation-modal-content">
                <div class="modal-header" style="background: linear-gradient(135deg, var(--warning) 0%, #ffeb99 100%);">
                    <h2>Confirm Logout</h2>
                </div>
                <p class="confirmation-message"><i class="fas fa-exclamation-triangle" style="color: var(--warning); margin-right: 8px;"></i>Are you sure you want to logout?</p>
                <div class="confirmation-buttons">
                    <button class="btn btn-danger" onclick="cancelLogout()"><i class="fas fa-times"></i> Cancel</button>
                    <button class="btn btn-primary" id="confirmLogoutBtn"><i class="fas fa-sign-out-alt"></i> Confirm</button>
                </div>
            </div>
        </div>

        <!-- Message Modal for Success/Error -->
        <%
            String popupMessage = (String) sessionVar.getAttribute("popupMessage");
            String popupType = (String) sessionVar.getAttribute("popupType");
            if (popupMessage != null) {
        %>
        <div class="modal active" id="messageModal">
            <div class="modal-content confirmation-modal-content">
                <div class="modal-header" style="background: linear-gradient(135deg, <%= "success".equals(popupType) ? "var(--success) 0%, #00e7d0" : "var(--danger) 0%, #ff829b" %> 100%);">
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
        // Validation functions
        function isValidGmailEmail(email) {
            const gmailPattern = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
            return gmailPattern.test(email);
        }

        function isValidPhone(phone) {
            const phonePattern = /^\d{10}$/;
            return phonePattern.test(phone);
        }

        // Real-time validation for Add Lead form
        document.getElementById('addEmail').addEventListener('input', function() {
            const email = this.value.trim();
            const errorElement = document.getElementById('addEmailError');
            if (email === '') {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
                return;
            }
            if (!isValidGmailEmail(email)) {
                this.classList.add('invalid-input');
                errorElement.style.display = 'block';
            } else {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
            }
        });

        document.getElementById('addContact').addEventListener('input', function() {
            const phone = this.value.trim();
            const errorElement = document.getElementById('addContactError');
            if (phone === '') {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
                return;
            }
            if (!isValidPhone(phone)) {
                this.classList.add('invalid-input');
                errorElement.style.display = 'block';
            } else {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
            }
        });

        // Real-time validation for Edit Lead form
        document.getElementById('popup-email').addEventListener('input', function() {
            const email = this.value.trim();
            const errorElement = document.getElementById('editEmailError');
            if (email === '') {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
                return;
            }
            if (!isValidGmailEmail(email)) {
                this.classList.add('invalid-input');
                errorElement.style.display = 'block';
            } else {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
            }
        });

        document.getElementById('popup-phone').addEventListener('input', function() {
            const phone = this.value.trim();
            const errorElement = document.getElementById('editPhoneError');
            if (phone === '') {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
                return;
            }
            if (!isValidPhone(phone)) {
                this.classList.add('invalid-input');
                errorElement.style.display = 'block';
            } else {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
            }
        });

        // Form validation before submission
        function validateAddForm() {
            const email = document.getElementById('addEmail').value.trim();
            const phone = document.getElementById('addContact').value.trim();
            let isValid = true;

            if (!isValidGmailEmail(email)) {
                document.getElementById('addEmailError').style.display = 'block';
                document.getElementById('addEmail').classList.add('invalid-input');
                isValid = false;
            }

            if (!isValidPhone(phone)) {
                document.getElementById('addContactError').style.display = 'block';
                document.getElementById('addContact').classList.add('invalid-input');
                isValid = false;
            }

            if (!isValid) {
                const firstError = document.querySelector('.error-message[style="display: block;"]');
                if (firstError) {
                    firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
                return false;
            }

            return true;
        }

        function validateEditForm() {
            const email = document.getElementById('popup-email').value.trim();
            const phone = document.getElementById('popup-phone').value.trim();
            let isValid = true;

            if (!isValidGmailEmail(email)) {
                document.getElementById('editEmailError').style.display = 'block';
                document.getElementById('popup-email').classList.add('invalid-input');
                isValid = false;
            }

            if (!isValidPhone(phone)) {
                document.getElementById('editPhoneError').style.display = 'block';
                document.getElementById('popup-phone').classList.add('invalid-input');
                isValid = false;
            }

            if (!isValid) {
                const firstError = document.querySelector('.error-message[style="display: block;"]');
                if (firstError) {
                    firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
                return false;
            }

            return true;
        }

        // Set today's date as default for date fields
        window.onload = function() {
            var today = new Date();
            var day = ("0" + today.getDate()).slice(-2);
            var month = ("0" + (today.getMonth() + 1)).slice(-2);
            var year = today.getFullYear();
            var dateString = year + "-" + month + "-" + day;

            document.querySelector("input[name='in_date']").value = dateString;
        };

        // Modal functions
        function openModal(modalId) {
            document.getElementById(modalId).classList.add('active');
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.remove('active');
        }

        function closeMessageModal() {
            const modal = document.getElementById('messageModal');
            if (modal) modal.classList.remove('active');
            window.location.href = 'empdashboared.jsp';
        }

        let deleteLeadId = null;

        function openDeleteConfirmModal(leadId) {
            deleteLeadId = leadId;
            openModal('deleteConfirmModal');
        }

        function cancelDelete() {
            deleteLeadId = null;
            closeModal('deleteConfirmModal');
        }

        function confirmDelete() {
            if (deleteLeadId !== null) {
                window.location.href = 'empLeadServlet?action=delete&lead_id=' + deleteLeadId;
            }
            closeModal('deleteConfirmModal');
            deleteLeadId = null;
        }

        let logoutConfirmed = false;

        function openLogoutConfirmModal() {
            openModal('logoutConfirmModal');
        }

        function cancelLogout() {
            logoutConfirmed = false;
            closeModal('logoutConfirmModal');
        }

        function confirmLogout() {
            logoutConfirmed = true;
            document.querySelector('form[action="LogoutServlet"]').submit();
        }

        function openEditPopup(leadId, projectName, firm, inDate, customerName, email, contact, address, org) {
            document.getElementById("popup-lead-id").value = leadId;
            document.getElementById("popup-project-name").value = projectName;
            document.getElementById("popup-firm-name").value = firm;
            
            if (inDate && inDate !== "---") {
                let formattedDate = new Date(inDate).toISOString().split('T')[0];
                document.getElementById("popup-in-date").value = formattedDate;
            } else {
                document.getElementById("popup-in-date").value = "";
            }

            document.getElementById("popup-customer-name").value = customerName;
            document.getElementById("popup-email").value = email;
            document.getElementById("popup-phone").value = contact;
            document.getElementById("popup-address").value = address;
            document.getElementById("popup-org").value = org;

            document.getElementById('popup-email').dispatchEvent(new Event('input'));
            document.getElementById('popup-phone').dispatchEvent(new Event('input'));

            openModal('editdata');
        }

        // Close modal when clicking outside
        document.addEventListener('click', function(event) {
            const modals = document.querySelectorAll('.modal.active');
            modals.forEach(modal => {
                if (event.target === modal) {
                    modal.classList.remove('active');
                    if (modal.id === 'deleteConfirmModal') {
                        deleteLeadId = null;
                    }
                    if (modal.id === 'logoutConfirmModal') {
                        logoutConfirmed = false;
                    }
                }
            });
        });

        // Close modal on Esc key press
        document.addEventListener('keydown', function(event) {
            const modals = document.querySelectorAll('.modal.active');
            if (event.key === 'Escape' && modals.length > 0) {
                modals.forEach(modal => {
                    modal.classList.remove('active');
                    if (modal.id === 'deleteConfirmModal') {
                        deleteLeadId = null;
                    }
                    if (modal.id === 'logoutConfirmModal') {
                        logoutConfirmed = false;
                    }
                });
            }
        });

        // Animation on scroll
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

            animatedElements.forEach(element => {	                
                observer.observe(element);
            });

            document.getElementById('addEmail').dispatchEvent(new Event('input'));
            document.getElementById('addContact').dispatchEvent(new Event('input'));

            // Attach confirmDelete handler
            const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
            if (confirmDeleteBtn) {
                confirmDeleteBtn.addEventListener('click', confirmDelete);
            }

            // Attach confirmLogout handler
            const confirmLogoutBtn = document.getElementById('confirmLogoutBtn');
            if (confirmLogoutBtn) {
                confirmLogoutBtn.addEventListener('click', confirmLogout);
            }
        });
    </script>
</body>
</html>