# 02 — ddd-discover 产出（Blind Run）

> 输入：`01-ddd-scope.out.md`。
> 本文件为 `ddd-discover` 在 blind run 下的模拟执行产出，**未参考**任何真值材料（本案例无参考实现）。

## 事件流表

### 主路径 M：投保 → 承保 → 出单 → 理赔 → 赔付

| 序号 | 事件（过去时） | 触发命令 | 参与者 | 输入 / 输出 | 异常分支 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| M1 | ApplicationSubmitted | SubmitApplication | 客户 / 经纪 | 入：标的、期望保额、期限、既往损失记录；出：申请号 | E1 关键信息缺失 |
| M2 | QuoteRequested | RequestQuote | 客服系统 | 入：申请；出：报价请求 → 外部费率 | E2 外部费率不可用 |
| M3 | QuotePresented | PresentQuote | 系统 | 入：费率结果；出：报价（含条款要素） | E2 降级报价 |
| M4 | UnderwritingStarted | StartUnderwriting | 核保人 | 入：申请 + 报价 + 客户历史赔付表现；出：核保案 | — |
| M5 | UnderwritingDecisionMade | MakeUnderwritingDecision | 核保人 | 出：接受 / 加费 / 限责 / 拒保；拒保 → E4 | E3 需分保支持 |
| M6 | PolicyIssued | IssuePolicy | 系统 | 入：接受决策 + 条款要素；出：保单号、等待期、免赔额快照 | — |
| M7 | EndorsementApplied | ApplyEndorsement | 客服 / 客户 | 入：批改请求（保额 / 地址 / 标的）；出：条款新版本 | E5 批改与理赔并行 |
| M8 | RenewalCompleted | RenewPolicy | 系统 | 入：到期前续保评估；出：新一期保单 | E6 欠费 → 中止 |
| M9 | ClaimNotified | NotifyClaim | 客户 / 客服 | 入：损失描述、出险时间地点；出：报案号 | E7 高峰并发、E8 信息迟到 |
| M10 | ClaimLinkedToPolicy | LinkClaimToPolicy | 系统 | 入：报案 + 保单匹配；出：关联结果 | E8 无法匹配保单 |
| M11 | SurveyCompleted | CompleteSurvey | 查勘员 | 入：照片 / 实地报告；出：查勘报告 | E8 材料迟到 |
| M12 | LossAssessed | AssessLoss | 理赔员 | 入：查勘报告 + 条款（免赔额 / 除外 / 等待期）；出：定损金额 | E9 欺诈嫌疑 → 调查 |
| M13 | PaymentApproved | ApprovePayment | 审批人 | 入：定损结论；出：审批意见 | E10 大额需更高权限 |
| M14 | PaymentMade | MakePayment | 财务系统 | 入：审批通过的支付指令；出：支付回执 | E11 支付失败重试 |
| M15 | ClaimClosed | CloseClaim | 系统 | 入：支付完成；出：结案 | — |
| M16 | SubrogationRecovered | RecoverSubrogation | 理赔员 | 入：向责任方追偿；出：追偿回款 | — |

### 异常分支

| 编号 | 异常事件 | 触发条件 | 处理 |
| :--- | :--- | :--- | :--- |
| E1 | ApplicationQuarantined | 申请缺标的 / 保额 / 期限 | 进隔离区待客服补全，不进入报价 |
| E2 | QuoteDegraded | 外部费率超时 / 故障 | 降级：用缓存费率或提示稍后重试；报价不承诺 |
| E3 | ReinsuranceRequested | 标的超自留额度 | 与再保方交互后合并进承保决策 |
| E4 | ApplicationRejected | 核保拒绝 | 通知客户拒保及理由摘要，流程终止 |
| E5 | EndorsementHeldForClaim | 批改与理赔并行 | 以报案时条款版本为准，批改挂起至结案后生效 |
| E6 | PolicyLapsed | 逾期未缴保费 | 保单中止；中止期间出险不受理（E8 处理为拒赔路径） |
| E7 | ClaimBurstReceived | 巨灾高峰 | 高并发异步受理；先收件后补全，不可丢件 |
| E8 | ClaimPendingInformation | 报案 / 查勘材料迟到 | 等待补齐，状态可见；超时升级人工跟进 |
| E9 | FraudInvestigationOpened | 欺诈嫌疑 | 理赔挂起、暂停支付；调查结论可推翻赔付 |
| E10 | ApprovalEscalated | 金额超当前权限 | 升级审批链，审批耗时更长 |
| E11 | PaymentRetried | 支付失败 | 幂等重试；多次失败转人工 |

## 命令候选清单

| 命令 | 发起者 | 期望结果 | 幂等性要求 |
| :--- | :--- | :--- | :--- |
| SubmitApplication | 客户 / 经纪 | 生成申请号 | 高（重复提交不重复建申请） |
| RequestQuote | 客服系统 | 发起费率查询 | 中（可缓存） |
| MakeUnderwritingDecision | 核保人 | 决策生效 | 高（防止重复决策） |
| IssuePolicy | 系统 | 生成保单 | 高（防止重复出单） |
| ApplyEndorsement | 客服 | 条款版本更新 | 高 |
| RenewPolicy | 系统 | 新一期保单 | 高（防重复续保） |
| NotifyClaim | 客户 / 客服 | 生成报案号 | 高（防重复报案） |
| CompleteSurvey | 查勘员 | 查勘报告归档 | 高 |
| AssessLoss | 理赔员 | 定损金额 | 高 |
| ApprovePayment | 审批人 | 审批意见 | 中（审批记录追加） |
| MakePayment | 财务系统 | 支付回执 | 高（幂等键防重复支付） |
| RecoverSubrogation | 理赔员 | 追偿回款入账 | 中 |

## 事件候选清单

| 事件 | 关键字段 | 是否跨上下文 | 是否对外发布 |
| :--- | :--- | :--- | :--- |
| ApplicationSubmitted | applicationId, partyId, coverage, amount, period | 是（客户 → 承保） | 内部 |
| QuotePresented | applicationId, quoteId, premium, terms | 是 | 内部 |
| UnderwritingDecisionMade | applicationId, decision, reason, premiumAdjustment | 是（承保 → 保单） | 内部 |
| PolicyIssued | policyId, applicationId, termsSnapshot, deductible, waitingPeriod | 是（保单 → 理赔 / 监管） | 内部 + 监管报送 |
| EndorsementApplied | policyId, newTermsVersion, effectiveAt | 是 | 内部 |
| PolicyLapsed | policyId, lapsedAt | 是 | 内部 |
| ClaimNotified | claimId, policyId, lossDate, lossDesc | 是（客户 → 理赔） | 内部 |
| ClaimLinkedToPolicy | claimId, policyId, termsVersionAtLoss | 是 | 内部 |
| SurveyCompleted | claimId, surveyReport, lossAmountEstimate | 否 | 内部 |
| LossAssessed | claimId, assessedAmount, deductibleApplied, exclusionsApplied | 否 | 内部 |
| FraudInvestigationOpened | claimId, reason | 是（理赔 → 合规） | 内部 |
| PaymentApproved | claimId, approvedAmount, approver | 是（理赔 → 财务） | 内部 |
| PaymentMade | claimId, paymentId, amount, paidAt | 是（财务 → 理赔） | 内部 + 对账 |
| ClaimClosed | claimId, closedAt, totalPaid | 是（理赔 → 监管） | 内部 + 监管报送 |
| SubrogationRecovered | claimId, recoveredAmount | 是 | 内部 |

## 热点标注

- **一致性热点**：
  1. 报案与保单条款版本的绑定（E5：批改并行时以报案时版本为准）——跨保单与理赔的强一致需求。
  2. 赔付累计不超保额（多笔部分赔付的累计约束）。
  3. 欺诈调查期间禁止支付（状态互斥）。
- **集成热点**：外部费率接口（E2 降级）、经纪系统交互、财务支付系统（E11 幂等重试）、监管报送（口径对齐）。
- **性能热点**：巨灾高峰报案（E7）——受理必须异步、不可丢件。
- **合规热点**：报送数据口径、未决赔款准备金实时投影、审批链权限。

## 歧义清单

| 歧义点 | 影响范围 | 需确认方 | 建议决策 |
| :--- | :--- | :--- | :--- |
| 报价是否具约束力 | 承保决策 | 业务方 | 报价为意向，以承保决策为准 |
| 批改生效时点（申请时 / 审核时） | 保单管理 | 业务方 | 审核通过时生效，回写生效日 |
| 一标的多保单是否允许 | 投保 | 业务方 | 允许，理赔时按责任顺序分摊 |
| 免赔额分次损失是否累计 | 理赔定损 | 条款团队 | 按条款约定（分险种配置） |
| 同一损失多次报案如何合并 | 理赔受理 | 运营 | 报案聚合，保留主报案 |
| "已报案未赔付"口径 | 监管 / 财务 | 财务精算 | 含已审批未支付，需实时视图 |
| 中止保单可否恢复 | 保单管理 | 业务方 | 允许补缴恢复，恢复时重新计算等待期 |

## 边界线索

- **能力分组候选**：
  1. 客户与主体管理（客户、经纪、历史赔付表现查询）
  2. 投保与报价（申请受理、报价、隔离区补全）
  3. 承保决策（核保、分保、决策生效）
  4. 保单管理（出单、批改、续保、中止、条款版本）
  5. 理赔受理（报案、合并、高峰接入）
  6. 理赔处理（查勘、定损、调查、审批、支付指令）
  7. 财务与支付（支付执行、追偿回款）
  8. 监管与视图（报送、未决赔款准备金投影）
- **上下文边界候选**：客户主体、投保报价、承保决策、保单管理、理赔、财务支付、监管视图 7 个候选边界；"理赔受理"倾向并入理赔处理（同一一致性边界）。
