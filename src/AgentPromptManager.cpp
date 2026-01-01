#include "AgentPromptManager.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QFileDialog>
#include <QClipboard>
#include <QGuiApplication>
#include <QMimeData>
#include <QImage>
#include <QDateTime>
#include <QDesktopServices>
#include <QUrl>
#include <QProcess>
#include <QDebug>

AgentPromptManager::AgentPromptManager(QObject *parent)
    : QObject(parent)
    , m_isImageFolder(false)
{
}

QString AgentPromptManager::rootPath() const { return m_rootPath; }

void AgentPromptManager::setRootPath(const QString &path)
{
    if (m_rootPath != path) {
        m_rootPath = path;
        emit rootPathChanged();
        refreshTree();
    }
}

QVariantList AgentPromptManager::fileTree() const { return m_fileTree; }

QString AgentPromptManager::currentFilePath() const { return m_currentFilePath; }

void AgentPromptManager::setCurrentFilePath(const QString &path)
{
    if (m_currentFilePath != path) {
        // 保存之前的文件
        if (!m_currentFilePath.isEmpty() && !m_isImageFolder) {
            saveCurrentFile();
        }
        
        m_currentFilePath = path;
        emit currentFilePathChanged();
        
        QFileInfo info(path);
        if (info.isDir() && info.fileName().toLower() == "images") {
            m_isImageFolder = true;
            m_currentImageFolder = path;
            emit isImageFolderChanged();
            loadImagesFromFolder(path);
        } else if (info.isFile()) {
            m_isImageFolder = false;
            emit isImageFolderChanged();
            loadFileContent(path);
        } else if (info.isDir()) {
            m_isImageFolder = false;
            emit isImageFolderChanged();
            m_currentFileContent.clear();
            emit currentFileContentChanged();
        }
    }
}

QString AgentPromptManager::currentFileContent() const { return m_currentFileContent; }

void AgentPromptManager::setCurrentFileContent(const QString &content)
{
    if (m_currentFileContent != content) {
        m_currentFileContent = content;
        emit currentFileContentChanged();
    }
}

bool AgentPromptManager::isImageFolder() const { return m_isImageFolder; }

QStringList AgentPromptManager::currentImages() const { return m_currentImages; }

void AgentPromptManager::selectRootFolder()
{
    QString path = QFileDialog::getExistingDirectory(nullptr, 
        "选择协同文件夹", 
        QDir::homePath(),
        QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks);
    
    if (!path.isEmpty()) {
        setRootPath(path);
    }
}

void AgentPromptManager::refreshTree()
{
    if (m_rootPath.isEmpty()) {
        m_fileTree.clear();
        emit fileTreeChanged();
        return;
    }
    
    m_fileTree = buildTreeFromPath(m_rootPath, 0);
    emit fileTreeChanged();
}

QVariantList AgentPromptManager::buildTreeFromPath(const QString &path, int depth)
{
    QVariantList result;
    QDir dir(path);
    
    if (!dir.exists()) return result;
    
    // 获取目录和文件列表
    QStringList entries = dir.entryList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot, QDir::DirsFirst | QDir::Name);
    
    for (const QString &entry : entries) {
        QString fullPath = dir.absoluteFilePath(entry);
        QFileInfo info(fullPath);
        
        QVariantMap item;
        item["name"] = entry;
        item["path"] = fullPath;
        item["isDir"] = info.isDir();
        item["isImageFolder"] = info.isDir() && entry.toLower() == "images";
        item["depth"] = depth;
        
        if (info.isDir()) {
            item["children"] = buildTreeFromPath(fullPath, depth + 1);
        }
        
        // 只显示 md 文件、yaml/yml 文件、sql 文件，或者是目录
        if (info.isDir() || entry.endsWith(".md", Qt::CaseInsensitive) ||
            entry.endsWith(".yaml", Qt::CaseInsensitive) ||
            entry.endsWith(".yml", Qt::CaseInsensitive) ||
            entry.endsWith(".sql", Qt::CaseInsensitive) ||
            entry.endsWith(".txt", Qt::CaseInsensitive)) {
            result.append(item);
        }
    }
    
    return result;
}

void AgentPromptManager::loadFileContent(const QString &path)
{
    QFile file(path);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        in.setEncoding(QStringConverter::Utf8);
        m_currentFileContent = in.readAll();
        file.close();
        emit currentFileContentChanged();
    } else {
        emit errorOccurred(QString("无法打开文件: %1").arg(path));
    }
}

void AgentPromptManager::loadImagesFromFolder(const QString &path)
{
    QDir dir(path);
    QStringList filters;
    filters << "*.png" << "*.jpg" << "*.jpeg" << "*.gif" << "*.bmp" << "*.webp" << "*.svg";
    
    QStringList images;
    for (const QString &file : dir.entryList(filters, QDir::Files, QDir::Name)) {
        images.append(dir.absoluteFilePath(file));
    }
    
    m_currentImages = images;
    emit currentImagesChanged();
}

void AgentPromptManager::saveCurrentFile()
{
    if (m_currentFilePath.isEmpty() || m_isImageFolder) return;
    
    QFileInfo info(m_currentFilePath);
    if (!info.isFile()) return;
    
    QFile file(m_currentFilePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out.setEncoding(QStringConverter::Utf8);
        out << m_currentFileContent;
        file.close();
    } else {
        emit errorOccurred(QString("无法保存文件: %1").arg(m_currentFilePath));
    }
}

void AgentPromptManager::createFile(const QString &parentPath, const QString &fileName)
{
    QString fullPath = QDir(parentPath).absoluteFilePath(fileName);
    QFile file(fullPath);
    
    if (file.exists()) {
        emit errorOccurred("文件已存在");
        return;
    }
    
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        file.close();
        emit successMessage("文件创建成功");
        refreshTree();
    } else {
        emit errorOccurred("创建文件失败");
    }
}

void AgentPromptManager::createFolder(const QString &parentPath, const QString &folderName)
{
    QDir dir(parentPath);
    if (dir.mkdir(folderName)) {
        emit successMessage("文件夹创建成功");
        refreshTree();
    } else {
        emit errorOccurred("创建文件夹失败");
    }
}

void AgentPromptManager::deleteItem(const QString &path)
{
    QFileInfo info(path);
    bool success = false;
    
    if (info.isDir()) {
        QDir dir(path);
        success = dir.removeRecursively();
    } else {
        QFile file(path);
        success = file.remove();
    }
    
    if (success) {
        if (m_currentFilePath == path) {
            m_currentFilePath.clear();
            m_currentFileContent.clear();
            emit currentFilePathChanged();
            emit currentFileContentChanged();
        }
        emit successMessage("删除成功");
        refreshTree();
    } else {
        emit errorOccurred("删除失败");
    }
}

void AgentPromptManager::renameItem(const QString &oldPath, const QString &newName)
{
    QFileInfo info(oldPath);
    QString newPath = info.dir().absoluteFilePath(newName);
    
    bool success = false;
    if (info.isDir()) {
        QDir dir;
        success = dir.rename(oldPath, newPath);
    } else {
        QFile file(oldPath);
        success = file.rename(newPath);
    }
    
    if (success) {
        if (m_currentFilePath == oldPath) {
            m_currentFilePath = newPath;
            emit currentFilePathChanged();
        }
        emit successMessage("重命名成功");
        refreshTree();
    } else {
        emit errorOccurred("重命名失败");
    }
}

void AgentPromptManager::initializeSkeleton()
{
    if (m_rootPath.isEmpty()) {
        emit errorOccurred("请先选择协同文件夹");
        return;
    }
    
    QDir rootDir(m_rootPath);
    
    // 定义目录结构
    QStringList folders = {
        "architecture",
        "domain",
        "patterns",
        "tasks",
        "references",
        "images",
        "verify",
        "prompts"
    };
    
    // 定义文件及其内容
    QMap<QString, QString> files;
    
    // 根目录文件
    files["project_overview.md"] = R"(# 项目全景图

## 项目简介
<!-- 简要描述项目的目的和核心功能 -->

## 技术栈概览
<!-- 列出主要使用的技术、框架和工具 -->

## 目录结构
<!-- 描述项目的主要目录结构 -->

## 快速开始
<!-- 如何启动和运行项目 -->

## 核心概念
<!-- 项目中的关键概念和术语 -->
)";

    // architecture 目录
    files["architecture/tech_stack.md"] = R"(# 技术栈说明

## 前端技术
<!-- 前端框架、UI库、状态管理等 -->

## 后端技术
<!-- 后端框架、数据库、缓存等 -->

## 基础设施
<!-- 部署、CI/CD、监控等 -->

## 开发工具
<!-- IDE、调试工具、测试框架等 -->
)";

    files["architecture/module_boundaries.md"] = R"(# 模块划分原则

## 模块列表
<!-- 列出所有主要模块 -->

## 模块职责
<!-- 每个模块的核心职责 -->

## 模块间通信
<!-- 模块之间如何交互 -->

## 依赖规则
<!-- 哪些模块可以依赖哪些模块 -->
)";

    files["architecture/data_flow.md"] = R"(# 核心数据流

## 数据流图
<!-- 描述主要数据流向 -->

## 关键流程
<!-- 核心业务流程的数据流 -->

## 状态管理
<!-- 应用状态如何管理和流转 -->
)";

    // domain 目录
    files["domain/entities.md"] = R"(# 核心实体定义

## 实体列表
<!-- 列出所有核心实体 -->

## 实体关系
<!-- 实体之间的关系 -->

## 实体属性
<!-- 每个实体的属性定义 -->
)";

    files["domain/business_rules.md"] = R"(# 业务规则

## 核心规则
<!-- 最重要的业务规则 -->

## 约束条件
<!-- 业务约束和限制 -->

## 计算逻辑
<!-- 复杂的业务计算逻辑 -->
)";

    // patterns 目录
    files["patterns/api_design.md"] = R"(# API设计模式

## 接口规范
<!-- RESTful/GraphQL等规范 -->

## 请求/响应格式
<!-- 标准的请求响应格式 -->

## 错误码定义
<!-- API错误码规范 -->

## 版本管理
<!-- API版本策略 -->
)";

    files["patterns/error_handling.md"] = R"(# 错误处理规范

## 错误分类
<!-- 错误类型分类 -->

## 处理策略
<!-- 不同错误的处理方式 -->

## 日志规范
<!-- 错误日志记录规范 -->

## 用户提示
<!-- 如何向用户展示错误 -->
)";

    files["patterns/naming_convention.md"] = R"(# 命名规范

## 文件命名
<!-- 文件和目录命名规则 -->

## 变量命名
<!-- 变量、常量命名规则 -->

## 函数命名
<!-- 函数、方法命名规则 -->

## 类命名
<!-- 类、接口命名规则 -->
)";

    // tasks 目录
    files["tasks/feature_template.md"] = R"(# 功能开发模板

## 需求描述
<!-- 功能需求详细描述 -->

## 技术方案
<!-- 实现方案 -->

## 影响范围
<!-- 涉及的模块和文件 -->

## 测试要点
<!-- 需要测试的场景 -->

## 验收标准
<!-- 功能完成的标准 -->
)";

    files["tasks/bugfix_template.md"] = R"(# Bug修复模板

## 问题描述
<!-- Bug现象描述 -->

## 复现步骤
<!-- 如何复现 -->

## 根因分析
<!-- 问题根本原因 -->

## 修复方案
<!-- 修复方法 -->

## 回归测试
<!-- 需要的回归测试 -->
)";

    // references 目录
    files["references/api_spec.yaml"] = R"(openapi: 3.0.0
info:
  title: API Specification
  version: 1.0.0
  description: API接口规范文档

paths:
  /example:
    get:
      summary: 示例接口
      responses:
        '200':
          description: 成功响应
)";

    files["references/db_schema.sql"] = R"(-- 数据库结构定义
-- Database Schema

-- 示例表
-- CREATE TABLE example (
--     id SERIAL PRIMARY KEY,
--     name VARCHAR(255) NOT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );
)";

    // verify 目录
    files["verify/verification_plan.md"] = R"(# 验证方案

## 单元测试
<!-- 单元测试策略 -->

## 集成测试
<!-- 集成测试策略 -->

## E2E测试
<!-- 端到端测试策略 -->

## 性能测试
<!-- 性能测试要点 -->
)";

    // prompts 目录
    files["prompts/generate_api.md"] = R"(# API生成提示词

根据以下需求生成API接口：

## 需求
<!-- 描述API需求 -->

## 要求
- 遵循项目的API设计规范
- 包含完整的错误处理
- 添加必要的注释
)";

    files["prompts/write_tests.md"] = R"(# 测试编写提示词

为以下代码编写测试：

## 代码
<!-- 待测试的代码 -->

## 要求
- 覆盖正常流程
- 覆盖边界条件
- 覆盖异常情况
)";

    files["prompts/review_code.md"] = R"(# 代码审查提示词

请审查以下代码：

## 代码
<!-- 待审查的代码 -->

## 审查要点
- 代码质量
- 性能问题
- 安全隐患
- 可维护性
)";

    // 创建目录
    int createdFolders = 0;
    for (const QString &folder : folders) {
        QString folderPath = rootDir.absoluteFilePath(folder);
        if (!QDir(folderPath).exists()) {
            if (rootDir.mkpath(folder)) {
                createdFolders++;
            }
        }
    }
    
    // 创建文件
    int createdFiles = 0;
    for (auto it = files.constBegin(); it != files.constEnd(); ++it) {
        QString filePath = rootDir.absoluteFilePath(it.key());
        QFileInfo fileInfo(filePath);
        
        // 确保父目录存在
        fileInfo.dir().mkpath(".");
        
        // 只在文件不存在时创建
        if (!QFile::exists(filePath)) {
            QFile file(filePath);
            if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
                QTextStream out(&file);
                out.setEncoding(QStringConverter::Utf8);
                out << it.value();
                file.close();
                createdFiles++;
            }
        }
    }
    
    refreshTree();
    emit successMessage(QString("初始化完成！创建了 %1 个文件夹和 %2 个文件").arg(createdFolders).arg(createdFiles));
}

QString AgentPromptManager::generateImageName()
{
    return QString("image_%1.png").arg(QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss_zzz"));
}

void AgentPromptManager::pasteImageFromClipboard()
{
    if (m_currentImageFolder.isEmpty()) {
        emit errorOccurred("请先选择 images 文件夹");
        return;
    }
    
    QClipboard *clipboard = QGuiApplication::clipboard();
    const QMimeData *mimeData = clipboard->mimeData();
    
    if (mimeData->hasImage()) {
        QImage image = qvariant_cast<QImage>(mimeData->imageData());
        if (!image.isNull()) {
            QString fileName = generateImageName();
            QString savePath = QDir(m_currentImageFolder).absoluteFilePath(fileName);
            
            if (image.save(savePath, "PNG")) {
                emit successMessage("图片粘贴成功");
                loadImagesFromFolder(m_currentImageFolder);
            } else {
                emit errorOccurred("保存图片失败");
            }
        }
    } else if (mimeData->hasUrls()) {
        // 处理文件URL
        addImagesFromUrls(mimeData->urls());
    } else {
        emit errorOccurred("剪切板中没有图片");
    }
}

void AgentPromptManager::addImageFromPath(const QString &sourcePath)
{
    if (m_currentImageFolder.isEmpty()) {
        emit errorOccurred("请先选择 images 文件夹");
        return;
    }
    
    QFileInfo sourceInfo(sourcePath);
    if (!sourceInfo.exists()) {
        emit errorOccurred("源文件不存在");
        return;
    }
    
    QString destPath = QDir(m_currentImageFolder).absoluteFilePath(sourceInfo.fileName());
    
    // 如果目标文件已存在，添加时间戳
    if (QFile::exists(destPath)) {
        QString baseName = sourceInfo.baseName();
        QString suffix = sourceInfo.suffix();
        QString timestamp = QDateTime::currentDateTime().toString("_yyyyMMdd_HHmmss");
        destPath = QDir(m_currentImageFolder).absoluteFilePath(baseName + timestamp + "." + suffix);
    }
    
    if (QFile::copy(sourcePath, destPath)) {
        emit successMessage("图片添加成功");
        loadImagesFromFolder(m_currentImageFolder);
    } else {
        emit errorOccurred("添加图片失败");
    }
}

void AgentPromptManager::addImagesFromUrls(const QList<QUrl> &urls)
{
    if (m_currentImageFolder.isEmpty()) {
        emit errorOccurred("请先选择 images 文件夹");
        return;
    }
    
    int successCount = 0;
    for (const QUrl &url : urls) {
        QString localPath = url.toLocalFile();
        if (!localPath.isEmpty()) {
            QFileInfo info(localPath);
            QString suffix = info.suffix().toLower();
            if (suffix == "png" || suffix == "jpg" || suffix == "jpeg" || 
                suffix == "gif" || suffix == "bmp" || suffix == "webp" || suffix == "svg") {
                
                QString destPath = QDir(m_currentImageFolder).absoluteFilePath(info.fileName());
                if (QFile::exists(destPath)) {
                    QString baseName = info.baseName();
                    QString timestamp = QDateTime::currentDateTime().toString("_yyyyMMdd_HHmmss");
                    destPath = QDir(m_currentImageFolder).absoluteFilePath(baseName + timestamp + "." + suffix);
                }
                
                if (QFile::copy(localPath, destPath)) {
                    successCount++;
                }
            }
        }
    }
    
    if (successCount > 0) {
        emit successMessage(QString("成功添加 %1 张图片").arg(successCount));
        loadImagesFromFolder(m_currentImageFolder);
    } else {
        emit errorOccurred("没有添加任何图片");
    }
}

void AgentPromptManager::deleteImage(const QString &imagePath)
{
    QFile file(imagePath);
    if (file.remove()) {
        emit successMessage("图片删除成功");
        loadImagesFromFolder(m_currentImageFolder);
    } else {
        emit errorOccurred("删除图片失败");
    }
}

QString AgentPromptManager::getAbsolutePath(const QString &imagePath)
{
    return QFileInfo(imagePath).absoluteFilePath();
}

QString AgentPromptManager::getRelativePath(const QString &imagePath)
{
    if (m_rootPath.isEmpty()) return imagePath;
    
    QDir rootDir(m_rootPath);
    return rootDir.relativeFilePath(imagePath);
}

void AgentPromptManager::copyToClipboard(const QString &text)
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setText(text);
    emit successMessage("已复制到剪切板");
}

void AgentPromptManager::openInExplorer(const QString &path)
{
    QFileInfo info(path);
    QString dirPath = info.isDir() ? path : info.absolutePath();
    
#ifdef Q_OS_WIN
    QProcess::startDetached("explorer", QStringList() << "/select," << QDir::toNativeSeparators(path));
#else
    QDesktopServices::openUrl(QUrl::fromLocalFile(dirPath));
#endif
}

QVariantList AgentPromptManager::getSelectableFiles()
{
    QVariantList result;
    if (m_rootPath.isEmpty()) return result;
    
    collectFilesRecursive(m_rootPath, result, 0);
    return result;
}

void AgentPromptManager::collectFilesRecursive(const QString &path, QVariantList &result, int depth)
{
    QDir dir(path);
    if (!dir.exists()) return;
    
    QStringList entries = dir.entryList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot, QDir::DirsFirst | QDir::Name);
    
    for (const QString &entry : entries) {
        QString fullPath = dir.absoluteFilePath(entry);
        QFileInfo info(fullPath);
        
        // 跳过 images 文件夹
        if (info.isDir() && entry.toLower() == "images") {
            continue;
        }
        
        if (info.isDir()) {
            collectFilesRecursive(fullPath, result, depth + 1);
        } else {
            // 只包含文本文件
            if (entry.endsWith(".md", Qt::CaseInsensitive) ||
                entry.endsWith(".yaml", Qt::CaseInsensitive) ||
                entry.endsWith(".yml", Qt::CaseInsensitive) ||
                entry.endsWith(".sql", Qt::CaseInsensitive) ||
                entry.endsWith(".txt", Qt::CaseInsensitive)) {
                
                QVariantMap item;
                item["name"] = entry;
                item["path"] = fullPath;
                item["relativePath"] = QDir(m_rootPath).relativeFilePath(fullPath);
                item["depth"] = depth;
                result.append(item);
            }
        }
    }
}

QString AgentPromptManager::generatePrompt(const QStringList &selectedPaths)
{
    if (selectedPaths.isEmpty()) return QString();
    
    QString prompt;
    prompt += "# AI-First Development 协同上下文\n\n";
    prompt += "以下是项目的相关文档，请基于这些内容帮助我推进项目开发：\n\n";
    prompt += "---\n\n";
    
    for (const QString &filePath : selectedPaths) {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            continue;
        }
        
        QTextStream in(&file);
        in.setEncoding(QStringConverter::Utf8);
        QString content = in.readAll();
        file.close();
        
        QString relativePath = QDir(m_rootPath).relativeFilePath(filePath);
        QString extension = QFileInfo(filePath).suffix().toLower();
        
        prompt += QString("## 📄 %1\n\n").arg(relativePath);
        
        // 根据文件类型添加代码块
        QString codeType = "text";
        if (extension == "md") codeType = "markdown";
        else if (extension == "yaml" || extension == "yml") codeType = "yaml";
        else if (extension == "sql") codeType = "sql";
        
        prompt += QString("```%1\n%2\n```\n\n").arg(codeType, content.trimmed());
        prompt += "---\n\n";
    }
    
    prompt += "## 📝 任务\n\n";
    prompt += "请基于以上上下文内容，帮我：\n";
    prompt += "1. [在这里描述你的具体需求]\n\n";
    prompt += "请确保你的回复符合项目已有的架构设计和编码规范。\n";
    
    return prompt;
}
