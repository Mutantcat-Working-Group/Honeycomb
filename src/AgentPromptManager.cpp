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
