<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>CRMSPOT</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <style>
        body {
            background: linear-gradient(135deg, #1e3c72, #4ecdc4);
            color: white;
            min-height: 100vh;
            margin: 0;
            font-family: 'Poppins', sans-serif;
            overflow-x: hidden;
            padding-top: 70px; /* Space for fixed navbar */
        }
        .navbar {
            background: #1e3c72;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
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
            min-height: calc(100vh - 70px);
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .home-container {
            text-align: center;
            max-width: 800px;
        }
        h2 {
            font-size: 4rem;
            margin-bottom: 30px;
            background: linear-gradient(to right, #fff, #4ecdc4);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
            position: relative;
            display: inline-block;
            animation: slideInFromLeft 1.5s ease-out forwards;
        }
        h2:after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 100px;
            height: 4px;
            background: #4ecdc4;
            border-radius: 2px;
            animation: widthGrow 1s ease-out 1s forwards;
        }
        @keyframes slideInFromLeft {
            0% { transform: translateX(-100%); opacity: 0; }
            100% { transform: translateX(0); opacity: 1; }
        }
        @keyframes widthGrow {
            0% { width: 0; }
            100% { width: 100px; }
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
        <div class="home-container">
            <h2>Tars CRM</h2>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>