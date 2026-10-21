# iOS IoT Video Calling App

## Overview

Connect an iOS mobile client to an Agora IoT device for live audio/video calling and device interaction.

Repository: [AgoraIO-Community/ag-iot-ios-app](https://github.com/AgoraIO-Community/ag-iot-ios-app)

## Prerequisites and Setup

1. Use Xcode and a physical device running iOS 13 or later, with the matching device SDK v2.1.2.
2. Obtain Agora Link developer credentials (appId, key, secret) and the required IoT libraries; place the libraries in `iot_libs/` as described in the README.
3. From `IotLinkDemo/`, run `pod install`, open `IotLinkDemo.xcworkspace`, select your signing team and device, and build.
4. At first launch, enter the Agora Link credentials. Add the device by NodeId; the device list operates on `PUBLIC_STREAM_1`.

## What To Check

- Confirm the device moves through Connecting, Connected, and Subscribed states.
- Check device video, audio mute, recording and screenshots; disconnect and reconnect the device.

## Integration Notes

This is an Agora Link device-management sample. A matching provisioned IoT device is required; joining an ordinary RTC channel from a second browser is not the setup flow.

Keep App Certificates, customer secrets and privileged token generation on a trusted backend for production. Use only your own test credentials while configuring historical demos; do not commit them. Preserve the sample's existing dependency versions and lifecycle until a separate migration is tested.

## Source References

- [README.md](../../README.md)
- [IotLinkDemo/Podfile](../../IotLinkDemo/Podfile)

## Validation Status

This recipe was checked against the repository's source and setup documents. The platform build and live service/device flow have not been run as part of this documentation change. Complete the checks above in an environment with the required SDKs, hardware and service access before treating it as a validated deployment.

## Implementation Prompt

```text
You are working in AgoraIO-Community/ag-iot-ios-app. Use docs/ai/RECIPE.md and its linked source files to adapt the iOS IoT Video Calling App reference to this project.

Start by inspecting the actual sample directory and configuration described above. Resolve its listed missing prerequisites before claiming it is runnable. Preserve the existing architecture and compatible dependency versions. Implement the recipe's feature-specific flow, permissions and resource cleanup. Use a trusted backend for privileged credentials and tokens in production.

Run the repository-specific build or launch flow, then perform each What To Check item. Report the commands run, the observed results and anything blocked by service access, hardware or incomplete sample code. Do not claim live validation from a documentation or catalog build alone.
```
