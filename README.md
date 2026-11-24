# FacebookLoginDemo

最小 HarmonyOS Facebook 登录示例，本地引用 `libs/facebookLogin.har`（`@kora/fb-login` 1.0.1），无需复制 SDK 源码。

## 运行

1. 使用支持 API 22 的 DevEco Studio 打开项目，执行 Sync / `ohpm install`。
2. 配置应用签名后运行到设备。
3. 在页面输入已注册安卓应用的 Facebook App ID，选择登录方式。

当前 HAR 的最低兼容版本为 API 21，所以 Demo 的 `compatibleSdkVersion` 设置为 `6.0.1(21)`，目标版本保留 API 22。

## 登录示例

调用代码集中在 `entry/src/main/ets/pages/Index.ets`：

```typescript
const facebookLogin = new FacebookLogin({ appId: appId });
facebookLogin.login(this.getUIContext(), {
  mode: mode,
  permissions: ['openid', 'public_profile'],
  authType: 'rerequest'
}, (err, data) => {
  // 非零 err.code：失败；data.resultCode === -1：取消。
  // data.resultCode === 0 且 accessToken 非空：成功。
});
```

- App 登录：`FacebookLoginMode.NATIVE_ONLY`。
- Web 登录：`FacebookLoginMode.WEB_ONLY`，使用 SDK 内置 WebView。
- 优先 App：`FacebookLoginMode.NATIVE_WITH_FALLBACK`，仅 App 不可用时回退 Web；取消、签名或配置错误不回退。

登录中禁用输入和按钮，避免重复授权。页面展示成功、取消、错误码和授权信息，不输出完整 Token。实际业务可在成功回调处将 `data.accessToken` 交给服务端获取用户信息。

## 宿主配置

已配置 `ohos.permission.INTERNET` 和 `querySchemes: ["bridgesdk"]`。

Web 登录需要有效 App ID、对应 Facebook 后台登录配置及能访问 Facebook 的网络。

App 登录还需要：

1. 将 `entry/src/main/module.json5` 的 `anco_packageName` 替换为 Facebook 后台登记的安卓包名。
2. 在 `entry/src/main/resources/rawfile/` 放入该安卓应用的 DER 格式签名证书 `anco_cert.der`。
3. 在同一目录放入 `anco_sign.json`：

   ```json
   { "anco_signInfo": "签名后的 Base64 字符串" }
   ```

待签名内容为 `<安卓包名>-<当前鸿蒙应用appIdentifier>`，使用安卓应用签名私钥按 `SHA256withRSA` 签名，再进行 Base64 编码。私钥不要放入项目。安装应用后可查询身份：

```bash
hdc shell "bm dump -n com.example.facebooklogindemo|grep appIdentifier"
```

本 Demo 不提供虚假的证书或签名占位文件；未完成配置时可先验证 Web 登录。