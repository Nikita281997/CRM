<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Projects | CRMSPOT</title>
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
            background: #e55a75;
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
            margin: 0 20px;
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

        .action-btn.email {
            background: var(--info);
            color: white;
        }

        .action-btn.edit {
            background: var(--success);
            color: white;
        }

        .action-btn.delete {
            background: var(--danger);
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
            max-width: 800px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            transform: translateY(-20px);
            transition: all 0.3s ease;
            padding: 25px;
            position: relative;
            border: 2px solid var(--accent);
            background: linear-gradient(135deg, #ffffff 0%, #f0faff 100%);
        }

        .confirmation-modal-content {
            width: 397px;
            display: flex;
            flex-direction: column;
            min-height: 149px;
            padding: 20px;
        }

        .modal.active .modal-content {
            transform: translateY(0);
        }

        .modal-header {
            padding: 15px;
            border-bottom: 1px solid #eee;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: var(--table-header-bg);
            border-radius: 10px 10px 0 0;
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

        .modal-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 0;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--dark);
            font-size: 1.1rem;
            text-transform: uppercase;
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

        .form-control[readonly], .form-control[readonly]:focus {
            background-color: #f8f9fa;
            border-color: #ddd;
            box-shadow: none;
        }

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

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }

        .input-group {
            display: flex;
            gap: 10px;
            align-items: flex-end;
        }

        .full-width {
            grid-column: 1 / -1;
        }

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

        .progress-container {
            width: 100%;
            background-color: #e5e7eb;
            border-radius: 5px;
            height: 20px;
            margin-bottom: 5px;
        }

        .progress-bar {
            height: 100%;
            border-radius: 5px;
            transition: width 0.3s ease;
        }

        .progress-text {
            font-size: 0.8rem;
            color: #6b7280;
        }

        .employee-section {
            margin-bottom: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .employee-section h4 {
            margin-bottom: 10px;
            color: var(--dark);
            font-size: 1.2rem;
            font-weight: 600;
            border-bottom: 2px solid var(--accent);
            padding-bottom: 5px;
        }

        .employee-checkbox {
            margin-bottom: 8px;
            display: flex;
            align-items: center;
        }

        .employee-checkbox input {
            margin-right: 10px;
            transform: scale(1.2);
        }

        .employee-checkbox label {
            font-size: 1rem;
            color: var(--text-color);
        }

        .expired {
            color: var(--danger);
            font-weight: 500;
        }

        .save-btn {
            width: 100%;
            padding: 12px;
            font-size: 1.1rem;
            background: var(--accent);
            color: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }

        .save-btn:hover {
            background: #1a91da;
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.15);
        }

        .confirmation-buttons {
            margin-top: auto;
            display: flex;
            justify-content: flex-end;
            padding-top: 20px;
        }

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

            .modal-content {
                width: 95%;
                padding: 15px;
            }

            .confirmation-modal-content {
                width: 90%;
                min-height: 150px;
            }

            .modal-grid {
                grid-template-columns: 1fr;
            }

            .full-width {
                grid-column: 1 / -1;
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
            <h1 class="page-title">On-going Projects</h1>
            <div class="button-group" style="display: flex; gap: 10px;">
                <a href="dashmanager.jsp" class="btn btn-primary"><i class="fas fa-project-diagram"></i> Projects</a>
                <a href="addDashemp.jsp" class="btn btn-primary"><i class="fas fa-user-plus"></i> Add Employee</a>
                <a href="emptask.jsp" class="btn btn-primary"><i class="fas fa-tasks"></i> Tasks</a>
                <a href="login1.jsp" class="btn btn-danger"><i class="fas fa-sign-out-alt"></i> Logout</a>
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
                    conProfile = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI" );
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

        <!-- Projects Table -->
        <div class="table-container slide-up">
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Lead Id</th>
                            <th>Project Name</th>
                            <th>Due Date</th>
                            <th>Customer Name</th>
                            <th>Progress</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection con = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;

                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

                                String query = "SELECT f.*, l.*, p.percent, q.* " +
                                        "FROM financemanagement f " +
                                        "JOIN leads l ON f.lead_id = l.lead_id " +
                                        "JOIN project p ON l.lead_id = p.lead_id " +
                                        "LEFT JOIN quotation q ON l.lead_id = q.lead_id " +
                                        "WHERE (f.installment1 IS NOT NULL OR f.installment1 = 0) " +
                                        "AND l.company_id = ?";
                                ps = con.prepareStatement(query);
                                ps.setInt(1, companyId);
                                rs = ps.executeQuery();

                                while (rs.next()) {
                                    int leadId = rs.getInt("lead_id");
                                    int progress = rs.getInt("percent");
                        %>
                        <tr onclick="showPopup(
                            '<%= leadId %>',
                            '<%= rs.getString("project_name") %>',
                            '<%= rs.getString("due_date") != null ? rs.getString("due_date") : "N/A" %>',
                            '<%= rs.getString("customer_name") %>',
                            '<%= rs.getInt("percent") %>',
                            '<%= rs.getString("requirement") != null ? rs.getString("requirement") : "N/A" %>',
                            '<%= rs.getString("quotation_date") != null ? rs.getString("quotation_date") : "N/A" %>',
                            '<%= rs.getString("feature") != null ? rs.getString("feature") : "N/A" %>',
                            '<%= rs.getString("amount") != null ? rs.getString("amount") : "N/A" %>',
                            '<%= rs.getString("daily_report") != null ? rs.getString("daily_report") : "" %>'
                        )">
                            <td data-title="Lead Id"><%= leadId %></td>
                            <td data-title="Project Name"><%= rs.getString("project_name") %></td>
                            <td data-title="Due Date" class="<%= (rs.getString("due_date") != null && rs.getDate("due_date").before(new java.util.Date())) ? "expired" : "" %>">
                                <%= rs.getString("due_date") != null ? rs.getString("due_date") : "N/A" %>
                            </td>
                            <td data-title="Customer Name"><%= rs.getString("customer_name") %></td>
                            <td data-title="Progress">
                                <div class="progress-container">
                                    <div class="progress-bar"
                                         style="width: <%= progress %>%; 
                                                background-color: <%= (progress < 40) ? "var(--danger)" : (progress < 70) ? "var(--warning)" : "var(--success)" %>;">
                                    </div>
                                </div>
                                <span class="progress-text"><%= progress %>%</span>
                            </td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='6' style='text-align:center;'>Error fetching projects: " + e.getMessage() + "</td></tr>");
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

        <!-- Project Details Modal -->
        <div class="modal" id="projectModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>Project Details</h2>
                    <button class="close-btn" onclick="closeModal('projectModal')">×</button>
                </div>
                <form action="EditprojectBYmanager" method="post">
                    <input type="hidden" name="leadId" id="popupLeadIdInput">
                    <input type="hidden" name="projectName" id="popupProjectNameInput">

                    <div class="modal-grid">
                        <!-- Row 1, Col 1: Project Name -->
                        <div class="form-group">
                            <label>Project Name</label>
                            <p id="popupProjectName" class="form-control" readonly></p>
                        </div>
                        <!-- Row 1, Col 2: Due Date -->
                        <div class="form-group">
                            <label>Due Date</label>
                            <p id="popupDueDate" class="form-control" readonly></p>
                        </div>
                        <!-- Row 2, Col 1: Customer Name -->
                        <div class="form-group">
                            <label>Customer Name</label>
                            <p id="popupCustomerName" class="form-control" readonly></p>
                        </div>
                        <!-- Row 2, Col 2: Progress -->
                        <div class="form-group">
                            <label for="progressInput">Progress (%)</label>
                            <input type="number" class="form-control" id="progressInput" name="progress" min="0" max="100" required
                                   onchange="validateProgress(this)">
                        </div>
                        <!-- Row 3, Col 1: Report Date -->
                        <div class="form-group">
                            <label for="reportDate">Report Date</label>
                            <input type="date" class="form-control" name="reportDate" id="reportDate">
                        </div>
                        <!-- Row 3, Col 2: Search Previous Reports -->
                        <div class="form-group">
                            <label>Search Previous Reports</label>
                            <div class="input-group">
                                <input type="date" class="form-control" id="searchReportDate">
                                <button type="button" class="btn btn-primary" onclick="searchDailyReport()">
                                    <i class="fas fa-search"></i> Search
                                </button>
                            </div>
                        </div>
                        <!-- Row 4, Col 1: Add New Daily Report -->
                        <div class="form-group">
                            <label for="newReport">Add New Daily Report</label>
                            <textarea class="form-control" name="newReport" id="newReport" placeholder="Enter new daily report"></textarea>
                        </div>
                        <!-- Row 4, Col 2: Existing Daily Report -->
                        <div class="form-group">
                            <label>Existing Daily Report</label>
                            <textarea class="form-control" name="existingReport" id="existingReport" readonly></textarea>
                        </div>
                        <!-- Row 5, Col 1-2: Assign Employees -->
                        <div class="employee-section full-width">
                            <h4>Assign Employees</h4>
                            <div id="employeeList"></div>
                        </div>
                        <!-- Row 6, Col 1: Employees Currently on Project -->
                        <div class="employee-section" id="withProjectsSection">
                            <h4>Employees Currently on Project</h4>
                            <!-- Populated via JavaScript -->
                        </div>
                        <!-- Row 6, Col 2: Available Employees -->
                        <div class="employee-section" id="withoutProjectsSection">
                            <h4>Available Employees</h4>
                            <!-- Populated via JavaScript -->
                        </div>
                    </div>

                    <button type="submit" class="save-btn">
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                </form>
            </div>
        </div>

        <% 
            String popupMessage = (String) sessionVar.getAttribute("popupMessage");
            String popupType = (String) sessionVar.getAttribute("popupType");
            if (popupMessage != null) {
        %>
        <div class="modal active" id="messageModal">
            <div class="modal-content confirmation-modal-content">
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
        window.onload = function() {
            const reportDateInput = document.getElementById('reportDate');
            if (reportDateInput) {
                const today = new Date().toISOString().split('T')[0];
                reportDateInput.value = today;
            }
        };

        function showPopup(leadId, projectName, dueDate, customerName, progress, requirement, quotationDate, feature, amount, dailyReport) {
            document.getElementById("popupLeadIdInput").value = leadId;
            document.getElementById("popupProjectNameInput").value = projectName;
            document.getElementById("popupProjectName").innerText = projectName;
            document.getElementById("popupDueDate").innerText = dueDate;
            document.getElementById("popupCustomerName").innerText = customerName;

            const progressInput = document.getElementById("progressInput");
            progressInput.value = progress;
            progressInput.dataset.previousValue = progress;

            document.getElementById("existingReport").value = dailyReport || 'No daily report available';

            const today = new Date().toISOString().split('T')[0];
            document.getElementById('reportDate').value = today;

            fetch('GetEmployeesServlet')
                .then(response => response.json())
                .then(data => {
                    let employeeListDiv = document.getElementById("employeeList");
                    let withProjectsSection = document.getElementById("withProjectsSection");
                    let withoutProjectsSection = document.getElementById("withoutProjectsSection");

                    employeeListDiv.innerHTML = "";
                    withProjectsSection.innerHTML = "<h4>Employees Currently on Project</h4>";
                    withoutProjectsSection.innerHTML = "<h4>Available Employees</h4>";

                    if (data.withProjects && data.withProjects.length > 0) {
                        data.withProjects.forEach(emp => {
                            let checkboxDiv = document.createElement("div");
                            checkboxDiv.className = "employee-checkbox";

                            let checkbox = document.createElement("input");
                            checkbox.type = "checkbox";
                            checkbox.name = "removeEmployees";
                            checkbox.value = emp.id;
                            checkbox.id = "remove_" + emp.id;

                            let label = document.createElement("label");
                            label.htmlFor = "remove_" + emp.id;
                            label.innerHTML = emp.name + " (Project: " + emp.project + ")";

                            checkboxDiv.appendChild(checkbox);
                            checkboxDiv.appendChild(label);
                            withProjectsSection.appendChild(checkboxDiv);
                        });
                    } else {
                        withProjectsSection.innerHTML += "<p>No employees currently assigned.</p>";
                    }

                    if (data.withoutProjects && data.withoutProjects.length > 0) {
                        data.withoutProjects.forEach(emp => {
                            let checkboxDiv = document.createElement("div");
                            checkboxDiv.className = "employee-checkbox";

                            let checkbox = document.createElement("input");
                            checkbox.type = "checkbox";
                            checkbox.name = "addEmployees";
                            checkbox.value = emp.id;
                            checkbox.id = "add_" + emp.id;

                            let label = document.createElement("label");
                            label.htmlFor = "add_" + emp.id;
                            label.innerHTML = emp.name;

                            checkboxDiv.appendChild(checkbox);
                            checkboxDiv.appendChild(label);
                            withoutProjectsSection.appendChild(checkboxDiv);
                        });
                    } else {
                        withoutProjectsSection.innerHTML += "<p>No available employees.</p>";
                    }
                })
                .catch(error => {
                    console.error('Error fetching employees:', error);
                    document.getElementById("employeeList").innerHTML =
                        "<div class='error-message'>Error loading employee data</div>";
                });

            openModal('projectModal');
        }

        function searchDailyReport() {
            const leadId = document.getElementById('popupLeadIdInput').value;
            const searchDate = document.getElementById('searchReportDate').value;

            if (!searchDate) {
                alert('Please select a date to search');
                return;
            }

            fetch('GetDailyReportServlet?leadId=' + leadId + '&reportDate=' + searchDate)
                .then(response => response.json())
                .then(data => {
                    if (data.report) {
                        document.getElementById('existingReport').value = data.report;
                    } else {
                        document.getElementById('existingReport').value = 'No report found for this date';
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error fetching report');
                });
        }

        function validateProgress(input) {
            const previousValue = parseInt(input.dataset.previousValue || input.value);
            const newValue = parseInt(input.value);

            if (isNaN(newValue)) {
                input.value = previousValue;
                return false;
            }

            if (newValue < previousValue) {
                alert('Progress percentage cannot be decreased. Please enter a value equal to or greater than ' + previousValue + '%');
                input.value = previousValue;
                return false;
            }

            if (newValue > 100) {
                alert('Progress cannot exceed 100%');
                input.value = previousValue;
                return false;
            }

            input.dataset.previousValue = newValue;
            return true;
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
            window.location.href = 'dashmanager.jsp';
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

        document.querySelector('form').addEventListener('submit', function(e) {
            const progressInput = document.getElementById('progressInput');
            if (!validateProgress(progressInput)) {
                e.preventDefault();
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

            animatedElements.forEach(element => {
                observer.observe(element);
            });
        });
    </script>
</body>
</html>