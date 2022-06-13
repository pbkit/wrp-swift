//
//  AsyncSequence+publisher.swift
//  WrpExample
//
//  Created by Jaeyoung Yoon on 2022/06/10.
//

import Combine

extension AsyncSequence {
    func toPublisher() -> AnyPublisher<Element, Error> {
        let subject = PassthroughSubject<Element, Error>()

        Task {
            do {
                for try await element in self {
                    subject.send(element)
                }

                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }

        return subject.eraseToAnyPublisher()
    }
}
