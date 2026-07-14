import re
with open(r"E:\Projects\Honeycomb\sdk\NSIS\Honeycomb.nsi", "r", encoding="utf-8-sig") as f:
    content = f.read()
# Remove the non-functional MUI_TEXT_INSTALLER_BRANDINGTEXT define and its comment
content = content.replace('; 替换底部品牌文字\n!define MUI_TEXT_INSTALLER_BRANDINGTEXT "蜂巢工具箱 v${VERSION}"\n\n', '')
# Add BrandingText directive right after RequestExecutionLevel admin
content = content.replace("RequestExecutionLevel admin\n", 'RequestExecutionLevel admin\nBrandingText "蜂巢工具箱 v${VERSION}"\n')
with open(r"E:\Projects\Honeycomb\sdk\NSIS\Honeycomb.nsi", "w", encoding="utf-8") as f:
    f.write(content)
print("Done")
