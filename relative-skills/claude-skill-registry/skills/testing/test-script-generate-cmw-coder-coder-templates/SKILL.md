---
name: test_script_generate
description: 编写用于新华三技术有限公司H3C网络设备自动化测试脚本。支持全库检索、迭代优化策略以及过程文档自动归档。
---

# SDD规范驱动测试脚本生成宪法 (Rev. 2025-12)

**核心定位**：本宪法定义所有测试脚本生成任务的**强制三阶段框架**。全流程严格遵循"先规划后编码"原则。


## 1. 三阶段工作流框架（强制顺序）

**Phase 1: Specification** → 分析用户需求与用户提供的 `conftest.py`，通过**全库检索与迭代分析**，产出 `topoConfig.md`（拓扑与配置分析）+ `spec.md`（测试规范）。

**Phase 2: Tasks** → 基于Phase 1的交付物，继续**全库检索**细节，产出 `tasks.md`（任务清单）。

**Phase 3: Implementation & Archiving** → 根据前两个阶段交付物完成编码，并**强制归档**过程文档。

**强制交付顺序**：必须完成 `spec.md` 和 `tasks.md` 后，才能开始编码。编码完成后必须清理环境。

---

## 2. 工具使用与数据库检索标准（唯一真理源）

必须通过以下工具检索云端知识库。
**检索策略（强制）**：在每一阶段，必须遍历所有 indexname。初次检索后，必须阅读返回内容，提取更准确的专业术语或命令片段，优化检索词（Description）后进行**迭代检索**，直到获得足够精确的信息。

### 2.1 获取背景与环境 (`background_ke`)
- **用途**：查找相似业务背景以**理解**用户提供的 `conftest.py` 逻辑。
- **命令**：
  ```bash
  /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "[业务描述]" --indexname "background_ke"
  ```

### 2.2 获取组网配置 (`v9_press_example`)
- **用途**：查找常见的组网配置、交换机多网段互通配置等。
- **命令**：
  ```bash
  /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "[配置描述]" --indexname "v9_press_example"
  ```

### 2.3 获取测试代码实现 (`example_ke`)
- **用途**：查找测试用例的具体实现代码（Reference Code）。
- **命令**：
  ```bash
  /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "[功能描述]" --indexname "example_ke"
  ```

### 2.4 获取设备命令行 (`cmd_ke`)
- **用途**：查询具体的网络设备命令行（CLI）。
- **命令**：
  ```bash
  /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "[命令意图]" --indexname "cmd_ke"
  ```

### 2.5 获取配置步骤说明 (`press_config_des`)
- **用途**：查询标准化的配置流程、参数说明、步骤描述。
- **命令**：
  ```bash
  /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "[配置逻辑]" --indexname "press_config_des"
  ```

---

## 3. 通用约束与原则

### 3.1 代码生成原则
- **单需求/测试点单脚本**：每个测试需求生成一个脚本文件。
- **不生成空文件**：禁止生成无用的 `__init__.py`。
- **头文件明确模块引入**：
  ```python
  import pytest
  from pytest_atf.atf_globalvar import globalVar as gl
  from pytest_atf import run_multithread, atf_assert, atf_check, atf_skip, atf_logs
  ```

### 3.2 资料引用规范
所有设计与代码实现必须有据可查：
- **环境背景**：参考用户提供的 `conftest.py`，辅助参考 `background_ke`。
- **业务逻辑**：来源 `v9_press_example` / `press_config_des`。
- **代码参考**：来源 `example_ke`。
- **具体命令**：来源 `cmd_ke`。

### 3.3 设备与配置一致性
- **命名一致**：脚本中的设备名（`gl.DUTx`）必须与 `.topox` 拓扑文件严格对应。
- **配置优先**：**优先复用 目录下用户提供的配置**。
- **清理强制**：所有 `teardown_class` 必须实现完整配置清除逻辑。

### 3.4 **核心原则**：Flat is better than nested
- **禁止二次封装**：严禁在脚本内定义非必要的 Helper Function。
- **风格一致性**：代码结构必须严格对齐 `example_ke` 中检索到的范例。

### 3.5 **目录访问黑名单（重要）**
- **禁止读取**：**严禁** Agent 读取、检索或引用 `{当前文件夹}/templeate/` 目录及其子目录下的任何文件内容。该目录仅作为“黑洞”用于存放归档文件。

---

## 4. 拓扑与基础配置准备流程

### 4.1 查找与评估阶段
**交付物**: `topoConfig.md`

**执行流程**:
1. **检查用户输入**: 确认目录下是否存在用户提供的 `conftest.py` 和 `*.topox`。
2. **全库迭代检索**: 即使是分析拓扑，也必须运行所有 5 个检索工具 (`background_ke` 至 `press_config_des`)。
3. **迭代优化**: 如果初次检索返回的配置或背景不够匹配，根据返回内容中的关键词优化 `--description` 参数，再次检索。
4. **评估匹配度**: 确认用户提供的文件是否满足当前测试需求。

### 4.2 生成topoConfig.md
**文档模板**:
```markdown
# 拓扑与基础配置说明

## 1. 现有资源状态（必须检查）
- conftest.py: [用户已提供/未提供]
- topox文件: [用户已提供/未提供]

## 2. 数据库检索与迭代记录 (强制记录)
- 遍历索引: [必须包含全部5个索引名]
- 迭代次数: [记录优化检索词的次数]
- 最终使用的关键词: [关键词]
- 关键参考来源: [background_ke/v9_press_example等]

## 3. 需求对齐分析
- 用户提供的配置是否满足需求: [是/否]
- 拓扑连接: [分析topox中的连接关系]

## 4. 结论
- 状态: "配置就绪" 或 "等待用户补充"
- 警告: [若用户未上传conftest.py，此处必须警示]
```

---

## 5. Phase 1: Specification（测试规范）

### 5.1 拓扑与基础配置确认（⚠️ 独立任务）
**执行动作**：
1. 检查目录下的 `conftest.py` 和 `topox`。
2. **全库检索**：运行 2.1 至 2.5 所有检索工具。
3. **分析与迭代**：阅读返回的 JSON/文本，若发现不明确的术语，将其加入新检索词重新搜索。
4. 产出 `topoConfig.md`。

### 5.2 测试点分析与场景设计
**执行动作**：
1. 再次**全库检索**：重点关注 `press_config_des` 和 `v9_press_example`，但必须同时查询 `cmd_ke` 和 `example_ke` 以验证可行性。
2. 产出 `spec.md`，明确：
   - **测试点英文缩写 (`test_abbr`)**：必须定义一个简洁的英文缩写（如 `vlan_iso`, `ospf_basic`），后续归档将使用此名称。
   - **测试场景**: Given-When-Then 格式。
   - **数据需求**: 输入数据与预期输出。
   - **检索依据**: 标注每个场景主要参考的检索结果索引。

---

## 6. Phase 2: Tasks（任务清单）

### 6.1 设计模板
```python
class Test[模块名][功能名]:
    @classmethod
    def setup_class(cls):
        """
        必须依赖用户提供的 conftest.py。
        此处仅编写脚本特有的额外配置（如有），
        严禁修改或重新生成 conftest.py 的内容。
        """
            
    def test_step_1(self):
        """基于 example_ke 与 cmd_ke 综合检索结果"""
        # 步骤: 参考 press_config_des 逻辑
        # 实现: 参考 example_ke 代码
        # 命令: 参考 cmd_ke
```

### 6.2 任务拆解清单

#### Task 0: 拓扑与配置确认
- [ ] 确认 `conftest.py` 已由用户上传（**不生成**）。
- [ ] 确认 `topox` 文件已存在。
- [ ] 阅读 `conftest.py` 了解预置环境。

#### Task 1: 深度代码调研（迭代检索）
while True:
  - [ ] **全库遍历**：运行全部 5 个索引检索。
  - [ ] **迭代优化**：根据每次索引检索返回的内容，加深对业务的了解。然后变更搜索词，用具体的命令再次运行5个索引检索。
  - [ ] **评估匹配度**：确认检索提示的知识是否满足当前测试需求。
- 产出: `__reference_code__` 引用定义（记录在tasks.md中），必须包含经过验证的最佳匹配片段。

#### Task 2: 编写setup/teardown
- [ ] 编写测试类中的 `setup_class` (仅调用必要的configure，不生成fixture文件)。
- [ ] 编写 `teardown_class` 清理逻辑。

#### Task 3: 实现test_step
- **文件**: `{当前文件夹}/test_case_序号.py`
- **要求**: 
  - 逻辑参考 `press_config_des`。
  - 代码参考 `example_ke`。
  - 命令参考 `cmd_ke`。
  - **必须确认所有步骤都经过全库检索验证**。

---

## 7. Phase 3: Implementation & Archiving

### 7.1 脚本实现
严格按照 `tasks.md` 和检索到的参考代码进行编码。禁止臆造命令或配置流程。如果在编码过程中发现细节模糊：
1. 暂停编码。
2. 使用具体的模糊点（如报错信息、特定参数）作为 Description，再次对 **所有数据库** 进行检索。
3. 根据新检索结果修正代码。

### 7.2 产物归档（强制执行）
**触发条件**：测试脚本（`test_case_*.py`）生成完成。

**执行动作**：
1. 识别 `spec.md` 中定义的 **测试点英文缩写 (`test_abbr`)**。
2. 创建归档目录：
   ```bash
   mkdir -p {当前文件夹}/templeate/{test_abbr}/
   ```
3. 移动过程文件：
   ```bash
   mv spec.md topoConfig.md tasks.md {当前文件夹}/templeate/{test_abbr}/
   ```
4. **验证**：确认当前目录下只剩下 `test_case_*.py`、`conftest.py` 和 `*.topox` 文件。

---

## 8. 工作流程约束总结

### 执行顺序（强制）：
1. **Phase 1**: 
   - 检查用户上传文件。
   - **遍历所有数据库**并进行**迭代检索**优化关键词。
   - 产出 `topoConfig.md` + `spec.md`（含 `test_abbr` 定义）。

2. **Phase 2**:
   - **遍历所有数据库**，针对代码实现细节进行**迭代检索**。
   - 产出 `tasks.md`。

3. **Phase 3**:
   - 参考检索结果完成编码。
   - **执行归档操作**：将中间文件移入 `templeate` 目录。

### 关键检查点：
- ✅ 是否**没有**生成或修改 `conftest.py`？
- ✅ 是否完全脱离了本地 `press/KE` 文件夹，仅使用工具检索？
- ✅ **是否在每个阶段（Phase 1/2/3）都遍历了全部 5 个数据库索引？**
- ✅ **是否执行了“检索-分析-优化关键词-再检索”的迭代过程？**
- ✅ **是否在代码生成后将 spec/tasks/topoConfig 移动到了 `./templeate/{test_abbr}/`？**
- ✅ **是否严守纪律，从未尝试读取 `./templeate/` 文件夹中的内容？**
- ✅ 测试脚本名称是否是test_case_序号？从0开始递增的。
```