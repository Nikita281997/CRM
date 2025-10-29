<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%-- Small HTML-escape helper to avoid XSS --%>
<%! 
    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contacts</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* ... (kept your CSS unchanged for brevity) ... */
        /* Paste the CSS content from your original file here */
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
            --sidebar-width: 240px;
            --transition: all 0.3s ease;
        }
        * { margin:0; padding:0; box-sizing:border-box; font-family:'Poppins',sans-serif; }
        body { background:#f5f7fa; color:var(--dark); min-height:100vh; display:flex; flex-direction:column; }
        /* ... include all other CSS rules from original file ... */
        /* For final use, copy all CSS blocks from your original file into this style section */
    </style>
</head>
<body>
<%
    // Robust retrieval of company_id from session (handles Integer or String)
    HttpSession sessionVar = request.getSession(false);
    Integer companyId = null;
    if (sessionVar != null) {
        Object companyObj = sessionVar.getAttribute("company_id");
        if (companyObj instanceof Integer) {
            companyId = (Integer) companyObj;
        } else if (companyObj instanceof String) {
            try {
                companyId = Integer.parseInt((String) companyObj);
            } catch (NumberFormatException e) {
                // leave companyId null
            }
        }
    }
    if (companyId == null) {
        response.sendRedirect("login1.jsp");
        return;
    }
%>

<div class="container">
    <!-- Sidebar -->
    <div class="sidebar">
        <button class="sidebar-close" id="sidebarClose">×</button>
        <img src="<%= request.getContextPath() %>/images/TARS.jpg" alt="Tars Logo" class="logo"
             onerror="console.error('Failed to load logo'); this.src='https://via.placeholder.com/150?text=Logo+Not+Found';">
        <div class="page-title">Contacts</div>
        <div class="sidebar-menu">
            <ul>
                <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="leads.jsp"><i class="fas fa-users"></i> Leads</a></li>
                <li><a href="leadmanagement.jsp"><i class="fas fa-tasks"></i> Lead Management</a></li>
                <li><a href="projects.jsp"><i class="fas fa-project-diagram"></i> Projects</a></li>
                <li><a href="quotes.jsp"><i class="fas fa-file-invoice-dollar"></i> Quotes</a></li>
                <li><a href="financemanagement.jsp"><i class="fas fa-money-bill-wave"></i> Finance Management</a></li>
                <li class="active"><a href="#"><i class="fas fa-address-book"></i> Contacts</a></li>
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
            // Load profile info using try-with-resources to ensure proper closing
            String fullName = "User";
            String imgPath = request.getContextPath() + "/images/default-profile.jpg";
            // DB connection values - consider moving to a config file or environment variables
            String jdbcUrl = "jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb";
            String dbUser = "atharva";
            String dbPass = "AVNS_SFoivcl39tz_B7wqssI";
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String query = "SELECT full_name, img FROM company_registration1 WHERE company_id = ?";
                try (Connection conNav = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
                     PreparedStatement pstmtNav = conNav.prepareStatement(query)) {
                    pstmtNav.setInt(1, companyId);
                    try (ResultSet rsNav = pstmtNav.executeQuery()) {
                        if (rsNav.next()) {
                            String fn = rsNav.getString("full_name");
                            String ip = rsNav.getString("img");
                            if (fn != null && !fn.trim().isEmpty()) fullName = fn;
                            if (ip != null && !ip.trim().isEmpty()) {
                                // if stored path is relative, prepend context path
                                imgPath = ip.startsWith("http") ? ip : (request.getContextPath() + "/" + ip);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                // Log server-side; do not expose stacktrace to user page
                log("Error loading profile: " + e.getMessage(), e);
            }
        %>

        <div class="profile" onclick="window.location.href='profile1.jsp'">
            <img src="<%= imgPath %>" alt="User Profile">
            <span><%= escapeHtml(fullName) %></span>
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

        <div class="table-container slide-up">
            <div class="scroll-container">
                <table>
                    <thead>
                        <tr>
                            <th>Lead Id</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Address</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // Fetch contacts for logged-in company with safe resource handling
                            String contactsQuery =
                                "SELECT DISTINCT leads.lead_id, leads.customer_name, leads.email, leads.contact, leads.address " +
                                "FROM leads " +
                                "JOIN project ON leads.lead_id = project.lead_id " + // keep JOIN if you only want leads with projects
                                "WHERE leads.company_id = ?";
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                try (Connection conTable = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
                                     PreparedStatement ps = conTable.prepareStatement(contactsQuery)) {
                                    ps.setInt(1, companyId);
                                    try (ResultSet rsTable = ps.executeQuery()) {
                                        // Use a HashSet to prevent duplicate rendering (defensive)
                                        HashSet<Integer> displaySet = new HashSet<>();
                                        while (rsTable.next()) {
                                            int leadId = rsTable.getInt("lead_id");
                                            if (displaySet.contains(leadId)) continue;
                                            displaySet.add(leadId);

                                            String custName = rsTable.getString("customer_name");
                                            String email = rsTable.getString("email");
                                            String contact = rsTable.getString("contact");
                                            String address = rsTable.getString("address");
                        %>
                        <tr>
                            <td><%= leadId %></td>
                            <td><%= escapeHtml(custName) %></td>
                            <td><%= escapeHtml(email) %></td>
                            <td><%= escapeHtml(contact) %></td>
                            <td class="long-text"><%= escapeHtml(address) %></td>
                            <td>
                                <div class="action-buttons-container">
                                    <form action="composeEmail.jsp" method="get" style="display: inline;">
                                        <input type="hidden" name="recipient" value="<%= escapeHtml(email) %>">
                                        <button type="submit" class="action-btn bill">
                                            <i class="fas fa-envelope"></i> Email
                                        </button>
                                    </form>

                                    <form action="sendMeetingLink" method="post" style="display: inline;">
                                        <input type="hidden" name="email" value="<%= escapeHtml(email) %>">
                                        <button type="submit" class="action-btn delete">
                                            <i class="fas fa-video"></i> Video Call
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%
                                        } // end while
                                    }
                                }
                            } catch (Exception e) {
                                // Log server side and show friendly error row
                                log("Error loading contacts: " + e.getMessage(), e);
                                out.println("<tr><td colspan='6' class='error-message'>Error loading data. Please check server logs.</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Delete Contact Modal -->
<div class="modal" id="deletedata">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Delete Contact</h2>
            <button class="close-btn" onclick="closedelete()">×</button>
        </div>
        <form action="deletecontctservlet" method="post">
            <div class="form-group">
                <label for="contactid">Contact ID</label>
                <input type="text" id="contactid" name="contactid" class="form-control" placeholder="Enter contact ID to delete" required>
            </div>
            <button type="submit" class="btn btn-danger" style="width: 100%;">
                <i class="fas fa-trash"></i> Delete Contact
            </button>
        </form>
    </div>
</div>

<!-- Video Call Modal -->
<div class="modal" id="videoCallModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Video Call</h2>
            <button class="close-btn" onclick="closeVideoCallModal()">×</button>
        </div>
        <div class="video-container">
            <div class="video-wrapper">
                <video id="localVideo" autoplay muted playsinline></video>
            </div>
            <div class="video-wrapper">
                <video id="remoteVideo" autoplay playsinline></video>
            </div>
        </div>
        <button class="btn btn-danger" onclick="endCall()" style="margin-top: 15px; width: 100%;">
            <i class="fas fa-phone-slash"></i> End Call
        </button>
    </div>
</div>

<!-- Success/Error Modal -->
<div class="modal" id="popupModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Notification</h2>
            <button class="close-btn" onclick="closePopup()">×</button>
        </div>
        <h3 id="popupMessage">Video call link sent successfully!</h3>
        <button class="btn btn-primary" onclick="closePopup()" style="width: 100%;">OK</button>
    </div>
</div>

<!-- Meeting Modal -->
<div class="modal" id="meetingModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Schedule a Meeting</h2>
            <button class="close-btn" onclick="closeMeetingModal()">×</button>
        </div>
        <form action="ScheduleMeetingServlet" method="post">
            <input type="hidden" name="lead_id" id="meetingLeadId">
            <div class="form-group">
                <label for="meeting_date">Meeting Date</label>
                <input type="date" id="meeting_date" name="meeting_date" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="meeting_time">Meeting Time</label>
                <input type="time" id="meeting_time" name="meeting_time" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%;">
                <i class="fas fa-calendar-alt"></i> Schedule Meeting
            </button>
        </form>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    const sidebar = document.querySelector('.sidebar');
    const menuToggle = document.getElementById('menuToggle');
    const sidebarClose = document.getElementById('sidebarClose');
    const dmodal = document.getElementById('deletedata');
    const videoModal = document.getElementById('videoCallModal');
    const localVideo = document.getElementById('localVideo');
    const remoteVideo = document.getElementById('remoteVideo');
    let localStream = null;
    let peerConnection = null;

    // Toggle sidebar on mobile
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

    // Close sidebar when clicking outside on mobile
    document.addEventListener('click', (e) => {
        if (window.innerWidth <= 768 && sidebar && !sidebar.contains(e.target) && menuToggle && !menuToggle.contains(e.target)) {
            sidebar.classList.remove('active');
        }
    });

    // Modal Functions
    function opendelete() {
        if (dmodal) dmodal.classList.add('active');
    }

    function closedelete() {
        if (dmodal) dmodal.classList.remove('active');
    }

    function openMeetingModal(leadId) {
        const meetingLeadId = document.getElementById("meetingLeadId");
        if (meetingLeadId) meetingLeadId.value = leadId;
        const mm = document.getElementById("meetingModal");
        if (mm) mm.classList.add('active');
    }

    function closeMeetingModal() {
        const mm = document.getElementById("meetingModal");
        if (mm) mm.classList.remove('active');
    }

    function openPopup(message) {
        const popup = document.getElementById('popupModal');
        const popupMessage = document.getElementById('popupMessage');
        if (popupMessage) popupMessage.innerText = message;
        if (popup) popup.classList.add('active');
    }

    function closePopup() {
        const popup = document.getElementById('popupModal');
        if (popup) popup.classList.remove('active');
    }

    // Video Call Functions
    function startMeeting(contactEmail) {
        if (!videoModal) return;
        videoModal.classList.add('active');
        startWebRTC(contactEmail);
    }

    function closeVideoCallModal() {
        if (!videoModal) return;
        videoModal.classList.remove('active');
        if (localStream) {
            localStream.getTracks().forEach(track => track.stop());
            localStream = null;
        }
        if (peerConnection) {
            try { peerConnection.close(); } catch (e) {}
            peerConnection = null;
        }
        if (localVideo) localVideo.srcObject = null;
        if (remoteVideo) remoteVideo.srcObject = null;
    }

    function endCall() {
        closeVideoCallModal();
    }

    function startWebRTC(contactEmail) {
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            console.warn('Media devices not supported.');
            return;
        }
        navigator.mediaDevices.getUserMedia({ video: true, audio: true })
        .then(stream => {
            if (localVideo) localVideo.srcObject = stream;
            localStream = stream;
            peerConnection = new RTCPeerConnection();

            localStream.getTracks().forEach(track => peerConnection.addTrack(track, localStream));

            peerConnection.ontrack = event => {
                if (remoteVideo) remoteVideo.srcObject = event.streams[0];
            };

            // NOTE: This is placeholder signalling behaviour.
            // Real implementation must exchange SDP/ICE through the websocket signaling server.
            if (socket && socket.readyState === WebSocket.OPEN) {
                socket.send(JSON.stringify({ type: 'startCall', target: contactEmail }));
            }
        })
        .catch(error => console.log('Error accessing media devices:', error));
    }

    // Dynamic WebSocket URL (works with http/https and real host)
    const wsProtocol = (location.protocol === 'https:') ? 'wss:' : 'ws:';
    const socketUrl = wsProtocol + '//' + location.host + '<%= request.getContextPath() %>' + '/video-call';
    let socket = null;
    try {
        socket = new WebSocket(socketUrl);
        socket.onopen = () => console.log('WebSocket connected to', socketUrl);
        socket.onmessage = event => {
            try {
                const message = JSON.parse(event.data);
                if (message.type === 'startCall') {
                    // your app may want to handle signalling differently
                    startWebRTC(message.target);
                }
                // handle other signaling message types (offer/answer/ice) here
            } catch (e) {
                console.warn('Invalid websocket message', e);
            }
        };
        socket.onclose = () => console.log('WebSocket closed');
        socket.onerror = (err) => console.warn('WebSocket error', err);
    } catch (e) {
        console.warn('WebSocket initialization failed:', e);
    }

    // Modal click-outside-to-close (defensive checks)
    if (dmodal) {
        dmodal.addEventListener('click', function(event) {
            if (event.target === dmodal) {
                closedelete();
            }
        });
    }

    const meetingModalEl = document.getElementById('meetingModal');
    if (meetingModalEl) {
        meetingModalEl.addEventListener('click', function(event) {
            if (event.target === meetingModalEl) {
                closeMeetingModal();
            }
        });
    }

    const popupModalEl = document.getElementById('popupModal');
    if (popupModalEl) {
        popupModalEl.addEventListener('click', function(event) {
            if (event.target === popupModalEl) {
                closePopup();
            }
        });
    }

    if (videoModal) {
        videoModal.addEventListener('click', function(event) {
            if (event.target === videoModal) {
                closeVideoCallModal();
            }
        });
    }

    // Close modals on Escape key
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            if (dmodal && dmodal.classList.contains('active')) closedelete();
            if (meetingModalEl && meetingModalEl.classList.contains('active')) closeMeetingModal();
            if (popupModalEl && popupModalEl.classList.contains('active')) closePopup();
            if (videoModal && videoModal.classList.contains('active')) closeVideoCallModal();
        }
    });

    // Auto-scroll sidebar to center the active item
    window.addEventListener('load', function() {
        const activeItem = document.querySelector('.sidebar-menu li.active');
        const sidebarMenu = document.querySelector('.sidebar-menu');
        if (activeItem && sidebarMenu) {
            const itemRect = activeItem.getBoundingClientRect();
            const menuRect = sidebarMenu.getBoundingClientRect();
            const offset = itemRect.top - menuRect.top - (menuRect.height / 2) + (itemRect.height / 2);
            sidebarMenu.scrollTop += offset;
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
