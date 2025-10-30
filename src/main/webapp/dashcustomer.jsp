<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Details | CRMSPOT</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* [Previous CSS styles remain exactly the same] */
        :root {
            --primary: #0c022d;
            --secondary: #140a42;
            --accent: #ff2e63;
            --light: #f8f9fa;
            --dark: #2c3e50;
            --success: #4bc0c0;
            --info: #36a2eb;
            --warning: #ffcd56;
            --danger: #ff6384;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
            color: var(--dark);
            min-height: 100vh;
        }

        /* [All other CSS styles remain exactly the same] */
        /* ... */
                                    .content {
            padding: 20px;
        }

        /* Navbar */
        .navbar {
            background: white;
            padding: 15px 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .navbar ul {
            list-style: none;
            display: flex;
            gap: 20px;
        }

        .navbar a {
            color: var(--dark);
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
        }

        .navbar a:hover {
            color: var(--accent);
        }

        /* Page Header */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
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
            background: #e61e4d;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn i {
            margin-right: 8px;
        }

        /* Card container */
        .card-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            padding: 25px;
            transition: all 0.3s ease;
            margin-bottom: 20px;
        }

        .card-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        /* Project Card */
        .project-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            transition: all 0.3s ease;
        }

        .project-card:hover {
            transform: scale(1.01);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .project-card h3 {
            color: var(--primary);
            margin-bottom: 15px;
            font-size: 1.2rem;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }

        .project-card p {
            margin-bottom: 10px;
            display: flex;
        }

        .project-card strong {
            min-width: 180px;
            display: inline-block;
            color: var(--dark);
        }

        .project-card span {
            color: #555;
        }

        /* Progress Bar */
        .progress-container {
            width: 100%;
            background-color: #e9ecef;
            border-radius: 5px;
            margin: 10px 0;
        }

        .progress-bar {
            height: 20px;
            border-radius: 5px;
            background-color: var(--success);
            text-align: center;
            line-height: 20px;
            color: white;
            font-size: 12px;
            transition: width 0.5s ease;
        }

        /* Employee Section */
        .employee-section {
            margin-top: 20px;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }

        .employee-section h3 {
            color: var(--primary);
            margin-bottom: 15px;
        }

        /* Logout Button */
        .logout-btn {
            margin-top: 20px;
            padding: 12px 25px;
            background: var(--danger);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
        }

        .logout-btn:hover {
            background: #cc0000;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .logout-btn i {
            margin-right: 8px;
        }

        /* Reports Table Styles */
        .reports-container {
            margin-top: 20px;
            overflow-x: auto;
        }
        
        .reports-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .reports-table th {
            background-color: var(--primary);
            color: white;
            padding: 12px 15px;
            text-align: left;
        }
        
        .reports-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #eee;
            vertical-align: top;
        }
        
        .reports-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        .reports-table tr:hover {
            background-color: #f1f1f1;
        }
        
        .report-date {
            white-space: nowrap;
            width: 120px;
        }
        
        .report-content {
            word-wrap: break-word;
            max-width: 0;
        }
        
        .no-reports {
            padding: 15px;
            text-align: center;
            color: #666;
            font-style: italic;
        }
        
        .loading-reports {
            padding: 15px;
            text-align: center;
            color: var(--info);
            font-style: italic;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .project-card strong {
                min-width: 120px;
            }
            
            .project-card p {
                flex-direction: column;
            }
            
            .project-card span {
                margin-top: 5px;
            }
            
            .page-title {
                font-size: 1.5rem;
            }
            
            .reports-table {
                display: block;
                overflow-x: auto;
            }
            
            .report-date {
                white-space: normal;
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
    <!-- Main Content -->
    <div class="content">
        <!-- Navbar -->
        <div class="navbar slide-up">
            <div></div> <!-- Empty div for spacing -->
        </div>
        
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">Project Details</h1>
        </div>
        
        <!-- Project Details -->
        <div class="card-container slide-up">
            <%
                Connection con = null;
                PreparedStatement psProject = null, psQuotation = null, psEmp = null, psFinance = null;
                ResultSet rsProject = null, rsQuotation = null, rsEmp = null, rsFinance = null;
                
                HttpSession sessionVar = request.getSession();
                String companyIdStr = (String) sessionVar.getAttribute("company_id");
                String leadIdsStr = (String) sessionVar.getAttribute("lead_id");

                Integer companyId = null;
                Integer leadId = null;

                if (companyIdStr != null && leadIdsStr != null) {
                    try {
                        companyId = Integer.parseInt(companyIdStr);
                        leadId = Integer.parseInt(leadIdsStr);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }

                if (companyId == null || leadId == null) {
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

                    // Fetch project details
                    psProject = con.prepareStatement("SELECT project_name, due_date, percent FROM project WHERE company_id = ? AND lead_id = ?");
                    psProject.setInt(1, companyId);
                    psProject.setInt(2, leadId);
                    rsProject = psProject.executeQuery();

                    while (rsProject.next()) {
                        int percent = rsProject.getInt("percent");
            %>
            <div class="project-card">
                <h3><i class="fas fa-project-diagram"></i> Project Information</h3>
                <p><strong>Project Name:</strong> <span><%= rsProject.getString("project_name") != null ? rsProject.getString("project_name") : "000" %></span></p>
                <p><strong>Due Date:</strong> <span><%= rsProject.getString("due_date") != null ? rsProject.getString("due_date") : "dd/mm/yyyy" %></span></p>
                <p><strong>Completion Status:</strong></p>
                <div class="progress-container">
                    <div class="progress-bar" style="width: <%= percent %>%"><%= percent %>%</div>
                </div>
            </div>
            <%
                    }

                    // Fetch quotation details
                    psQuotation = con.prepareStatement("SELECT lead_id, requirement, feature, amount, addrequirement, addfeature, daily_report, addiamt FROM quotation WHERE company_id = ? AND lead_id = ?");
                    psQuotation.setInt(1, companyId);
                    psQuotation.setInt(2, leadId);
                    rsQuotation = psQuotation.executeQuery();

                    while (rsQuotation.next()) {
                        double amount = rsQuotation.getDouble("amount");
                        double addiamt = rsQuotation.getDouble("addiamt");
                        double totalAmount = amount + addiamt;
            %>
            <div class="project-card">
                <h3><i class="fas fa-file-invoice-dollar"></i> Quotation Details</h3>
                <p><strong>Requirement:</strong> <span><%= rsQuotation.getString("requirement") %></span></p>
                <p><strong>Feature:</strong> <span><%= rsQuotation.getString("feature") %></span></p>
                <p><strong>Amount:</strong> <span>₹<%= String.format("%.2f", amount) %></span></p>
               <!--  <p><strong>Additional Requirement:</strong> <span><%= rsQuotation.getString("addrequirement")!=null ? rsQuotation.getString("addrequirement"):"No" %></span></p>
                <p><strong>Additional Feature:</strong> <span><%= rsQuotation.getString("addfeature") !=null ? rsQuotation.getString("addfeature"):"No" %></span></p>
                <p><strong>Daily Report:</strong> <span><%= rsQuotation.getString("daily_report") !=null ? rsQuotation.getString("daily_report"):"No Updates" %></span></p>
               -->  <p><strong>Additional Feature<br> Amount:</strong> <span>₹<%= String.format("%.2f", addiamt) %></span></p>
                <p><strong>Total Amount:</strong> <span>₹<%= String.format("%.2f", totalAmount) %></span></p>
            </div>
            <%
                    }

                    // Fetch finance management details - UPDATED BASED ON YOUR SCREENSHOT
                    psFinance = con.prepareStatement("SELECT addfeature, addirequirement, addiamt, finalvalue FROM financemanagement WHERE company_id = ? AND lead_id = ?");
                    psFinance.setInt(1, companyId);
                    psFinance.setInt(2, leadId);
                    rsFinance = psFinance.executeQuery();

                    if (rsFinance.next()) {
            %>
            <div class="project-card">
                <h3><i class="fas fa-money-bill-wave"></i> Financial Details</h3>
                <p><strong>Additional Feature:</strong> <span><%= rsFinance.getString("addfeature") != null ? rsFinance.getString("addfeature") : "None" %></span></p>
                <p><strong>Additional Requirement:</strong> <span><%= rsFinance.getString("addirequirement") != null ? rsFinance.getString("addirequirement") : "None" %></span></p>
                <p><strong>Additional Amount:</strong> <span>₹<%= rsFinance.getString("addiamt") != null ? String.format("%.2f", rsFinance.getDouble("addiamt")) : "0.00" %></span></p>
                <p><strong>Final Value:</strong> <span>₹<%= rsFinance.getString("finalvalue") != null ? String.format("%.2f", rsFinance.getDouble("finalvalue")) : "0.00" %></span></p>
            </div>
            <%
                    }

                    // Fetch only team lead and project manager from emp table
                    psEmp = con.prepareStatement("SELECT emp_name, email, phone, position FROM emp WHERE company_id = ? AND (LOWER(position) = 'team lead' OR LOWER(position) = 'project manager')", 
                        ResultSet.TYPE_SCROLL_INSENSITIVE, 
                        ResultSet.CONCUR_READ_ONLY);
                    psEmp.setInt(1, companyId);
                    rsEmp = psEmp.executeQuery();
                    
                    // Check if there are any results
                    if (rsEmp.next()) {
            %>
            <div class="employee-section">
                <h3><i class="fas fa-user-tie"></i> Project Leadership</h3>
            <%
                        // Reset the cursor to before first result
                        rsEmp.beforeFirst();
                        
                        // Now iterate through the results
                        while (rsEmp.next()) {
            %>
                <div class="project-card">
                    <p><strong>Employee Name:</strong> <span><%= rsEmp.getString("emp_name") %></span></p>
                    <p><strong>Email:</strong> <span><%= rsEmp.getString("email") %></span></p>
                    <p><strong>Phone:</strong> <span><%= rsEmp.getString("phone") %></span></p>
                    <p><strong>Position:</strong> <span><%= rsEmp.getString("position") %></span></p>
                </div>
            <%
                        }
            %>
            </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rsProject != null) rsProject.close();
                    if (psProject != null) psProject.close();
                    if (rsQuotation != null) rsQuotation.close();
                    if (psQuotation != null) psQuotation.close();
                    if (rsEmp != null) rsEmp.close();
                    if (psEmp != null) psEmp.close();
                    if (rsFinance != null) rsFinance.close();
                    if (psFinance != null) psFinance.close();
                    if (con != null) con.close();
                }
            %>
            
            <!-- Daily Reports Section - Updated -->
            <div class="project-card">
                <h3><i class="fas fa-calendar-day"></i> Daily Reports</h3>
                <div class="reports-container" id="reportsContainer">
                    <div class="loading-reports">Loading daily reports...</div>
                </div>
            </div>
        </div>

        <form action="LogoutServlet" method="post">
            <button type="submit" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </form>

    </div>

    <script>
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
            
            // Load daily reports
            loadDailyReports();
        });

        function loadDailyReports() {
            const container = document.getElementById('reportsContainer');
            container.innerHTML = '<div class="loading-reports">Loading reports...</div>';
            
            console.log('Fetching daily reports from servlet...');
            
            fetch('DailyReportServlet')
                .then(response => {
                    console.log('Received response from servlet');
                    if (!response.ok) {
                        console.error('Network response was not ok');
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Processing response data:', data);
                    
                    if (data.error) {
                        console.error('Error from servlet:', data.error);
                        container.innerHTML = '<div class="no-reports">Error: ' + data.error + '</div>';
                        return;
                    }
                    
                    if (!data.reports || data.reports.length === 0) {
                        console.log('No reports found in response');
                        container.innerHTML = '<div class="no-reports">No daily reports found for this project</div>';
                        return;
                    }
                    
                    console.log('Found reports:', data.reports.length);
                    let tableHTML = '<table class="reports-table"><thead><tr><th>Date</th><th>Report Content</th></tr></thead><tbody>';
                    
                    data.reports.forEach(report => {
                        console.log('Processing report:', report.id, report.date, report.content);
                        
                        let formattedDate = report.date;
                        try {
                            const date = new Date(report.date);
                            formattedDate = date.toLocaleDateString('en-US', { 
                                year: 'numeric', 
                                month: 'short', 
                                day: 'numeric' 
                            });
                        } catch (e) {
                            console.error('Date formatting error:', e);
                        }
                        
                        let content = report.content || 'No content';
                        content = content.replace(/\n/g, '<br>');
                        
                        tableHTML += '<tr>' +
                            '<td class="report-date">' + formattedDate + '</td>' +
                            '<td class="report-content">' + content + '</td>' +
                            '</tr>';
                    });
                    
                    tableHTML += '</tbody></table>';
                    container.innerHTML = tableHTML;
                    console.log('Reports table rendered successfully');
                })
                .catch(error => {
                    console.error('Error loading reports:', error);
                    container.innerHTML = '<div class="no-reports">Error loading reports: ' + error.message + '</div>';
                });
        }

        // Call loadDailyReports when page loads
        document.addEventListener('DOMContentLoaded', () => {
            // Your existing animation code
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
            
            // Load reports
            loadDailyReports();
        });
    </script>
</body>
</html>