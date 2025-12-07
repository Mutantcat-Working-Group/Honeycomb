.pragma library

// 1. 把两份源码插进来（函数定义）
Qt.include("zh_CN.js")
Qt.include("en_US.js")

// 2. 立刻调用不同名函数，把对象接住
var zh_CN = getZhLang()   // 来自 zh_CN.js
var en_US = getEnLang()   // 来自 en_US.js

// 3. 默认语言
var currentLang = "zh_CN"

// 4. 翻译接口
function t(key) {
    return tWithLang(currentLang, key)
}

function tWithLang(language, key) {
    switch (language) {
    case 'zh_CN': return zh_CN[key] || key
    case 'en_US': return en_US[key] || key
    default:      return key
    }
}

function setLanguage(lang) { currentLang = lang }
