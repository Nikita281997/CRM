<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>


<!DOCTYPE html>
<html lang="en">
<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRM Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        /* Main Layout */
        .container {
            display: flex;
            min-height: 100vh;
            background: #f8f9fa;
        }
        .sidebar {
            width: 240px;
            background: #0c022d;
            color: #fff;
            padding: 20px;
            height: 100vh;
            width: 15%;
        }

        .sidebar h2 span {
            color: #ff2e63;
        }

        .sidebar ul {
            list-style: none;
            padding: 0;
        }

        .sidebar li {
            margin: 10px 0;
            padding: 5px;
            cursor: pointer;
        }

        .sidebar .active {
            color: #ff2e63;
        }

        a{
            color:white;
            text-decoration: none;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            text-align: left;
        }

        thead {
            background-color: #f3f4f6;
        }

        thead th {
            padding: 15px;
            font-size: 14px;
            text-transform: uppercase;
            color: #6b7280;
            font-weight: bold;
            border-bottom: 1px solid #e5e7eb;
        }

        tbody td {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
        }

        tbody tr:hover {
            background-color: #f9fafb;
        }

        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
            display: flex; /* Align sidebar and content horizontally */
        }

        /* Dashboard Content */
        .content {
            flex: 1;
            padding: 25px;
        }

        /* Dashboard Cards Layout */
        .dashboard-container {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            width: 90%;
            margin: auto;
        }

        /* Card Styling */
        .card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: 0.3s ease-in-out;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.15);
        }

        /* Card Headings */
        .card h2 {
            font-size: 1.2rem;
            font-weight: bold;
            margin-bottom: 10px;
        }

        /* Card Icons */
        .card img {
            width: 50px;
            height: 50px;
            margin-bottom: 10px;
        }

        /* Card Text */
        .card2 p {
            font-size: 0.9rem;
            color: gray;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                text-align: center;
            }

            .dashboard-container {
                grid-template-columns: 1fr;
            }
        }
        .navbar {
   background-color: #374;
    padding: 3px;
    text-align: right;
    position: fixed;
    top: 0;
    right:0;
    width: 950px; /* Ensure the navbar spans the full width */
    z-index: 1000; /* Keeps navbar on top of content */
	height:30px;
}
.navbar ul {
    list-style: none;
    padding: 0;
}

.navbar li {
    display: inline;
    margin-right: 20px;
}

.navbar a {
    color: white;
    text-decoration: none;
    font-size: 16px;
}

.navbar a:hover {
    color: #ff2e63;
}
    </style>
</head>
<body>

    <div class="container">
        <!-- Sidebar -->
        
        <div class="sidebar">
            <h2>CRM<span>SPOT</span></h2>
            <ul>
                <li><a href="#">Dashboard</a></li>
                <li><a href="#">Leads</a></li>
                <li><a href="#">Lead Management</a></li>
                <li><a href="#">Projects</a></li>
                <li><a href="#">Quotes</a></li>
                <li><a href="#">Finance Management</a></li>
                <li><a href="#">Contacts</a></li>
                <li><a href="#">Tasks</a></li>
                <li><a href="#">Employees</a></li>
                <li><a href="#">Email</a></li>
                <li><a href="#">Integration</a></li>
            </ul>
        </div>

        <!-- Main Content -->
        <div class="content">
            <div class="dashboard-container">
            <div class="navbar">
        <ul>
        	<li><a href="#"> 🔔</a></li>
            <li><a href="notification.jsp"> 🔔</a></li>
            <li><a href="profile.jsp">👤</a></li>
        </ul>
    </div>
               
               <div class="card">
                    <h2>My Open Tasks</h2>
                    <%
                        Connection con = null;
                        PreparedStatement pst = null;
                        ResultSet rs = null;
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
                            pst = con.prepareStatement("SELECT COUNT(*) FROM open_tasks");
                            rs = pst.executeQuery();
                            if (rs.next()) open = rs.getInt(1);
                            rs.close(); pst.close();
                            
                            pst = con.prepareStatement("SELECT COUNT(*) FROM in_progress_tasks");
                            rs = pst.executeQuery();
                            if (rs.next()) progress = rs.getInt(1);
                            rs.close(); pst.close();
                            
                            pst = con.prepareStatement("SELECT COUNT(*) FROM todo_tasks");
                            rs = pst.executeQuery();
                            if (rs.next()) todo = rs.getInt(1);
                            rs.close(); pst.close();
                            
                            pst = con.prepareStatement("SELECT COUNT(*) FROM completed_tasks");
                            rs = pst.executeQuery();
                            if (rs.next()) completed = rs.getInt(1);
                            rs.close(); pst.close();
                    %>
                  <!-- Pie Chart for Task Distribution -->
                  <div style="display: flex; justify-content: center; align-items: center; height: 227px;">
                    <canvas id="taskPieChart" width="300" height="300"></canvas>
                  </div>

                  <script>
                    // Pie Chart for Task Distribution
                    var pieCtx = document.getElementById('taskPieChart').getContext('2d');
                    new Chart(pieCtx, {
                        type: 'pie',
                        data: {
                            labels: ['Open', 'In Progress', 'ToDo', 'Completed'],
                            datasets: [{
                                data: [<%= open %>, <%= progress %>, <%= todo %>, <%= completed %>],
                                backgroundColor: ['#ff6384', '#36a2eb', '#ffcd56', '#4bc0c0']
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    position: 'bottom'
                                }
                            }
                        }
                    });
                  </script>

                    <%
                        } catch (Exception e) {
                            out.println("Error: " + e.getMessage());
                        } finally {
                            if (rs != null) rs.close();
                            if (pst != null) pst.close();
                            if (con != null) con.close();
                        }
                    %>
                </div>
                <!-- Card 2 -->
                <div class="card2">
                    <h2>Yearly Revenue and Product Sales Overview</h2>
                    <canvas id="revenueChart"></canvas>

                    <%
                       con = null;
                       pst = null;
                        StringBuilder years = new StringBuilder();
                        StringBuilder productsSoldData = new StringBuilder();
                        StringBuilder revenueData = new StringBuilder();

                        try {
                           String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);

                            String query = "SELECT COALESCE(YEAR(due_date), 'Unknown') AS year, " +
                               "COUNT(lead_id) AS products_sold, " +
                               "SUM(COALESCE(finalvalue, quotes_values)) AS total_revenue " +
                               "FROM financemanagement " +
                               "GROUP BY year " +
                               "ORDER BY year";

                            pst = con.prepareStatement(query);
                            rs = pst.executeQuery();

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
                    %>

                    <script>
                    var barCtx = document.getElementById('revenueChart').getContext('2d');
                    new Chart(barCtx, {
                        type: 'bar', // Bar chart
                        data: {
                            labels: [<%= years.toString() %>], // Year labels
                            datasets: [
                                {
                                    label: 'Products Sold',
                                    data: [<%= productsSoldData.toString() %>],
                                    backgroundColor: 'rgba(54, 162, 235, 0.2)',
                                    borderColor: 'rgba(54, 162, 235, 1)',
                                    borderWidth: 1
                                },
                                {
                                    label: 'Total Revenue',
                                    data: [<%= revenueData.toString() %>],
                                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                                    borderColor: 'rgba(75, 192, 192, 1)',
                                    borderWidth: 1
                                }
                            ]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: {
                                    position: 'top',
                                },
                                tooltip: {
                                    mode: 'index',
                                    intersect: false,
                                }
                            },
                            scales: {
                                x: {
                                    beginAtZero: true,
                                    title: {
                                        display: true,
                                        text: 'Year'
                                    }
                                },
                                y: {
                                    title: {
                                        display: true,
                                        text: 'Values'
                                    }
                                }
                            }
                        }
                    });
                    </script>

                    <%
                        } catch (Exception e) {
                            out.println("Error: " + e.getMessage());
                        } finally {
                            if (rs != null) rs.close();
                            if (pst != null) pst.close();
                            if (con != null) con.close();
                        }
                    %>
                </div>
                
                <!-- Other Cards -->
                <div class="card">
                    <h2>Today's Leads</h2>
                    <img src="phone-icon.png" alt="Phone Icon">
                    <p>No New Leads.</p>
                </div>

                <div class="card">
                    <h2>Leads</h2>
                    <img src="graph-icon.png" alt="Graph Icon">
                    <p>No Leads found.</p>
                </div>
            </div>
        </div>
    </div>

</body> 
</html>
