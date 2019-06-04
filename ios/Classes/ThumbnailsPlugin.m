#import "ThumbnailsPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation ThumbnailsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"thumbnails"
            binaryMessenger:[registrar messenger]];
  ThumbnailsPlugin* instance = [[ThumbnailsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"getThumbnail" isEqualToString:call.method]) {
      @try {
          NSString *filepath = call.arguments[@"videoFilePath"];
          filepath = [filepath stringByReplacingOccurrencesOfString:@"file://"
                                                         withString:@""];
          NSURL *videoURL = [NSURL fileURLWithPath:filepath];
          
          MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]
                                                  initWithContentURL:videoURL];
          moviePlayer.shouldAutoplay = NO;
          UIImage *thumbnail = [moviePlayer thumbnailImageAtTime:1.0
                                                      timeOption:MPMovieTimeOptionNearestKeyFrame];
          // save to document directory
          NSString* documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                         NSUserDomainMask,
                                                                         YES) lastObject];
          if (thumbnail != nil) {
              NSData *data = UIImageJPEGRepresentation(thumbnail, 1.0);
              NSFileManager *fileManager = [NSFileManager defaultManager];
              NSString *fullPath = [documentDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"thumb-%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]]];
              bool fileIsWrited = [fileManager createFileAtPath:fullPath contents:data attributes:nil];
              if (result && fileIsWrited) {
                  result(fullPath);
              } else {
                  result(@"An error occurs when try to write the output image file");
              }
          } else {
              result(@"An error occurs when try to extract image from video");
          }
      } @catch(NSException *e) {
          result(@{@"error": e.reason});
      }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
