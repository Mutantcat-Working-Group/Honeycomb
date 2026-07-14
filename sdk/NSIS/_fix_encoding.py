import codecs
with open(r"E:\Projects\Honeycomb\sdk\NSIS\Honeycomb.nsi", "r", encoding="utf-8") as f:
    content = f.read()
with open(r"E:\Projects\Honeycomb\sdk\NSIS\Honeycomb.nsi", "w", encoding="utf-8-sig") as f:
    f.write(content)
print("Fixed: added UTF-8 BOM")