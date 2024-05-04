//
//  iRetroGBCCore.swift
//  iRetroGBCCore
//
//  Created by Davide Andreoli on 01/05/24.
//

import Foundation
import iRetroCore
import GBCCore
import QuartzCore

public struct iRetroGBC: iRetroCoreProtocol {
    
    public init() {
        
        retro_set_environment(libretro_environment_callback)
        retro_init()
        load_rom()
        retro_set_video_refresh(libretro_video_refresh_callback)
        retro_set_audio_sample(libretro_audio_sample_callback)
        retro_set_audio_sample_batch(libretro_audio_sample_batch_callback)
        retro_set_input_poll(libretro_input_poll_callback)
        retro_set_input_state(libretro_input_state_callback)
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            retro_run()
        }
        RunLoop.current.add(timer, forMode: .common)
        RunLoop.current.run()
        
    }
    
    func load_rom() {
        var filepath = Bundle.main.path(forResource: "Tetris", ofType: "gb")!
        var location = filepath.cString(using: String.Encoding.utf8)!
        var fileData = loadBinaryContentOfFile(atPath: filepath)!
        
        let rom_name_cstr = (filepath as NSString).utf8String
        let rom_name_cptr = UnsafePointer<CChar>(rom_name_cstr)
        
        guard let contents = FileManager.default.contents(atPath: filepath),
              let data = contents.withUnsafeBytes({ $0.baseAddress }) else {
            fatalError("Failed to read file")
        }
        
        var rom_info = retro_game_info(path: rom_name_cptr, data: data, size: contents.count, meta: nil)
        
        retro_load_game(&rom_info)
        
    }
    
    let libretro_environment_callback: retro_environment_t = {command, data in
        print("libretro_environment_callback Called with command: \(command)")
        switch command {
        case 3:
            data?.storeBytes(of: true, as: Bool.self)
            return true
        case 10:
            print("TODO: Handle ENVIRONMENT_SET_PIXEL_FORMAT when we start drawing the the screen buffer")
            return true
        default:
            return false
        }
    }
    
    let libretro_video_refresh_callback: retro_video_refresh_t = {_,_,_,_  in
        print("video refresh")
    }
    let libretro_audio_sample_callback: retro_audio_sample_t = {_,_  in
        print("audio sample")
    }
    let libretro_audio_sample_batch_callback: retro_audio_sample_batch_t = {_,_  in
        print("audio sample batch")
        return 0
    }
    let libretro_input_poll_callback: retro_input_poll_t = {
        print("input poll")
    }
    
    let libretro_input_state_callback: retro_input_state_t = {_,_,_,_ in
        print("input state")
        return Int16()
    }
    
    func loadBinaryContentOfFile(atPath filePath: String) -> Data? {
        
        if let filepath = Bundle.main.url(forResource: "Tetris", withExtension: "gb") {
            do {
                let contents = try Data(contentsOf: filepath)
                return contents
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    /*
     retro_set_environment: *(dylib.get(b"retro_set_environment").unwrap()),
     retro_set_video_refresh: *(dylib.get(b"retro_set_video_refresh").unwrap()),
     retro_set_audio_sample: *(dylib.get(b"retro_set_audio_sample").unwrap()),
     retro_set_audio_sample_batch: *(dylib.get(b"retro_set_audio_sample_batch").unwrap()),
     retro_set_input_poll: *(dylib.get(b"retro_set_input_poll").unwrap()),
     retro_set_input_state: *(dylib.get(b"retro_set_input_state").unwrap()),

     retro_init: *(dylib.get(b"retro_init").unwrap()),
     retro_deinit: *(dylib.get(b"retro_deinit").unwrap()),

     retro_api_version: *(dylib.get(b"retro_api_version").unwrap()),

     retro_get_system_info: *(dylib.get(b"retro_get_system_info").unwrap()),
     retro_get_system_av_info: *(dylib.get(b"retro_get_system_av_info").unwrap()),
     retro_set_controller_port_device: *(dylib.get(b"retro_set_controller_port_device").unwrap()),

     retro_reset: *(dylib.get(b"retro_reset").unwrap()),
     retro_run: *(dylib.get(b"retro_run").unwrap()),

     retro_serialize_size: *(dylib.get(b"retro_serialize_size").unwrap()),
     retro_serialize: *(dylib.get(b"retro_serialize").unwrap()),
     retro_unserialize: *(dylib.get(b"retro_unserialize").unwrap()),

     retro_cheat_reset: *(dylib.get(b"retro_cheat_reset").unwrap()),
     retro_cheat_set: *(dylib.get(b"retro_cheat_set").unwrap()),

     retro_load_game: *(dylib.get(b"retro_load_game").unwrap()),
     retro_load_game_special: *(dylib.get(b"retro_load_game_special").unwrap()),
     retro_unload_game: *(dylib.get(b"retro_unload_game").unwrap()),

     retro_get_region: *(dylib.get(b"retro_get_region").unwrap()),
     retro_get_memory_data: *(dylib.get(b"retro_get_memory_data").unwrap()),
     retro_get_memory_size: *(dylib.get(b"retro_get_memory_size").unwrap()),
    */
}
