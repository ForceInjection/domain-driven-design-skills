---
name: network-conftest-generator
description: 生成并配置用于新华三技术有限公司H3C网络设备自动化的 pytest `conftest.py`，`conftest.py`文件主要负责测试背景搭建和测试背景清理。
---

# 网络测试环境生成器

## 目标
参考工作流程制定`Todo List`, 按照任务列表, 生成 `conftest.py` 文件，该文件是网络设备测试背景的代码文件。它负责测试背景搭建和测试背景清理，确保所有网络测试用例在统一的组网环境中执行并提供设备资源、拓扑配置和测试数据的共享机制。


## 核心资源：：H3C 知识库检索指南
**重要策略：** 检索必须遵循 **“循环迭代”** 和 **“全库扫描”** 的原则。

**可用知识库（每一轮检索都必须覆盖以下所有库）：**
6. **design_ke** (用户设计经验库)
1. **background_ke** (历史背景库，conftest.py代码仓库)
2. **v9_press_example** (常见组网配置库)
3. **example_ke** (测试用例实现库)
4. **cmd_ke** (具体的命令行/配置参数库)
5. **press_config_des** (标准化配置步骤/流程)



**知识库检索脚本：**

使用一下`bash`脚本可以完成指定的知识库检索。
1. **design_ke库检索，存储用户历史测试经验，需要优先重点参考**: 需要配置时间段策略
   ```bash
   /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "IGMP snooping查询组" --indexname "design_ke"
   ```

2. **background_ke库检索，该库有历史背景背景代码conftest.py**: 搭建DPI功能，必须检索
   ```bash
   /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "DPI安全测试" --indexname "background_ke"
   ```

3. **v9_press_example库检索，该库有常见的组网配置**: 配置交换机实现多网段互通
   ```bash
   /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "交换机多网段配置" --indexname "v9_press_example"
   ```

4. **example_ke库检索，该库有测试用例的实现代码，包含部分背景配置代码**: DHCP中继测试用例，必须检索
   ```bash
   /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "DHCP中继" --indexname "example_ke"
   ```

5. **cmd_ke库检索，用于存储网络设备命令行**: 配置接口IP地址
   ```bash
   /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "ip address " --indexname "cmd_ke"

   /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "配置接口IP地址" --indexname "cmd_ke"
   ```

6. **press_config_des库检索，存储标准化的配置步骤说明，提供详细的配置流程和参数说明。**: 需要配置时间段策略
   ```bash
   /opt/coder/venvs/comware-test/bin/python {当前skill路径}/script/data_search_h3c_example.py --description "时间段配置" --indexname "press_config_des"
   ```




## 工作流程

### 步骤 1：初始化检查
目标：确保工作区内存在一个可用的 `conftest.py` 基准文件。

1. **检查文件**：使用 `Ls` 检查当前工作区是否存在 `conftest.py`。
2. **执行拷贝 (如果缺失)**：
   - **若文件不存在**：
     - 读取模版文件：`{当前skill路径}/templates/conftest.py`。
     - 使用cp命令将该文件拷贝到当前工作区中。
     - *（此时工作区内已确保存在 `conftest.py`，继续执行步骤 2）*
   - **若文件已存在**：
     - 直接跳到步骤 2。

### 步骤 2：深度校验与循环知识检索
目标：**这是最关键的一步**，通过**多轮循环检索且每轮都遍历所有数据库**，通过动态调整检索词的循环,从宏观到微观完全吃透业务背景，从各个维度（背景+命令+步骤）深刻理解业务，，对比“当前conftest.py文件能力”与“用户实际需求”。

**严禁事项：**
- **严禁**在检索开始前就制定好所有的检索轮次（例如：“我计划第1轮查BGP，第2轮查邻居...”）。这是错误的！
- **必须**执行完一轮检索，**阅读并分析**返回内容后，才能决定下一轮查什么。

**必做事项**
- **Todo List**：每完成一轮的检索，必须**更新Todo List, 但是不要删除步骤4的校验**。


1. **读取现状**
   - 读取当前工作区下 `conftest.py` 的完整内容。
   - 读取拓扑文件（通常是 .topox），获取物理设备列表（如 DUT1, DUT2），了解各个设备间链接方式。
2. **动态检索循环 (The Dynamic Loop)**：
   请严格按照以下算法执行，直到业务逻辑完全清晰：

   - **初始启动 (Seed)**：
     - 提取用户输入中的核心名词（例如用户输入“BGP add-path”，初始词为“BGP add-path”）。

   - **执行循环 (Start Loop)**：
     1. **全库扫描 (Action)**：
        - 使用当前的“关键词”，**连续执行 5 次检索命令**，遍历所有 5 个数据库。
     
     2. **结果分析 (Observation)**：
        - 仔细阅读 5 个库的返回内容。
        - **寻找“未知的已知”**：注意那些在返回结果中出现，但你还不知道具体配置方法的**新术语**。
          - *示例*：你搜索了“BGP”，结果中提到了“需要配置 Route-Reflector 才能生效”。此时，“Route-Reflector”就是检索结果暴露出的新盲区。

     3. **决策判定 (Decision)**：
        - 问自己：我是否已经掌握了完成用户需求所需的每一个具体的命令行、参数取值和配置顺序？
        - **YES** -> 退出循环，进入步骤 3。
        - **NO** -> **更新关键词**。
          - **关键规则**：新的关键词必须**直接来源于上一轮的检索结果**，而不是用户的原始输入。
          - *示例*：下一轮的关键词应调整为“配置 BGP Route-Reflector 命令”，而不是继续搜“BGP”。

     4. **重返第一步**：使用新关键词再次执行全库扫描。

3. **需求对比**：
   - 基于完全理解的业务背景，分析用户的具体测试需求，
   - 检查当前代码内容是否已包含用户所需的逻辑。
   - *注意：如果是刚拷贝的默认模版，通常因缺乏特定配置（如只有单设备）而被判定为“不符合”。*

### 步骤 3：决策与执行
根据步骤 2 的对比结果执行：

#### 情况 A：内容不符合 (Mismatch)
1.  **制定计划 (Todo List)**：
    - 向用户简述修改计划。
2.  **重构代码与查漏补缺**：
    - 在编写具体代码行时，如果发现步骤 2 的检索仍有遗漏，**必须再次触发全库扫描**。
    - 针对 Todo List 中的每一项，确保有明确的数据库检索结果作为支撑，**严禁臆造配置，严禁删除步骤4**。
3.  **覆盖写入**：使用 `Edit` 将更新后的代码写入 `conftest.py`。
4.  **反馈**：回复“已通过多轮全库检索参考 H3C 知识库，深入理解业务背景后更新了 `conftest.py`。”
    

#### 情况 B：内容符合 (Match)
1.  **动作**：不做任何修改。
2.  **反馈**：回复“现有 `conftest.py` 已符合需求，无需修改。”。

### 步骤4：校验
校验最终的`conftest.py`文件，避免出现以下错误。

1. **全覆盖验证**：确认在每一轮检索中，是否都**没有遗漏任何一个数据库**？（即使你觉得某个库可能没用，也要查，以防万一）。
2. **关键词进化**：确认下一轮的检索词是否基于上一轮的学习成果进行了优化？
3. **深刻理解**：在开始写代码前，你是否已经像一个 H3C 网络专家一样完全理解了该特性？
4. `conftest.py`文件中不需要使用CheckCommand()或者assert()等函数来验证配置结果。
5. 不要使用topox中不存在的设备名或者或者端口, 注意是大小问题和是否存在问题。
   例如一下拓扑的设备名是dut1,端口名是port1。
   ```xml
      <LINK_LIST>
      <LINK>
         <NODE>
         <DEVICE>dut1</DEVICE>
         <PORT>
            <NAME>port1</NAME>
            <TYPE/>
            <IPAddr/>
            <IPv6Addr/>
            <SLOT_TYPE/>
            <TAG/>
         </PORT>
         </NODE>
         <NODE>
         <DEVICE>PC</DEVICE>
         <PORT>
            <NAME>port1</NAME>
            <TYPE/>
            <IPAddr/>
            <IPv6Addr/>
            <SLOT_TYPE/>
            <TAG/>
         </PORT>
         </NODE>
      </LINK>
   </LINK_LIST>
  ```
  。
6. 不要使用atf_check和atf_assert，这种方式是违法的，对于H3C设备相关的检查只可以使用CheckCommand， 例如：
   ```python
   gl.DUT.CheckCommand('检查端口信息，预期链路状态UP，IP地址正确', 
                  cmd=f'display interface Ethernet0/1',
         expect=['Line protocol current state: UP', 'Internet Address is 11.91.255.79/24'],
         is_strict=True, 
                  relationship='and',
         stop_max_attempt=3, wait_fixed=2)
   ```
7. 接口使用注意实现事项：
   - 端口ipv4地址掩码：    gl.dut.port1.mask
   - 端口ipv4地址反掩码：  gl.dut.port1.hostmask
   - 端口ipv6地址:         gl.dut.port1.ip6
   - 端口ipv6地址掩码:     gl.dut.port1.mask6
   - 端口ipv6地址掩码长度： gl.dut.port1.masklen6
   - atf_logs(f'脚本记录', 'info')   -----  只支持info warn error 三个级别
   - 等待时间:  atf_wait('等待原因描述', 5)   ----  单位为秒
