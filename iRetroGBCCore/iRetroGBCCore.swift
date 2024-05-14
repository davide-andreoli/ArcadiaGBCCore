//
//  iRetroGBCCore.swift
//  iRetroGBCCore
//
//  Created by Davide Andreoli on 01/05/24.
//

import Foundation
import iRetroCore
import GBCCore
import SwiftUI
import Observation
import CoreGraphics
import CoreVideo
import AVFoundation


extension retro_game_geometry: iRetroGameGeometry {
    
}

extension retro_system_timing: iRetroSystemTiming {
    
}

extension retro_system_av_info: iRetroAudioVideoInfo {
    public typealias iRetroGeometryType = retro_game_geometry
    public typealias iRetroTimingType = retro_system_timing
    
}

extension retro_game_info: iRetroGameInfoProtocol {
    
}


@Observable public class iRetroGBC: iRetroCoreProtocol {

    public typealias iRetroCoreType = iRetroGBC
    public typealias iRetroAudioVideoInfoType = retro_system_av_info
    public typealias iRetroGameInfo = retro_game_info
    public typealias iRetroGameGeometryType = retro_game_geometry
    public typealias iRetroSystemTimingType = retro_system_timing
    
    public static var sharedInstance = iRetroGBC()
    
    public var paused = false
    public var initialized = false
    public var mainGameLoop : Timer? = nil
    public var loadedGame: URL? = nil
    public var audioVideoInfo: retro_system_av_info = retro_system_av_info(geometry: retro_game_geometry(base_width: 160, base_height: 144, max_width: 160, max_height: 144, aspect_ratio: 1.1111112), timing: retro_system_timing(fps: 59.72750056960583, sample_rate: 32768.0))
    public var pitch = 2048
        
    public var mainBuffer = [UInt8]()
    public var currentFrame : CGImage? = nil
    public var buttonsPressed : [Int16] = []
    public var currentAudioFrame = [Int16]()
    public var currentAudioFrameData = Data()

        
    private init() {
    }

    public func startGameLoop() {
        mainGameLoop = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(gameLoop), userInfo: nil, repeats: true)
        RunLoop.current.add(mainGameLoop!, forMode: .default)
        paused = false
    }
    
    public func stopGameLoop() {
        mainGameLoop!.invalidate()
        mainGameLoop = nil
        paused = true
    }
    
    
    @objc func gameLoop() {
        if !paused {
            retroRun()
        }
    }
     
}

extension iRetroGBC {
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
    
    public func test() {
        print("Hell")
    }
        

    
}



