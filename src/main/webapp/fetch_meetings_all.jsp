<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendar - CRMSPOT</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.js"></script>
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
            --sidebar-width: 240px;
            --transition: all 0.3s ease;
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
            width: var(--sidebar-width);
            background: var(--sidebar-bg);
            color: var(--text-color);
            padding: 20px;
            position: fixed;
            height: 100vh;
            transition: var(--transition);
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
            transition: var(--transition);
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

        .content {
            flex: 1;
            margin-left: var(--sidebar-width);
            padding: 20px;
            transition: margin-left 0.3s ease;
        }

        .navbar {
            background: transparent;
            padding: 15px 25px;
            display: flex;
            justify-content: flex-start;
            align-items: center;
            margin-bottom: 25px;
        }

        .calendar-section {
       
    margin-top: -47px;
            background: var(--card-bg);
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            padding: 20px;
            transition: var(--transition);
        }

        .calendar-section:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        #calendar {
            max-width: 100%;
            margin: 0 auto;
        }

        .create-event-btn {
            background: var(--accent);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 500;
            margin-bottom: 20px;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
        }

        .create-event-btn i {
            margin-right: 8px;
        }

        .create-event-btn:hover {
            background: #00b0a3;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 2000;
            justify-content: center;
            align-items: center;
            opacity: 0;
            visibility: hidden;
            transition: var(--transition);
        }

        .modal.active {
            display: flex;
            opacity: 1;
            visibility: visible;
        }

        .modal-content {
            background: var(--card-bg);
            border-radius: 10px;
            width: 90%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 5px 30px rgba(0,0,0,0.2);
            transform: translateY(-20px);
            transition: var(--transition);
            padding: 20px;
            position: relative;
        }

        .modal.active .modal-content {
            transform: translateY(0);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }

        .modal-header h3 {
            margin: 0;
            font-size: 1.5rem;
            color: var(--text-color);
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #6b7280;
            transition: var(--transition);
        }

        .modal-close:hover {
            color: var(--accent);
        }

        .modal-body {
            max-height: 60vh;
            overflow-y: auto;
        }

        .modal-body label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: var(--text-color);
        }

        .modal-body input,
        .modal-body textarea {
            width: 100%;
            padding: 10px 15px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
            transition: var(--transition);
        }

        .modal-body input:focus,
        .modal-body textarea:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(0, 196, 180, 0.1);
            outline: none;
        }

        .modal-body textarea {
            height: 100px;
            resize: vertical;
        }

        .modal-footer {
            border-top: 1px solid #eee;
            padding-top: 10px;
            text-align: right;
        }

        .btn {
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 500;
            transition: var(--transition);
        }

        .btn-primary {
            background: var(--accent);
            color: white;
            border: none;
        }

        .btn-primary:hover {
            background: #00b0a3;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn-outline {
            background: none;
            border: 1px solid var(--text-color);
            color: var(--text-color);
        }

        .btn-outline:hover {
            background: #f1f1f1;
            transform: translateY(-2px);
        }

        .meeting-details-modal {
            max-width: 600px;
        }

        .meeting-details-modal .modal-header {
            background: linear-gradient(135deg, var(--accent), #00b0a3);
            color: white;
            padding: 15px 20px;
            border-radius: 10px 10px 0 0;
            margin: -20px -20px 20px -20px;
        }

        .meeting-details-modal .modal-header h3 {
            color: white;
        }

        .meeting-details-modal .modal-close {
            color: white;
        }

        .meeting-details-modal .modal-close:hover {
            color: #f8f9fa;
        }

        .meeting-details-content {
            display: grid;
            gap: 15px;
        }

        .meeting-details-content .detail-item {
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }

        .meeting-details-content .detail-item i {
            color: var(--accent);
            font-size: 1.2rem;
            margin-top: 3px;
        }

        .meeting-details-content .detail-item div {
            flex: 1;
        }

        .meeting-details-content .detail-item strong {
            color: var(--text-color);
            font-weight: 500;
            display: block;
            margin-bottom: 5px;
        }

        .meeting-details-content .detail-item span {
            color: var(--dark);
            font-size: 0.95rem;
            line-height: 1.4;
            word-wrap: break-word;
        }

        .meeting-details-modal .modal-footer {
            text-align: center;
            border-top: none;
            padding-top: 0;
        }

        .meeting-details-modal .modal-footer .btn {
            margin: 0 5px;
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

        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-100%);
                width: var(--sidebar-width);
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

            .navbar {
                flex-direction: column;
                align-items: flex-start;
            }
        }

        @media (max-width: 768px) {
            .calendar-section {
                padding: 15px;
            }

            .meeting-details-modal {
                max-width: 90%;
            }
        }

        .fade-in {
            animation: fadeIn 0.3s ease-out;
        }

        .slide-up {
            animation: slideUp 0.3s ease-out;
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
    <div class="container">
        <div class="sidebar">
            <button class="sidebar-close" id="sidebarClose">×</button>
            <img src="${pageContext.request.contextPath}/images/TARS.jpg" alt="Tars Logo" class="logo" 
                 onerror="console.error('Failed to load logo'); this.src='https://via.placeholder.com/150?text=Logo+Not+Found';">
            <div class="page-title">Calendar</div>
            <div class="sidebar-menu">
                <ul>
                    <li><a href="Dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
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
                    <li class="active"><a href="fetch_meetings_all.jsp"><i class="fas fa-calendar-alt"></i> Calendar</a></li>
                   
                </ul>
            </div>
            <%
                Connection conNav = null;
                PreparedStatement pstmtNav = null;
                ResultSet rsNav = null;
                String fullName = "User";
                String imgPath = "https://via.placeholder.com/40";

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conNav = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

                    String companyIdStrNav = (String) session.getAttribute("company_id");
                    Integer companyIdNav = null;

                    if (companyIdStrNav == null || companyIdStrNav.trim().isEmpty()) {
                        response.sendRedirect("login1.jsp");
                        return;
                    }

                    try {
                        companyIdNav = Integer.parseInt(companyIdStrNav);
                    } catch (NumberFormatException e) {
                        response.sendRedirect("login1.jsp");
                        return;
                    }

                    String query = "SELECT full_name, img FROM company_registration1 WHERE company_id = ?";
                    pstmtNav = conNav.prepareStatement(query);
                    pstmtNav.setInt(1, companyIdNav);
                    rsNav = pstmtNav.executeQuery();

                    if (rsNav.next()) {
                        fullName = rsNav.getString("full_name");
                        imgPath = rsNav.getString("img");
                        if (imgPath == null || imgPath.isEmpty()) {
                            imgPath = "images/default-profile.jpg";
                        }

                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rsNav != null) try { rsNav.close(); } catch (SQLException e) {}
                    if (pstmtNav != null) try { pstmtNav.close(); } catch (SQLException e) {}
                    if (conNav != null) try { conNav.close(); } catch (SQLException e) {}
                }
            %>
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
            </div>
            
            <div class="calendar-section slide-up">
                <button class="create-event-btn" id="createEventBtn">
                    <i class="fas fa-plus"></i> Create Event
                </button>
                <div id="calendar"></div>
            </div>

            <!-- Create Event Modal -->
            <div id="eventModal" class="modal">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3>Create Event</h3>
                        <button class="modal-close btn btn-outline">×</button>
                    </div>
                    <div class="modal-body">
                        <form id="eventForm">
                            <label for="eventName">Event Name</label>
                            <input type="text" id="eventName" name="event_name" placeholder="Enter event name">

                            <label for="description">Description</label>
                            <textarea id="description" name="description" placeholder="Enter description"></textarea>

                            <label for="startDate">Start Date</label>
                            <input type="date" id="startDate" name="start_date" value="2025-06-26">

                            <label for="endDate">End Date</label>
                            <input type="date" id="endDate" name="end_date" value="2025-06-26">

                            <label for="startTime">Start Time</label>
                            <input type="time" id="startTime" name="start_time" value="13:52">

                            <label for="endTime">End Time</label>
                            <input type="time" id="endTime" name="end_time" value="14:52">

                            <label for="location">Location</label>
                            <input type="text" id="location" name="location" placeholder="Enter location">
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-outline modal-close">Cancel</button>
                        <button class="btn btn-primary" id="saveEventBtn">Save Event</button>
                    </div>
                </div>
            </div>

            <!-- Edit Event Modal -->
            <div id="editEventModal" class="modal">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3>Edit Event</h3>
                        <button class="modal-close btn btn-outline">×</button>
                    </div>
                    <div class="modal-body">
                        <form id="editEventForm">
                            <input type="hidden" id="editEventId" name="event_id">
                            <label for="editEventName">Event Name</label>
                            <input type="text" id="editEventName" name="event_name" placeholder="Enter event name">

                            <label for="editDescription">Description</label>
                            <textarea id="editDescription" name="description" placeholder="Enter description"></textarea>

                            <label for="editStartDate">Start Date</label>
                            <input type="date" id="editStartDate" name="start_date">

                            <label for="editEndDate">End Date</label>
                            <input type="date" id="editEndDate" name="end_date">

                            <label for="editStartTime">Start Time</label>
                            <input type="time" id="editStartTime" name="start_time">

                            <label for="editEndTime">End Time</label>
                            <input type="time" id="editEndTime" name="end_time">

                            <label for="editLocation">Location</label>
                            <input type="text" id="editLocation" name="location" placeholder="Enter location">
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-outline modal-close">Cancel</button>
                        <button class="btn btn-primary" id="updateEventBtn">Update Event</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%
        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        ArrayList<Map<String, String>> events = new ArrayList<>();

        try {
            HttpSession sessionVar = request.getSession();
            String companyIdStr = (String) sessionVar.getAttribute("company_id");
            Integer companyId = null;

            if (companyIdStr != null) {
                companyId = Integer.parseInt(companyIdStr);
            }

            if (companyId == null) {
                response.sendRedirect("login1.jsp");
                return;
            }

            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb", "atharva", "AVNS_SFoivcl39tz_B7wqssI");

            String query = "SELECT event_id, company_id, event_name, description, start_date, end_date, start_time, end_time, location, created_at " +
                          "FROM new_calendar_events " +
                          "WHERE company_id = ?";
            pst = con.prepareStatement(query);
            pst.setInt(1, companyId);
            rs = pst.executeQuery();

            while (rs.next()) {
                Map<String, String> event = new HashMap<>();
                event.put("event_id", rs.getString("event_id"));
                event.put("event_name", rs.getString("event_name"));
                event.put("description", rs.getString("description"));
                event.put("start_date", rs.getString("start_date"));
                event.put("end_date", rs.getString("end_date"));
                event.put("start_time", rs.getString("start_time"));
                event.put("end_time", rs.getString("end_time"));
                event.put("location", rs.getString("location"));
                event.put("created_at", rs.getString("created_at"));
                events.add(event);
            }

        } catch (Exception e) {
            out.println("<div class='error'>Error: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pst != null) try { pst.close(); } catch (SQLException e) {}
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }
    %>

    <script>
        const sidebar = document.querySelector('.sidebar');
        const menuToggle = document.getElementById('menuToggle');
        const sidebarClose = document.getElementById('sidebarClose');
        const eventModal = document.getElementById('eventModal');
        const editEventModal = document.getElementById('editEventModal');
        const createEventBtn = document.getElementById('createEventBtn');
        const saveEventBtn = document.getElementById('saveEventBtn');
        const updateEventBtn = document.getElementById('updateEventBtn');
        const modalCloseBtns = document.querySelectorAll('.modal-close');

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
            if (window.innerWidth <= 992 && !sidebar.contains(e.target) && !menuToggle.contains(e.target)) {
                sidebar.classList.remove('active');
            }
        });

        // Modal Controls
        createEventBtn.addEventListener('click', () => {
            eventModal.classList.add('active');
        });

        modalCloseBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                eventModal.classList.remove('active');
                editEventModal.classList.remove('active');
                document.getElementById('eventForm').reset();
                document.getElementById('editEventForm').reset();
            });
        });

        [eventModal, editEventModal].forEach(modal => {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.classList.remove('active');
                    if (modal === eventModal) document.getElementById('eventForm').reset();
                    if (modal === editEventModal) document.getElementById('editEventForm').reset();
                }
            });
        });

        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                if (eventModal.classList.contains('active')) {
                    eventModal.classList.remove('active');
                    document.getElementById('eventForm').reset();
                }
                if (editEventModal.classList.contains('active')) {
                    editEventModal.classList.remove('active');
                    document.getElementById('editEventForm').reset();
                }
            }
        });

        let calendar;
        document.addEventListener('DOMContentLoaded', function() {
            const calendarEl = document.getElementById('calendar');
            calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
                },
                slotLabelFormat: {
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: false
                },
                eventTimeFormat: {
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: false
                },
                timeZone: 'Asia/Kolkata',
                events: [
                    <% 
                        for (Map<String, String> event : events) { 
                            String eventId = event.get("event_id");
                            String eventName = event.get("event_name");
                            String startDate = event.get("start_date");
                            String startTime = event.get("start_time");
                            String endDate = event.get("end_date");
                            String endTime = event.get("end_time");
                            String location = event.get("location");
                            String description = event.get("description");
                            if (startDate != null) {
                                String startDateTime = startDate;
                                if (startTime != null) {
                                    startDateTime += "T" + startTime;
                                }
                                String endDateTime = null;
                                if (endDate != null) {
                                    endDateTime = endDate;
                                    if (endTime != null) {
                                        endDateTime += "T" + endTime;
                                    }
                                }
                                String title = eventName != null ? eventName : "Untitled Event";
                    %>
                        {
                            id: '<%= eventId %>',
                            title: '<%= title %>',
                            start: '<%= startDateTime %>',
                            <% if (endDateTime != null) { %>
                            end: '<%= endDateTime %>',
                            <% } %>
                            extendedProps: {
                                description: '<%= description != null ? description : "" %>',
                                location: '<%= location != null ? location : "" %>',
                                created_at: '<%= event.get("created_at") != null ? event.get("created_at") : "" %>'
                            },
                            backgroundColor: getRandomColor(),
                            borderColor: getRandomColor()
                        },
                    <% 
                            }
                        } 
                    %>
                ],
                dateClick: function(info) {
                    const clickedDate = info.dateStr.split('T')[0];
                    const eventsOnDate = calendar.getEvents().filter(event => {
                        const eventDate = event.start.toISOString().split('T')[0];
                        return eventDate === clickedDate;
                    });

                    if (eventsOnDate.length > 0) {
                        const event = eventsOnDate[0];
                        document.getElementById('editEventId').value = event.id || '';
                        document.getElementById('editEventName').value = event.title || '';
                        document.getElementById('editDescription').value = event.extendedProps.description || '';
                        document.getElementById('editStartDate').value = event.start.toISOString().split('T')[0];
                        document.getElementById('editEndDate').value = event.end ? event.end.toISOString().split('T')[0] : '';
                        document.getElementById('editStartTime').value = event.start.toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }).slice(0, 5) || '';
                        document.getElementById('editEndTime').value = event.end ? event.end.toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }).slice(0, 5) : '';
                        document.getElementById('editLocation').value = event.extendedProps.location || '';
                        editEventModal.classList.add('active');
                    } else {
                        eventModal.classList.add('active');
                        document.getElementById('startDate').value = clickedDate;
                        document.getElementById('endDate').value = clickedDate;
                    }
                },
                eventClick: function(info) {
                    const event = info.event;
                    document.getElementById('editEventId').value = event.id || '';
                    document.getElementById('editEventName').value = event.title || '';
                    document.getElementById('editDescription').value = event.extendedProps.description || '';
                    document.getElementById('editStartDate').value = event.start.toISOString().split('T')[0];
                    document.getElementById('editEndDate').value = event.end ? event.end.toISOString().split('T')[0] : '';
                    document.getElementById('editStartTime').value = event.start.toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }).slice(0, 5) || '';
                    document.getElementById('editEndTime').value = event.end ? event.end.toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }).slice(0, 5) : '';
                    document.getElementById('editLocation').value = event.extendedProps.location || '';
                    editEventModal.classList.add('active');
                }
            });
            calendar.render();
        });

        saveEventBtn.addEventListener('click', () => {
            const formData = new FormData(document.getElementById('eventForm'));
            const data = {};
            formData.forEach((value, key) => {
                if (value.trim() !== '') {
                    data[key] = value;
                }
            });

            fetch('save_event.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.statusText);
                }
                return response.json();
            })
            .then(result => {
                if (result.success) {
                    eventModal.classList.remove('active');
                    document.getElementById('eventForm').reset();
                    window.location.reload();
                } else {
                    alert('Error saving event: ' + result.error);
                }
            })
            .catch(error => {
                console.error('Error saving event:', error);
                alert('Error saving event: ' + error.message);
            });
        });

        updateEventBtn.addEventListener('click', () => {
            const formData = new FormData(document.getElementById('editEventForm'));
            const data = {};
            formData.forEach((value, key) => {
                if (value.trim() !== '') {
                    data[key] = value;
                }
            });
            // Ensure event_id is included even if empty for debugging
            data['event_id'] = document.getElementById('editEventId').value || '';

            fetch('UpdateEventServletNew', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.statusText);
                }
                return response.json();
            })
            .then(result => {
                if (result.success) {
                    editEventModal.classList.remove('active');
                    document.getElementById('editEventForm').reset();
                    window.location.reload();
                } else {
                    alert('Error updating event: ' + result.error);
                }
            })
            .catch(error => {
                console.error('Error updating event:', error);
                alert('Error updating event: ' + error.message);
            });
        });

        function getRandomColor() {
            const colors = [
                '#6f42c1',
                '#ff851b',
                '#ffcd56',
                '#28a745',
                '#00c4b4'
            ];
            return colors[Math.floor(Math.random() * colors.length)];
        }

        // Auto-scroll sidebar to bottom on load
        window.onload = function() {
            const sidebarMenu = document.querySelector('.sidebar-menu');
            if (sidebarMenu) {
                sidebarMenu.scrollTop = sidebarMenu.scrollHeight;
            }
        };
    </script>
</body>
</html>