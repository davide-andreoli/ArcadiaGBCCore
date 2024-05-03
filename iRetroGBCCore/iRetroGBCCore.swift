//
//  iRetroGBCCore.swift
//  iRetroGBCCore
//
//  Created by Davide Andreoli on 01/05/24.
//

import Foundation
import iRetroCore
import GBCCore

public struct iRetroGBC: iRetroCoreProtocol {
    
    public init() {
        
        retro_set_environment(libretro_environment_callback)
        retro_init()
        load_rom()
    }
    
    func load_rom() {

        var location = "/Users/davideandreoli/Developer/iRetro/Cores/iRetroGBCCore/iRetroGBCCore/Tetris.gbc".cString(using: String.Encoding.utf8)!
        var fileData = loadBinaryContentOfFile(atPath: "/Users/davideandreoli/Developer/iRetro/Cores/iRetroGBCCore/iRetroGBCCore/Tetris.gbc")!
        
        var rom_info = retro_game_info()
        
        withUnsafePointer(to: location[0]) { locationPointer in
            withUnsafePointer(to: fileData) { fileDataPointer in
                rom_info = retro_game_info.init(path: locationPointer, data: fileDataPointer, size: MemoryLayout.size(ofValue: fileData), meta: locationPointer)
            }
        }
        
        withUnsafePointer(to: rom_info) { rom_infoPointer in
            retro_load_game(rom_infoPointer)
        }
        
        

        
    }
    
    let libretro_environment_callback: @convention(c) (UInt32, UnsafeMutableRawPointer?) -> Bool = {command, data in
        print("libretro_environment_callback Called with command: \(command)")
        switch command {
        case 3:
            data?.storeBytes(of: true, as: Bool.self)
            return true
        default:
            return false
        }
        return false
    }
    
    func loadBinaryContentOfFile(atPath filePath: String) -> Data? {
        
        if let filepath = Bundle.main.url(forResource: "Tetris", withExtension: "gbc") {
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
