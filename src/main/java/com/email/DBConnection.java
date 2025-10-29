package com.email;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
	   private static final String URL = "jdbc:mysql://mysql-java-crmpro.b.aivencloud.com:25978/crmprodb"; // Update with your DB details
	    private static final String USER = "atharva"; // Update with your DB username
	    private static final String PASSWORD ="AVNS_SFoivcl39tz_B7wqssI"; // Update with your DB password
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
