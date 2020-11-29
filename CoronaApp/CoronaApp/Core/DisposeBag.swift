//
//  DisposeBag.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import Combine
import Foundation

class DisposeBag {
    fileprivate var lock = NSRecursiveLock()
    private var isDisposed = false

    var subscriptions: Set<AnyCancellable> = []

    deinit {
        dispose()
    }

    func insert(_ subscription: AnyCancellable) {
        lock.lock(); defer { lock.unlock() }

        if isDisposed {
            subscription.cancel()
        }

        subscription.store(in: &subscriptions)
    }

    func dispose() {
        lock.lock(); defer { lock.unlock() }
        guard !isDisposed else { return }

        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll(keepingCapacity: false)
        isDisposed = true
    }
}

extension DisposeBag {
    convenience init(disposing subscriptions: AnyCancellable...) {
        self.init()
        self.subscriptions.formUnion(subscriptions)
    }

    convenience init(@SubscriptionBuilder builder: () -> [AnyCancellable]) {
        self.init(disposing: builder())
    }

    convenience init(disposing subscriptions: [AnyCancellable]) {
        self.init()
        self.subscriptions.formUnion(subscriptions)
    }

    func insert(_ subscriptions: AnyCancellable...) {
        insert(subscriptions)
    }

    func insert(@SubscriptionBuilder builder: () -> [AnyCancellable]) {
        insert(builder())
    }

    func insert(_ subscriptions: [AnyCancellable]) {
        lock.lock(); defer { lock.unlock() }

        if isDisposed {
            subscriptions.forEach { $0.cancel() }
        } else {
            self.subscriptions.formUnion(subscriptions)
        }
    }

    @_functionBuilder
    enum SubscriptionBuilder {
        public static func buildBlock(_ subscriptions: AnyCancellable...) -> [AnyCancellable] {
            subscriptions
        }
    }
}

extension AnyCancellable {
    func disposed(by disposeBag: DisposeBag) {
        disposeBag.insert(self)
    }
}

extension Collection where Element == AnyCancellable {
    func disposed(by disposeBag: DisposeBag) {
        forEach { disposeBag.insert($0) }
    }
}

