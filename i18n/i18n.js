import { zh_CN } from "zh_CN.js";
import { en_US } from "en_US.js";

export currentLang = "zh_CN"

export function t(language,key){

    switch(language){
        case 'zh_CN':
            return zh_CN[key];
        case 'en_US':
            return en_US[key];
        default:
            return key;
    }
}
