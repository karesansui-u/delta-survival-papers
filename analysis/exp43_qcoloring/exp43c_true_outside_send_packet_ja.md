# Exp43c True Outside-Group Send Packet JA

Status: send-ready Japanese request text for an Exp43c outside-group rerun.
This is not an empirical result and not validation evidence.

Date: 2026-04-27

Fill before sending:

```text
<SEND_COMMIT_HASH>
<ZIP_FILENAME>
<ZIP_SHA256>
```

## 1. Short Request

```text
はじめまして。

研究用 Python パッケージの再現実行について、ご相談させていただきました。

お願いしたいのはコード修正や改善ではなく、こちらで用意した zip ファイルと
手順書を使って、ご自身の環境で凍結済みの q-coloring 実験をそのまま再実行
し、結果ファイルを返送していただく作業です。

zip 名:
<ZIP_FILENAME>

zip sha256:
<ZIP_SHA256>

元になった公開 commit:
<SEND_COMMIT_HASH>

可能でしたら、手順書どおりに実行し、出力ファイル、ハッシュ、行数、簡単な
実行環境メモをご返送いただけますと幸いです。
```

## 2. Longer Posting Text

```text
【Python実行のご依頼】研究用 q-coloring パッケージの再現実行
（zip解凍・Python実行・改善不要）

zip でお渡しする Python 実行パッケージを、手順書どおりにご自身の PC 環境
で実行し、結果ファイルを返送していただきたいです。

新機能開発や改善提案ではなく、凍結済み実験の再現実行作業になります。

【依頼内容】

作業内容:
- zip ファイルを受け取る
- zip を展開する
- Python 依存関係を導入する
- 手順書どおりに事前確認と本実行を行う
- 指定された出力ファイルと実行メモを返送する

やってほしいこと:
- 手順書どおりに実行する
- 出力を指定ディレクトリに保存する
- 結果ファイル、ハッシュ、行数、ステータス数、簡単な実行メモを返送する

やらなくてよいこと:
- コード修正
- 改善提案
- 評価指標の変更
- 設計変更
- 新機能開発

使用言語:
- Python

実行形式:
- コマンドライン実行

用意してあるもの:
- zip 一式
- 手順書
- requirements.txt
- 実行環境メモのテンプレート
- 比較用の正式参照ファイル

所要時間の目安:
- PC 環境に依存します
- solver 実行を含むため、1 時間を超える可能性があります
- まず手順書の「事前確認」だけ実行し、問題なければ本実行に進んでください

必要な経験:
- Python 実行環境があること
- requirements.txt から依存関係を導入できること
- コマンドラインで Python スクリプトを実行できること
- 手順書どおりに作業し、結果を返送できること

注意:
- AI を手順整理の補助に使っていただいて構いません
- ただし、推測でコードや条件を変更しないでください
- うまくいかない場合は、変更せずにエラーメッセージをそのまま共有してください

zip 名:
<ZIP_FILENAME>

zip sha256:
<ZIP_SHA256>

元になった公開 commit:
<SEND_COMMIT_HASH>

ご確認お願いいたします。
```

## 3. Attachment Checklist

Attach or link:

1. `<ZIP_FILENAME>`
2. zip sha256: `<ZIP_SHA256>`

If the platform allows a note body, include:

1. this is a rerun of an already validated frozen package;
2. no code changes or redesign are requested;
3. returned artifacts should include the three output files plus the filled
   environment memo.
