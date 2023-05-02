#import <Foundation/Foundation.h>
#import "PigeonParser.h"

@implementation PigeonParser

+ (PigeonUserCredential *)getPigeonUserCredentialFromAuthResult:(nonnull FIRAuthDataResult *)authResult {
    return [PigeonUserCredential makeWithUser:[self getPigeonDetails:authResult.user] additionalUserInfo:[self getPigeonAdditionalUserInfo:authResult.additionalUserInfo] credential:[self getPigeonAuthCredential:authResult.credential]];
}

+ (PigeonUserDetails *)getPigeonDetails:(nonnull FIRUser *)user {
    return [PigeonUserDetails makeWithUserInfo:[self getPigeonUserInfo:user] providerData:[self getProviderData:user.providerData]];
}

+ (PigeonUserInfo *)getPigeonUserInfo:(nonnull FIRUser *)user {
    return [PigeonUserInfo makeWithUid:user.uid email:user.email displayName:user.displayName photoUrl:user.photoURL.absoluteString phoneNumber:user.phoneNumber isAnonymous:[NSNumber numberWithBool:user.isAnonymous] isEmailVerified:[NSNumber numberWithBool:user.emailVerified] providerId:user.providerID tenantId:user.tenantID refreshToken:user.refreshToken creationTimestamp:[NSNumber numberWithDouble:user.metadata.creationDate.timeIntervalSince1970 * 1000] lastSignInTimestamp:[NSNumber numberWithDouble:user.metadata.lastSignInDate.timeIntervalSince1970 * 1000]];
}


+ (NSArray<NSDictionary<id, id> *> *)getProviderData:(nonnull NSArray<id<FIRUserInfo>> *)providerData {
    NSMutableArray<NSDictionary<id, id> *> *dataArray = [NSMutableArray arrayWithCapacity:providerData.count];
    for (id<FIRUserInfo> userInfo in providerData) {
        NSDictionary *dataDict = @{
                                   @"providerId": userInfo.providerID,
                                   @"uid": userInfo.uid,
                                   @"displayName": userInfo.displayName ?: [NSNull null],
                                   @"email": userInfo.email ?: [NSNull null],
                                   @"phoneNumber": userInfo.phoneNumber ?: [NSNull null],
                                   @"photoURL": userInfo.photoURL ?: [NSNull null]
                                   };
        [dataArray addObject:dataDict];
    }
    return [dataArray copy];
}

+ (PigeonAdditionalUserInfo *)getPigeonAdditionalUserInfo:(nonnull FIRAdditionalUserInfo *)userInfo {
    return [PigeonAdditionalUserInfo makeWithIsNewUser:[NSNumber numberWithBool:userInfo.isNewUser] providerId:userInfo.providerID username:userInfo.username profile:userInfo.profile];
}

+ (PigeonAuthCredential *)getPigeonAuthCredential:(FIRAuthCredential *)authCredential {
    if (authCredential == nil) {
      return nil;
    }

    NSString *accessToken = nil;
    if ([authCredential isKindOfClass:[FIROAuthCredential class]]) {
      if (((FIROAuthCredential *)authCredential).accessToken != nil) {
        accessToken = ((FIROAuthCredential *)authCredential).accessToken;
      } else if (((FIROAuthCredential *)authCredential).IDToken != nil) {
        // For Sign In With Apple, the token is stored in IDToken
        accessToken = ((FIROAuthCredential *)authCredential).IDToken;
      }
    }

    return [PigeonAuthCredential makeWithProviderId:authCredential.provider signInMethod:authCredential.provider nativeId:@([authCredential hash]) accessToken:accessToken ?: nil];
}


@end
