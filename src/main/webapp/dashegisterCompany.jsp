<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Register Company</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <style>
        body {
            background: linear-gradient(135deg, #1e3c72, #4ecdc4);
            color: #333;
            min-height: 100vh;
            margin: 0;
            font-family: 'Poppins', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            padding-top: 70px;
        }
        .navbar {
            background: #1e3c72;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 1000;
        }
        .navbar-nav {
            margin: 0 auto;
        }
        .navbar-nav .nav-link {
            color: white !important;
            margin: 0 15px;
            padding: 8px 15px;
            border-radius: 5px;
            transition: all 0.3s ease;
            font-weight: 500;
        }
        .navbar-nav .nav-link:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
        }
        .container {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: calc(100vh - 70px);
            padding: 20px;
        }
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            max-width: 500px;
            width: 100%;
            padding: 20px;
            background: white;
        }
        h2 {
            color: #1e3c72;
            text-align: center;
            margin-bottom: 20px;
            position: relative;
            padding-bottom: 10px;
        }
        h2:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 50px;
            height: 2px;
            background: #00ced1;
            border-radius: 1px;
        }
        .form-label {
            font-weight: 500;
            color: #555;
        }
        .form-control, .form-select {
            border-radius: 5px;
        }
        .form-control:focus, .form-select:focus {
            border-color: #00ced1;
            box-shadow: 0 0 0 3px rgba(0, 206, 209, 0.2);
        }
        .btn-primary {
            background-color: #1e3c72;
            border: none;
            width: 100%;
            padding: 10px;
            transition: all 0.3s ease;
        }
        .btn-primary:hover {
            background-color: #16325e;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(30, 60, 114, 0.3);
        }
        .popup {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .popup-content {
            background: #fff;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
            max-width: 400px;
            width: 90%;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            animation: slideIn 0.5s ease-out;
        }
        @keyframes slideIn {
            from { transform: translateY(100%); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .popup-content h3 {
            color: #1e3c72;
            font-size: 1.5rem;
            margin-bottom: 15px;
            text-transform: uppercase;
        }
        .popup-content p {
            color: #555;
            font-size: 1rem;
            margin-bottom: 20px;
        }
        .popup-content .btn {
            background-color: #1e3c72;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            transition: all 0.3s ease;
        }
        .popup-content .btn:hover {
            background-color: #16325e;
            transform: translateY(-2px);
        }
        .password-container {
            position: relative;
        }
        .password-container input {
            padding-right: 40px;
        }
        .password-toggle {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #555;
            font-size: 1.2rem;
        }
        .password-toggle:hover {
            color: #1e3c72;
        }
        .form-check-label {
            color: #555;
            font-size: 0.9rem;
        }
        .form-check-label a {
            color: #00ced1;
            text-decoration: underline;
        }
        .form-check-label a:hover {
            color: #1e3c72;
        }
        .modal-content {
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }
        .modal-header {
            background: #1e3c72;
            color: white;
            border-top-left-radius: 15px;
            border-top-right-radius: 15px;
        }
        .modal-title {
            font-weight: 600;
        }
        .modal-body {
            max-height: 60vh;
            overflow-y: auto;
            padding: 20px;
            background: white;
            color: #333;
        }
        .modal-body h3 {
            color: #1e3c72;
            font-size: 1.5rem;
            margin-top: 20px;
        }
        .modal-body p, .modal-body ul {
            font-size: 0.9rem;
            line-height: 1.6;
            color: #555;
        }
        .modal-body ul {
            padding-left: 20px;
        }
        .modal-footer {
            border-top: none;
            padding: 15px;
        }
        .btn-secondary {
            background-color: #6c757d;
            border: none;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg">
        <div class="container-fluid">
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item"><a class="nav-link" href="login1.jsp">Home</a></li>
                    <li class="nav-item"><a class="nav-link" href="dashadminLogin.jsp">Login</a></li>
                    <li class="nav-item"><a class="nav-link" href="dashegisterCompany.jsp">Register Company</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="card" style="animation: fadeInUp 0.8s ease-out;">
            <h2>Register Company</h2>
            <form id="registerForm" action="RegisterCompanyServlet" method="post" autocomplete="off">
                <div class="mb-3"><label class="form-label">Full Name:</label><input type="text" class="form-control" name="full_name" placeholder="Enter your full name" autocomplete="off" required></div>
                <div class="mb-3"><label class="form-label">Email:</label><input type="email" class="form-control" name="email" id="email" placeholder="Enter your email" autocomplete="off" required></div>
                <div class="mb-3"><label class="form-label">Company Name:</label><input type="text" class="form-control" name="company_name" placeholder="Enter company name" autocomplete="off" required></div>
                <div class="mb-3"><label class="form-label">Phone Number:</label><input type="tel" class="form-control" name="phone_number" placeholder="Enter phone number" pattern="[0-9]{10}" autocomplete="off" required></div>
                <div class="mb-3"><label class="form-label">Country:</label><select class="form-select" name="country" required><option value="" selected disabled>Select Country</option><option value="India">India</option><option value="USA">USA</option><option value="UK">UK</option><option value="Germany">Germany</option></select></div>
                <div class="mb-3"><label class="form-label">Company Size:</label><select id="company_size" class="form-select" name="company_size" onchange="toggleCustomSize()" required><option value="" selected disabled>Select Company Size</option><option value="3">3</option><option value="9">9</option><option value="15">15</option><option value="custom">Other (Enter Manually)</option></select></div>
                <div class="mb-3"><input type="number" id="custom_size" class="form-control" name="custom_size" placeholder="Enter custom size" style="display: none;" min="1"></div>
                <div class="mb-3 password-container">
                    <label class="form-label">Password:</label>
                    <input type="password" class="form-control" name="password" id="password" placeholder="Enter password" autocomplete="new-password" required>
                    <span class="password-toggle" onclick="togglePassword('password', this)">👁</span>
                </div>
                <div class="mb-3 password-container">
                    <label class="form-label">Confirm Password:</label>
                    <input type="password" class="form-control" name="confirm_password" id="confirm_password" placeholder="Confirm password" autocomplete="new-password" required>
                    <span class="password-toggle" onclick="togglePassword('confirm_password', this)">👁</span>
                </div>
                <div class="mb-3"><label class="form-label">Company Address:</label><input type="text" class="form-control" name="address" placeholder="Enter company address" autocomplete="off" required></div>
                <div class="mb-3"><label class="form-label">Company Website:</label><input type="url" class="form-control" name="website" placeholder="Enter company website" autocomplete="off" required></div>
                <div class="mb-3 form-check">
                    <input type="checkbox" class="form-check-input" id="agreePolicy" name="agreePolicy" disabled>
                    <label class="form-check-label" for="agreePolicy">I agree to the <a href="#" data-bs-toggle="modal" data-bs-target="#privacyPolicyModal">Privacy Policy</a> and Terms & Conditions</label>
                </div>
                <button type="submit" class="btn btn-primary">Register</button>
            </form>
        </div>
    </div>

    <div class="modal fade" id="privacyPolicyModal" tabindex="-1" aria-labelledby="privacyPolicyModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="privacyPolicyModalLabel">Privacy Policy</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <h3>Privacy Policy for Tars CRM</h3>
                    <p>At Tars CRM, we are committed to safeguarding the privacy and security of our users’ personal information. This Privacy Policy outlines how Tars CRM, a customer relationship management (CRM) platform, collects, uses, stores, shares, and protects data across its Admin, Employee (Sales, Team Lead/Project Manager), and Customer modules. This policy applies to all users, including Admins, Employees, and Customers.</p>
                    
                    <h3>1. Information We Collect</h3>
                    <p>We collect the following data to provide and enhance our CRM services:</p>
                    <ul>
                        <li><strong>Admin Module Data</strong>:
                            <ul>
                                <li><strong>Company Information</strong>: Company size, admin email, and password provided during registration.</li>
                                <li><strong>Lead Information</strong>: Lead ID, Project Name, Firm, In Date, Customer Name, Email, Contact, Address, Organizations, Added By (Admin/Employee).</li>
                                <li><strong>Financial Data</strong>: Lead ID, Project Name, Customer Name, Due Date, Advance Payment, Mid Payment, Final Payment, Quotes Amount, Final Value (adjusted for discounts or additional requirements), Balance, Payment Status, and invoice details.</li>
                                <li><strong>Employee Data</strong>: Name, email, contact, salary, and role (Sales, Project Manager, Team Lead) added or edited by the Admin.</li>
                                <li><strong>Integration Data</strong>: Service names, charges, and renewal details for third-party integrations.</li>
                                <li><strong>Task Data</strong>: Task details, priorities (Low, Medium, High, Urgent), and status (Open, In-Progress, Completed).</li>
                                <li><strong>Quotation Data</strong>: Customer requirements, features, pricing, and generated PDFs.</li>
                            </ul>
                        </li>
                        <li><strong>Employee Module Data</strong>:
                            <ul>
                                <li><strong>Personal Information</strong>: Email and password provided by the Admin for login.</li>
                                <li><strong>Sales Employee Data</strong>: Leads added (Lead ID, Project Name, Customer Name, Email, Contact, Address, Organizations).</li>
                                <li><strong>Team Lead/Project Manager Data</strong>: Daily project reports, progress percentages, employee assignments, and task status updates (Open, In-Progress, Completed).</li>
                            </ul>
                        </li>
                        <li><strong>Customer Module Data</strong>:
                            <ul>
                                <li><strong>Personal Information</strong>: Email and password provided by the Admin for login.</li>
                                <li><strong>Project Data</strong>: Project progress (Ongoing, Testing, Waiting, Delivered) and status updates.</li>
                            </ul>
                        </li>
                        <li><strong>Usage Data</strong>: Interactions with dashboards (e.g., Task Management pie charts, Yearly Revenue/Expense/Profit bar graphs) and platform activities (e.g., email, video calls).</li>
                        <li><strong>Technical Data</strong>: IP addresses, browser types, device information, and login timestamps for security and performance monitoring.</li>
                    </ul>

                    <h3>2. How We Use Your Information</h3>
                    <p>We use collected data to:</p>
                    <ul>
                        <li><strong>Enable Core Functionality</strong>:
                            <ul>
                                <li>Support Admins in managing leads, projects, tasks, finances, quotations, employees, and integrations.</li>
                                <li>Allow Sales Employees to add and edit leads.</li>
                                <li>Enable Team Leads/Project Managers to update project progress, assign employees, and manage tasks.</li>
                                <li>Provide Customers with project tracking access.</li>
                            </ul>
                        </li>
                        <li><strong>Generate Insights</strong>: Create visualizations (e.g., pie charts for task status, bar graphs for revenue/expenses/profit) for business decisions.</li>
                        <li><strong>Facilitate Communication</strong>: Support email and video call interactions between Admins, Employees, and Customers.</li>
                        <li><strong>Improve Services</strong>: Analyze usage data to optimize platform performance and user experience.</li>
                        <li><strong>Ensure Security</strong>: Monitor technical data to prevent unauthorized access.</li>
                    </ul>

                    <h3>3. Data Sharing</h3>
                    <p>We do not sell or share personal data with third parties except as follows:</p>
                    <ul>
                        <li><strong>Within the Platform</strong>:
                            <ul>
                                <li>Admins can access Employee and Customer data for management purposes.</li>
                                <li>Sales Employees can view leads they’ve added.</li>
                                <li>Team Leads/Project Managers can access project and task data for their assigned projects.</li>
                                <li>Customers can view project progress for their specific projects.</li>
                            </ul>
                        </li>
                        <li><strong>Third-Party Integrations</strong>: Integration data (e.g., service names, charges) may be shared with service providers as configured by the Admin.</li>
                        <li><strong>Legal Obligations</strong>: Data may be disclosed to comply with legal requirements or protect Tars CRM, our users, or others.</li>
                    </ul>

                    <h3>4. Data Storage and Security</h3>
                    <ul>
                        <li><strong>Storage</strong>: Data is stored on secure, encrypted cloud servers with access restricted to authorized personnel.</li>
                        <li><strong>Security Measures</strong>: We use industry-standard encryption, access controls, and regular security audits to protect data from unauthorized access, loss, or alteration.</li>
                        <li><strong>Retention</strong>: Data is retained only as long as necessary or required by law:
                            <ul>
                                <li>Lead, project, and task data are retained until deleted by the Admin.</li>
                                <li>Financial data is retained for 7 years for compliance.</li>
                                <li>Employee and Customer credentials are retained until accounts are deactivated.</li>
                            </ul>
                        </li>
                    </ul>

                    <h3>5. User Rights</h3>
                    <p>Users have the following rights:</p>
                    <ul>
                        <li><strong>Access</strong>: View your account data (e.g., Customers can view project progress, Employees can view tasks).</li>
                        <li><strong>Correction</strong>: Request updates to inaccurate data (e.g., Admins can edit lead/employee details).</li>
                        <li><strong>Deletion</strong>: Request data deletion (e.g., Admins can delete leads or employee records).</li>
                        <li><strong>Restriction</strong>: Limit data processing (e.g., Customers can contact Admins to restrict project data access).</li>
                        <li><strong>Data Portability</strong>: Request a copy of your data in a structured format (where applicable).</li>
                    </ul>
                    <p>Contact us at rmshinde0303@gmail.com to exercise these rights.</p>

                    <h3>6. Third-Party Integrations</h3>
                    <p>Admins may enable third-party integrations. We are not responsible for the privacy practices of these services. Users should review their respective privacy policies.</p>

                    <h3>7. Cookies and Tracking</h3>
                    <p>We use cookies to enhance user experience, track platform usage, and generate analytics for dashboards (e.g., Task Management pie charts). Users can manage cookie preferences via browser settings.</p>

                    <h3>8. Children’s Privacy</h3>
                    <p>Tars CRM is not intended for individuals under 16. We do not knowingly collect data from children.</p>

                    <h3>9. Changes to This Policy</h3>
                    <p>We may update this policy to reflect changes in our services or legal requirements. Users will be notified via email or platform notifications.</p>

                    <h3>10. Contact Us</h3>
                    <p>For questions or concerns, contact us at 9156847025 or rmshinde0303@gmail.com .</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" id="closeModalBtn">Ok</button>
                </div>
            </div>
        </div>
    </div>

    <div class="popup" id="errorPopup">
        <div class="popup-content">
            <h3>Error</h3>
            <p id="errorMessage">Passwords do not match. Please try again.</p>
            <button class="btn" onclick="closePopup()">OK</button>
        </div>
    </div>

    <div class="popup" id="paymentPopup">
        <div class="popup-content">
            <h3>Complete Your Payment</h3>
            <p>Please use the link below to pay <span id="paymentAmount"></span> INR:</p>
            <p><a id="paymentLink" href="" target="_blank"></a></p>
            <button class="btn" onclick="copyPaymentLink()">Copy Link</button>
            <p>After payment, click below to proceed to login.</p>
            <button class="btn" onclick="proceedToLogin()">Proceed to Login</button>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script>
        window.onload = function () {
            document.querySelectorAll("input").forEach(input => input.value = "");
            document.querySelectorAll("select").forEach(select => select.selectedIndex = 0);
            document.getElementById("agreePolicy").checked = false;
            document.getElementById("agreePolicy").disabled = true;

            <% if (request.getAttribute("errorMessage") != null) { %>
                document.getElementById("errorMessage").innerText = "<%= request.getAttribute("errorMessage") %>";
                document.getElementById("errorPopup").style.display = "flex";
            <% } %>
            <% if (request.getAttribute("paymentLink") != null) { %>
                document.getElementById("paymentLink").href = "<%= request.getAttribute("paymentLink") %>";
                document.getElementById("paymentLink").innerText = "<%= request.getAttribute("paymentLink") %>";
                document.getElementById("paymentAmount").innerText = "<%= request.getAttribute("paymentAmount") %>";
                document.getElementById("paymentPopup").style.display = "flex";
            <% } %>
        };

        function toggleCustomSize() {
            let select = document.getElementById("company_size");
            let customInput = document.getElementById("custom_size");
            if (select.value === "custom") {
                customInput.style.display = "block";
                customInput.required = true;
            } else {
                customInput.style.display = "none";
                customInput.required = "";
            }
        }

        function togglePassword(inputId, element) {
            let input = document.getElementById(inputId);
            if (input.type === "password") {
                input.type = "text";
                element.textContent = "👁";
            } else {
                input.type = "password";
                element.textContent = "👁";
            }
        }

        document.getElementById("registerForm").addEventListener("submit", function (e) {
            let agreeCheckbox = document.getElementById("agreePolicy");
            if (!agreeCheckbox.checked) {
                alert("You must agree to the Privacy Policy and Terms & Conditions to proceed with registration.");
                e.preventDefault();
                return false;
            }

            let password = document.getElementById("password").value;
            let confirmPassword = document.getElementById("confirm_password").value;
            if (password !== confirmPassword) {
                document.getElementById("errorMessage").innerText = "Passwords do not match. Please try again.";
                document.getElementById("errorPopup").style.display = "flex";
                e.preventDefault();
                document.getElementById("confirm_password").focus();
                return false;
            }

            let emailInput = document.getElementById("email");
            let email = emailInput.value.trim();
            const emailgmailPattern = /^[a-zA-Z0-9._-]+@gmail\.com$/;
            if (!emailgmailPattern.test(email)) {
                alert("Please enter a valid Gmail address (e.g., yourname@gmail.com).");
                emailInput.focus();
                e.preventDefault();
                return false;
            }

            let select = document.getElementById("company_size");
            let customInput = document.getElementById("custom_size");
            if (select.value === "custom") {
                select.value = customInput.value;
            }
        });

        function closePopup() {
            document.getElementById("errorPopup").style.display = "none";
        }

        function copyPaymentLink() {
            let link = document.getElementById("paymentLink").href;
            navigator.clipboard.writeText(link).then(() => alert("Payment link copied to clipboard!")).catch(err => alert("Failed to copy link: " + err));
        }

        function proceedToLogin() { window.location.href = "dashadminLogin.jsp"; }

        document.getElementById('closeModalBtn').addEventListener('click', function() {
            document.getElementById("agreePolicy").disabled = false;
        });
    </script>
</body>
</html>