# Tera Term Cisco 複数機器コンフィグ取得マクロ v0.3

Cisco IOS / IOS-XE を対象に、複数機器へ順番に接続して複数の `show` コマンドを取得する簡易版マクロです。

## 主な仕様

- `hosts.txt` : 1行1ホスト
- `commands.txt` : 1行1コマンド
- 通常取得 : `logs\\YYYYMMDD_HHMM\\<host>_log.txt`
- 認証・特権EXEC到達が全方式で失敗 : `logs\\YYYYMMDD_HHMM\\<host>_NG.txt`
- TFTP redirect : Cisco機器からTFTPサーバーへ直接送信
- TFTP先ファイルの存在確認、0KB確認、自動リトライは行わない

## 初回セットアップ

Tera Term 5.x と Windows PowerShell 5.1 以降を前提とします。

最初に、利用するWindowsユーザーで次を実行します。

```powershell
powershell.exe -NoProfile -File .\setup-credentials.ps1
```

登録対象は次の3方式です。不要な方式はユーザー名を空欄にして無効化できます。

1. TACACS SSH : ユーザー名 / パスワード
2. 共通SSH : ユーザー名 / パスワード / enableパスワード
3. 共通Telnet : ユーザー名 / パスワード / enableパスワード

資格情報は次の場所へ保存します。

```text
%LOCALAPPDATA%\TeraTermCiscoMacros\credentials.v1.json
```

ファイル内のユーザー名・パスワード・enableパスワードは、Windows DPAPI を利用して現在のWindowsユーザーに紐づけて暗号化します。暗号化用の独自キーをリポジトリや同一フォルダへ保存しません。

**注意:** 複数人が同じWindowsログオンアカウントを共有している場合、DPAPIはその人同士を区別できません。共有端末でも、Windowsアカウント自体は個人ごとに分かれている運用を推奨します。

## 実行

通常はTTLを直接開かず、次を起動します。

```text
start-capture.cmd
```

`start-capture.ps1` がDPAPI保護された資格情報を復号し、当該プロセスの環境変数だけへ渡してから `capture.ttl` を起動します。終了時にランチャー側の環境変数を削除します。

## 認証フォールバック

各ホストで次の順に1回ずつ試します。

1. **TACACS SSH**
2. **共通SSH**
3. **共通Telnet**

TACACS SSH はログイン直後に特権EXEC `#` へ到達することを前提とします。認証自体が成功しても `>` の場合は、その方式では取得せず共通SSHへフォールバックします。

共通SSH / 共通Telnetで `>` の場合は `enable` を実行し、方式ごとに登録したenableパスワードで `#` への到達を確認します。

すべての方式で認証または特権EXEC到達に失敗した場合、そのホストではコマンドを送らず、次のようなファイルを作成します。

```text
<host>_NG.txt
```

NGファイルにはホスト、時刻、失敗した方式・段階だけを記録し、ユーザー名やパスワードは出力しません。

**Telnetは通信経路上で資格情報を暗号化しません。** 最終フォールバックとしてのみ使用し、利用ネットワークの運用方針に従ってください。

## 通常取得

実行ごとに次の形式でフォルダを作成します。

```text
logs\YYYYMMDD_HHMM\
```

同一分に再実行した場合は `_02`, `_03` を付与します。

成功した各機器のログ:

```text
<host>_log.txt
```

実行結果:

```text
capture_summary.txt
```

## TFTP redirect モード

Cisco IOS / IOS-XE 側で次の形式を実行します。

```text
show running-config | redirect tftp://<TFTP_SERVER>/<filename>
```

TFTPサーバーはTera Term実行PCとは別機器でも問題ありません。通信元はCisco機器です。

このマクロでは以下を行いません。

- TFTP先ファイルの存在確認
- 0KB確認
- 自動リトライ

マクロ側では、redirectコマンド送信、Ciscoプロンプト復帰確認、summaryへの記録までを担当します。受信確認はTFTPサーバー側で行ってください。

## 安全側の動作

- 認証方式はTACACS SSH → 共通SSH → 共通Telnetの順で固定
- 特権EXEC `#` を確認できない方式では取得コマンドを送らない
- コマンド実行後に `#` が戻らない場合、その機器の後続コマンドを送らない
- 全認証方式失敗時は `<host>_NG.txt` を残して次ホストへ進む
- 資格情報はリポジトリ、取得ログ、summary、NGファイルへ書かない
- TFTPの0KB検知・自動再送は行わない

## 構成

- `capture.ttl` : 本体
- `setup-credentials.ps1` : DPAPI資格情報登録
- `start-capture.ps1` : 復号・起動ランチャー
- `start-capture.cmd` : ダブルクリック用ランチャー
- `hosts.txt` : 1行1ホスト
- `commands.txt` : 1行1コマンド
- `cursor_review_prompt.txt` : Cursor等で再レビューするためのプロンプト

## 未確認事項

以下はコード上の設計であり、利用環境での結合確認が必要です。

- 実機Cisco IOS / IOS-XEでの認証フォールバック
- 実際のAAA / enable設定差異
- Windows端末上のTera Term + PowerShell + DPAPIの結合動作
- 初回SSHホスト鍵確認やTTSSHダイアログの挙動
- 利用中TFTPサーバーでの転送

本番利用前に、検証機1台・`show version` 等の読み取り専用コマンドから確認してください。
