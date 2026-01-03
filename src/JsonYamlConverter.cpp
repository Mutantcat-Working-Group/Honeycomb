#include "JsonYamlConverter.h"
#include <yaml-cpp/yaml.h>
#include <json/json.h>
#include <sstream>
#include <iostream>

JsonYamlConverter::JsonYamlConverter(QObject *parent)
    : QObject(parent)
{
}

QString JsonYamlConverter::jsonToYaml(const QString &jsonText)
{
    try {
        // 使用jsoncpp解析JSON
        Json::Value root;
        Json::Reader reader;
        std::string jsonStr = jsonText.toStdString();
        
        if (!reader.parse(jsonStr, root)) {
            throw std::runtime_error("Invalid JSON format: " + reader.getFormattedErrorMessages());
        }
        
        // 将JSON转换为YAML::Node
        YAML::Node yamlNode;
        if (!JsonToYaml(root, yamlNode)) {
            throw std::runtime_error("Failed to convert JSON to YAML");
        }
        
        // 输出YAML
        std::stringstream yamlStream;
        yamlStream << yamlNode;
        return QString::fromStdString(yamlStream.str());
        
    } catch (const std::exception &e) {
        return "错误: " + QString::fromStdString(e.what());
    }
}

QString JsonYamlConverter::yamlToJson(const QString &yamlText)
{
    try {
        // 使用yaml-cpp解析YAML
        std::string yamlStr = yamlText.toStdString();
        YAML::Node yamlNode = YAML::Load(yamlStr);
        
        // 将YAML转换为JSON
        Json::Value jsonRoot;
        if (!YamlToJson(yamlNode, jsonRoot)) {
            throw std::runtime_error("Failed to convert YAML to JSON");
        }
        
        // 输出JSON
        Json::StreamWriterBuilder builder;
        builder["indentation"] = "  ";
        std::unique_ptr<Json::StreamWriter> writer(builder.newStreamWriter());
        std::stringstream jsonStream;
        writer->write(jsonRoot, &jsonStream);
        
        return QString::fromStdString(jsonStream.str());
        
    } catch (const std::exception &e) {
        return "错误: " + QString::fromStdString(e.what());
    }
}

QString JsonYamlConverter::formatJson(const QString &jsonText)
{
    try {
        Json::Value root;
        Json::Reader reader;
        std::string jsonStr = jsonText.toStdString();
        
        if (!reader.parse(jsonStr, root)) {
            throw std::runtime_error("Invalid JSON format: " + reader.getFormattedErrorMessages());
        }
        
        Json::StreamWriterBuilder builder;
        builder["indentation"] = "  ";
        std::unique_ptr<Json::StreamWriter> writer(builder.newStreamWriter());
        std::stringstream jsonStream;
        writer->write(root, &jsonStream);
        
        return QString::fromStdString(jsonStream.str());
        
    } catch (const std::exception &e) {
        return jsonText; // 如果格式化失败，返回原始文本
    }
}

bool JsonYamlConverter::YamlToJson(const YAML::Node &yamlNode, Json::Value &jsonNode)
{
    try {
        if (yamlNode.IsScalar()) {
            // 检查是否为数字
            std::string scalar = yamlNode.as<std::string>();
            if (isNumeric(QString::fromStdString(scalar))) {
                // 检查是否为整数或浮点数
                if (scalar.find('.') != std::string::npos) {
                    jsonNode = std::stod(scalar);
                } else {
                    jsonNode = static_cast<Json::Int64>(std::stoll(scalar));
                }
            } else if (isBoolean(QString::fromStdString(scalar))) {
                jsonNode = (scalar == "true" || scalar == "True");
            } else {
                jsonNode = scalar;
            }
        } else if (yamlNode.IsSequence()) {
            jsonNode = Json::arrayValue;
            for (size_t i = 0; i < yamlNode.size(); ++i) {
                Json::Value element;
                if (!YamlToJson(yamlNode[i], element)) {
                    return false;
                }
                jsonNode.append(element);
            }
        } else if (yamlNode.IsMap()) {
            jsonNode = Json::objectValue;
            for (auto it = yamlNode.begin(); it != yamlNode.end(); ++it) {
                Json::Value value;
                if (!YamlToJson(it->second, value)) {
                    return false;
                }
                jsonNode[it->first.as<std::string>()] = value;
            }
        }
        return true;
    } catch (...) {
        return false;
    }
}

bool JsonYamlConverter::JsonToYaml(const Json::Value &jsonNode, YAML::Node &yamlNode)
{
    try {
        if (jsonNode.isString()) {
            yamlNode = jsonNode.asString();
        } else if (jsonNode.isInt()) {
            yamlNode = jsonNode.asInt();
        } else if (jsonNode.isUInt()) {
            yamlNode = jsonNode.asUInt();
        } else if (jsonNode.isInt64()) {
            yamlNode = jsonNode.asInt64();
        } else if (jsonNode.isUInt64()) {
            yamlNode = jsonNode.asUInt64();
        } else if (jsonNode.isDouble()) {
            yamlNode = jsonNode.asDouble();
        } else if (jsonNode.isBool()) {
            yamlNode = jsonNode.asBool();
        } else if (jsonNode.isArray()) {
            yamlNode = YAML::Node(YAML::NodeType::Sequence);
            for (Json::ArrayIndex i = 0; i < jsonNode.size(); ++i) {
                YAML::Node element;
                if (!JsonToYaml(jsonNode[i], element)) {
                    return false;
                }
                yamlNode.push_back(element);
            }
        } else if (jsonNode.isObject()) {
            yamlNode = YAML::Node(YAML::NodeType::Map);
            for (auto const& id : jsonNode.getMemberNames()) {
                YAML::Node value;
                if (!JsonToYaml(jsonNode[id], value)) {
                    return false;
                }
                yamlNode[id] = value;
            }
        }
        return true;
    } catch (...) {
        return false;
    }
}

bool JsonYamlConverter::isNumeric(const QString &str)
{
    bool ok;
    str.toDouble(&ok);
    return ok;
}

bool JsonYamlConverter::isBoolean(const QString &str)
{
    return str.toLower() == "true" || str.toLower() == "false";
}

QString JsonYamlConverter::escapeYamlValue(const QString &value)
{
    QString escaped = value;
    escaped.replace("\\", "\\\\");
    escaped.replace("\"", "\\\"");
    escaped.replace("\n", "\\n");
    escaped.replace("\r", "\\r");
    escaped.replace("\t", "\\t");
    return escaped;
}

QString JsonYamlConverter::getIndentString(int indent)
{
    return QString("  ").repeated(indent);
}