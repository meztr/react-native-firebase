#import "RNFirebaseAuth.h"
#import "RNFirebaseEvents.h"
#import "RCTDefines.h"


#if __has_include(<FirebaseAuth/FIRAuth.h>)

@implementation RNFirebaseAuth
RCT_EXPORT_MODULE();

- (id)init {
    self = [super init];
    if (self != nil) {
        _authStateHandlers = [[NSMutableDictionary alloc] init];
        _idTokenHandlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 addAuthStateListener

 */
RCT_EXPORT_METHOD(addAuthStateListener:
    (NSString *) appName) {

    if (![_authStateHandlers valueForKey:appName]) {
        FIRApp *firApp = [FIRApp appNamed:appName];
        FIRAuthStateDidChangeListenerHandle newListenerHandle = [[FIRAuth authWithApp:firApp] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
            if (user != nil) {
                [self sendJSEventWithAppName:appName title:AUTH_CHANGED_EVENT props:[@{@"authenticated": @(true), @"user": [self firebaseUserToDict:user]} mutableCopy]];
            } else {
                [self sendJSEventWithAppName:appName title:AUTH_CHANGED_EVENT props:[@{@"authenticated": @(false)} mutableCopy]];
            }
        }];

        _authStateHandlers[appName] = [NSValue valueWithNonretainedObject:newListenerHandle];
    }
}

/**
 removeAuthStateListener

 */
RCT_EXPORT_METHOD(removeAuthStateListener:
    (NSString *) appName) {

    if ([_authStateHandlers valueForKey:appName]) {
        FIRApp *firApp = [FIRApp appNamed:appName];
        [[FIRAuth authWithApp:firApp] removeAuthStateDidChangeListener:[_authStateHandlers valueForKey:appName]];
        [_authStateHandlers removeObjectForKey:appName];
    }
}

/**
 addIdTokenListener

 */
RCT_EXPORT_METHOD(addIdTokenListener:
                  (NSString *) appName) {

    if (![_idTokenHandlers valueForKey:appName]) {
        FIRApp *firApp = [FIRApp appNamed:appName];
        FIRIDTokenDidChangeListenerHandle newListenerHandle = [[FIRAuth authWithApp:firApp] addIDTokenDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
            if (user != nil) {
                [self sendJSEventWithAppName:appName title:AUTH_ID_TOKEN_CHANGED_EVENT props:[@{@"authenticated": @(true), @"user": [self firebaseUserToDict:user]} mutableCopy]];
            } else {
                [self sendJSEventWithAppName:appName title:AUTH_ID_TOKEN_CHANGED_EVENT props:[@{@"authenticated": @(false)} mutableCopy]];
            }
        }];

        _idTokenHandlers[appName] = [NSValue valueWithNonretainedObject:newListenerHandle];
    }
}

/**
 removeAuthStateListener

 */
RCT_EXPORT_METHOD(removeIdTokenListener:
                  (NSString *) appName) {
    if ([_idTokenHandlers valueForKey:appName]) {
        FIRApp *firApp = [FIRApp appNamed:appName];
        [[FIRAuth authWithApp:firApp] removeIDTokenDidChangeListener:[_idTokenHandlers valueForKey:appName]];
        [_idTokenHandlers removeObjectForKey:appName];
    }
}



/**
 signOut

 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(signOut:
    (NSString *) appName
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRUser *user = [FIRAuth auth].currentUser;

    if (user) {
        NSError *error;
        [[FIRAuth authWithApp:firApp] signOut:&error];
        if (!error) [self promiseNoUser:resolve rejecter:reject isError:NO];
        else [self promiseRejectAuthException:reject error:error];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}


/**
 signInAnonymously

 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(signInAnonymously:
    (NSString *) appName
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    [[FIRAuth authWithApp:firApp] signInAnonymouslyWithCompletion:^(FIRUser *user, NSError *error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            [self promiseWithUser:resolve rejecter:reject user:user];
        }
    }];

}

/**
 signInWithEmailAndPassword

 @param NSString NSString email
 @param NSString NSString password
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return return
 */
RCT_EXPORT_METHOD(signInWithEmailAndPassword:
    (NSString *) appName
            email:
            (NSString *) email
            pass:
            (NSString *) password
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    [[FIRAuth authWithApp:firApp] signInWithEmail:email password:password completion:^(FIRUser *user, NSError *error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            [self promiseWithUser:resolve rejecter:reject user:user];
        }
    }];
}

/**
 createUserWithEmailAndPassword

 @param NSString NSString email
 @param NSString NSString password
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return return
 */
RCT_EXPORT_METHOD(createUserWithEmailAndPassword:
    (NSString *) appName
            email:
            (NSString *) email
            pass:
            (NSString *) password
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    [[FIRAuth authWithApp:firApp] createUserWithEmail:email password:password completion:^(FIRUser *user, NSError *error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            [self promiseWithUser:resolve rejecter:reject user:user];
        }
    }];
}

/**
 deleteUser

 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return return
 */
RCT_EXPORT_METHOD(delete:
    (NSString *) appName
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];
    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;

    if (user) {
        [user deleteWithCompletion:^(NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                [self promiseNoUser:resolve rejecter:reject isError:NO];
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 reload

 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return return
 */
RCT_EXPORT_METHOD(reload:
    (NSString *) appName
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;

    if (user) {
        [user reloadWithCompletion:^(NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                FIRUser *userAfterReload = [FIRAuth authWithApp:firApp].currentUser;
                [self promiseWithUser:resolve rejecter:reject user:userAfterReload];
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 sendEmailVerification

 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return return
 */
RCT_EXPORT_METHOD(sendEmailVerification:
    (NSString *) appName
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;
    if (user) {
        [user sendEmailVerificationWithCompletion:^(NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                FIRUser *userAfterUpdate = [FIRAuth authWithApp:firApp].currentUser;
                [self promiseWithUser:resolve rejecter:reject user:userAfterUpdate];
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 updateEmail

 @param NSString email
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return return
 */
RCT_EXPORT_METHOD(updateEmail:
    (NSString *) appName
            email:
            (NSString *) email
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];
    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;

    if (user) {
        [user updateEmail:email completion:^(NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                FIRUser *userAfterUpdate = [FIRAuth authWithApp:firApp].currentUser;
                [self promiseWithUser:resolve rejecter:reject user:userAfterUpdate];
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 updatePassword

 @param NSString password
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return return
 */
RCT_EXPORT_METHOD(updatePassword:
    (NSString *) appName
            password:
            (NSString *) password
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRUser *user = [FIRAuth auth].currentUser;

    if (user) {
        [user updatePassword:password completion:^(NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                FIRUser *userAfterUpdate = [FIRAuth authWithApp:firApp].currentUser;
                [self promiseWithUser:resolve rejecter:reject user:userAfterUpdate];
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 updateProfile

 @param NSDictionary props
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return return
 */
RCT_EXPORT_METHOD(updateProfile:
    (NSString *) appName
            props:
            (NSDictionary *) props
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;

    if (user) {
        FIRUserProfileChangeRequest *changeRequest = [user profileChangeRequest];
        NSMutableArray *allKeys = [[props allKeys] mutableCopy];

        for (NSString *key in allKeys) {
            @try {
                if ([key isEqualToString:@"photoURL"]) {
                    NSURL *url = [NSURL URLWithString:[props valueForKey:key]];
                    [changeRequest setValue:url forKey:key];
                } else {
                    [changeRequest setValue:props[key] forKey:key];
                }
            } @catch (NSException *exception) {
                NSLog(@"Exception occurred while configuring: %@", exception);
            }
        }

        [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                FIRUser *userAfterUpdate = [FIRAuth authWithApp:firApp].currentUser;
                [self promiseWithUser:resolve rejecter:reject user:userAfterUpdate];
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 getToken

 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(getToken:
    (NSString *) appName
            forceRefresh:
            (BOOL) forceRefresh
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;

    if (user) {
        [user getIDTokenForcingRefresh:(BOOL) forceRefresh completion:^(NSString *token, NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                resolve(token);
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 signInWithCredential

 @param NSString provider
 @param NSString authToken
 @param NSString authSecret
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(signInWithCredential:
    (NSString *) appName
            provider:
            (NSString *) provider
            token:
            (NSString *) authToken
            secret:
            (NSString *) authSecret
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRAuthCredential *credential = [self getCredentialForProvider:provider token:authToken secret:authSecret];

    if (credential == nil) {
        return reject(@"auth/invalid-credential", @"The supplied auth credential is malformed, has expired or is not currently supported.", nil);
    }

    [[FIRAuth authWithApp:firApp] signInWithCredential:credential completion:^(FIRUser *user, NSError *error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            [self promiseWithUser:resolve rejecter:reject user:user];
        }
    }];
}

/**
 confirmPasswordReset

 @param NSString code
 @param NSString newPassword
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(confirmPasswordReset:
    (NSString *) code
            newPassword:
            (NSString *) newPassword
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    [[FIRAuth auth] confirmPasswordResetWithCode:code newPassword:newPassword completion:^(NSError *_Nullable error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            [self promiseNoUser:resolve rejecter:reject isError:NO];
        }
    }];
}


/**
 * applyActionCode
 *
 * @param NSString code
 * @param RCTPromiseResolveBlock resolve
 * @param RCTPromiseRejectBlock reject
 * @return
 */
RCT_EXPORT_METHOD(applyActionCode:
    (NSString *) code
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    [[FIRAuth auth] applyActionCode:code completion:^(NSError *_Nullable error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            [self promiseNoUser:resolve rejecter:reject isError:NO];
        }
    }];
}

/**
 * checkActionCode
 *
 * @param NSString code
 * @param RCTPromiseResolveBlock resolve
 * @param RCTPromiseRejectBlock reject
 * @return
 */
RCT_EXPORT_METHOD(checkActionCode:
    (NSString *) code
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    [[FIRAuth auth] checkActionCode:code completion:^(FIRActionCodeInfo *_Nullable info, NSError *_Nullable error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            NSString *actionType = @"ERROR";
            switch (info.operation) {
                case FIRActionCodeOperationPasswordReset:
                    actionType = @"PASSWORD_RESET";
                    break;
                case FIRActionCodeOperationVerifyEmail:
                    actionType = @"VERIFY_EMAIL";
                    break;
                case FIRActionCodeOperationUnknown:
                    actionType = @"UNKNOWN";
                    break;
                case FIRActionCodeOperationRecoverEmail:
                    actionType = @"RECOVER_EMAIL";
                    break;
            }

            NSDictionary *result = @{@"data": @{@"email": [info dataForKey:FIRActionCodeEmailKey], @"fromEmail": [info dataForKey:FIRActionCodeFromEmailKey],}, @"actionType": actionType,};

            resolve(result);
        }
    }];
}

/**
 sendPasswordResetEmail

 @param NSString email
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(sendPasswordResetEmail:
    (NSString *) appName
            email:
            (NSString *) email
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    [[FIRAuth authWithApp:firApp] sendPasswordResetWithEmail:email completion:^(NSError *_Nullable error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            [self promiseNoUser:resolve rejecter:reject isError:NO];
        }
    }];
}

/**
 getCurrentUser

 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(getCurrentUser:
    (NSString *) appName
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;
    [self promiseWithUser:resolve rejecter:reject user:user];
}


/**
 signInWithCustomToken

 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(signInWithCustomToken:
    (NSString *) appName
            customToken:
            (NSString *) customToken
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    [[FIRAuth authWithApp:firApp] signInWithCustomToken:customToken completion:^(FIRUser *user, NSError *error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            [self promiseWithUser:resolve rejecter:reject user:user];
        }
    }];
}

/**
 signInWithPhoneNumber

 @param string phoneNumber
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(signInWithPhoneNumber:(NSString *) appName
            phoneNumber:(NSString *) phoneNumber
            resolver:(RCTPromiseResolveBlock) resolve
            rejecter:(RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    [[FIRPhoneAuthProvider providerWithAuth:[FIRAuth authWithApp:firApp]] verifyPhoneNumber:phoneNumber UIDelegate:nil completion:^(NSString * _Nullable verificationID, NSError * _Nullable error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:verificationID forKey:@"authVerificationID"];
            resolve(@{
                    @"verificationId": verificationID
            });
        }
    }];
}

/**
 verifyPhoneNumber
 
 @param string phoneNumber
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(verifyPhoneNumber:(NSString *) appName
                  phoneNumber:(NSString *) phoneNumber
                  requestKey:(NSString *) requestKey) {
    FIRApp *firApp = [FIRApp appNamed:appName];
    
    [[FIRPhoneAuthProvider providerWithAuth:[FIRAuth authWithApp:firApp]] verifyPhoneNumber:phoneNumber UIDelegate:nil completion:^(NSString * _Nullable verificationID, NSError * _Nullable error) {
        if (error) {
            NSDictionary * jsError = [self getJSError:(error)];
            NSMutableDictionary * props =  [@{
                                              @"type": @"onVerificationFailed",
                                              @"requestKey":requestKey,
                                              @"state": @{@"error": jsError},
                                          } mutableCopy];
            [self sendJSEventWithAppName:appName title:PHONE_AUTH_STATE_CHANGED_EVENT props: props];
        } else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:verificationID forKey:@"authVerificationID"];
            NSMutableDictionary * props =  [@{
                                              @"type": @"onCodeSent",
                                              @"requestKey":requestKey,
                                              @"state": @{@"verificationId": verificationID},
                                          } mutableCopy];
            [self sendJSEventWithAppName:appName title:PHONE_AUTH_STATE_CHANGED_EVENT props: props];
        }
    }];
}

RCT_EXPORT_METHOD(_confirmVerificationCode:(NSString *) appName
            verificationCode:(NSString *) verificationCode
            resolver:(RCTPromiseResolveBlock) resolve
            rejecter:(RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *verificationId = [defaults stringForKey:@"authVerificationID"];
    FIRAuthCredential *credential = [[FIRPhoneAuthProvider provider] credentialWithVerificationID:verificationId verificationCode:verificationCode];

    [[FIRAuth authWithApp:firApp] signInWithCredential:credential completion:^(FIRUser *user, NSError *error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else {
            [self promiseWithUser:resolve rejecter:reject user:user];
        }
    }];
}

/**
 link - *insert zelda joke here*

 @param NSString provider
 @param NSString authToken
 @param NSString authSecret
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(link:
    (NSString *) appName
            provider:
            (NSString *) provider
            authToken:
            (NSString *) authToken
            authSecret:
            (NSString *) authSecret
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRAuthCredential *credential = [self getCredentialForProvider:provider token:authToken secret:authSecret];

    if (credential == nil) {
        return reject(@"auth/invalid-credential", @"The supplied auth credential is malformed, has expired or is not currently supported.", nil);
    }

    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;

    if (user) {
        [user linkWithCredential:credential completion:^(FIRUser *_Nullable _user, NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                [self promiseWithUser:resolve rejecter:reject user:_user];
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 unlink

 @param NSString provider
 @param NSString authToken
 @param NSString authSecret
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(unlink:
    (NSString *) appName
            providerId:
            (NSString *) providerId
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];
    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;

    if (user) {
        [user unlinkFromProvider:providerId completion:^(FIRUser *_Nullable _user, NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                // This is here to protect against bugs in the iOS SDK which don't
                // correctly refresh the user object when unlinking certain accounts
                [user reloadWithCompletion:^(NSError * _Nullable error) {
                    if (error) {
                        [self promiseRejectAuthException:reject error:error];
                    } else {
                        [self promiseWithUser:resolve rejecter:reject user:user];
                    }
                }];
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 reauthenticate

 @param NSString provider
 @param NSString authToken
 @param NSString authSecret
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(reauthenticate:
    (NSString *) appName
            provider:
            (NSString *) provider
            authToken:
            (NSString *) authToken
            authSecret:
            (NSString *) authSecret
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    FIRAuthCredential *credential = [self getCredentialForProvider:provider token:authToken secret:authSecret];

    if (credential == nil) {
        return reject(@"auth/invalid-credential", @"The supplied auth credential is malformed, has expired or is not currently supported.", nil);
    }

    FIRUser *user = [FIRAuth authWithApp:firApp].currentUser;

    if (user) {
        [user reauthenticateWithCredential:credential completion:^(NSError *_Nullable error) {
            if (error) {
                [self promiseRejectAuthException:reject error:error];
            } else {
                FIRUser *userAfterAuth = [FIRAuth authWithApp:firApp].currentUser;
                [self promiseWithUser:resolve rejecter:reject user:userAfterAuth];
            }
        }];
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }
}

/**
 fetchProvidersForEmail

 @param NSString email
 @param RCTPromiseResolveBlock resolve
 @param RCTPromiseRejectBlock reject
 @return
 */
RCT_EXPORT_METHOD(fetchProvidersForEmail:
    (NSString *) appName
            email:
            (NSString *) email
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {
    FIRApp *firApp = [FIRApp appNamed:appName];

    [[FIRAuth authWithApp:firApp] fetchProvidersForEmail:email completion:^(NSArray<NSString *> *_Nullable providers, NSError *_Nullable error) {
        if (error) {
            [self promiseRejectAuthException:reject error:error];
        } else if (!providers) {
            NSMutableArray *emptyResponse = [[NSMutableArray alloc] init];
            resolve(emptyResponse);
        } else {
            resolve(providers);
        }
    }];
}

/**
 getCredentialForProvider

 @param provider string
 @param authToken string
 @param authTokenSecret string
 @return FIRAuthCredential
 */
- (FIRAuthCredential *)getCredentialForProvider:(NSString *)provider token:(NSString *)authToken secret:(NSString *)authTokenSecret {
    FIRAuthCredential *credential;

    if ([provider compare:@"twitter.com" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        credential = [FIRTwitterAuthProvider credentialWithToken:authToken secret:authTokenSecret];
    } else if ([provider compare:@"facebook.com" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        credential = [FIRFacebookAuthProvider credentialWithAccessToken:authToken];
    } else if ([provider compare:@"google.com" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        credential = [FIRGoogleAuthProvider credentialWithIDToken:authToken accessToken:authTokenSecret];
    } else if ([provider compare:@"password" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        credential = [FIREmailAuthProvider credentialWithEmail:authToken password:authTokenSecret];
    } else if ([provider compare:@"github.com" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        credential = [FIRGitHubAuthProvider credentialWithToken:authToken];
    } else if ([provider compare:@"phone" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        credential = [[FIRPhoneAuthProvider provider] credentialWithVerificationID:authToken verificationCode:authTokenSecret];
    } else {
        NSLog(@"Provider not yet handled: %@", provider);
    }

    return credential;
}


/**
 Resolve or reject a promise based on isError value

 @param resolve RCTPromiseResolveBlock
 @param reject RCTPromiseRejectBlock
 @param isError BOOL
 */
- (void)promiseNoUser:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject isError:(BOOL)isError {
    if (isError) {
        reject(@"auth/no-current-user", @"No user currently signed in.", nil);
    } else {
        resolve([NSNull null]);
    }
}

/**
 Reject a promise with an auth exception

 @param reject RCTPromiseRejectBlock
 @param error NSError
 */
- (void)promiseRejectAuthException:(RCTPromiseRejectBlock)reject error:(NSError *)error {
    NSDictionary * jsError = [self getJSError:(error)];
    reject([jsError valueForKey:@"code"], [jsError valueForKey:@"message"], error);
}

/**
 Reject a promise with an auth exception
 
 @param error NSError
 */
- (NSDictionary *)getJSError:(NSError *)error {
    NSString *code = @"auth/unknown";
    NSString *message = [error localizedDescription];
    NSString *nativeErrorMessage = [error localizedDescription];
    
    switch (error.code) {
        case FIRAuthErrorCodeInvalidCustomToken:
            code = @"auth/invalid-custom-token";
            message = @"The custom token format is incorrect. Please check the documentation.";
            break;
        case FIRAuthErrorCodeCustomTokenMismatch:
            code = @"auth/custom-token-mismatch";
            message = @"The custom token corresponds to a different audience.";
            break;
        case FIRAuthErrorCodeInvalidCredential:
            code = @"auth/invalid-credential";
            message = @"The supplied auth credential is malformed or has expired.";
            break;
        case FIRAuthErrorCodeInvalidEmail:
            code = @"auth/invalid-email";
            message = @"The email address is badly formatted.";
            break;
        case FIRAuthErrorCodeWrongPassword:
            code = @"auth/wrong-password";
            message = @"The password is invalid or the user does not have a password.";
            break;
        case FIRAuthErrorCodeUserMismatch:
            code = @"auth/user-mismatch";
            message = @"The supplied credentials do not correspond to the previously signed in user.";
            break;
        case FIRAuthErrorCodeRequiresRecentLogin:
            code = @"auth/requires-recent-login";
            message = @"This operation is sensitive and requires recent authentication. Log in again before retrying this request.";
            break;
        case FIRAuthErrorCodeAccountExistsWithDifferentCredential:
            code = @"auth/account-exists-with-different-credential";
            message = @"An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.";
            break;
        case FIRAuthErrorCodeEmailAlreadyInUse:
            code = @"auth/email-already-in-use";
            message = @"The email address is already in use by another account.";
            break;
        case FIRAuthErrorCodeCredentialAlreadyInUse:
            code = @"auth/credential-already-in-use";
            message = @"This credential is already associated with a different user account.";
            break;
        case FIRAuthErrorCodeUserDisabled:
            code = @"auth/user-disabled";
            message = @"The user account has been disabled by an administrator.";
            break;
        case FIRAuthErrorCodeUserTokenExpired:
            code = @"auth/user-token-expired";
            message = @"The user's credential is no longer valid. The user must sign in again.";
            break;
        case FIRAuthErrorCodeUserNotFound:
            code = @"auth/user-not-found";
            message = @"There is no user record corresponding to this identifier. The user may have been deleted.";
            break;
        case FIRAuthErrorCodeInvalidUserToken:
            code = @"auth/invalid-user-token";
            message = @"The user's credential is no longer valid. The user must sign in again.";
            break;
        case FIRAuthErrorCodeWeakPassword:
            code = @"auth/weak-password";
            message = @"The given password is invalid.";
            break;
        case FIRAuthErrorCodeOperationNotAllowed:
            code = @"auth/operation-not-allowed";
            message = @"This operation is not allowed. You must enable this service in the console.";
            break;
        case FIRAuthErrorCodeNetworkError:
            code = @"auth/network-error";
            message = @"A network error has occurred, please try again.";
            break;
        case FIRAuthErrorCodeInternalError:
            code = @"auth/internal-error";
            message = @"An internal error has occurred, please try again.";
            break;
            
            // unsure of the below codes so leaving them as the default error message
        case FIRAuthErrorCodeTooManyRequests:
            code = @"auth/too-many-requests";
            break;
        case FIRAuthErrorCodeProviderAlreadyLinked:
            code = @"auth/provider-already-linked";
            break;
        case FIRAuthErrorCodeNoSuchProvider:
            code = @"auth/no-such-provider";
            break;
        case FIRAuthErrorCodeInvalidAPIKey:
            code = @"auth/invalid-api-key";
            break;
        case FIRAuthErrorCodeAppNotAuthorized:
            code = @"auth/app-not-authorised";
            break;
        case FIRAuthErrorCodeExpiredActionCode:
            code = @"auth/expired-action-code";
            break;
        case FIRAuthErrorCodeInvalidMessagePayload:
            code = @"auth/invalid-message-payload";
            break;
        case FIRAuthErrorCodeInvalidSender:
            code = @"auth/invalid-sender";
            break;
        case FIRAuthErrorCodeInvalidRecipientEmail:
            code = @"auth/invalid-recipient-email";
            break;
        case FIRAuthErrorCodeKeychainError:
            code = @"auth/keychain-error";
            break;
        default:
            break;
    }
    
    return @{
             @"code": code,
             @"message": message,
             @"nativeErrorMessage": nativeErrorMessage,
           };
}


/**
 Resolve or reject a promise based on FIRUser value existance

 @param resolve RCTPromiseResolveBlock
 @param reject RCTPromiseRejectBlock
 @param user FIRUser
 */
- (void)promiseWithUser:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject user:(FIRUser *)user {
    if (user) {
        NSDictionary *userDict = [self firebaseUserToDict:user];
        resolve(userDict);
    } else {
        [self promiseNoUser:resolve rejecter:reject isError:YES];
    }

}


/**
 wrapper for sendEventWithName for auth events

 @param title sendEventWithName
 @param props <#props description#>
 */
- (void)sendJSEvent:(NSString *)title props:(NSDictionary *)props {
    @try {
        [self sendEventWithName:title body:props];
    } @catch (NSException *error) {
        NSLog(@"An error occurred in sendJSEvent: %@", [error debugDescription]);
    }
}

- (void)sendJSEventWithAppName:(NSString *)appName title:(NSString *)title props:(NSMutableDictionary *)props {
    props[@"appName"] = appName;

    @try {
        [self sendEventWithName:title body:props];
    } @catch (NSException *error) {
        NSLog(@"An error occurred in sendJSEvent: %@", [error debugDescription]);
    }
}

/**
 Converts an array of FIRUserInfo instances into the correct format to match the web sdk

 @param providerData FIRUser.providerData
 @return NSArray
 */
- (NSArray <NSObject *> *)convertProviderData:(NSArray <id <FIRUserInfo>> *)providerData {
    NSMutableArray *output = [NSMutableArray array];

    for (id <FIRUserInfo> userInfo in providerData) {
        NSMutableDictionary *pData = [NSMutableDictionary dictionary];

        if (userInfo.providerID != nil) {
            [pData setValue:userInfo.providerID forKey:@"providerId"];
        }

        if (userInfo.uid != nil) {
            [pData setValue:userInfo.uid forKey:@"uid"];
        }

        if (userInfo.displayName != nil) {
            [pData setValue:userInfo.displayName forKey:@"displayName"];
        }

        if (userInfo.photoURL != nil) {
            [pData setValue:[userInfo.photoURL absoluteString] forKey:@"photoURL"];
        }

        if (userInfo.email != nil) {
            [pData setValue:userInfo.email forKey:@"email"];
        }

        if (userInfo.phoneNumber != nil) {
            [pData setValue:userInfo.phoneNumber forKey:@"phoneNumber"];
        }

        [output addObject:pData];
    }

    return output;
}

/**
 Converts a FIRUser instance into a dictionary to send via RNBridge

 @param user FIRUser
 @return NSDictionary
 */
- (NSMutableDictionary *)firebaseUserToDict:(FIRUser *)user {
    NSMutableDictionary *userDict = [@{@"uid": user.uid, @"email": user.email ? user.email : [NSNull null], @"emailVerified": @(user.emailVerified), @"isAnonymous": @(user.anonymous), @"displayName": user.displayName ? user.displayName : [NSNull null], @"refreshToken": user.refreshToken, @"providerId": [user.providerID lowercaseString], @"phoneNumber": user.phoneNumber ? user.phoneNumber : [NSNull null], @"providerData": [self convertProviderData:user.providerData]} mutableCopy];

    if ([user valueForKey:@"photoURL"] != nil) {
        [userDict setValue:[user.photoURL absoluteString] forKey:@"photoURL"];
    }

    return userDict;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[AUTH_CHANGED_EVENT, AUTH_ID_TOKEN_CHANGED_EVENT, PHONE_AUTH_STATE_CHANGED_EVENT];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end

#else
@implementation RNFirebaseAuth
@end
#endif
