# Tera Term Cisco 複数機器コンフィグ取得マクロ v0.2

## 構成

- `capture.ttl`
- `hosts.txt` : 1行1ホスト
- `commands.txt` : 1行1コマンド
- `capture_summary.txt` : 実行結果
- `cursor_review_prompt.txt`

## 通常取得

実行ごとに次の形式でフォルダを作成します。

    logs\YYYYMMDD_HHMM\

各機器のログは、

    <host>_log.txt

として保存します。

同一分に再実行した場合は `_02`, `_03` を付与します。

## TFTP redirect モード

Cisco IOS / IOS-XE 側で次の形式を実行します。

    show running-config | redirect tftp://<TFTP_SERVER>/<filename>

TFTPサーバーは、Tera Term実行PCとは別機器でも問題ありません。

### 重要

このマクロでは以下を行いません。

- TFTP先ファイルの存在確認
- 0KB確認
- 自動リトライ

TFTP先の確認は、別途PowerShell等で目視確認する運用を想定しています。

マクロ側では、

- redirectコマンド送信
- Ciscoプロンプト復帰確認
- 実行結果をsummaryへ記録

までを担当します。

## 安全側の動作

redirect実行後にCiscoの `#` プロンプトが戻らない場合、
その機器の処理を打ち切ります。

状態不明のまま次コマンドを送信しないためです。

## 認証

認証情報はファイルへ保存せず、実行時に入力します。

## 未実施

- 実機Cisco IOS / IOS-XEでの検証
- 利用環境のAAA/enable差分確認
- 利用中TFTPサーバーでの転送確認

本番利用前に検証機1台で `show version` 等から確認してください。
