# CaptureVideoDemo
关于视频处理的一些东西....
JCCameraImageHelper 是一个帮助类

直接把摄像头的视频流投射到一个view上
- (void)embedPreviewInView:(UIView *)aView;

捕获摄像头其中的一帧并转化为CIImage

typedef void(^cameraCallBacklBlock)(CIImage *image, NSString *qrContent, BOOL *isNextFilterImage);
- (void)carmeraScanBlock:(cameraCallBacklBlock)cameraCallBacklBlock;

附带二维码识别功能

txttxttrtzt
