import Foundation

enum MomentsCreateFormatting {
    static func spendPlanDescription(_ plan: MomentsCreditSpendPlan?) -> String {
        guard let plan else {
            return "Not enough spendable credits yet."
        }

        let parts = [
            plan.proMonthly > 0 ? "\(plan.proMonthly) monthly" : nil,
            plan.purchased > 0 ? "\(plan.purchased) purchased" : nil,
            plan.promotional > 0 ? "\(plan.promotional) other" : nil
        ]
        .compactMap { $0 }

        return parts.isEmpty ? "No credits needed." : "Spend order: " + parts.joined(separator: ", ")
    }
}
