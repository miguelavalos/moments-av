import Foundation

enum MomentsCreateFormatting {
    static func spendPlanDescription(_ plan: MomentsCreditSpendPlan?) -> String {
        guard let plan else {
            return L10n.string("create.spendPlan.notEnough")
        }

        let parts = [
            plan.proMonthly > 0 ? L10n.string("create.spendPlan.monthly", plan.proMonthly) : nil,
            plan.purchased > 0 ? L10n.string("create.spendPlan.purchased", plan.purchased) : nil,
            plan.promotional > 0 ? L10n.string("create.spendPlan.other", plan.promotional) : nil
        ]
        .compactMap { $0 }

        return parts.isEmpty
            ? L10n.string("create.spendPlan.none")
            : L10n.string("create.spendPlan.order", parts.joined(separator: ", "))
    }
}
