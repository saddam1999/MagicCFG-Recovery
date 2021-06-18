//
//  SSH_Functions.m
//  MagicCFG Recovery
//
//  Created by Jan Fabel on 12.02.21.
//

#import <Foundation/Foundation.h>
#import <NMSSH/NMSSH.h>


NSString* runSSH (NSString* command)
{
      NSLog (@"Hello");
    NMSSHSession *session = [NMSSHSession connectToHost:@"127.0.0.1:2222"
                                           withUsername:@"root"];
    

    if (session.isConnected) {
        [session authenticateByPassword:@"alpine"];

        if (session.isAuthorized) {
            NSLog(@"Authentication succeeded");
        }
    } else {
        return @"ERROR";
    }
        
    NSError *error = nil;
    NSString *response1 = [session.channel execute:@"find /System/Library/Caches/com.apple.factorydata -name 'bbpv*' -print" error:&error];
    sleep(1);
    NSString *response3 = [session.channel execute:@"find /System/Library/Caches/com.apple.factorydata -name 'seal*' -print" error:&error];
    sleep(1);
    NSString *introduction = [NSString stringWithFormat:@"cat %@", response1];
    NSString *introduction2 = [NSString stringWithFormat:@"cat %@", response3];
    NSString *response2 = [session.channel execute:introduction error:&error];
    sleep(1);
    NSString *response4 = [session.channel execute:introduction2 error:&error];
    NSString *final = [NSString stringWithFormat:@"[BBPV]\n %@\n\n[SEAL]\n%@", response2, response4];
    [session disconnect];
    return final;
}


NSString* eraseSSH () /// Not working with older devices...
{
      NSLog (@"Hello");
    NMSSHSession *session = [NMSSHSession connectToHost:@"127.0.0.1:2222"
                                           withUsername:@"root"];
    

    if (session.isConnected) {
        [session authenticateByPassword:@"alpine"];

        if (session.isAuthorized) {
            NSLog(@"Authentication succeeded");
        }
    } else {
        return @"ERROR";
    }
        
    NSError *error = nil;
    NSString *response1 = [session.channel execute:@"mount -o rw,union,update /" error:&error];
    sleep(1);
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"tool" ofType:@""];
    BOOL success = [session.channel uploadFile: filePath to:@"/bin/"];
    printf("%hhd", success);
    NSString *response3 = [session.channel execute:@"chmod -R 755 /bin" error:&error];
    sleep(1);
    printf("%s", response3);
    
    NSString *response4 = [session.channel execute:@"/bin/tool -command da7e6b6d2c20eb316c093" error:&error];
    sleep(1);
    [session disconnect];
    return response4;
}

