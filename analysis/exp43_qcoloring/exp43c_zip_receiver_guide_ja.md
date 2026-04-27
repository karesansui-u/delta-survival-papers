# Python 再現実行 手順書（Exp43c zip 受領者向け）

状態: zip で Exp43c q-coloring 実行パッケージを受け取った人向けの手順書。
改善や再設計ではなく、凍結済みパッケージの再現実行だけを行う。

日付: 2026-04-27

## 1. 最初に知っておいてほしいこと

この作業は **再現実行** です。

してほしいこと:

1. zip を展開する
2. 指定手順どおりに実行する
3. 結果を返送する

してほしくないこと:

1. コードを改善する
2. 設計を変える
3. 指標や閾値を変える
4. 正式参照ファイルを上書きする

## 2. 受け取るもの

最低限、次のものを受け取ります。

1. `exp43c_true_outside_bundle_<hash>.zip`
2. 元になった公開 commit hash
3. zip 自体の sha256

この zip には、実行に必要なものだけが入っています。

1. `手順書.md`
2. `requirements.txt`
3. `実行環境メモ_テンプレート.md`
4. `BUNDLE_INFO.txt`
5. `analysis/exp43_qcoloring/config/exp43c_primary_config.json`
6. `analysis/exp43_qcoloring/src/*.py`
7. `analysis/exp43_qcoloring/data/exp43c_primary_manifest.jsonl`
8. `analysis/exp43_qcoloring/data/exp43c_primary_results.jsonl`
9. `analysis/exp43_qcoloring/data/exp43c_primary_evaluation.json`

最後の 3 つは比較用の正式参照ファイルです。上書きしないでください。

## 3. 作業の流れ

作業の流れはこの順です。

1. zip を展開する
2. 展開したフォルダに移動する
3. 依存関係を入れる
4. 出力先ディレクトリを作る
5. manifest 生成の事前確認
6. solver 実行の事前確認
7. manifest 生成
8. 本実行
9. 評価
10. 結果ファイルとメモを返送する

## 4. 実行コマンド

Windows の `cmd` / PowerShell では、`.py` を直接実行せず、必ず `python`
経由で実行してください。WSL / Ubuntu / macOS では `python` を `python3`
に読み替えても大丈夫です。

### 4-1. zip 展開

zip を展開し、展開されたフォルダに移動してください。

例:

```bash
unzip exp43c_true_outside_bundle_<hash>.zip
cd exp43c_true_outside_bundle_<hash>
```

Windows の場合は、エクスプローラーで展開してから、展開先フォルダで
PowerShell / cmd を開いても大丈夫です。

### 4-2. 依存関係

```bash
python -m pip install -r requirements.txt
```

### 4-3. 出力先の作成

```bash
python -c "from pathlib import Path; Path('analysis/exp43_qcoloring/external_outputs').mkdir(parents=True, exist_ok=True)"
```

### 4-4. manifest 生成の事前確認

```bash
python analysis/exp43_qcoloring/src/primary_manifest.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_manifest_external.jsonl --check-only
```

期待される表示:

```text
phase: exp43c_primary
planned instances: 4000
cells: 20
```

### 4-5. solver 実行の事前確認

この段階では solver を実行しません。最初の数件の例だけ表示します。

```bash
python analysis/exp43_qcoloring/src/pilot_runner.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_results_external.jsonl dry-run
```

### 4-6. manifest 生成

```bash
python analysis/exp43_qcoloring/src/primary_manifest.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_manifest_external.jsonl
```

### 4-7. 本実行

このコマンドは solver を使って 4000 インスタンスを解きます。PC によっては
時間がかかります。

```bash
python analysis/exp43_qcoloring/src/pilot_runner.py --config analysis/exp43_qcoloring/config/exp43c_primary_config.json --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_results_external.jsonl run --execute
```

### 4-8. 評価

```bash
python analysis/exp43_qcoloring/src/evaluate_primary.py analysis/exp43_qcoloring/external_outputs/exp43c_primary_results_external.jsonl --output analysis/exp43_qcoloring/external_outputs/exp43c_primary_evaluation_external.json
```

## 5. 返送してほしいもの

最低限、次のものを返送してください。

1. `analysis/exp43_qcoloring/external_outputs/exp43c_primary_manifest_external.jsonl`
2. `analysis/exp43_qcoloring/external_outputs/exp43c_primary_results_external.jsonl`
3. `analysis/exp43_qcoloring/external_outputs/exp43c_primary_evaluation_external.json`
4. 実行環境メモ
5. 回避策の有無
6. 一言の結論

実行環境メモは、zip ルートの `実行環境メモ_テンプレート.md` を埋めるだけ
で大丈夫です。

## 6. 一言の結論の書き方

`exp43c_primary_evaluation_external.json` を見て、次を確認してください。

1. `total_records` が `4000`
2. `timeout_summary` で `MALFORMED` 相当が出ていない
3. `fm_plus_n` の mean held-out log loss が raw baseline より良い

難しければ、自分で理論判断しなくて大丈夫です。次のどちらかで返してくださ
い。

1. 最後まで実行できた:
   `手順書どおりに最後まで実行できた`
2. 途中で止まった:
   `途中で止まったので、エラー内容を共有します`

## 7. 困ったときの判断

次のどちらかで迷ったら、変更せずに止めて相談してください。

1. コードや閾値を変えたくなったとき
2. 正式参照ファイルを上書きしそうなとき

詰まった場合は、変更せず止めて、その時点のエラーメッセージをそのまま返し
てください。

この作業は「より良くする」ことではなく、「そのまま再現する」ことが目的で
す。

## 8. 一言でのまとめ

```text
zip を展開し、指定手順を上から順番に実行し、結果ファイルと実行メモを返送
してください。改善や再設計は不要です。
```
