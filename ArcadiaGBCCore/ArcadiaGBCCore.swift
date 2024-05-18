//
//  iRetroGBCCore.swift
//  iRetroGBCCore
//
//  Created by Davide Andreoli on 01/05/24.
//

import Foundation
import ArcadiaCore
import LibretroGearboy
import SwiftUI
import Observation
import CoreGraphics
import CoreVideo
import AVFoundation

//TODO: There is an issue with GBC games, the core does not input the correct pixel values (they're very dark) and after loading them the core starts behaving in weird way (outputting very dark pixel values also for GB games)

extension retro_game_geometry: ArcadiaGameGeometryProtocol {
    
}

extension retro_system_timing: ArcadiaSystemTimingProtocol {
    
}

extension retro_system_av_info: ArcadiaAudioVideoInfoProtocol {
    public typealias ArcadiaGeometryType = retro_game_geometry
    public typealias ArcadiaTimingType = retro_system_timing
    
}

extension retro_game_info: ArcadiaGameInfoProtocol {
    
}

extension retro_variable: ArcadiaVariableProtocol {
    
}


@Observable public class ArcadiaGBC: ArcadiaCoreProtocol {
    
    public typealias ArcadiaCoreType = ArcadiaGBC
    public typealias ArcadiaAudioVideoInfoType = retro_system_av_info
    public typealias ArcadiaGameInfo = retro_game_info
    public typealias ArcadiaGameGeometryType = retro_game_geometry
    public typealias ArcadiaSystemTimingType = retro_system_timing
    public typealias ArcadiaVariableType = retro_variable
    

    public var paused = false
    public var initialized = false
    public var mainGameLoop : Timer? = nil
    public var loadedGame: URL? = nil
    public var audioVideoInfo: retro_system_av_info = retro_system_av_info(geometry: retro_game_geometry(base_width: 160, base_height: 144, max_width: 160, max_height: 144, aspect_ratio: 1.1111112), timing: retro_system_timing(fps: 59.72750056960583, sample_rate: 44100))

    
    public init() {
    }
    
    

    public func startGameLoop() {
        mainGameLoop = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(gameLoop), userInfo: nil, repeats: true)
        RunLoop.current.add(mainGameLoop!, forMode: .default)
        paused = false
    }
    
    public func stopGameLoop() {
        mainGameLoop?.invalidate()
        mainGameLoop = nil
        paused = true
    }
    
    
    @objc func gameLoop() {
        if !paused {
            retroRun()
        }
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
    
    public func retroLoadGame(gameInfo: retro_game_info) {
        var gameInfo = gameInfo
        retro_load_game(&gameInfo)
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



