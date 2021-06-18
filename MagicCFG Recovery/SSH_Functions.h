//
//  SSH_Functions.h
//  MagicCFG Recovery
//
//  Created by Jan Fabel on 12.02.21.
//

#ifndef SSH_Functions_h
#define SSH_Functions_h
#import <Foundation/Foundation.h>
#import <NMSSH/NMSSH.h>

NSString* runSSH (NSString* command);
NSString* eraseSSH();

#endif /* SSH_Functions_h */
