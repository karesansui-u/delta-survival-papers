# v4 変更履歴

## v2 → v4 の主な変更

### 用語の統一変更

| v2の用語 | v4の用語 | 英語 | 理由 |
|---------|---------|------|------|
| 構造消耗 | 段階損失 | stage loss | 情報理論・最適化で標準的 |
| 消耗量 d_t | 損失量 d_t | loss amount | 同上 |
| 純消耗 b_t | 純損失 b_t | net loss | 会計で標準 |
| 構造維持可能集合 | 生存可能集合 | viable set | Aubinの生存可能性理論に準拠 |
| 維持可能領域 | 生存可能領域 | viable region | 同上 |
| 有効維持余力 M | 有効資源 M | effective resource | 簡潔で普遍的 |
| 回復量 r_t | 修復量 r_t | repair amount | 工学・生物学で標準 |
| 凍結検証 | 事前登録検証 | pre-registered test | 科学方法論で定着 |
| 消耗局面 | 損失局面 | loss regime | — |
| 回復局面 | 修復局面 | repair regime | — |

### 変更しないもの

- 数式: S = Me^{-L}, m(V_n) = m(V_0)e^{-L_n}
- 変数記号: L, B, M, d_t, r_t, b_t, V, m
- 公理ラベル: A1, A2, B1-B4
- 理論名: 構造持続理論（Structural Persistence Theory）

### 変更の原則

1. 「この概念は既存のXに対応する」と明示する
2. 「Xと同じである」とは言わない（NonIdentityTheorem参照）
3. 読者が自分の分野の言葉で理解できるようにする
4. 数学的内容は一切変更しない

### Lean形式検証の反映

v4時点で372モジュール（v2時点は179モジュール）。
主な追加:
- 表現定理・不可能性定理（理論の一意性）
- 60+分野への formal bridge
- 200+の基礎定理の吸収
- 完全閉包定理（CompleteScopeClosure）
