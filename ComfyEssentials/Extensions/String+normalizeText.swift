//
//  String+normalizeText.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

extension String {
    var normalizedWhitespace: String {
        replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
