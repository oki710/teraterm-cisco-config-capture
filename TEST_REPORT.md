# v0.3 検証結果

検証日：2026-10-27（日本時間）

## 確認済み

GitHub Actions の Windows runner で一時検証を実施し、run `40444137358` は **success** でした。

- `setup-credentials.ps1` のPowerShell構文解析
- `start-capture.ps1` のPowerShell構文解析
- Windows DPAPIによる `ConvertFrom-SecureString` → `ConvertTo-SecureString` の往復
- 8個の認証用環境変数名の整合
- TACACS SSH → 共通SSH → 共通Telnetの順序
- `TACACS_NOT_PRIVILEGED` の分岐
- `<host>_NG.txt` 出力経路
- 専用 `capture.ini` の利用
- TTL内で保存資格情報用の `passwordbox` を使わないこと

一時検証用GitHub Actions workflowは確認後に削除しており、配布物には残していません。

## 未確認

- Tera Term本体でのTTLネイティブ実行
- Cisco IOS / IOS-XE実機へのSSH/Telnet接続
- TACACS/ローカルAAAの実環境フォールバック
- enable成功・失敗の実機挙動
- 初回SSHホスト鍵確認、TTSSHダイアログ
- TFTPサーバーへの実転送
- 強制終了時のプロセスメモリ残留

本番利用前に、検証機1台と読み取り専用コマンド（例：`show version`）で受入確認してください。
