#ifndef AGENTPROMPTMANAGER_H
#define AGENTPROMPTMANAGER_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QUrl>

class AgentPromptManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString rootPath READ rootPath WRITE setRootPath NOTIFY rootPathChanged)
    Q_PROPERTY(QVariantList fileTree READ fileTree NOTIFY fileTreeChanged)
    Q_PROPERTY(QString currentFilePath READ currentFilePath WRITE setCurrentFilePath NOTIFY currentFilePathChanged)
    Q_PROPERTY(QString currentFileContent READ currentFileContent WRITE setCurrentFileContent NOTIFY currentFileContentChanged)
    Q_PROPERTY(bool isImageFolder READ isImageFolder NOTIFY isImageFolderChanged)
    Q_PROPERTY(QStringList currentImages READ currentImages NOTIFY currentImagesChanged)

public:
    explicit AgentPromptManager(QObject *parent = nullptr);

    QString rootPath() const;
    void setRootPath(const QString &path);

    QVariantList fileTree() const;

    QString currentFilePath() const;
    void setCurrentFilePath(const QString &path);

    QString currentFileContent() const;
    void setCurrentFileContent(const QString &content);

    bool isImageFolder() const;
    QStringList currentImages() const;

    Q_INVOKABLE void selectRootFolder();
    Q_INVOKABLE void refreshTree();
    Q_INVOKABLE void saveCurrentFile();
    Q_INVOKABLE void createFile(const QString &parentPath, const QString &fileName);
    Q_INVOKABLE void createFolder(const QString &parentPath, const QString &folderName);
    Q_INVOKABLE void deleteItem(const QString &path);
    Q_INVOKABLE void renameItem(const QString &oldPath, const QString &newName);
    Q_INVOKABLE void initializeSkeleton();
    
    // 图片相关
    Q_INVOKABLE void pasteImageFromClipboard();
    Q_INVOKABLE void addImageFromPath(const QString &sourcePath);
    Q_INVOKABLE void addImagesFromUrls(const QList<QUrl> &urls);
    Q_INVOKABLE void deleteImage(const QString &imagePath);
    Q_INVOKABLE QString getAbsolutePath(const QString &imagePath);
    Q_INVOKABLE QString getRelativePath(const QString &imagePath);
    Q_INVOKABLE void copyToClipboard(const QString &text);
    Q_INVOKABLE void openInExplorer(const QString &path);

signals:
    void rootPathChanged();
    void fileTreeChanged();
    void currentFilePathChanged();
    void currentFileContentChanged();
    void isImageFolderChanged();
    void currentImagesChanged();
    void errorOccurred(const QString &error);
    void successMessage(const QString &message);

private:
    QVariantList buildTreeFromPath(const QString &path, int depth = 0);
    void loadFileContent(const QString &path);
    void loadImagesFromFolder(const QString &path);
    QString generateImageName();

    QString m_rootPath;
    QVariantList m_fileTree;
    QString m_currentFilePath;
    QString m_currentFileContent;
    bool m_isImageFolder;
    QStringList m_currentImages;
    QString m_currentImageFolder;
};

#endif // AGENTPROMPTMANAGER_H
