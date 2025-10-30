<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
   <%@ page import="java.sql.*" %>
   <%
       int companyId = Integer.parseInt(request.getParameter("companyId"));
       int year = Integer.parseInt(request.getParameter("year"));
       int open = 0, progress = 0, completed = 0;
       Connection con = null;
       PreparedStatement pstmt = null;
       ResultSet rs = null;

       try {
           String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String user = System.getenv("DB_USER");
            String pass = System.getenv("DB_PASS");

            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName;
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
           pstmt = con.prepareStatement("SELECT COUNT(*) FROM open_tasks WHERE company_id = ? AND YEAR(dead_line) = ?");
           pstmt.setInt(1, companyId);
           pstmt.setInt(2, year);
           rs = pstmt.executeQuery();
           if (rs.next()) open = rs.getInt(1);
           rs.close(); pstmt.close();

           pstmt = con.prepareStatement("SELECT COUNT(*) FROM in_progress_tasks WHERE company_id = ? AND YEAR(dead_line) = ?");
           pstmt.setInt(1, companyId);
           pstmt.setInt(2, year);
           rs = pstmt.executeQuery();
           if (rs.next()) progress = rs.getInt(1);
           rs.close(); pstmt.close();

           pstmt = con.prepareStatement("SELECT COUNT(*) FROM completed_tasks WHERE company_id = ? AND YEAR(dead_line) = ?");
           pstmt.setInt(1, companyId);
           pstmt.setInt(2, year);
           rs = pstmt.executeQuery();
           if (rs.next()) completed = rs.getInt(1);
           rs.close(); pstmt.close();

           out.print("{\"success\": true, \"open\": " + open + ", \"progress\": " + progress + ", \"completed\": " + completed + "}");
       } catch (Exception e) {
           out.print("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
       } finally {
           if (rs != null) rs.close();
           if (pstmt != null) pstmt.close();
           if (con != null) con.close();
       }
   %>