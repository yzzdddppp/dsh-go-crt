# dsh-Go + 550C CRT 层（自制版）

基于 https://github.com/ccch1mneyyy/dsh-Go 的改动版，只做两件事：

1. `app/lib/ui/common/crt_overlay.dart` — 新增 CRT 覆盖层（扫描线 / 滚动刷新带 / 暗角 / 微闪）
2. `app/lib/app.dart` — 在 `MaterialApp.builder` 外层包上 `CrtOverlay`

另外把包名改成 `io.github.ccch1mneyyy.dsh_app.mine`，让这个版本可以和官方 App 并存，不覆盖、不卸载、不动原有数据。

## 出 APK

推到你的仓库（main 分支），GitHub Actions 会自动跑 `Build APK`，十分钟左右在
Actions → 运行记录 → Artifacts 里下载 `dsh-go-crt-apk`。

也可以在 Actions 页面手动点 `Run workflow`。

## 调参数

改 `app/lib/ui/common/crt_overlay.dart` 里 `CrtOverlay` 的默认值：

| 参数 | 默认 | 作用 |
|---|---|---|
| `scanlineAlpha` | 46 | 扫描线浓度 0–255 |
| `lineSpacing` | 3.0 | 线间距，越小越密 |
| `vignetteStrength` | 0.55 | 暗角强度 0–1 |
| `rollDuration` | 7 秒 | 刷新带扫一屏的时间 |
| `flicker` | true | 微闪 |
| `tint` | `#E8A020` | 刷新带颜色（绿 `#4AD46A` / 青 `#3FC8DC` / 白 `#C9C9C9`） |

## 装

下载 APK，手机点开安装（允许未知来源）。首次启动是全新环境，
用 `DSH-Go/migrate` 那个包把记忆和插件搬过来。
