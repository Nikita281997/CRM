<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Employee Login</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="navbar">
     <a href="login1.jsp">Home</a>
        <a href="dashadminLogin.jsp">Login</a>
           
        <a href="dashegisterCompany.jsp">Register Company</a>
    </div>
    
    <div class="container">
        <h2>Employee Login</h2>
        <form action="EmployeeLoginServlet" method="post">
            <label>Company ID:</label>
            <input type="text" name="company_id" required>
            
            <label>Employee ID:</label>
            <input type="text" name="emp_id" required>

            <button type="submit" class="button">Login</button>
        </form>
    </div>
</body>
</html>
