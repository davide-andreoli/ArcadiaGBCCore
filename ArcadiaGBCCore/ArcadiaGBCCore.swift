//
//  iRetroGBCCore.swift
//  iRetroGBCCore
//
//  Created by Davide Andreoli on 01/05/24.
//

import Foundation
import ArcadiaCore
import SwiftUI
import Observation
import CoreGraphics
import CoreVideo
import AVFoundation

@Observable public class ArcadiaGBC: ArcadiaCoreProtocol {    
    
    public typealias ArcadiaCoreType = ArcadiaGBC
    
    public var paused = false
    public var initialized = false
    public var mainGameLoop : Timer? = nil
    public var loadedGame: URL? = nil
    public var audioVideoInfo: retro_system_av_info = retro_system_av_info(geometry: retro_game_geometry(base_width: 160, base_height: 144, max_width: 160, max_height: 144, aspect_ratio: 1.1111112), timing: retro_system_timing(fps: 59.72750056960583, sample_rate: 44100))
    public var initialSaveRamSnapshot: [UInt8]? = nil
    public var currentSaveRamSnapshot: [UInt32 : [UInt8]]? = [:]
    public var defaultCoreOptions: [ArcadiaCoreOption] = []
    
    public init() {
    }
    
}

extension ArcadiaGBC {
    public func retroInit() {
        retro_init()
    }
    
    public func retroGetSystemAVInfo(info: UnsafeMutablePointer<retro_system_av_info>!) {
        retro_get_system_av_info(info)
    }
    
    public func retroDeinit() {
        retro_deinit()
    }
    
    public func retroRun() {
        retro_run()
    }
    
    public func retroLoadGame(gameInfo: retro_game_info) -> Bool {
        var gameInfo = gameInfo
        return retro_load_game(&gameInfo)
    }
    
    public func retroReset() {
        retro_reset()
    }
    
    public func retroUnloadGame() {
        retro_unload_game()
    }
    
    public func retroSerializeSize() -> Int {
        return retro_serialize_size()
    }
    
    public func retroSerialize(data: UnsafeMutableRawPointer!, size: Int) {
        retro_serialize(data, size)
    }
    
    public func retroUnserialize(data: UnsafeRawPointer!, size: Int) {
        retro_unserialize(data, size)
    }
    
    public func retroGetMemoryData(memoryDataId: UInt32) -> UnsafeMutableRawPointer! {
        return retro_get_memory_data(memoryDataId)
    }
    
    public func retroGetMemorySize(memoryDataId: UInt32) -> Int {
        return retro_get_memory_size(memoryDataId)
    }
    
    public func retroSetEnvironment(environmentCallback: @convention(c) (UInt32, UnsafeMutableRawPointer?) -> Bool) {
        retro_set_environment(environmentCallback)
    }
    
    public func retroSetVideoRefresh(videoRefreshCallback: @convention(c) (UnsafeRawPointer?, UInt32, UInt32, Int) -> Void) {
        retro_set_video_refresh(videoRefreshCallback)
    }
    
    public func retroSetAudioSample(audioSampleCallback: @convention(c) (Int16, Int16) -> Void) {
        retro_set_audio_sample(audioSampleCallback)
    }
    public func retroSetAudioSampleBatch(audioSampleBatchCallback: @convention(c) (UnsafePointer<Int16>?, Int) -> Int) {
        retro_set_audio_sample_batch(audioSampleBatchCallback)
    }
    public func retroSetInputPoll(inputPollCallback: @convention(c) () -> Void) {
        retro_set_input_poll(inputPollCallback)
    }
    public func retroSetInputState(inputStateCallback: @convention(c) (UInt32, UInt32, UInt32, UInt32) -> Int16) {
        retro_set_input_state(inputStateCallback)
    }
    
}



