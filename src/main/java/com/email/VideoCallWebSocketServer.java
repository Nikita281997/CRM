package com.email;

import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import jakarta.mail.MessagingException;

import java.net.InetSocketAddress;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class VideoCallWebSocketServer extends WebSocketServer {
    private final Map<WebSocket, String> clients = new ConcurrentHashMap<>();

    public VideoCallWebSocketServer(int port) {
        super(new InetSocketAddress(port));
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        String clientAddress = conn.getRemoteSocketAddress().toString();
        clients.put(conn, clientAddress);

        System.out.println("New connection from: " + clientAddress);
        conn.send("Connected to WebSocket server.");
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        String clientAddress = clients.get(conn);
        clients.remove(conn);
        
        System.out.println("Closed connection from: " + clientAddress + " Reason: " + reason);
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
        System.out.println("Received message from " + clients.get(conn) + ": " + message);

        if (message.startsWith("CALL_REQUEST:")) {
            String recipientEmail = message.split(":")[1]; 
            String videoCallLink = "https://your-videocall-platform.com/call/" + conn.getRemoteSocketAddress();
            EmailSender.sendEmail(recipientEmail, "Video Call Invitation", "Join the video call: " + videoCallLink);
            System.out.println("Video call link sent to: " + recipientEmail);
        }
    }

    @Override
    public void onError(WebSocket conn, Exception ex) {
        System.err.println("WebSocket error: " + ex.getMessage());
        ex.printStackTrace();
    }

    @Override
    public void onStart() {
        System.out.println("WebSocket server started successfully!");
    }

    public static void main(String[] args) {
        int port = 8082;
        VideoCallWebSocketServer server = new VideoCallWebSocketServer(port);
        server.start();
        System.out.println("WebSocket server is running on port: " + port);
    }
}
