---
title: AESUtils
date: '2021-03-06 00:00:00'
tags:
- Java
---

# AESUtils

```java
/**
 * @author wangshuo
 * @date 2021/03/06
 */
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;


public class AESUtils {

    private static final String ALGORITHM = "AES";

    /**
     * @param content 需要加密的字符串
     * @param key     密钥
     * @return 密文
     */
    public static String encrypt(String content, String key) {
        try {
            // 转换为AES专用密钥
            SecretKeySpec keySpec = generateKeySpec(key);
            // 创建密码器
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec);
            return Base64.getEncoder().encodeToString(cipher.doFinal(content.getBytes()));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * @param content AES加密过的密文
     * @param key     密钥
     * @return 明文
     */
    public static String decrypt(String content, String key) {
        try {
            // 转换为AES专用密钥
            SecretKeySpec keySpec = generateKeySpec(key);
            // 创建密码器
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, keySpec);
            return new String(cipher.doFinal(Base64.getDecoder().decode(content.getBytes())));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static SecretKeySpec generateKeySpec(String key) throws NoSuchAlgorithmException {
        // 创建AES的Key生产者
        KeyGenerator keyGenerator = KeyGenerator.getInstance(ALGORITHM);
        /*
        SecureRandom 实现完全随操作系统本身的內部状态，
        除非调用方先调用getInstance方法，然后调用setSeed方法；
        该实现在windows上每次生成的key都相同，但是在solaris或部分linux系统上则不同。
        关于SecureRandom类的详细介绍，见http://yangzb.iteye.com/blog/325264
         */
        SecureRandom secureRandom = SecureRandom.getInstance("SHA1PRNG");
        secureRandom.setSeed(key.getBytes());
        keyGenerator.init(128, secureRandom);
        SecretKey secretKey = keyGenerator.generateKey();
        byte[] enCodeFormat = secretKey.getEncoded();
        return new SecretKeySpec(enCodeFormat, ALGORITHM);
    }

    public static void main(String[] args) {
        String miwen = "xxx";
        String key = "I don't know.";
        System.out.println(decrypt(miwen, key));
    }
}
```
