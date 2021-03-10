# Agora Voice iOS

*[English](README.md) | 中文*

## 环境准备

- XCode 10.0 +
- iOS 真机设备
- 支持模拟器

## 运行示例程序

这个段落主要讲解了如何编译和运行实例程序。

### 下载 AgoraRte Framework
下载 [AgoraRte](https://github.com/AgoraIO-Usecase/AgoraVoice/releases/download/ios_1.1.0/AgoraRte.framework.zip) 并解压，然后将 "AgoraRte.framework" 文件移动到 "AgoraVoice-iOS/AgoraRte" 文件夹下。

### 获取 Keys

1. 在[agora.io](https://dashboard.agora.io/signin/)创建一个开发者账号。
2. 创建一个项目,  然后获取一组 **AppId**, **CustomerId**, **customerCertificate**。 
3. 用 **AppId**, **CustomerId**, **customerCertificate** 去更新 "Keys" 文件。


### Run
1. 在 "AgoraVoice-iOS/AgoraVoice" 路径下，使用 "pod install" 命令去链接所有需要依赖的库。
2. 最后使用 Xcode 打开 AgoraVoice.xcworkspace，连接 iPhone／iPad 测试设备，设置有效的开发者签名后即可运行。

## 联系我们

- 如果你遇到了困难，可以先参阅 [常见问题](https://docs.agora.io/cn/faq)
- 如果你想了解更多官方示例，可以参考 [官方SDK示例](https://github.com/AgoraIO)
- 如果你想了解声网SDK在复杂场景下的应用，可以参考 [官方场景案例](https://github.com/AgoraIO-usecase)
- 如果你想了解声网的一些社区开发者维护的项目，可以查看 [社区](https://github.com/AgoraIO-Community)
- 完整的 API 文档见 [文档中心](https://docs.agora.io/cn/)
- 若遇到问题需要开发者帮助，你可以到 [开发者社区](https://rtcdeveloper.com/) 提问
- 如果需要售后技术支持，你可以在 [Agora Dashboard](https://dashboard.agora.io) 提交工单
- 如果发现了示例代码的 bug，欢迎提交 [issue](https://github.com/AgoraIO-Usecase/AgoraVoice/issues)

## 代码许可

The MIT License (MIT)
