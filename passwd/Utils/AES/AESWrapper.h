//
//  AESWrapper.h
//  passwd
//
//  Created by Leslie D on 2024/2/5.
//

#import <Foundation/Foundation.h>

@interface AESWrapper : NSObject

@property (nonatomic, strong) NSData *iv; // IV变量

- (void)initialize; // 初始化方法

- (NSString *) decrypt2WithSecretKey:(NSString *) secretKey cipherText:(NSString *)cipherText;

- (NSString *)encryptWithSecretKey:(NSString *)secretKey plainText:(NSString *)plainText;

@end
