# 05 — ddd-context-map 产出（Blind Run）

> 输入：`01`~`04` 的 blind 产出。
> 本文件为 `ddd-context-map` 在 blind run 下的模拟执行产出，**未参考**任何真值材料（本案例无参考实现）。

## 上下文关系矩阵

| 上游 → 下游 | 关系模式 | 集成方式 | 传输契约 | 方向 |
| :--- | :--- | :--- | :--- | :--- |
| Party → Quotation / Underwriting / Claim | Customer-Supplier | 同步查询（历史赔付表现、主体信息） | PartyProfile 查询契约（只读） | 单向（Party 上游） |
| Quotation → Underwriting | Customer-Supplier | 异步事件 | ApplicationSubmitted / QuotePresented | 单向 |
| Underwriting → Policy | Customer-Supplier | 异步事件 | UnderwritingDecisionMade（含条款要素） | 单向 |
| Policy → Claim | Open Host Service + Published Language | 异步事件 + 快照查询 | PolicyEvent 族（PolicyIssued / EndorsementApplied / PolicyLapsed / TermsSnapshot） | 单向（Policy 上游） |
| Claim → Payment | Customer-Supplier | 异步命令 + 回执事件 | PaymentInstruction（幂等键）+ PaymentExecuted | 双向（指令 / 回执） |
| Payment → Regulatory | Conformist（对监管口径） | 事件投影 | PaymentExecuted | 单向 |
| Policy / Claim → Regulatory | Conformist | 事件投影 | PolicyIssued / ClaimClosed / ReserveView 输入 | 单向 |
| Quotation → 外部费率系统 | ACL（Conformist 反面） | 同步请求/响应 | 外部费率 OpenAPI → 内部 QuoteTerms | 单向（外部上游） |
| Party → 经纪系统（外部） | ACL | 同步/文件 | 经纪主体报文 → 内部 PartyProfile | 双向（数据交换） |
| Payment → 外部资金系统 | ACL | 同步请求/响应 | 内部 PaymentInstruction → 外部资金报文 → 回执 | 双向 |

## 契约所有权矩阵

| 契约 | 所有者 | 消费者 | 变更流程 | 发布策略 |
| :--- | :--- | :--- | :--- | :--- |
| PartyProfile 查询 | 客户数据团队 | Quotation / Underwriting / Claim | 字段只增不删；语义变更需三方评审 | 向后兼容优先 |
| ApplicationSubmitted / QuotePresented | 渠道产品团队 | Underwriting | 新增字段允许；删除需版本号 | 向后兼容 |
| UnderwritingDecisionMade | 承保产品团队 | Policy | 决策类型枚举变更需评审 | 版本化枚举 |
| PolicyEvent 族（TermsSnapshot） | 保单服务团队 | Claim / Regulatory | 快照结构变更影响理赔判定，需理赔团队确认 | 版本化 + 兼容窗口 |
| PaymentInstruction / PaymentExecuted | 财务科技团队 | Claim | 幂等键规则不可变；其余向后兼容 | 版本化 |
| 报送投影输入（PolicyIssued / ClaimClosed） | 合规数据团队 | 监管 | 口径变化由合规驱动，业务事件不动 | 事件原样保留 |

## 翻译 / ACL 决策

### ACL-1：外部费率系统 → Quotation

- **入**：外部费率结果（险种编码、费率表、条款要素编码可能与内部不一致）。
- **出**：内部 `QuoteTerms { premium, deductible, waitingPeriod, exclusions[] }`。
- **规则**：
  - 险种编码外部 ↔ 内部映射表；未知编码进隔离区并报警。
  - 金额统一为分（避免浮点）；期限统一为 ISO 日期。
  - 报价有效期由内部生成（外部不提供）。
  - 不兼容版本：用缓存费率；无缓存则"延迟报价"（E2）。

### ACL-2：经纪系统 → Party / Quotation

- **入**：经纪报文（主体信息、申请信息，字段命名与直营渠道不同）。
- **出**：内部 `PartyProfile` 与 `Application` 标准结构。
- **规则**：主体去重（证件号 + 姓名）；申请字段补默认值；渠道标记保留。

### ACL-3：外部资金系统 ← Payment

- **入**：内部 `PaymentInstruction` → 资金系统报文（收款账号、金额、币种）。
- **出**：资金系统回执 → 内部 `PaymentExecuted`。
- **规则**：幂等键（paymentId + claimId）透传以保证外部幂等；失败分类（可重试 / 不可重试）；对账日切由财务团队核对。

## 失败模式与缓解

| 失败模式 | 影响 | 检测方式 | 缓解措施 | 补偿策略 |
| :--- | :--- | :--- | :--- | :--- |
| 外部费率超时 / 5xx | 报价无法生成 | 超时监控 | 缓存费率降级；报价标注"待确认" | 恢复后重试报价 |
| 经纪报文格式变更 | 申请受理失败 | 校验失败率监控 | ACL 版本适配；未知字段隔离 | 人工补录 |
| Payment 指令丢失 | 赔付延迟 | 指令超时监控 | 指令持久化 + 重发（幂等） | 幂等键去重 |
| 支付失败（可重试） | 赔付未到账 | 回执分类 | 自动重试 ≤3 次 | 超限转人工 |
| 支付失败（不可重试） | 需人工介入 | 回执分类 | 人工处理通道 | 结案前必须支付成功 |
| Policy 事件投递延迟 | 理赔无法关联条款 | 投递延迟监控 | 事件总线重放；理赔可等条款快照 | 快照补齐后继续 |
| 巨灾高峰报案 | 报案积压 | 队列水位监控 | 异步受理、先收后补 | 不可丢件（持久化队列） |
| 报送投影滞后 | 报送时点数据不齐 | 对账任务 | 报送时刻快照对齐 | 补报机制 |
| Party 主数据冲突 | 核保读到错误历史 | 冲突率监控 | 主数据治理流程 | 人工仲裁 |

## 版本策略

- 事件契约统一结构版本号；字段只增不删；破坏性变更走 2 个大版本 deprecation 窗口。
- `PaymentInstruction` 的幂等键规则**不可变更**（防重复支付底线）。
- `TermsSnapshot` 结构变更需 Claim 团队评审（影响定损计算）。
- 报送投影输入事件不做版本升级——业务事件原样保留，口径在 Regulatory 侧适配。
- 契约测试：每个消费者对上游契约维护契约测试，上游发布前跑全量。
