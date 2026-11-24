import { FacebookLogin, FacebookLoginMode } from '@kora/fb-login';

@Entry
@Component
struct Index {
  @State appId: string = '';
  @State loggingIn: boolean = false;
  @State result: string = '输入 Facebook App ID 后选择登录方式。';

  private login(mode: FacebookLoginMode): void {
    if (this.loggingIn) {
      return;
    }
    const appId = this.appId.trim();
    if (!appId) {
      this.result = '请先输入 Facebook App ID。';
      return;
    }

    this.loggingIn = true;
    this.result = '正在登录…';
    const facebookLogin = new FacebookLogin({ appId: appId });
    facebookLogin.login(this.getUIContext(), {
      mode: mode,
      permissions: ['openid', 'public_profile'],
      authType: 'rerequest'
    }, (err, data) => {
      this.loggingIn = false;
      if (err && err.code !== 0) {
        this.result = `登录失败（${err.code}）：${err.message}`;
        return;
      }
      if (!data || data.resultCode === -1) {
        this.result = '已取消登录。';
        return;
      }
      if (data.resultCode !== 0 || !data.accessToken) {
        this.result = '登录返回数据无效：未取得 accessToken。';
        return;
      }

      // 在此将 data.accessToken 交给业务服务端，不打印或持久化完整令牌。
      this.result = `登录成功，已取得 accessToken。\n` +
        `已授权权限：${data.grantedScopes || '未返回'}\n` +
        `已拒绝权限：${data.deniedScopes || '未返回'}\n` +
        `有效期（SDK 原始值）：${data.expiresIn || '未返回'}`;
    });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('Facebook 登录 Demo')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        Text('使用本地 @kora/fb-login SDK')
          .fontSize(14)
          .fontColor('#666666')

        TextInput({ text: this.appId, placeholder: 'Facebook App ID' })
          .fontSize(16)
          .placeholderFont({ size: 16 })
          .enabled(!this.loggingIn)
          .onChange((value: string) => {
            this.appId = value;
          })

        Button('App 登录')
          .width('100%')
          .enabled(!this.loggingIn)
          .onClick(() => this.login(FacebookLoginMode.NATIVE_ONLY))
        Button('Web 登录')
          .width('100%')
          .enabled(!this.loggingIn)
          .onClick(() => this.login(FacebookLoginMode.WEB_ONLY))
        Button('优先 App，不可用时回退 Web')
          .width('100%')
          .enabled(!this.loggingIn)
          .onClick(() => this.login(FacebookLoginMode.NATIVE_WITH_FALLBACK))

        Text('App 登录需先完成 README 中的包名与签名配置。')
          .fontSize(14)
          .fontColor('#666666')
        Text(this.result)
          .fontSize(16)
          .width('100%')
          .padding(16)
          .backgroundColor('#F2F4F7')
          .borderRadius(8)
          .copyOption(CopyOptions.InApp)
      }
      .width('100%')
      .constraintSize({ maxWidth: 520 })
      .alignItems(HorizontalAlign.Start)
      .padding(24)
    }
    .width('100%')
    .height('100%')
  }
}
