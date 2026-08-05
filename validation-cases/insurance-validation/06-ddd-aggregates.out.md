# 06 — ddd-aggregates 产出（Blind Run）

> 输入：`02-ddd-discover.out.md`（事件流与命令候选）+ `04-ddd-contexts.out.md`（上下文目录与词汇表）+ `05-ddd-context-map.out.md`（映射与失败模式）。
> 本文件为 `ddd-aggregates` 在 blind run 下的模拟执行产出，**未参考**任何真值材料（本案例无参考实现）。

## 聚合目录

| 聚合               | 所属上下文   | 聚合根             | 包含实体                       | 包含值对象                               | 关键不变量                                               | 关键命令                                                                             |
| :----------------- | :----------- | :----------------- | :----------------------------- | :--------------------------------------- | :------------------------------------------------------- | :----------------------------------------------------------------------------------- |
| Application        | Quotation    | Application        | —                              | CoverageRequest, QuotedTerms             | 报价不具约束力；申请号唯一                               | SubmitApplication, RequestQuote                                                      |
| UnderwritingCase   | Underwriting | UnderwritingCase   | —                              | Decision, ReinsuranceNeed                | 一次申请仅一条生效决策；决策不可覆盖已出单决策           | MakeUnderwritingDecision                                                             |
| Policy             | Policy       | Policy             | Endorsement                    | TermsVersion, Deductible, WaitingPeriod  | 条款版本单调递增不可变；中止期间出险不受理（配合 Claim） | IssuePolicy, ApplyEndorsement, RenewPolicy, LapsePolicy                              |
| Claim              | Claim        | Claim              | SurveyRecord, AssessmentRecord | LossDetails, AssessedLoss, TermsSnapshot | 调查挂起中禁支付；同一损失合并为一报案；条款快照不可变   | NotifyClaim, LinkToPolicy, CompleteSurvey, AssessLoss, OpenInvestigation, CloseClaim |
| PaymentInstruction | Payment      | PaymentInstruction | —                              | PaymentReceipt                           | 幂等键唯一；已支付不可改金额                             | ExecutePayment, RetryPayment                                                         |
| Party              | Party        | Party              | —                              | LossHistory                              | 历史赔付表现只读派生                                     | (主数据维护)                                                                         |
| ReserveView        | Regulatory   | ReserveView        | —                              | —                                        | 只读投影，业务不可写                                     | (投影刷新)                                                                           |

## 不变量表

| 不变量                                                                     | 触发命令                          | 校验位置                                | 违反时行为                       |
| :------------------------------------------------------------------------- | :-------------------------------- | :-------------------------------------- | :------------------------------- |
| I-1 同一客户同一标的同一申请号唯一                                         | SubmitApplication                 | Application 聚合内                      | 拒绝重复提交（幂等返回原申请）   |
| I-2 报价基于有效申请，报价不承诺                                           | RequestQuote                      | Application 聚合内                      | 无有效申请不可报价               |
| I-3 一次申请最多一条生效决策，出单后决策不可变                             | MakeUnderwritingDecision          | UnderwritingCase 聚合内                 | 重复决策拒绝；已出单则拒绝覆盖   |
| I-4 条款版本号单调递增，历史版本不可变                                     | ApplyEndorsement                  | Policy 聚合内                           | 版本冲突拒绝                     |
| I-5 累计已付 + 本次应付 ≤ 保额 - 免赔后责任上限                            | AssessLoss / PaymentExecuted 消费 | Claim 聚合内（累计口径）                | 超额赔付申请拒绝                 |
| I-6 调查挂起中，支付审批一律拒绝                                           | ApprovePayment                    | Claim 状态机                            | 审批被拒绝并提示挂起原因         |
| I-7 报案时条款快照不可变（TermsSnapshot）                                  | LinkToPolicy                      | Claim 聚合内                            | 快照生成后不可更新               |
| I-8 同一损失的多起报案合并为一聚合（去重键：标的+出险时间窗+损失描述指纹） | NotifyClaim                       | Claim 聚合内                            | 返回主报案号，不新建             |
| I-9 赔付结论金额 = 定损金额 - 免赔额 - 除外不赔部分，不可手工改            | AssessLoss                        | Claim 聚合内                            | 手工改金额被拒绝（必须走重定损） |
| I-10 中止保单不可关联新报案                                                | LinkToPolicy                      | Claim 聚合内（依据 TermsSnapshot 状态） | 关联失败，提示保单中止           |

## 实体与值对象清单

| 名称                       | 类型         | 所属聚合           | 标识策略 / 相等性定义                             |
| :------------------------- | :----------- | :----------------- | :------------------------------------------------ |
| Application                | Entity（根） | Application        | applicationId 唯一标识                            |
| CoverageRequest            | VO           | Application        | 按值相等（标的+保额+期限+既往损失）               |
| QuotedTerms                | VO           | Application        | 按值相等（保费+免赔额+等待期+除外清单+有效期）    |
| UnderwritingCase           | Entity（根） | UnderwritingCase   | caseId 唯一标识                                   |
| Decision                   | VO           | UnderwritingCase   | 按值相等（decision+reason+premiumAdjustment）     |
| ReinsuranceNeed            | VO           | UnderwritingCase   | 按值相等（需分保比例+再保方候选）                 |
| Policy                     | Entity（根） | Policy             | policyId 唯一标识                                 |
| Endorsement                | Entity       | Policy             | endorsementId；生命周期内追加                     |
| TermsVersion               | VO           | Policy             | 版本号相等；内容不可变                            |
| Deductible / WaitingPeriod | VO           | Policy             | 按值相等；固化在 TermsVersion 内                  |
| Claim                      | Entity（根） | Claim              | claimId 唯一标识（合并后为主报案号）              |
| SurveyRecord               | Entity       | Claim              | surveyId；按时间追加                              |
| AssessmentRecord           | Entity       | Claim              | assessmentId；定损结论不可变（修正走新记录）      |
| LossDetails                | VO           | Claim              | 按值相等（标的+出险时间+损失描述+指纹）           |
| AssessedLoss               | VO           | Claim              | 按值相等（金额+免赔额应用+除外应用）              |
| TermsSnapshot              | VO           | Claim              | **外部引用**（来自 Policy）：仅保留报案时版本快照 |
| PaymentInstruction         | Entity（根） | PaymentInstruction | instructionId + claimId 幂等键                    |
| PaymentReceipt             | VO           | PaymentInstruction | 回执按值相等（状态+金额+时间）                    |
| Party                      | Entity（根） | Party              | partyId 唯一标识                                  |
| LossHistory                | VO           | Party              | 只读派生（次数+金额+时间窗）                      |
| ReserveView                | Entity（根） | ReserveView        | 只读投影（key: 统计日+口径）                      |

## 边界规则说明

- **外部引用再审视**（每个外部引用对象回答"其生命周期是否由我方管理"）：
  - `TermsSnapshot`（Claim 引用 Policy 条款）：**否**——条款生命周期归 Policy 管理，Claim 只持有报案时快照引用，不升格内部聚合 ✅。
  - `LossHistory`（Underwriting 引用 Party）：**否**——主数据归 Party，核保只读消费 ✅。
  - `QuotedTerms`（Underwriting 引用 Quotation）：**否**——报价归 Quotation 管理，决策只引用其结果 ✅。
  - `PaymentReceipt`（Claim 引用 Payment）：**否**——回执生命周期归 Payment 管理，Claim 消费回执更新累计口径 ✅。
- **Specification 模式识别**（谓词型业务规则显式抽取）：
  - `UnderwritingAcceptanceSpec`（isSatisfiedBy(Application, LossHistory, QuoteTerms) → 接受/加费/限责/拒保）：核保规则以"给定申请 X 是否可接受"的谓词形式出现，抽取为 Specification，而非塞进 UnderwritingCase 的 if 分支。
  - `LossPayableSpec`（isSatisfiedBy(AssessedLoss, TermsSnapshot, CumulativePaid) → 是否可支付）：定损后"是否满足支付条件"（含免赔、除外、累计上限、挂起互斥）抽取为 Specification，供审批流复用。
- **事务边界**：默认 1 个事务修改 1 个聚合；跨聚合一致性见下表。
- **并发 / 锁策略**：Policy 条款版本号乐观锁；Claim 累计已付口径用「已支付事件幂等消费 + 重算」避免锁热点。

## 跨聚合一致性策略

| 场景                    | 触发事件                 | 补偿方式                         | 幂等保障            | 重试策略          |
| :---------------------- | :----------------------- | :------------------------------- | :------------------ | :---------------- |
| 决策生效 → 出单         | UnderwritingDecisionMade | 出单失败 → 决策保留，重试出单    | 决策 eventId        | ≤3 次，超限转人工 |
| 条款变更 → 新报案快照   | EndorsementApplied       | 已关联报案不受影响（快照不可变） | —                   | 无（设计保证）    |
| 支付回执 → 累计已付更新 | PaymentExecuted          | 回执重放重算累计                 | paymentId + claimId | 重放直至一致      |
| 支付成功 → 未决赔付投影 | PaymentExecuted          | Regulatory 投影重算              | 事件幂等            | 对账任务补齐      |
| 追偿回款 → 结案后冲减   | SubrogationRecovered     | 结案后冲减计入已收追偿           | recoveryId          | 重试              |

## 仓储接口草案

| 聚合               | 方法（语义）                                  | 语义说明         | 查询边界             |
| :----------------- | :-------------------------------------------- | :--------------- | :------------------- |
| Application        | findByApplicationId / save                    | 申请聚合持久化   | 按申请号             |
| Application        | findPendingByPartyAndCoverage                 | 防重复提交预检   | 按客户+标的          |
| UnderwritingCase   | findByApplicationId / save                    | 核保案持久化     | 按申请号             |
| Policy             | findByPolicyId / save                         | 保单聚合持久化   | 按保单号             |
| Policy             | findByPartyId(active)                         | 续保与批改场景   | 按客户（仅有效保单） |
| Claim              | findByClaimId / save                          | 理赔聚合持久化   | 按报案号             |
| Claim              | findByPolicyAndLossWindow(policyId, lossDate) | 重复报案合并预检 | 按保单+出险时间窗    |
| PaymentInstruction | findById / save                               | 支付指令持久化   | 按指令号             |
| PaymentInstruction | findByClaimId                                 | 对账与重试       | 按报案号             |
| Party              | findByPartyId / save                          | 主数据持久化     | 按客户号             |
| ReserveView        | refresh(dimension, asOf)                      | 只读投影刷新     | 按统计维度           |
