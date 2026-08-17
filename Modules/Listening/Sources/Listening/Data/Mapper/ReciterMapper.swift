//
//  ReciterMapper.swift
//  Listening
//

import Foundation

enum ReciterMapper {

    private static func arabicName(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("husary") || n.contains("husari") { return "محمود خليل الحصري" }
        if n.contains("afasy") || n.contains("efasy") { return "مشاري راشد العفاسي" }
        if n.contains("minshawi") || n.contains("menshawy") { return "محمد صديق المنشاوي" }
        if n.contains("shuraym") || n.contains("shuraim") { return "سعود الشريم" }
        if n.contains("tablawi") || n.contains("tblawi") { return "محمد الطبلاوي" }
        if n.contains("sudais") || n.contains("sudays") { return "عبد الرحمن السديس" }
        if n.contains("abdulbaset") || n.contains("baset") || n.contains("abdulsamad") { return "عبد الباسط عبد الصمد" }
        if n.contains("shatri") || n.contains("shatree") { return "أبو بكر الشاطري" }
        if n.contains("rifai") || n.contains("rifa'i") { return "هاني الرفاعي" }
        if n.contains("muaiqly") || n.contains("moaiqly") { return "ماهر المعيقلي" }
        if n.contains("dosari") || n.contains("dossary") { return "ياسر الدوسري" }
        if n.contains("tunaiji") { return "خليفة التنحي" }
        if n.contains("jibreel") || n.contains("jibril") { return "محمد جبريل" }
        if n.contains("ghamdi") || n.contains("ghamdiy") { return "سعد الغامدي" }
        if n.contains("hudaify") || n.contains("hudhaify") { return "علي بن عبد الرحمن الحذيفي" }
        if n.contains("ajamy") || n.contains("ajmi") { return "أحمد بن علي العجمي" }
        if n.contains("ayyoub") || n.contains("ayub") { return "محمد أيوب" }
        return name
    }

    static func toDomain(_ dto: ReciterDTO) -> Reciter {
        let arName = arabicName(for: dto.reciterName)
        return Reciter(
            id: dto.id,
            name: dto.reciterName,
            arabicName: arName,
            style: dto.style,
            translatedName: dto.translatedName?.name
        )
    }

    static func toDomainList(_ dtos: [ReciterDTO]) -> [Reciter] {
        dtos.map { toDomain($0) }
    }
}
