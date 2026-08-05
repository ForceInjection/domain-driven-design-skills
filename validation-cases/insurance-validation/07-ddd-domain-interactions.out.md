# 07 — ddd-domain-interactions 产出（Blind Run）

> 输入：`01`~`06`。
> 本文件为 `ddd-domain-interactions` 在 blind run 下的模拟执行产出，**未参考**任何真值材料（本案例无参考实现）。

## 领域事件目录

### Quotation 上下文发布

| 事件 | 源聚合 | 触发条件 | 关键字段 | 范围 |
| :--- | :--- | :--- | :--- | :--- |
| ApplicationSubmitted | Application | SubmitApplication 成功 | applicationId, partyId, coverageRequest | Integration |
| ApplicationQuarantined | Application | 关键信息缺失 | applicationId, missingFields | Domain |
| QuotePresented | Application | 报价生成（含降级） | applicationId, quoteTerms, degraded | Integration |

### Underwriting 上下文发布

| 事件 | 源聚合 | 触发条件 | 关键字段 | 范围 |
| :--- | :--- | :--- | :--- | :--- |
| UnderwritingStarted | UnderwritingCase | 核保受理 | caseId, applicationId | Domain |
| UnderwritingDecisionMade | UnderwritingCase | 决策生效 | caseId, applicationId, decision, reason, premiumAdjustment | Integration |
| ReinsuranceRequested | UnderwritingCase | 超自留额度 | caseId, reinsuranceNeed | Domain |

### Policy 上下文发布

| 事件 | 源聚合 | 触发条件 | 关键字段 | 范围 |
| :--- | :--- | :--- | :--- | :--- |
| PolicyIssued | Policy | 出单成功 | policyId, applicationId, termsVersion, deductible, waitingPeriod | Integration |
| EndorsementApplied | Policy | 批改生效 | policyId, newTermsVersion, effectiveAt | Integration |
| PolicyLapsed | Policy | 中止 | policyId, lapsedAt | Integration |
| PolicyReinstated | Policy | 复效 | policyId, newWaitingPeriodStart | Integration |
| PolicyRenewed | Policy | 续保 | policyId, newPeriod | Domain |

### Claim 上下文发布

| 事件 | 源聚合 | 触发条件 | 关键字段 | 范围 |
| :--- | :--- | :--- | :--- | :--- |
| ClaimNotified | Claim | 报案受理 | claimId, policyId, lossDetails | Integration |
| DuplicateClaimMerged | Claim | 重复报案合并 | claimId, mergedClaimId, primaryClaimId | Domain |
| ClaimLinkedToPolicy | Claim | 关联成功 | claimId, policyId, termsSnapshot | Integration |
| ClaimPendingInformation | Claim | 材料迟到 | claimId, missingInfo | Domain |
| SurveyCompleted | Claim | 查勘归档 | claimId, surveyReport, estimate | Domain |
| LossAssessed | Claim | 定损结论 | claimId, assessedLoss | Integration |
| FraudInvestigationOpened | Claim | 嫌疑触发 | claimId, reason | Integration |
| FraudInvestigationConcluded | Claim | 调查结束 | claimId, conclusion, (恢复支付/拒赔) | Integration |
| PaymentApproved | Claim | 审批通过 | claimId, approvedAmount, approver | Integration |
| PaymentRejected | Claim | 审批拒绝（含挂起中） | claimId, reason | Domain |
| PaymentRequested | Claim | 审批通过后发指令 | claimId, instructionId, amount | Integration（→ Payment） |
| ClaimClosed | Claim | 结案 | claimId, closedAt, totalPaid | Integration |
| SubrogationRecovered | Claim | 追偿回款 | claimId, recoveredAmount | Integration |

### Payment 上下文发布

| 事件 | 源聚合 | 触发条件 | 关键字段 | 范围 |
| :--- | :--- | :--- | :--- | :--- |
| PaymentInstructionAccepted | PaymentInstruction | 指令受理 | instructionId, claimId | Domain |
| PaymentExecuted | PaymentInstruction | 支付成功回执 | instructionId, claimId, amount, paidAt | Integration |
| PaymentFailed | PaymentInstruction | 支付失败 | instructionId, claimId, failureType, retryCount | Integration |

## 集成事件契约（对外）

| 契约 | 方向 | 载体 | 版本 | 备注 |
| :--- | :--- | :--- | :--- | :--- |
| ApplicationSubmitted / QuotePresented | Quotation → Underwriting | 事件总线 | v1 | Published Language |
| UnderwritingDecisionMade | Underwriting → Policy | 事件总线 | v1 | 决策枚举版本化 |
| PolicyEvent 族（PolicyIssued / EndorsementApplied / PolicyLapsed） | Policy → Claim / Regulatory | 事件总线 | v1 | OHS + PL；TermsSnapshot 子结构 |
| ClaimEvent 族（ClaimNotified / ClaimLinkedToPolicy / LossAssessed / PaymentRequested / ClaimClosed） | Claim → Policy? / Payment / Regulatory | 事件总线 | v1 | Claim → Payment 为指令语义 |
| PaymentInstruction / PaymentExecuted | Claim ↔ Payment | 事件总线 | v1 | 幂等键 rule 不可变 |
| 报送投影输入 | Policy / Claim / Payment → Regulatory | 事件总线 | v1 | 业务事件原样投影 |

## 幂等与重放策略

| 事件 | 幂等键 | 去重窗口 | 重放规则 | 异常处理 |
| :--- | :--- | :--- | :--- | :--- |
| ApplicationSubmitted | applicationId | 持久化 | 重放不重复建申请 | 隔离区人工补全 |
| UnderwritingDecisionMade | caseId + decisionVersion | 持久化 | 重放不覆盖 | 已出单拒绝覆盖 |
| PolicyIssued | policyId | 持久化 | 重放不重复出单 | 出单失败重试 |
| EndorsementApplied | policyId + endorsementId | 持久化 | 版本单调 | 版本冲突拒绝 |
| ClaimNotified | 去重指纹（标的+时间窗+描述） | 持久化 | 合并到主报案 | 返回主报案号 |
| PaymentRequested | instructionId | 持久化 | 重发指令（幂等） | 指令丢失自动重发 |
| PaymentExecuted | paymentId + claimId | 持久化 | 重放重算累计已付 | 对账补齐 |
| ClaimClosed | claimId | 持久化 | 结案后禁新支付 | 追偿回款继续接收 |

## 领域服务

| 服务 | 所在上下文 | 职责 | 为什么不放聚合 |
| :--- | :--- | :--- | :--- |
| QuoteService | Quotation | 调外部费率 ACL、组装 QuoteTerms、降级策略 | 外部调用 + 费率策略，不属于 Application 不变量 |
| UnderwritingService | Underwriting | 编排 UnderwritingAcceptanceSpec 的判定、分保评估 | 规则集合跨申请演进，独立于聚合状态 |
| LossAssessmentService | Claim | 执行 LossPayableSpec（免赔/除外/累计/挂起）计算应付金额 | 谓词规则集独立演进，供审批流复用 |
| ClaimDeduplicationService | Claim | 报案去重指纹计算与合并路由 | 与仓储协同的编排角色 |
| PaymentGateway | Payment | 指令 → 外部资金系统报文转换与回执解析 | 基础设施边界，防污染领域模型 |

## 工厂清单

| 工厂 / 方法 | 创建目标 | 创建条件 | 验证规则 | 初始状态 |
| :--- | :--- | :--- | :--- | :--- |
| ApplicationFactory.fromSubmission(input) | Application | 客户主体存在 | I-1 防重复；字段完整性 | 已提交 |
| QuoteFactory.fromRateResult(application, quoteTerms) | QuotedTerms | 申请有效 | I-2 报价非承诺；有效期生成 | 已报价 |
| UnderwritingCaseFactory.start(application, quote) | UnderwritingCase | 申请已报价 | I-3 无重复核保案 | 核保中 |
| PolicyFactory.issue(decision, terms) | Policy | 决策接受 | I-3 决策不可覆盖；条款要素完整 | 生效 |
| EndorsementFactory.apply(policy, change) | Endorsement | 保单有效 | I-4 版本单调 | 待生效（生效时点规则） |
| ClaimFactory.notify(policySnapshot, lossDetails) | Claim | 保单非中止 | I-10 中止不可关联；I-8 去重 | 已报案 |
| PaymentInstructionFactory.create(claim, approvedAmount) | PaymentInstruction | 审批通过且非挂起 | I-6 挂起禁支付；I-5 累计上限 | 待执行 |

## 订阅者与副作用

| 事件 | 订阅者 | 触发动作 | 补偿策略 | 监控指标 |
| :--- | :--- | :--- | :--- | :--- |
| UnderwritingDecisionMade | Policy | 出单（接受时） | 出单失败重试 | 决策→出单时延 |
| PaymentExecuted | Claim | 累计已付更新 → 必要时触发结案判定 | 重放重算 | 累计口径偏差 |
| EndorsementApplied | Claim | 已关联报案不回溯（快照不可变） | 无（设计保证） | 并行冲突数 |
| ClaimLinkedToPolicy | Regulatory | 未决赔付投影刷新 | 对账补齐 | 投影延迟 |
| PaymentExecuted | Regulatory | 未决赔付投影刷新 | 对账补齐 | 投影延迟 |
| ClaimClosed | Regulatory | 报送投影（结案口径） | 补报 | 报送对账差异 |
| PolicyIssued / PolicyLapsed | Regulatory | 报送投影（保单口径） | 补报 | 报送对账差异 |
| PaymentRequested | Payment | 指令受理与执行 | 幂等重发 | 支付成功率 / 时延 |
| FraudInvestigationOpened | 合规（调查） | 调查任务创建 | 挂起互斥 | 调查周期 |
| QuotePresented | Underwriting | 核保受理 | 无 | 报价→决策转化率 |
