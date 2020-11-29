//
//  Container.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import Foundation
import Combine

enum InstancePolicy {
    case new
    case reuse
}

struct InstanceFactory {
    let policy: InstancePolicy
    let builder: (Container) throws -> Any
}

@dynamicMemberLookup
class Container: ObservableObject {
    private var factories: [String: InstanceFactory] = [:]
    private var instances: [String: Any] = [:]

    func register<T>(policy: InstancePolicy = .new, builder: @escaping (Container) throws -> T) {
        let key = String(reflecting: T.self)

        instances.removeValue(forKey: key)
        factories[key] = .init(policy: policy, builder: builder)
    }

    func resolve<T>(key: String = String(reflecting: T.self)) -> T! {
        guard let factory = factories[key] else { return nil }

        switch factory.policy {
        case .new:
            return try? factory.builder(self) as? T
        case .reuse:
            if let instance = instances[key] as? T {
                return instance
            }

            let instance = try? factory.builder(self) as? T
            instances[key] = instance
            return instance
        }
    }

    subscript<T>(dynamicMember member: String) -> T! {
        get { resolve(key: member) ?? resolve() }
        set { register(policy: .new, builder: { _ in newValue }) }
    }
}

@propertyWrapper
class Injected<T> {
    private lazy var _wrappedValue: T = {
        guard let container = __InjectedContainerProvider.container else {
            fatalError("Container is missing while resolving: \(T.self)")
        }

        return container.resolve()
    }()

    var wrappedValue: T {
        _wrappedValue
    }

    init(lazy: Bool = true) {
        if !lazy {
            _ = _wrappedValue
        }
    }
}

enum __InjectedContainerProvider {
    static var container: Container!
}
