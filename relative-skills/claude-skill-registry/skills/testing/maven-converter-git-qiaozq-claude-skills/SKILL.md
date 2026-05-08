---
name: maven-converter
description: 将 Java 项目转换为标准 Maven 结构，自动重组目录、转换包名（test→example）并生成 pom.xml。当用户需要将非 Maven Java 项目转换为 Maven 项目、重构现有项目为 Maven 标准结构，或请求 Maven 项目设置/转换时使用此技能。
---

# Maven 项目转换器

自动将 Java 项目转换为 Maven 标准结构，包括重组目录、更新包名和生成构建配置。

## 快速开始

在目标项目上运行转换脚本：

```bash
python3 scripts/maven_converter.py [项目路径] [选项]
```

**常用选项：**
- `--dry-run`: 预览更改而不修改文件
- `--group-id`: 设置 Maven groupId（默认：com.example）
- `--artifact-id`: 设置 Maven artifactId（默认：项目目录名）
- `--version`: 设置项目版本（默认：1.0-SNAPSHOT）

**示例：**
```bash
# 预览转换
python3 scripts/maven_converter.py /path/to/project --dry-run

# 执行转换并自定义 groupId
python3 scripts/maven_converter.py /path/to/project --group-id com.mycompany --artifact-id my-app
```

## 功能说明

转换器自动执行以下操作：

1. **创建 Maven 标准结构**
   - `src/main/java/` - 生产源代码
   - `src/main/resources/` - 生产资源文件
   - `src/test/java/` - 测试源代码
   - `src/test/resources/` - 测试资源文件

2. **重组文件**
   - 分析 Java 文件中的包声明
   - 将文件移动到适当的 Maven 目录
   - 识别测试文件（通过注解、导入、命名规则）
   - 复制资源文件到 Maven 资源目录

3. **转换包名**
   - 将包声明中的 `test` 替换为 `example`
   - 处理模式：`test.*`、`*.test.*`、`*.test`
   - 更新所有 Java 文件中的 package 语句
   - 示例：
     - `package test;` → `package example;`
     - `package com.test.app;` → `package com.example.app;`
     - `package com.app.test.utils;` → `package com.app.example.utils;`

4. **生成 pom.xml**
   - 如果不存在则创建标准 Maven POM
   - 包含 JUnit 5 依赖
   - 配置编译器插件（Java 11）
   - 设置构建插件（surefire、jar）
   - 使用 UTF-8 编码

5. **清理**
   - 移动文件后删除空目录
   - 保留现有的 Maven 结构

## 使用工作流

### 步骤 1：评估项目

转换前先了解项目结构：

```bash
# 查看当前结构
find /path/to/project -type f -name "*.java" | head -20

# 检查是否已有 Maven 设置
ls -la /path/to/project/pom.xml
ls -la /path/to/project/src/
```

### 步骤 2：运行预演模式

始终先预览更改：

```bash
python3 scripts/maven_converter.py /path/to/project --dry-run
```

检查输出以验证：
- 文件移动是否合理
- 包转换是否正确
- 没有遗漏重要文件

### 步骤 3：执行转换

运行实际转换：

```bash
python3 scripts/maven_converter.py /path/to/project \
  --group-id com.company \
  --artifact-id project-name \
  --version 1.0.0
```

### 步骤 4：验证结果

检查转换后的结构：

```bash
# 查看 Maven 结构
tree /path/to/project/src -L 4

# 验证 pom.xml
cat /path/to/project/pom.xml

# 测试构建
cd /path/to/project
mvn clean compile
mvn test
```

### 步骤 5：手动调整

根据需要进行检查和调整：

1. **检查 pom.xml**
   - 添加项目特定的依赖
   - 如果不是 Java 11，设置正确的 Java 版本
   - 如果构建可执行 JAR，配置主类
   - 添加其他插件

2. **验证包名**
   - 确保所有 import 仍能解析
   - 检查代码中硬编码的包字符串
   - 更新引用旧包的文档

3. **检查移动的文件**
   - 确认测试文件在 `src/test/java`
   - 确认主代码在 `src/main/java`
   - 检查资源文件在适当的目录

## 自定义 POM 模板

如果要使用自定义 pom.xml 模板而不是自动生成：

1. 将模板放在 `assets/pom_template.xml`
2. 转换前将其复制到项目：
   ```bash
   cp assets/pom_template.xml /path/to/project/pom.xml
   ```
3. 运行转换器（如果文件存在则跳过 pom.xml 生成）

`assets/pom_template.xml` 中的模板提供了起点，包含：
- 标准 Maven 结构
- JUnit 5 配置
- 常用插件（compiler、surefire、jar）
- 依赖和主类的占位符

## 功能限制

- **已有 Maven 项目**：跳过已在 `src/main/java` 或 `src/test/java` 中的文件
- **已有 pom.xml**：不修改现有的 POM 文件
- **复杂包结构**：不寻常的包结构需要手动检查
- **非 Java 资源**：专用资源可能需要手动放置
- **import 语句**：不更新 import 语句（仅包声明）

## 故障排除

**文件未正确移动**
- 检查包声明是否与实际包结构匹配
- 验证文件有正确的 `.java` 扩展名
- 检查文件编码（脚本期望 UTF-8）

**包转换问题**
- 查看 dry-run 输出检查意外转换
- 如果模式不匹配，手动调整包名
- 更新引用旧包名的 import 语句

**转换后构建失败**
- 运行 `mvn clean compile` 检查编译
- 验证 pom.xml 中的所有依赖
- 检查 Java 版本是否与编译器配置匹配
- 确保资源文件在正确的目录

**脚本错误**
- 验证已安装 Python 3：`python3 --version`
- 检查项目目录的文件权限
- 确保没有文件被锁定或正在使用
