//
//  FChannelListener.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 02.11.2021.
//

import Foundation
import Firebase

class FChannelListener {

    static let shared = FChannelListener()

    var chanelListener: ListenerRegistration!

    typealias ChannelsHandler = (Result<[Channel], Error>) -> Void

    private init() {}

    func upload(channel: Channel, completion: @escaping (Error?) -> Void) {
        do {
            try FirebaseReference(.channel).document(channel.id).setData(from: channel)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func delete(channel: Channel) {
        FirebaseReference(.channel).document(channel.id).delete()
    }

    func loadSubscribedChannels(completion: @escaping ChannelsHandler) {
        chanelListener = FirebaseReference(.channel)
            .whereField(kChannelMember, arrayContains: User.currentId!)
            .addSnapshotListener({ snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let channels = snapshot?.documents
                .compactMap { try? $0.data(as: Channel.self) }
                .sorted { $0.updatedAt! > $1.updatedAt! } ?? []
            completion(.success(channels))
        })
    }

    func loadAllChannels(completion: @escaping ChannelsHandler) {
        chanelListener = FirebaseReference(.channel)
            .addSnapshotListener({ snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let channels = snapshot?.documents
                .compactMap { try? $0.data(as: Channel.self) }
                .sorted { $0.updatedAt! > $1.updatedAt! } ?? []
            completion(.success(channels))
        })
    }

    func loadMyChannels(completion: @escaping ChannelsHandler) {
        chanelListener = FirebaseReference(.channel)
            .whereField(kChannelAdmin, isEqualTo: User.currentId!)
            .addSnapshotListener({ snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let channels = snapshot?.documents
                .compactMap { try? $0.data(as: Channel.self) }
                .sorted { $0.updatedAt! > $1.updatedAt! } ?? []
            completion(.success(channels))
        })
    }

    func removeListener() {
        chanelListener?.remove()
    }
}
