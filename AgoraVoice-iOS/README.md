# Agora Voice iOS

*English | [中文](README.zh.md)*

## Prerequisites

- Xcode 10.0+
- Physical iOS device (iPhone)
- iOS simulator is supported

## Quick Start

This section shows you how to prepare, build, and run the application.

### Download AgoraRte Framework

Download [AgoraRte](https://github.com/AgoraIO-Usecase/AgoraVoice/releases/download/ios_1.1.0/AgoraRte.framework.zip), unzip and move "AgoraRte.framework" to "AgoraVoice-iOS/AgoraRte".

### Obtain keys

1. Create a developer account at [agora.io](https://dashboard.agora.io/signin/). Once you finish the signup process, you will be redirected to the Dashboard.
2. Create a project, and get An **AppId**, a **CustomerId**, a **customerCertificate**. 
3. Use **AppId**, **CustomerId**, **customerCertificate** to update "Keys" file.

### Run

1. Into "AgoraVoice-iOS/AgoraVoice" path, use "pod install" command to link all dependent frameworks and libs.
  
2. Open "AgoraVoice.xcworkspace", connect your iPhone device and run the project. Ensure a valid provisioning profile is applied or your project will not run.

## Contact Us

- For potential issues, take a look at our [FAQ](https://docs.agora.io/en/faq) first
- Dive into [Agora SDK Samples](https://github.com/AgoraIO) to see more tutorials
- Take a look at [Agora Use Case](https://github.com/AgoraIO-usecase) for more complicated real use case
- Repositories managed by developer communities can be found at [Agora Community](https://github.com/AgoraIO-Community)
- You can find full API documentation at [Document Center](https://docs.agora.io/en/)
- If you encounter problems during integration, you can ask question in [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io)
- You can file bugs about this sample at [issue](https://github.com/AgoraIO-Usecase/AgoraVoice/issues)

## License

The MIT License (MIT)
