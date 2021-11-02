//
//  AudioRecorder.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 01.11.2021.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject {

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranded: Bool = false

    static let shared = AudioRecorder()

    private override init() {
        super.init()
        checkPermissions()
    }

    func checkPermissions() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranded = true
        case .denied:
            isAudioRecordingGranded = false
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { isGranded in
                self.isAudioRecordingGranded = isGranded
            }
        @unknown default:
            break
        }
    }

    func setupRecorder() {
        guard isAudioRecordingGranded else { return }
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            assert(false, error.localizedDescription)
        }
    }

    func startRecording(fileName: String) {
        let filePath = FileStorage.documentsURL.appendingPathComponent(fileName + ".m4a", isDirectory: false)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            assert(false, error.localizedDescription)
            finishRecording()
        }
    }

    func finishRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorder: AVAudioRecorderDelegate {

}
