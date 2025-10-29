package com.email;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;

public class EncryptionUtil {
    // Use a valid AES key length (16, 24, or 32 bytes)
    private static final String SECRET_KEY = "1234567890123456"; // 16 bytes key

    public static String encrypt(String password) {
        try {
            SecretKeySpec secretKey = new SecretKeySpec(SECRET_KEY.getBytes(), "AES");
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding"); // Use AES with ECB mode and PKCS5 padding
            cipher.init(Cipher.ENCRYPT_MODE, secretKey);
            byte[] encryptedBytes = cipher.doFinal(password.getBytes());
            return Base64.getEncoder().encodeToString(encryptedBytes); // Base64 encode the encrypted bytes
        } catch (Exception e) {
            throw new RuntimeException("Error encrypting password", e);
        }
    }

    public static String decrypt(String encryptedPassword) {
        try {
            SecretKeySpec secretKey = new SecretKeySpec(SECRET_KEY.getBytes(), "AES");
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding"); // Use AES with ECB mode and PKCS5 padding
            cipher.init(Cipher.DECRYPT_MODE, secretKey);
            byte[] decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(encryptedPassword)); // Base64 decode before decryption
            return new String(decryptedBytes);
        } catch (Exception e) {
            throw new RuntimeException("Error decrypting password", e);
        }
    }
}