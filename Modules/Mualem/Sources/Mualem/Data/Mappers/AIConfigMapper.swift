// AIConfigMapper.swift
// Mualem

import Foundation

enum AIConfigMapper {
    static func mapHealth(_ dto: HealthResponseDTO) -> AIHealthInfo {
        return AIHealthInfo(
            status: dto.status,
            defaultEngine: dto.engine,
            availableEngines: dto.availableEngines
        )
    }
    
    static func mapRules(_ dto: TajweedRulesResponseDTO) -> [TajweedRuleConfig] {
        return dto.rules.map { rule in
            let kind: TajweedRuleKind
            switch rule.kind {
            case "sifa": kind = .sifa
            default: kind = .tajweed
            }
            return TajweedRuleConfig(
                key: rule.key,
                nameAr: rule.nameAr,
                nameEn: rule.nameEn,
                kind: kind
            )
        }
    }
    
    static func mapSchema(_ dto: MoshafSchemaResponseDTO) -> [MoshafSchemaField] {
        return dto.fields.map { field in
            let defaultValue: MoshafOptionValue
            switch field.defaultValue {
            case .string(let s): defaultValue = .string(s)
            case .integer(let i): defaultValue = .integer(i)
            }
            
            let options = field.options.map { opt -> MoshafOption in
                let val: MoshafOptionValue
                switch opt.value {
                case .string(let s): val = .string(s)
                case .integer(let i): val = .integer(i)
                }
                return MoshafOption(value: val, label: opt.label)
            }
            
            return MoshafSchemaField(
                key: field.key,
                nameAr: field.nameAr,
                description: field.description,
                defaultValue: defaultValue,
                options: options
            )
        }
    }
}
