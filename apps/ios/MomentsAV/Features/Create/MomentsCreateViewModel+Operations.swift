import Foundation

extension MomentsCreateViewModel {
    func runOperation(_ operation: @escaping @MainActor () async -> Void) {
        let id = UUID()
        operationTasks[id] = Task { [weak self] in
            await operation()
            self?.completeOperation(id)
        }
    }

    private func completeOperation(_ id: UUID) {
        operationTasks[id] = nil
    }

    func cancelOperations() {
        operationTasks.values.forEach { $0.cancel() }
        operationTasks.removeAll()
    }
}
