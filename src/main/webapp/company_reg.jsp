<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>CRMSPOT | Get Started</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            width: 50%;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
        }
        h2 {
            color: #2d8cff;
            text-align: left;
        }
        label {
            font-weight: bold;
        }
        input, select {
            width: 100%;
            padding: 8px;
            margin: 5px 0;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        .button {
            background: #6d4d79;
            color: white;
            border: none;
            padding: 10px;
            width: 100%;
            cursor: pointer;
            font-size: 16px;
            margin-top: 10px;
        }
        .button:hover {
            background: #573b5f;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>CRMSPOT | Get Started</h2>
        <form action="RegisterCompanyServlet" method="post">
            <label>First and Last Name:</label>
            <input type="text" name="full_name" required>

            <label>Email:</label>
            <input type="email" name="email" required>

            <label>Company Name:</label>
            <input type="text" name="company_name" required>

            <label>Phone Number:</label>
            <input type="text" name="phone_number" required>

            <label>Country:</label>
            <select name="country">
                <option value="India">India</option>
                <option value="USA">USA</option>
                <option value="UK">UK</option>
                <option value="Germany">Germany</option>
            </select>

            <label>Company Size:</label>
            <select name="company_size">
                <option value="1-10">1-10</option>
                <option value="11-50">11-50</option>
                <option value="51-200">51-200</option>
            </select>

            <button type="submit" class="button">Start Now</button>
        </form>
    </div>
</body>
</html>
