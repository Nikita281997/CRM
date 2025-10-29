<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Login</title>
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
            padding-top: 70px; /* Space for fixed navbar */
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
            min-height: calc(100vh - 70px); /* Adjust for navbar height */
            padding: 20px;
        }
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            max-width: 500px; /* Increased from 400px */
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
        .form-control:focus {
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
        .error {
            color: #dc3545;
            text-align: center;
            margin-bottom: 15px;
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
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
            <h2>Login</h2>
            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="error"><%= request.getAttribute("errorMessage") %></div>
            <% } %>
            <form action="adminloginservlet" method="post">
                <div class="mb-3"><label class="form-label">Email:</label><input type="email" class="form-control" name="email" placeholder="Enter your email" required></div>
                <div class="mb-3"><label class="form-label">Password:</label><input type="password" class="form-control" name="password" placeholder="Enter your password" required></div>
                <button type="submit" class="btn btn-primary">Login</button>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>