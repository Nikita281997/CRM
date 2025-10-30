<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Company Profile</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<style>
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap');
    
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Poppins', sans-serif;
    }
    
    body {
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        min-height: 100vh;
        padding: 20px;
        position: relative;
    }
    
    .container {
        max-width: 800px;
        margin: 0 auto;
        animation: fadeIn 0.8s ease-out;
    }
    
    h1 {
        text-align: center;
        color: #2c3e50;
        margin-bottom: 30px;
        font-size: 2.5rem;
        text-shadow: 1px 1px 3px rgba(0,0,0,0.1);
        position: relative;
        padding-bottom: 10px;
    }
    
    h1:after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 100px;
        height: 4px;
        background: linear-gradient(90deg, #e74c3c, #f39c12);
        border-radius: 2px;
    }
    
    .profile-card {
        background: white;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        padding: 30px;
        margin-bottom: 30px;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        position: relative;
    }
    
    .profile-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 15px 35px rgba(0,0,0,0.15);
    }
    
    .profile-image {
        text-align: center;
        margin-bottom: 20px;
    }
    
    .profile-image img {
        width: 150px;
        height: 150px;
        object-fit: cover;
        border-radius: 50%;
        border: 3px solid #e74c3c;
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }
    
    .profile-item {
        display: flex;
        margin-bottom: 15px;
        padding-bottom: 15px;
        border-bottom: 1px dashed #eee;
        animation: slideIn 0.5s ease-out forwards;
        opacity: 0;
    }
    
    .profile-item:last-child {
        border-bottom: none;
        margin-bottom: 0;
    }
    
    .profile-label {
        font-weight: 600;
        color: #2c3e50;
        min-width: 373px;
        position: relative;
        padding-left: 25px;
    }
    
    .profile-label:before {
        content: '•';
        color: #e74c3c;
        position: absolute;
        left: 5px;
        font-size: 20px;
    }
    
    .profile-value {
        color: #7f8c8d;
        flex-grow: 1;
    }
    
    .btn {
        padding: 10px 20px;
        border-radius: 5px;
        cursor: pointer;
        font-weight: 500;
        transition: all 0.3s ease;
        text-decoration: none;
        display: inline-block;
        border: none;
    }
    
    .btn-back {
        background: #3498db;
        color: white;
    }
    
    .btn-back:hover {
        background: #2980b9;
        transform: translateY(-2px);
    }
    
    .btn-logout {
        background: #e74c3c;
        color: white;
    }
    
    .btn-logout:hover {
        background: #c0392b;
        transform: translateY(-2px);
    }
    
    .btn-change-password {
        background: #2ecc71;
        color: white;
    }
    
    .btn-change-password:hover {
        background: #27ae60;
        transform: translateY(-2px);
    }
    
    .btn-edit-profile {
        background: #f39c12;
        color: white;
    }
    
    .btn-edit-profile:hover {
        background: #e67e22;
        transform: translateY(-2px);
    }
    
    .btn-settings {
        background: #95a5a6;
        color: white;
        position: absolute;
        top: 20px;
        right: 20px;
        display: flex;
        align-items: center;
        padding: 10px 15px;
    }
    
    .btn-settings:hover {
        background: #7f8c8d;
        transform: translateY(-2px);
    }
    
    .settings-dropdown {
        display: none;
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: #333;
        border-radius: 10px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.5);
        min-width: 250px;
        z-index: 1000;
        padding: 10px;
        color: #fff;
    }
    
    .settings-dropdown.show {
        display: block;
    }
    
    .settings-dropdown-item {
        display: block;
        padding: 10px 15px;
        color: #fff;
        text-decoration: none;
        font-size: 0.9rem;
        cursor: pointer;
        transition: background 0.2s ease;
        background: none;
        border: none;
        width: 100%;
        text-align: left;
    }
    
    .settings-dropdown-item:hover {
        background: #555;
    }
    
    .modal {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.5);
        z-index: 1000;
        justify-content: center;
        align-items: center;
    }
    
    .modal-content {
        background: white;
        border-radius: 10px;
        padding: 25px;
        width: 90%;
        max-width: 500px;
        max-height: 80vh;
        overflow-y: auto;
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    }
    
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 1px solid #eee;
        position: sticky;
        top: 0;
        background: white;
        z-index: 1;
    }
    
    .modal-header h2 {
        color: #2c3e50;
        font-size: 1.5rem;
    }
    
    .close-btn {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: #7f8c8d;
    }
    
    .form-group {
        margin-bottom: 15px;
    }
    
    .form-group label {
        display: block;
        margin-bottom: 5px;
        color: #2c3e50;
        font-weight: 500;
    }
    
    .form-control {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 5px;
        font-size: 1rem;
    }
    
    .form-control:focus {
        outline: none;
        border-color: #3498db;
    }
    
    .error-message {
        color: #e74c3c;
        font-size: 0.9rem;
        margin-top: 5px;
        display: none;
    }
    
    .success-message {
        color: #2ecc71;
        font-size: 0.9rem;
        margin-top: 5px;
        display: none;
    }
    
    .show-password {
        display: flex;
        align-items: center;
        margin-top: 10px;
    }
    
    .show-password input {
        margin-right: 8px;
    }
    
    .modal-footer {
        display: flex;
        justify-content: space-between;
        margin-top: 20px;
        position: sticky;
        bottom: 0;
        background: white;
        padding-top: 10px;
        z-index: 1;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    
    @keyframes slideIn {
        from { 
            opacity: 0;
            transform: translateX(-20px);
        }
        to { 
            opacity: 1;
            transform: translateX(0);
        }
    }
    
    .profile-item:nth-child(1) { animation-delay: 0.1s; }
    .profile-item:nth-child(2) { animation-delay: 0.2s; }
    .profile-item:nth-child(3) { animation-delay: 0.3s; }
    .profile-item:nth-child(4) { animation-delay: 0.4s; }
    .profile-item:nth-child(5) { animation-delay: 0.5s; }
    .profile-item:nth-child(6) { animation-delay: 0.6s; }
    .profile-item:nth-child(7) { animation-delay: 0.7s; }
    .profile-item:nth-child(8) { animation-delay: 0.8s; }
</style>
</head>
<body>
    <div class="container">
        <button id="settingsBtn" class="btn btn-settings">
            <i class="fas fa-cog"></i> Settings
        </button>
        <div id="settingsDropdown" class="settings-dropdown">
            <a href="#" class="settings-dropdown-item" id="editProfileMenuItem">Edit Profile</a>
            <a href="#" class="settings-dropdown-item" id="changePasswordMenuItem">Change Password</a>
            <form action="LogoutServlet" method="post" style="display: inline;">
                <button type="submit" class="settings-dropdown-item btn-logout">Logout</button>
            </form>
            <a href="Dashboard.jsp" class="settings-dropdown-item btn-back">Back to Dashboard</a>
            <button class="settings-dropdown-item btn-cancel" id="cancelDropdownBtn">Cancel</button>
        </div>
        
        <h1>Company Profile</h1>
        
       <div class="profile-card">
    <%
    HttpSession sessionVar = request.getSession(false);
    if (sessionVar == null) {
        response.sendRedirect("login1.jsp");
        return;
    }
    
    String companyIdStr = (String) sessionVar.getAttribute("company_id");
    String email = (String) sessionVar.getAttribute("email");
    Integer companyId = null;

    System.out.println("All session attributes:");
    java.util.Enumeration<String> attrNames = sessionVar.getAttributeNames();
    while (attrNames.hasMoreElements()) {
        String name = attrNames.nextElement();
        System.out.println(name + ": " + sessionVar.getAttribute(name));
    }

    if (companyIdStr != null) {
        try {
            companyId = Integer.parseInt(companyIdStr);
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("login1.jsp");
            return;
        }
    } else {
        companyIdStr = request.getParameter("company_id");
        if (companyIdStr != null) {
            try {
                companyId = Integer.parseInt(companyIdStr);
                sessionVar.setAttribute("company_id", companyIdStr);
            } catch (NumberFormatException e) {
                e.printStackTrace();
                response.sendRedirect("login1.jsp");
                return;
            }
        } else {
            response.sendRedirect("login1.jsp");
            return;
        }
    }

    String companyName = "", fullName = "", companySize = "", phoneNumber = "", address = "", website = "", imgPath = "";
    try {
        String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection(url, user, pass);
             PreparedStatement ps = con.prepareStatement("SELECT * FROM company_registration1 WHERE company_id=?")) {
            
            ps.setInt(1, companyId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                imgPath = rs.getString("img");
                companyName = rs.getString("company_name") != null ? rs.getString("company_name") : "";
                fullName = rs.getString("full_name") != null ? rs.getString("full_name") : "";
                companySize = rs.getString("company_size");
                phoneNumber = rs.getString("phone_number");
                address = rs.getString("address");
                website = rs.getString("website");
    %>
                <div class="profile-image">
                    <% 
                        // Set default image if imgPath is null or empty
                        if (imgPath == null || imgPath.isEmpty()) {
                            imgPath = request.getContextPath() + "/images/default-profile.jpg";
                        } else {
                            // Ensure imgPath is relative to context root
                            imgPath = request.getContextPath() + "/" + imgPath;
                        }
                    %>
                    <img src="<%= StringEscapeUtils.escapeHtml4(imgPath) %>" alt="Profile Image" onerror="this.src='<%= request.getContextPath() + "/images/default-profile.jpg" %>';">
                </div>
                
                <div class="profile-item">
                    <span class="profile-label">Company Name</span>
                    <span class="profile-value"><%= StringEscapeUtils.escapeHtml4(companyName) %></span>
                </div>
                
                <div class="profile-item">
                    <span class="profile-label">Owner Name</span>
                    <span class="profile-value"><%= StringEscapeUtils.escapeHtml4(fullName) %></span>
                </div>
                
                <div class="profile-item">
                    <span class="profile-label">Email</span>
                    <span class="profile-value"><%= StringEscapeUtils.escapeHtml4(email != null ? email : rs.getString("email")) %></span>
                </div>
                
                <div class="profile-item">
                    <span class="profile-label">Company ID</span>
                    <span class="profile-value"><%= rs.getString("company_id") %></span>
                </div>
                
                <div class="profile-item">
                    <span class="profile-label">Company Size</span>
                    <span class="profile-value"><%= companySize != null ? StringEscapeUtils.escapeHtml4(companySize) : "Not specified" %></span>
                </div>
                
                <div class="profile-item">
                    <span class="profile-label">Phone Number</span>
                    <span class="profile-value"><%= phoneNumber != null ? StringEscapeUtils.escapeHtml4(phoneNumber) : "Not specified" %></span>
                </div>
                
                <div class="profile-item">
                    <span class="profile-label">Address</span>
                    <span class="profile-value"><%= address != null ? StringEscapeUtils.escapeHtml4(address) : "Not specified" %></span>
                </div>
                
                <div class="profile-item">
                    <span class="profile-label">Website</span>
                    <span class="profile-value"><%= website != null ? StringEscapeUtils.escapeHtml4(website) : "Not specified" %></span>
                </div>
                <div class="profile-item" style="border-bottom: none; padding-top: 20px; text-align: center;">
                    <a href="Dashboard.jsp" class="btn btn-back">Back</a>
                </div>
    <%
            } else {
    %>
                <div class="profile-item">
                    <span class="profile-value">No company data found</span>
                </div>
    <%
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    %>
        <div class="profile-item">
            <span class="profile-value" style="color: #e74c3c;">Error loading company data</span>
        </div>
    <%
    }
    %>
</div>
    </div>

    <!-- Edit Profile Modal -->
    <div id="editProfileModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Profile</h2>
                <button class="close-btn" id="closeEditModal">×</button>
            </div>
            <form id="editProfileForm" method="post" action="UpdateProfileServlet" enctype="multipart/form-data">
                <input type="hidden" name="company_id" value="<%= companyId %>">
                
                <div class="form-group">
                    <label for="fullName">Owner Name</label>
                    <input type="text" class="form-control" id="fullName" name="full_name" required maxlength="255">
                    <div id="fullNameError" class="error-message"></div>
                </div>
                
                <div class="form-group">
                    <label for="companyName">Company Name</label>
                    <input type="text" class="form-control" id="companyName" name="company_name" required maxlength="255">
                    <div id="companyNameError" class="error-message"></div>
                </div>
                
                <div class="form-group">
                    <label for="phoneNumber">Phone Number</label>
                    <input type="text" class="form-control" id="phoneNumber" name="phone_number" maxlength="20">
                    <div id="phoneNumberError" class="error-message"></div>
                </div>
                
                <div class="form-group">
                    <label for="companySize">Company Size</label>
                    <input type="text" class="form-control" id="companySize" name="company_size" maxlength="50">
                    <div id="companySizeError" class="error-message"></div>
                </div>
                
                <div class="form-group">
                    <label for="address">Address</label>
                    <input type="text" class="form-control" id="address" name="address" maxlength="255">
                    <div id="addressError" class="error-message"></div>
                </div>
                
                <div class="form-group">
                    <label for="website">Website</label>
                    <input type="text" class="form-control" id="website" name="website" maxlength="255">
                    <div id="websiteError" class="error-message"></div>
                </div>
                
                <div class="form-group">
                    <label for="profilePhoto">Update Profile Photo</label>
                    <input type="file" class="form-control" id="profilePhoto" name="profile_photo" accept="image/*">
                    <div id="profilePhotoError" class="error-message"></div>
                </div>
                
                <div id="editSuccessMessage" class="success-message"></div>
                
                <div class="modal-footer">
                    <button type="button" id="cancelEditBtn" class="btn btn-back">
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-edit-profile">
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Change Password Modal -->
    <div id="passwordModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Change Password</h2>
                <button class="close-btn" id="closeModal">×</button>
            </div>
            <form id="changePasswordForm" method="post" action="ChangePasswordServlet">
                <input type="hidden" name="company_id" value="<%= companyId %>">
                <input type="hidden" name="email" value="<%= StringEscapeUtils.escapeHtml4(email) %>">
                
                <div class="form-group">
                    <label for="oldPassword">Old Password</label>
                    <input type="password" class="form-control" id="oldPassword" name="oldPassword" required>
                    <div id="oldPasswordError" class="error-message"></div>
                </div>
                
                <div class="form-group">
                    <label for="newPassword">New Password</label>
                    <input type="password" class="form-control" id="newPassword" name="newPassword" required minlength="6">
                    <div id="newPasswordError" class="error-message"></div>
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword">Confirm New Password</label>
                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required minlength="6">
                    <div id="confirmPasswordError" class="error-message"></div>
                </div>
                
                <div class="show-password">
                    <input type="checkbox" id="showPasswords">
                    <label for="showPasswords">Show passwords</label>
                </div>
                
                <div id="successMessage" class="success-message"></div>
                
                <div class="modal-footer">
                    <button type="button" id="cancelBtn" class="btn btn-back">
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-change-password">
                        <i class="fas fa-save"></i> Change Password
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Escape function to prevent JavaScript syntax errors
        function escapeJavaScriptString(str) {
            if (!str) return '';
            return str.replace(/\\/g, '\\\\')
                     .replace(/'/g, "\\'")
                     .replace(/"/g, '\\"')
                     .replace(/\n/g, '\\n')
                     .replace(/\r/g, '\\r');
        }

        // Settings Dropdown functionality
        const settingsBtn = document.getElementById('settingsBtn');
        const settingsDropdown = document.getElementById('settingsDropdown');
        const editProfileMenuItem = document.getElementById('editProfileMenuItem');
        const changePasswordMenuItem = document.getElementById('changePasswordMenuItem');
        const cancelDropdownBtn = document.getElementById('cancelDropdownBtn');

        settingsBtn.addEventListener('click', (e) => {
            e.preventDefault();
            settingsDropdown.classList.toggle('show');
        });

        cancelDropdownBtn.addEventListener('click', (e) => {
            e.preventDefault();
            settingsDropdown.classList.remove('show');
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', (e) => {
            if (!settingsBtn.contains(e.target) && !settingsDropdown.contains(e.target)) {
                settingsDropdown.classList.remove('show');
            }
        });

        // Edit Profile Modal functionality
        const editProfileModal = document.getElementById('editProfileModal');
        const closeEditModalBtn = document.getElementById('closeEditModal');
        const cancelEditBtn = document.getElementById('cancelEditBtn');
        const editProfileForm = document.getElementById('editProfileForm');

        // Trigger edit profile modal from dropdown
        editProfileMenuItem.addEventListener('click', (e) => {
            e.preventDefault();
            editProfileModal.style.display = 'flex';
            document.getElementById('fullName').focus();
            settingsDropdown.classList.remove('show');

            // Populate form fields with current values, escaping special characters
            document.getElementById('fullName').value = escapeJavaScriptString('<%= fullName != null ? fullName.replace("\"", "\\\"") : "" %>');
            document.getElementById('companyName').value = escapeJavaScriptString('<%= companyName != null ? companyName.replace("\"", "\\\"") : "" %>');
            document.getElementById('companySize').value = escapeJavaScriptString('<%= companySize != null ? companySize.replace("\"", "\\\"") : "" %>');
            document.getElementById('phoneNumber').value = escapeJavaScriptString('<%= phoneNumber != null ? phoneNumber.replace("\"", "\\\"") : "" %>');
            document.getElementById('address').value = escapeJavaScriptString('<%= address != null ? address.replace("\"", "\\\"") : "" %>');
            document.getElementById('website').value = escapeJavaScriptString('<%= website != null ? website.replace("\"", "\\\"") : "" %>');
        });

        // Close edit profile modal
        function closeEditModal() {
            editProfileModal.style.display = 'none';
            editProfileForm.reset();
            document.querySelectorAll('.error-message').forEach(el => {
                el.style.display = 'none';
                el.textContent = '';
            });
            document.getElementById('editSuccessMessage').style.display = 'none';
            document.getElementById('editSuccessMessage').textContent = '';
        }

        closeEditModalBtn.addEventListener('click', closeEditModal);
        cancelEditBtn.addEventListener('click', closeEditModal);

        // Close edit modal when clicking outside
        editProfileModal.addEventListener('click', (e) => {
            if (e.target === editProfileModal) {
                closeEditModal();
            }
        });

        // Edit profile form submission
        editProfileForm.addEventListener('submit', function(e) {
            e.preventDefault();

            // Reset error messages
            document.querySelectorAll('.error-message').forEach(el => {
                el.style.display = 'none';
                el.textContent = '';
            });

            const fullName = document.getElementById('fullName').value.trim();
            const companyName = document.getElementById('companyName').value.trim();
            const phoneNumber = document.getElementById('phoneNumber').value.trim();
            const companySize = document.getElementById('companySize').value.trim();
            const address = document.getElementById('address').value.trim();
            const website = document.getElementById('website').value.trim();
            const profilePhoto = document.getElementById('profilePhoto').files[0];

            let isValid = true;

            // Validate full name
            if (!fullName) {
                document.getElementById('fullNameError').textContent = 'Owner name is required';
                document.getElementById('fullNameError').style.display = 'block';
                isValid = false;
            }

            // Validate company name
            if (!companyName) {
                document.getElementById('companyNameError').textContent = 'Company name is required';
                document.getElementById('companyNameError').style.display = 'block';
                isValid = false;
            }

            // Validate phone number format (basic validation)
            if (phoneNumber && !/^\+?\d{7,15}$/.test(phoneNumber)) {
                document.getElementById('phoneNumberError').textContent = 'Invalid phone number format';
                document.getElementById('phoneNumberError').style.display = 'block';
                isValid = false;
            }

            // Validate website format (basic validation)
            if (website && !/^(https?:\/\/)?([\w-]+\.)+[\w-]+(\/[\w- ./?%&=]*)?$/.test(website)) {
                document.getElementById('websiteError').textContent = 'Invalid website URL';
                document.getElementById('websiteError').style.display = 'block';
                isValid = false;
            }

            // Validate profile photo (optional, but if provided, ensure it's an image)
            if (profilePhoto && !profilePhoto.type.startsWith('image/')) {
                document.getElementById('profilePhotoError').textContent = 'Please upload a valid image file';
                document.getElementById('profilePhotoError').style.display = 'block';
                isValid = false;
            }

            if (isValid) {
                const formData = new FormData();
                formData.append('company_id', document.querySelector('input[name="company_id"]').value);
                formData.append('full_name', fullName);
                formData.append('company_name', companyName);
                formData.append('phone_number', phoneNumber);
                formData.append('company_size', companySize);
                formData.append('address', address);
                formData.append('website', website);
                if (profilePhoto) {
                    formData.append('profile_photo', profilePhoto);
                }

                fetch('UpdateProfileServlet', {
                    method: 'POST',
                    body: formData
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok: ' + response.statusText);
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Response from servlet:', data);
                    if (data.success) {
                        const successMessage = document.getElementById('editSuccessMessage');
                        successMessage.textContent = data.message || 'Profile updated successfully!';
                        successMessage.style.display = 'block';

                        // Redirect to Profile1.jsp after 2 seconds
                        setTimeout(() => {
                            window.location.href = 'profile1.jsp';
                        }, 2000);
                    } else {
                        const errorField = document.getElementById('fullNameError');
                        errorField.textContent = data.message || 'Failed to update profile. Please try again.';
                        errorField.style.display = 'block';
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    const errorField = document.getElementById('fullNameError');
                    errorField.textContent = 'An error occurred: ' + error.message;
                    errorField.style.display = 'block';
                });
            }
        });

        // Change Password Modal functionality
        const modal = document.getElementById('passwordModal');
        const closeModalBtn = document.getElementById('closeModal');
        const cancelBtn = document.getElementById('cancelBtn');
        const changePasswordForm = document.getElementById('changePasswordForm');
        const showPasswordsCheckbox = document.getElementById('showPasswords');
        const passwordFields = document.querySelectorAll('input[type="password"]');
        
        // Trigger change password modal from dropdown
        changePasswordMenuItem.addEventListener('click', (e) => {
            e.preventDefault();
            modal.style.display = 'flex';
            document.getElementById('oldPassword').focus();
            settingsDropdown.classList.remove('show');
        });
        
        function closeModal() {
            modal.style.display = 'none';
            changePasswordForm.reset();
            document.querySelectorAll('.error-message').forEach(el => {
                el.style.display = 'none';
                el.textContent = '';
            });
            document.getElementById('successMessage').style.display = 'none';
            document.getElementById('successMessage').textContent = '';
        }
        
        closeModalBtn.addEventListener('click', closeModal);
        cancelBtn.addEventListener('click', closeModal);
        
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                closeModal();
            }
        });
        
        showPasswordsCheckbox.addEventListener('change', () => {
            passwordFields.forEach(field => {
                field.type = showPasswordsCheckbox.checked ? 'text' : 'password';
            });
        });
        
        changePasswordForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            document.querySelectorAll('.error-message').forEach(el => {
                el.style.display = 'none';
                el.textContent = '';
            });
            
            const oldPassword = document.getElementById('oldPassword').value.trim();
            const newPassword = document.getElementById('newPassword').value.trim();
            const confirmPassword = document.getElementById('confirmPassword').value.trim();
            
            let isValid = true;
            
            if (!oldPassword) {
                document.getElementById('oldPasswordError').textContent = 'Old password is required';
                document.getElementById('oldPasswordError').style.display = 'block';
                isValid = false;
            }
            
            if (!newPassword) {
                document.getElementById('newPasswordError').textContent = 'New password is required';
                document.getElementById('newPasswordError').style.display = 'block';
                isValid = false;
            } else if (newPassword.length < 6) {
                document.getElementById('newPasswordError').textContent = 'Password must be at least 6 characters';
                document.getElementById('newPasswordError').style.display = 'block';
                isValid = false;
            } else if (newPassword === oldPassword) {
                document.getElementById('newPasswordError').textContent = 'New password must be different from old password';
                document.getElementById('newPasswordError').style.display = 'block';
                isValid = false;
            }
            
            if (!confirmPassword) {
                document.getElementById('confirmPasswordError').textContent = 'Please confirm your new password';
                document.getElementById('confirmPasswordError').style.display = 'block';
                isValid = false;
            } else if (newPassword !== confirmPassword) {
                document.getElementById('confirmPasswordError').textContent = 'Passwords do not match';
                document.getElementById('confirmPasswordError').style.display = 'block';
                isValid = false;
            }
            
            if (isValid) {
                const formData = new URLSearchParams();
                formData.append('company_id', document.querySelector('input[name="company_id"]').value);
                formData.append('email', document.querySelector('input[name="email"]').value);
                formData.append('oldPassword', oldPassword);
                formData.append('newPassword', newPassword);
                formData.append('confirmPassword', confirmPassword);
                
                fetch('ChangePasswordServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: formData
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok: ' + response.statusText);
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Response from servlet:', data);
                    if (data.success) {
                        const successMessage = document.getElementById('successMessage');
                        successMessage.textContent = data.message || 'Password changed successfully!';
                        successMessage.style.display = 'block';
                        
                        setTimeout(() => {
                            closeModal();
                        }, 2000);
                    } else {
                        const errorField = document.getElementById('oldPasswordError');
                        errorField.textContent = data.message || 'Failed to change password. Please try again.';
                        errorField.style.display = 'block';
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    const errorField = document.getElementById('oldPasswordError');
                    errorField.textContent = 'An error occurred: ' + error.message;
                    errorField.style.display = 'block';
                });
            }
        });
    </script>
</body>
</html>