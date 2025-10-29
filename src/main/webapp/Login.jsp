<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | CRM</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f4f7f6;
        }
        .login-container {
            max-width: 400px;
            margin: auto;
            margin-top: 80px;
            padding: 30px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
        }
        .google-btn img {
            width: 100%;
            height: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="login-container">
            <h3 class="text-center">Sign in to CRM</h3>
            
            <!-- Display Error Message -->
            <% String errorMessage = request.getParameter("error"); %>
            <% if (errorMessage != null) { %>
                <div class="alert alert-danger text-center">
                    <%= errorMessage %>
                </div>
            <% } %>
            
            <!-- Google Sign-In -->
            <a href="GoogleOAuthServlet" class="btn btn-light w-100 mb-3 google-btn">
                <img src="https://developers.google.com/identity/images/btn_google_signin_light_normal_web.png" alt="Sign in with Google">
            </a>
            
            <div class="text-center my-2">OR</div>
            
            <!-- Manual Login Form -->
            <form action="LoginServlet" method="post">
                <div class="mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-control" name="email" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Password</label>
                    <input type="password" class="form-control" name="password" required>
                </div>
                <button type="submit" class="btn btn-primary w-100">Login</button>
            </form>

            <!-- Register Link -->
            <div class="text-center mt-3">
                Don't have an account? <a href="register.jsp">Register here</a>
            </div>
        </div>
    </div>
</body>
</html>
