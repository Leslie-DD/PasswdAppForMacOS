//
//  AESWrapper.mm
//  passwd
//
//  Created by Leslie D on 2024/2/5.
//

#import "AESWrapper.h"

#include <string>
#include <vector>

#import <CommonCrypto/CommonCryptor.h>


@implementation AESWrapper

- (void)initialize {
    // To implement
}

// Decode the secret key and cipher text
- (NSString *) decrypt2WithSecretKey:(NSString *) secretKey cipherText:(NSString *)cipherText {
    // 妈的，Object C 写的这个加密方法返回的加密结果会包含+这个符号，'+' 这个符号上传到服务器存到数据库里很奇怪变成了空格，导致从服务器返回的密文不是真正的加密结果，
    // 为了解决这个问题，暂时把 Object C 加密的密文中的 '+' 替换成 '-'，在解密的时候再替换回来，麻了。
    NSString * cipherText2 = [cipherText stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    NSData* secretKeyData = [[NSData alloc] initWithBase64EncodedString:secretKey options:0];
    NSData* cipherTextData = [[NSData alloc] initWithBase64EncodedString:cipherText2 options:0];
    
//    NSData* secretKeyData = [[NSData alloc] initWithBase64EncodedString:secretKey options:0];
//    NSData* cipherTextData = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];

    // Split the input into IV and cipher text
    NSData* iv = [cipherTextData subdataWithRange:NSMakeRange(0, 16)];
    NSData* data = [cipherTextData subdataWithRange:NSMakeRange(16, [cipherTextData length] - 16)];

    // Prepare a buffer for the decrypted data
    size_t decryptedDataBufferSize = [data length];
    void* decryptedDataBuffer = malloc(decryptedDataBufferSize);

    size_t decryptedDataLength = 0;

    CCCryptorStatus status = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                     [secretKeyData bytes], kCCKeySizeAES256,
                                     [iv bytes],
                                     [data bytes], [data length],
                                     decryptedDataBuffer, decryptedDataBufferSize,
                                     &decryptedDataLength);

    if (status == kCCSuccess) {
        NSData *decryptedData = [NSData dataWithBytesNoCopy:decryptedDataBuffer length:decryptedDataLength];
        NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] ;
        return decryptedString;
    } else {
        free(decryptedDataBuffer);
        return nil;
    }
}


- (NSString *)encryptWithSecretKey:(NSString *)secretKey plainText:(NSString *)plainText {
    NSData *secretKeyData = [[NSData alloc] initWithBase64EncodedString:secretKey options:0];
    NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create and configure the cipher
    NSMutableData *cipherData = [NSMutableData dataWithLength:plainTextData.length + kCCBlockSizeAES128];
    size_t outLength;
    
    NSMutableData *iv = [NSMutableData dataWithLength:kCCBlockSizeAES128];
    OSStatus noUsedStatus = SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, iv.mutableBytes);
    if (noUsedStatus != errSecSuccess) {
        // Handle the error here
        return nil;
    }
    
    CCCryptorStatus result = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                     secretKeyData.bytes, kCCKeySizeAES256,
                                     iv.bytes,
                                     plainTextData.bytes,
                                     plainTextData.length,
                                     cipherData.mutableBytes,
                                     cipherData.length,
                                     &outLength);
    if (result != kCCSuccess) {
        return nil;
    }
    cipherData.length = outLength;
    
    // Combine IV and cipher data
    NSMutableData *encryptData = [NSMutableData dataWithData:iv];
    [encryptData appendData:cipherData];
    
    
    NSString *base64String = [[encryptData base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return base64String;
    
    // Encode to base64
//    return [encryptData base64EncodedStringWithOptions:0];
}


@end
