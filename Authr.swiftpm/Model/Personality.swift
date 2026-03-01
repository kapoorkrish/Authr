//
//  Personality.swift
//
//
//  Created by Krish Kapoor on 2/11/26.
//

enum Personality: String, Codable, CaseIterable {
    case ISTJ, ISFJ, INFJ, INTJ
    case ISTP, ISFP, INFP, INTP
    case ESTP, ESFP, ENFP, ENTP
    case ESTJ, ESFJ, ENFJ, ENTJ
}

extension Personality {
    var traitDescription: String {
        switch self {
        case .INTJ: return "Architect: Independent, strategic thinkers who prefer working alone on complex problems."
        case .INTP: return "Thinker: Logical, flexible thinkers who love exploring theoretical possibilities."
        case .ENTJ: return "Commander: Natural leaders who focus on long-term goals and organizational efficiency."
        case .ENTP: return "Debater: Innovative, enthusiastic people who enjoy exploring new possibilities through discussion and debate."
        case .INFJ: return "Advocate: Idealistic individuals driven by personal values and a desire to help others."
        case .INFP: return "Mediator: Idealistic, flexible individuals who strongly value authenticity and personal freedom."
        case .ENFJ: return "Protagonist: Charismatic leaders who focus on helping others reach their potential."
        case .ENFP: return "Campaigner: Enthusiastic, creative individuals who see life as full of possibilities"
        case .ISTJ: return "Logistician: Practical, responsible individuals who value tradition and stability."
        case .ISFJ: return "Protector: Caring, responsible individuals who focus on meeting others’ needs."
        case .ESTJ: return "Executive: Organized, decisive leaders who focus on efficiency and results."
        case .ESFJ: return "Consul: Warm, cooperative individuals who focus on maintaining group harmony."
        case .ISTP: return "Virtuoso: Practical, adaptable individuals who prefer hands-on problem-solving."
        case .ISFP: return "Adventurer: Gentle, flexible individuals who value personal freedom and authenticity."
        case .ESTP: return "Entrepreneur: Energetic, practical individuals who thrive on immediate challenges and social interaction."
        case .ESFP: return "Entertainer: Enthusiastic, social individuals who focus on enjoying life and helping others feel included."
        }
    }
}
