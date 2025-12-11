#ifndef JSONYAMLCONVERTER_H
#define JSONYAMLCONVERTER_H

#include <QObject>
#include <QString>
#include <yaml-cpp/yaml.h>
#include <json/json.h>

class JsonYamlConverter : public QObject
{
    Q_OBJECT

public:
    explicit JsonYamlConverter(QObject *parent = nullptr);

    Q_INVOKABLE QString jsonToYaml(const QString &jsonText);
    Q_INVOKABLE QString yamlToJson(const QString &yamlText);
    Q_INVOKABLE QString formatJson(const QString &jsonText);

private:
    bool YamlToJson(const YAML::Node &yamlNode, Json::Value &jsonNode);
    bool JsonToYaml(const Json::Value &jsonNode, YAML::Node &yamlNode);
    bool isNumeric(const QString &str);
    bool isBoolean(const QString &str);
    QString escapeYamlValue(const QString &value);
    QString getIndentString(int indent);
};

#endif // JSONYAMLCONVERTER_H