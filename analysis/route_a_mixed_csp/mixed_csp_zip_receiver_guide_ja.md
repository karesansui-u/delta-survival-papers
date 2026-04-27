# Python 再現実行 手順書（zip 受領者向け）

状態: zip で Mixed-CSP 実行パッケージを受け取った人向けの手順書。改善や再
設計ではなく、凍結済みパッケージの再現実行だけを行う。

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

1. `mixed_csp_true_outside_bundle_<hash>.zip`
2. 元になった公開コミット hash
3. zip 自体の sha256

この zip には、実行に必要なものだけが入っています。

1. `手順書.md`
2. `requirements.txt`
3. `実行環境メモ_テンプレート.md`
4. `analysis/route_a_mixed_csp/run_mixed_csp.py`
5. `analysis/route_a_mixed_csp/analyze_mixed_csp.py`
6. `analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py`
7. `analysis/route_a_mixed_csp/mixed_csp_generator.py`
8. `analysis/route_a_mixed_csp/mixed_csp_solvers.py`
9. `analysis/route_a_mixed_csp/mixed_csp_aborted_primary_attempt_2026-04-22_0338.jsonl`
10. `analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl`
11. `analysis/route_a_mixed_csp/mixed_csp_results.json`
12. `analysis/route_a_mixed_csp/mixed_csp_results_summary.md`

`mixed_csp_aborted_primary_attempt_2026-04-22_0338.jsonl` は regression 診断
で使う参照ファイルです。

最後の 3 つは比較用の正式参照ファイルです。実行対象ではありません。

## 3. 作業の流れ

作業の流れはこの順です。

1. zip を展開する
2. 展開したフォルダに移動する
3. 依存関係を入れる
4. 出力先ディレクトリを作る
5. 事前確認の試行
6. 事前確認の本実行
7. エンコーディング診断
8. 本実行前の試行
9. 本実行
10. 保留テスト集計
11. 結果ファイルとメモを返送する

## 4. 実行コマンド

### 4-1. zip 展開

```bash
unzip mixed_csp_true_outside_bundle_<hash>.zip
cd mixed_csp_true_outside_bundle_<hash>
```

展開先のフォルダ名が違う場合は、2 行目はその名前に合わせてください。

### 4-2. 依存関係

```bash
python3 -m pip install -r requirements.txt
```

### 4-3. 出力先の作成

```bash
mkdir -p analysis/route_a_mixed_csp/external_outputs
```

### 4-4. 事前確認の試行

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/external_outputs/mixed_csp_smoke_external.jsonl \
  smoke dry-run
```

### 4-5. 事前確認の本実行

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/external_outputs/mixed_csp_smoke_external.jsonl \
  smoke run --execute
```

### 4-6. エンコーディング診断

```bash
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py regression
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 1000
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 500 --n 80 --density 2.0
python3 analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py agreement --instances 500 --n 160 --density 2.0
```

### 4-7. 本実行前の試行

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/external_outputs/mixed_csp_primary_external.jsonl \
  primary dry-run
```

### 4-8. 本実行

```bash
python3 analysis/route_a_mixed_csp/run_mixed_csp.py \
  --output analysis/route_a_mixed_csp/external_outputs/mixed_csp_primary_external.jsonl \
  primary run --execute
```

### 4-9. 保留テスト集計

```bash
python3 - <<'PY'
import sys
from pathlib import Path
sys.path.insert(0, 'analysis/route_a_mixed_csp')
import analyze_mixed_csp as am
outdir = Path('analysis/route_a_mixed_csp/external_outputs')
am.RESULTS_JSON = outdir / 'mixed_csp_primary_external_results.json'
am.RESULTS_MD = outdir / 'mixed_csp_primary_external_summary.md'
print(am.analyze(outdir / 'mixed_csp_primary_external.jsonl'))
PY
```

## 5. 返送してほしいもの

最低限、次のものを返送してください。

1. `analysis/route_a_mixed_csp/external_outputs/mixed_csp_primary_external.jsonl`
2. `analysis/route_a_mixed_csp/external_outputs/mixed_csp_primary_external_results.json`
3. `analysis/route_a_mixed_csp/external_outputs/mixed_csp_primary_external_summary.md`
4. 実行環境メモ
5. 回避策の有無
6. `support` の 4 つの真偽値
7. 一言の結論

実行環境メモは、zip ルートの `実行環境メモ_テンプレート.md` を埋めるだけ
で大丈夫です。

書き方:

1. 各項目は `:` の後ろに記入する
2. 最後の `記入欄:` の下に、一言の結論を 1 行だけ書く

一言の結論は、自分で解釈して書く必要はありません。`mixed_csp_primary_external_results.json`
の `support` を見て、次のどちらかをそのまま書いてください。

1. 4 つすべて `true`:
   `4つの支持フラグがすべて true だったので再現した`
2. 1 つでも `false`:
   `4つの支持フラグのうち少なくとも1つが false だったので再現しなかった`

## 6. 実行環境メモに入れてほしいこと

1. OS
2. Python version
3. もし分かれば solver / 依存ライブラリ version
4. 何か回避策を使ったかどうか

## 7. 困ったときの判断

次のどちらかで迷ったら、変更せずに止めて相談してください。

1. コードや閾値を変えたくなったとき
2. 正式参照ファイルを上書きしそうなとき

この作業は「より良くする」ことではなく、「そのまま再現する」ことが目的で
す。

## 8. 一言でのまとめ

```text
zip を展開し、指定手順を上から順番に実行し、結果ファイルと実行メモを返送
してください。改善や再設計は不要です。
```
