<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Management | CRMSPOT</title>
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
            background: var(--success);
            color: white;
        }

        .action-btn.delete {
            background: var(--danger);
            color: white;
        }

        /* Search Input */
        .search-container {
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }

        .search-input {
            padding: 12px 15px;
            border: 2px solid #ddd;
            border-radius: 10px;
            font-size: 1rem;
            background: #fff;
            transition: all 0.3s ease;
            flex-grow: 1;
            max-width: 300px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .search-input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(0, 196, 180, 0.1);
            outline: none;
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

        .confirmation-modal-content {
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
            background: linear-gradient(135deg, var(--warning) 0%, #ffeb99 100%);
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

        .optional-field {
            color: #6b7280;
            font-size: 12px;
            margin-top: -8px;
            margin-bottom: 8px;
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

            .action-btn {
                width: 100%;
                justify-content: center;
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

            .search-container {
                flex-direction: column;
                align-items: flex-start;
            }

            .search-input {
                max-width: 100%;
                margin-right: 0;
                margin-bottom: 10px;
            }

            .modal-content {
                width: 95%;
                padding: 15px;
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
            <h1 class="page-title">Employee Management</h1>
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
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conProfile = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
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

        <!-- Employee Table -->
        <div class="table-container slide-up">
            <div class="search-container">
               
                <button type="button" class="btn btn-primary" onclick="openModal('addContactModal')"><i class="fas fa-user-plus"></i> Add Employee</button>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Emp Name</th>
                            <th>Project Name</th>
                            <th>Position</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Address</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="employeeTableBody">
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");
                                PreparedStatement ps = con.prepareStatement("SELECT * FROM interns WHERE company_id = ?");
                                ps.setInt(1, companyId);
                                ResultSet rs = ps.executeQuery();

                                while (rs.next()) {
                        %>
                        <tr>
                            <td data-title="Emp Name" class="emp-name"><%= rs.getString("emp_name") %></td>
                            <td data-title="Project Name"><%= rs.getString("project_name") != null ? rs.getString("project_name") : "-" %></td>
                            <td data-title="Position" class="emp-position"><%= rs.getString("position") %></td>
                            <td data-title="Email"><%= rs.getString("email") %></td>
                            <td data-title="Phone"><%= rs.getString("contact") %></td>
                            <td data-title="Address"><%= rs.getString("address") %></td>
                            <td data-title="Action">
                                <button class="action-btn edit" onclick="openEditPopup(<%= rs.getInt("empid") %>, '<%= rs.getString("emp_name") %>', '<%= rs.getString("project_name") != null ? rs.getString("project_name") : "" %>', '<%= rs.getString("position") %>', '<%= rs.getString("email") %>', '<%= rs.getString("contact") %>', '<%= rs.getString("address") %>')">
                                    <i class="fas fa-edit"></i> Edit
                                </button>
                                <button class="action-btn delete" onclick="openDeleteConfirmModal(<%= rs.getInt("empid") %>)">
                                    <i class="fas fa-trash"></i> Delete
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                                rs.close();
                                ps.close();
                                con.close();
                            } catch (Exception e) {
                                out.println("<tr><td colspan='7' style='text-align:center;'>Error fetching employees: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Modal for Add Employee -->
    <div class="modal" id="addContactModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Add Employee</h2>
                <button class="close-btn" onclick="closeModal('addContactModal')">×</button>
            </div>
            <form id="addEmployeeForm" action="addinternservlet" method="post" onsubmit="return validateAddForm()">
                <div class="form-group">
                    <label>Employee Name</label>
                    <input type="text" name="emp_name" class="form-control" placeholder="Employee Name" required>
                </div>
                <div class="form-group">
                    <label>Project Name</label>
                    <input type="text" name="project_name" class="form-control" placeholder="Project Name (Optional)">
                    <div class="optional-field">Optional field</div>
                </div>
                <div class="form-group">
                    <label>Position</label>
                    <input type="text" name="position" class="form-control" placeholder="Position" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" id="empEmail" class="form-control" placeholder="Email (e.g., user@gmail.com)" required>
                    <div id="emailError" class="error-message">Please enter a valid email address (e.g., user@gmail.com)</div>
                </div>
                <div class="form-group">
                    <label>Phone</label>
                    <input type="text" name="phone" id="empPhone" class="form-control" placeholder="Phone (10 digits)" required>
                    <div id="phoneError" class="error-message">Please enter a valid 10-digit phone number</div>
                </div>
                <div class="form-group">
                    <label>Address</label>
                    <input type="text" name="address" class="form-control" placeholder="Address" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;"><i class="fas fa-save"></i> Add Employee</button>
            </form>
        </div>
    </div>

    <!-- Modal for Edit Employee -->
    <div class="modal" id="editdata">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Employee</h2>
                <button class="close-btn" onclick="closeModal('editdata')">×</button>
            </div>
            <form id="editEmployeeForm" action="EditinternServlet" method="post" onsubmit="return validateEditForm()">
                <input type="hidden" name="empid" id="popup-empid">
                <div class="form-group">
                    <label>Employee Name</label>
                    <input type="text" name="emp_name" id="popup-emp-name" class="form-control" placeholder="Employee Name" required>
                </div>
                <div class="form-group">
                    <label>Project Name</label>
                    <input type="text" name="project_name" id="popup-project-name" class="form-control" placeholder="Project Name (Optional)">
                    <div class="optional-field">Optional field</div>
                </div>
                <div class="form-group">
                    <label>Position</label>
                    <input type="text" name="position" id="popup-position" class="form-control" placeholder="Position" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" id="popup-email" class="form-control" placeholder="Email (e.g., user@gmail.com)" required>
                    <div id="editEmailError" class="error-message">Please enter a valid email address (e.g., user@gmail.com)</div>
                </div>
                <div class="form-group">
                    <label>Phone</label>
                    <input type="text" name="phone" id="popup-phone" class="form-control" placeholder="Phone (10 digits)" required>
                    <div id="editPhoneError" class="error-message">Please enter a valid 10-digit phone number</div>
                </div>
                <div class="form-group">
                    <label>Address</label>
                    <input type="text" name="address" id="popup-address" class="form-control" placeholder="Address" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;"><i class="fas fa-save"></i> Update Employee</button>
            </form>
        </div>
    </div>

    <!-- Modal for Delete Confirmation -->
    <div class="modal" id="deleteConfirmModal">
        <div class="modal-content confirmation-modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, var(--warning) 0%, #ffeb99 100%);">
                <h2>Confirm Deletion</h2>
            </div>
            <p class="confirmation-message"><i class="fas fa-exclamation-triangle" style="color: var(--warning); margin-right: 8px;"></i>Are you sure you want to remove this employee?</p>
            <div class="confirmation-buttons">
                <button class="btn btn-danger" onclick="cancelDelete()"><i class="fas fa-times"></i> Cancel</button>
                <button class="btn btn-primary" id="confirmDeleteBtn"><i class="fas fa-check"></i> Confirm</button>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function isValidGmailEmail(email) {
            const gmailPattern = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
            return gmailPattern.test(email);
        }

        function isValidPhone(phone) {
            const phonePattern = /^\d{10}$/;
            return phonePattern.test(phone);
        }

        document.getElementById('empEmail').addEventListener('input', function() {
            const email = this.value.trim();
            const errorElement = document.getElementById('emailError');
            if (email === '') {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
                return;
            }
            if (!isValidGmailEmail(email)) {
                this.classList.add('invalid-input');
                errorElement.textContent = 'Please use a valid Gmail address (e.g., yourname@gmail.com)';
                errorElement.style.display = 'block';
            } else {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
            }
        });

        document.getElementById('empPhone').addEventListener('input', function() {
            validatePhoneField(this, 'phoneError');
        });

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
                errorElement.textContent = 'Please use a valid Gmail address (e.g., yourname@gmail.com)';
                errorElement.style.display = 'block';
            } else {
                this.classList.remove('invalid-input');
                errorElement.style.display = 'none';
            }
        });

        document.getElementById('popup-phone').addEventListener('input', function() {
            validatePhoneField(this, 'editPhoneError');
        });

        function validatePhoneField(field, errorId) {
            const phone = field.value.trim();
            const errorElement = document.getElementById(errorId);
            if (phone === '') {
                field.classList.remove('invalid-input');
                errorElement.style.display = 'none';
                return;
            }
            if (!isValidPhone(phone)) {
                field.classList.add('invalid-input');
                errorElement.style.display = 'block';
            } else {
                field.classList.remove('invalid-input');
                errorElement.style.display = 'none';
            }
        }

        function validateAddForm() {
            const email = document.getElementById('empEmail').value.trim();
            const phone = document.getElementById('empPhone').value.trim();
            let isValid = true;

            if (!isValidGmailEmail(email)) {
                document.getElementById('emailError').textContent = 'Please use a valid Gmail address (e.g., yourname@gmail.com)';
                document.getElementById('emailError').style.display = 'block';
                document.getElementById('empEmail').classList.add('invalid-input');
                isValid = false;
            }

            if (!isValidPhone(phone)) {
                document.getElementById('phoneError').style.display = 'block';
                document.getElementById('empPhone').classList.add('invalid-input');
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
                document.getElementById('editEmailError').textContent = 'Please use a valid Gmail address (e.g., yourname@gmail.com)';
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

        function searchEmployee() {
            let input = document.getElementById('searchInput').value.toLowerCase().trim();
            let tableRows = document.getElementById('employeeTableBody').getElementsByTagName('tr');
            for (let row of tableRows) {
                let positionCell = row.querySelector('.emp-position');
                if (positionCell) {
                    let position = positionCell.textContent.toLowerCase().trim();
                    row.style.display = position.includes(input) ? '' : 'none';
                }
            }
        }

        function openEditPopup(empid, emp_name, project_name, position, email, phone, address) {
            document.getElementById('popup-empid').value = empid;
            document.getElementById('popup-emp-name').value = emp_name;
            document.getElementById('popup-project-name').value = project_name;
            document.getElementById('popup-position').value = position;
            document.getElementById('popup-email').value = email;
            document.getElementById('popup-phone').value = phone;
            document.getElementById('popup-address').value = address;
            document.getElementById('popup-email').dispatchEvent(new Event('input'));
            document.getElementById('popup-phone').dispatchEvent(new Event('input'));
            openModal('editdata');
        }

        let deleteEmpId = null;

        function openDeleteConfirmModal(empid) {
            deleteEmpId = empid;
            openModal('deleteConfirmModal');
        }

        function cancelDelete() {
            deleteEmpId = null;
            closeModal('deleteConfirmModal');
        }

        function confirmDelete() {
            if (deleteEmpId !== null) {
                window.location.href = "deleteinternservlet?empid=" + deleteEmpId;
            }
            closeModal('deleteConfirmModal');
            deleteEmpId = null;
        }

        function openModal(modalId) {
            document.getElementById(modalId).classList.add('active');
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.remove('active');
        }

        function closeMessageModal() {
            const modal = document.getElementById('messageModal');
            if (modal) modal.classList.remove('active');
            window.location.href = 'addDashemp.jsp';
        }

        document.addEventListener('click', function(event) {
            const modals = document.querySelectorAll('.modal.active');
            modals.forEach(modal => {
                if (event.target === modal) {
                    modal.classList.remove('active');
                    if (modal.id === 'deleteConfirmModal') {
                        deleteEmpId = null;
                    }
                }
            });
        });

        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                const modals = document.querySelectorAll('.modal.active');
                modals.forEach(modal => {
                    modal.classList.remove('active');
                    if (modal.id === 'deleteConfirmModal') {
                        deleteEmpId = null;
                    }
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

            document.getElementById('empEmail').dispatchEvent(new Event('input'));
            document.getElementById('empPhone').dispatchEvent(new Event('input'));

            // Attach confirmDelete handler
            const confirmBtn = document.getElementById('confirmDeleteBtn');
            if (confirmBtn) {
                confirmBtn.addEventListener('click', confirmDelete);
            }
        });
    </script>
</body>
</html>