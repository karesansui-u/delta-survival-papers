LLM 長期記憶制御
================
MemoryGit を有限の記憶制御層として読む
— 推定レイヤーにおける設計境界ノート —


要旨
----

本ノートは、MemoryGit 型の長期記憶を公開側でどう位置づけるかを記録する設計境界ノートである。新しい経験的支持パッケージを追加するものではない。ここで固定するのは、長期記憶を「全部覚える装置」や「人間記憶の再現」としてではなく、LLM の長期運用に必要な記憶制御層として読むための境界である。

中心となる設計境界は次である。

> LLM の長期記憶では、ユーザー入力を直ちに確定事実へ変換するのではなく、入力の出所、発話上の役割、範囲、権限、時間性、安定度を分けて扱うことが有望な設計境界になる。

この意味で MemoryGit は、有限の operational memory-control layer である。実体は、total recall database ではなく、不変な入力イベントログと、ポリシーにより再構成される可変ビューの組み合わせに近い。


1. 維持対象
-----------

対象は、長期運用される LLM 対話である。そこでは、ユーザー入力、assistant 出力、コピペ文、第三者情報、タスク、許可、削除要求、不安定な好み、仮説、相槌、後からの訂正が長期に蓄積する。

維持すべき構造は「過去に観測された全事実」ではない。維持すべきなのは、安全な読出し状態である。

- 現在使ってよい情報は、必要なときに使える。
- historical / hypothetical / quoted / third-party / no-store / secret / deleted / scope-limited な情報は、無制限の current premise に昇格しない。
- 矛盾や不安定な commitment は、単一の profile fact に潰されない。
- 後続の retrieval / action で、その記憶がなぜ使われたか、なぜ block されたか、なぜ excluded / review になったかを説明できる。

失敗境界は memory pollution である。すなわち、出所、commitment、scope、permission、time、stability がその使用を支えていないのに、あるテキストを current user fact や action premise として保存・読出ししてしまうことである。


2. Truth maintenance systems との接続
-------------------------------------

入力文を孤立した無条件の真理として扱わないという発想には、古典 AI の系譜がある。Doyle の truth maintenance system (TMS)、de Kleer の assumption-based truth maintenance system (ATMS)、および belief revision の周辺研究は、belief、assumption、justification、contradiction をどう管理するかを扱ってきた。

MemoryGit はこの系譜に接続する。ただし、同一視してはいけない。

共有する問題意識は次である。

- assertion を永久真理として扱わない。
- 後から revision できるように dependency / assumption を残す。
- inconsistent assumptions を同時に使わないようにする。

一方で、MemoryGit 側の問題は次の点で異なる。

第一に、入力は綺麗な記号命題ではなく、messy な自然言語会話である。ユーザーは draft を貼り、別モデルを引用し、丁寧な相槌を返し、仮定の話をし、一回限りの action を頼み、あとから過去の発話を弱める。

第二に、必要なラベルは truth label だけではない。長期 LLM 記憶では、source、speech act、scope、permission、deletion state、action eligibility、stability が同じくらい重要になる。

第三に、目標は full logical closure ではない。目標は operational readout である。つまり、この回答、この action、この scope、この時点で、その情報をどう使ってよいかである。

第四に、LLM は自然言語上の手がかりを読む補助には使えるが、最終安全境界を unconstrained LLM に任せるべきではない。現実解は、model-assisted parsing と明示的な構造検査と台帳化された判断の混成である。

したがって MemoryGit は、TMS-adjacent な operational layer として述べるべきであり、古典的 belief revision を一般に解いたという主張ではない。


3. 無限メタ推論ではなく有限メタポリシー
----------------------------------------

「この入力は本当に正しいか」を問う記憶システムは、すぐに再帰的な罠に入る。

- その入力を正しいと判定したのは誰か。
- その判定器を正しいと判定したのは誰か。
- そのメタ判定器自体が汚染されていたらどうするか。

MemoryGit は、これを無限の哲学問題として扱わない。メタ階層を有限の operational policy で打ち切る。

すなわち、最終真理を証明しようとせず、入力の出所、発話上の役割、同意の範囲、確信度、利用範囲、権限、削除状態、安定度のような有限個の運用状態として記録する。

重要なのは、これらが形而上学的な真理分類ではないことである。後で安全に使うための operational category である。具体的なラベル体系や遷移規則は実装・評価境界に属するため、この公開ノートでは固定しない。


4. state と stability は分ける
------------------------------

公開側で特に強調すべき境界は、現在使えるかという状態と、どれくらい軽く更新してよいかという安定度の分離である。

state は次を答える。

> この情報は今どう使えるか。

stability は次を答える。

> この分類を変更するコストはどれくらい高いか。

これにより、高い安定度を「より真である」と誤読しなくて済む。安定度の高い記憶は、他の記憶より形而上学的に真なのではない。ユーザーまたは policy により、軽い相槌、引用、未確認入力だけでは動かすべきでない高い更新コストを持つだけである。


5. ここでいう Git の意味
------------------------

Git は入口の比喩として有用だが、literal Git は長期会話記憶には硬すぎる。

Git が示唆する有用な要素は次である。

- 不変履歴
- diff
- branch
- conflict visibility
- rollback
- auditability

しかし長期会話記憶には、再構成ビューも必要である。

- current-use view
- project-scoped view
- historical snapshot view
- no-store / deletion-blocking view
- action-eligible view
- review-required view

したがって実装比喩としては、literal Git over facts ではなく、次の形が近い。

> immutable raw event log + mutable reconstructed views + policy-controlled readout

これは event sourcing に近い。raw input は event として残り、使える記憶状態は、それらから再構築される projection であり、再構築、監査、訂正ができる。


6. 人間記憶は警告であって設計図ではない
----------------------------------------

人間の記憶は再構成的である。人は作話し、source を混同し、矛盾を滑らかにし、自己像を守り、過去の出来事を後から解釈し直す。これは興味深いが、人工記憶システムの最適設計を意味しない。

借りるべき教訓は「人間記憶をコピーせよ」ではない。

> 記憶は単一機構ではない。

人間の社会的認知は、しばしば暗黙に次を分けている。

- その人が何を言ったか。
- それを本心として言ったのか。
- 冗談、建前、丁寧な相槌、面倒な同意ではなかったか。
- quote や pasted text ではないか。
- 今も有効か。
- 他者に言ってよいか。
- action に使う前に確認すべきか。

MemoryGit は、この暗黙の社会的区別を LLM システムが扱える程度に明示化する。人間の source confusion や motivated forgetting を設計目標として継承するものではない。


7. Total recall は目標ではない
-------------------------------

持続的な assistant は、すべてを覚えることを目標にすべきではない。total recall は多くの場合、誤った目標である。

目標は、選択的で、権限づけられ、巻き戻し可能な記憶である。

- raw event は許可された retention policy の範囲でだけ保持する。
- ambiguous input を current fact に昇格しない。
- deleted / no-store boundary を保つ。
- 不確実な commitment は event-only または review_required に置く。
- 過去状態を聞かれたときは historical snapshot を使う。
- high-stability memory は変更不能にするのではなく、変更に review を要求する。

この意味で、forgetting はデフォルトで failure mode ではない。forgetting、blocking、archiving、refusing promotion は中核操作である。


8. Context-window 構造は別レイヤーである
----------------------------------------

外部記憶制御は、context-window engineering を置き換えない。外部記憶状態が正しくても、長い context では attention dynamics、position bias、distractor effect、recency effect、prompt layout により失敗しうる。

したがって、少なくとも二つのレイヤーを分ける必要がある。

1. 外部記憶代謝: ある memory がどの state を持ち、読んでよいかを決める。
2. in-context presentation: 取り出した情報を prompt / context window 内でどう構造化するかを決める。

MemoryGit が主に扱うのは第一の層である。第二の層に対しても、clean, scoped, state-labeled readout を渡すことで助けにはなるが、それだけで in-context degradation 全体を解くわけではない。


9. 構造持続理論との関係
-----------------------

構造持続理論の中で、本プロファイルは inference layer に属する。「安全な記憶状態」の真の feasible region は直接数えられない。代わりに、観測可能な indicator を使う。

- unsafe current promotion
- scope leak
- deletion leak
- no-store violation
- third-party fact leakage
- blocked / uncertain claim に基づく action allow
- 必要な current / historical readout の value miss
- overblocking による utility collapse

構造消耗側の読みは次である。

> 汚染された、または未整理の memory state は、将来安全に取りうる answer / action path の集合を減らす。

回復側の読みは次である。

> 出所の記録、範囲境界、削除状態、review、構造検査、rollback、ledger は、安全に取りうる未来の path を保存または回復する。

これは estimation-layer profile である。正確な feasible path set を数えているとは主張しない。主張できるのは、規律ある memory-control layer が、unsafe use を減らしつつ utility を universal refusal へ潰していないかを、固定した内部検査で調べられる、という限定された方向である。

Lean 側の抽象接続は `llm_epistemic_control_bridge.md` に分ける。そこでは、
memory qualification を raw input の truth 判定としてではなく、accept-all
policy と filtered policy の post-admission coherent region の比較として読む。
証明されるのは、filter soundness に相当する region-containment 仮定のもとで、
filtered policy が accept-all policy より大きな log-ratio loss を負わない、
という条件つき補題である。これは MemoryGit や任意の記憶実装が安全である
ことの証明ではなく、memory-control layer を net-action kernel へ接続する
ための抽象 interface である。
`../../../lean/Survival/LLMEpistemicControlToy.lean` では、stale memory の
eligibility rejection と eligible memory admission の no-more-loss 比較を、
有限 toy surface としてこの抽象 interface に接続している。


10. 現在の検証境界
-------------------

2026-05-16 時点の内部実装台帳では、本プロファイルの主要論点は複数の小型検査で確認されている。ただし、それらはこの公開 v3 bundle における外部再実行済み証拠ではない。ここでは、現在の設計テレメトリとしてのみ読む。

内部検査で有望な兆候があるのは次の領域である。

- 短い相槌や曖昧な同意を、assistant 長文全体への同意として昇格しないこと。
- 文脈なしの長文ペースト、引用、別 AI 出力、第三者情報を user-authored current fact として扱わないこと。
- memory state と stability を分け、高安定度の記憶を軽い入力だけで動かさないこと。
- background、training example、manual excerpt、quote、meeting recap などの non-operative discourse を readout / action request と誤読しないこと。
- 近接した利用状態を、モデル出力だけに任せず後段の構造制御で分けること。
- secret、scope、deletion、third-party、no-store 境界を、モデル出力だけに任せず後段の構造制御で扱うこと。
- no-store と一回限り action の境界を分けること。
- 長期記憶の選択読出しを継続学習の更新・保持実験へ接続すること。

現時点の内部テレメトリは、特定の実装条件では入力資格づけ、no-store / action 境界、状態と安定度の分離、選択読出しを含む構成が有望であることを示している。ただし、条件名、数値、修理規則、候補構成の詳細は内部検証台帳に留める。この公開ノートでは、内部条件を公開証拠として主張しない。

一方で、まだ設計上の弱点として残っている領域もある。

- no-store と action utility の大規模化。より長い実ログ、複数話題、第三者情報、secret、外部送信、未来タスクが混ざる場合に過剰 block と unsafe allow の双方を抑える必要がある。
- retention policy の seed sensitivity。長期保持側は再提示方針によって seed ごとの揺れが残る。
- 内部候補構成のどの部品が効いているかの強い分解。通常 ablation では一部ノブが実行経路上で同値になりやすいため、より強い分解実験が必要である。
- 実プロダクト traffic、独立外部生成器、長期自然会話の大規模 blind holdout への一般化。
- context-window 内での提示順、attention bias、distractor effect との相互作用。

したがって、現時点で安全に言えるのは次である。

> MemoryGit 型の memory-control layer は、入力を fact storage へ直行させず、出所、発話上の役割、利用状態、範囲、権限、安定度、検査、台帳を分けることで、RAG / summary memory が起こしやすい memory pollution を抑える設計候補である。

まだ言わないことは次である。

> 任意自然会話で長期記憶問題を解いた、実プロダクト traffic で安全性を証明した、継続学習を一般に解いた、または AGI 的自己改善を閉じた。


11. Claims and non-claims
-------------------------

本プロファイルが支える公開可能な設計主張は次である。

- LLM 長期記憶は raw input event と current-use premise を分けるべきである。
- 出所、発話上の役割、範囲、権限、削除状態、認識上の状態、安定度は optional metadata ではなく memory-control variable である。
- 古典 TMS / ATMS / belief revision は関連する先行系譜だが、LLM 記憶には natural-language provenance、permission、deletion、scope、action-readout の問題が追加される。
- 実用システムは、無限メタ推論ではなく、有限の structural policy layer を持つべきである。
- total recall ではなく、安全な forgetting、blocking、archiving、review が目標の一部である。

本プロファイルは次を主張しない。

- MemoryGit が belief revision を一般に解いたこと。
- あらゆる矛盾に正確なスカラー量を割り当てられること。
- 人間記憶が最適な設計図であること。
- LLM parsing だけで安全な長期記憶が成立すること。
- Git metaphor を literal に実装すべきこと。
- private な MemoryGit 実験群が、この v3 bundle 内で公開証拠になっていること。
- 長期記憶制御だけで AGI、継続学習、再帰的自己改善が解けること。

安全な要約は次である。

> MemoryGit は、LLM システムのための有限で policy-gated な記憶制御層である。messy language の解釈には LLM を使うが、memory pollution が次の前提として再帰的に増殖しないようにする境界は、構造化された状態、明示的な検査、review、rollback、ledger に置く。


12. アダプタ接続補助資料
-------------------------

本プロファイルの実装接続ノートとして、入力資格状態をメモリプロバイダの前段に置くアダプタ設計を別紙に分ける。

- `03_domains/02_structurally_inferred/llm_input_qualification_memory_provider_adapter_design.md`
- `03_domains/02_structurally_inferred/llm_input_qualification_state_schema.json`
- `05_evidence/llm_input_qualification_minimal_cases.jsonl`
- `05_evidence/llm_input_qualification_minimal_result_summary.md`
- `05_evidence/llm_input_qualification_paraphrase_stress_cases.jsonl`
- `05_evidence/llm_input_qualification_paraphrase_stress_result_summary.md`

この補助資料は、Hermes、Mem0、ローカル記憶、セッション検索、ベクトル検索などを置き換えるものではない。既存の記憶プロバイダへ送る前に入力資格状態を付け、検索後に状態付き選択読出しを行い、回答・行動・共有・学習更新の直前に使用権限を確認するための、最小の公開設計である。
