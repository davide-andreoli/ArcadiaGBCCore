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

func convertToUInt32Pixels(from xrgb8888Pixels: [UInt8]) -> [UInt32] {
    var uint32Pixels = [UInt32]()
    var index = 0
    
    while index < xrgb8888Pixels.count {
        let x = UInt32(xrgb8888Pixels[index]) << 24
        let r = UInt32(xrgb8888Pixels[index + 1]) << 16
        let g = UInt32(xrgb8888Pixels[index + 2]) << 8
        let b = UInt32(xrgb8888Pixels[index + 3])
        
        let pixel = x | r | g | b
        uint32Pixels.append(pixel)
        
        index += 4
    }
    
    return uint32Pixels
}

func createCGImageFromUint8(pixels: [UInt8], width: Int, height: Int) -> CGImage? {
    
    let numBytes = pixels.count
    let numComponents = 1 // Grayscale image has one component per pixel
    let colorspace = CGColorSpaceCreateDeviceGray()
    
    guard let grayScaleData = CFDataCreate(nil, pixels, numBytes) else {
        return nil
    }

    
    guard let provider = CGDataProvider(data: grayScaleData) else {
        return nil
    }
    
    return CGImage(
        width: width,
        height: height,
        bitsPerComponent: 8,
        bitsPerPixel: 8 * numComponents,
        bytesPerRow: width * numComponents,
        space: colorspace,
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
        provider: provider,
        decode: nil,
        shouldInterpolate: true,
        intent: CGColorRenderingIntent.defaultIntent)
}

func createCGImageFromXRGB8888(pixels: [UInt8], width: Int, height: Int) -> CGImage? {
    print(pixels.count)
    
    let numBytes = pixels.count
    let bytesPerPixel = 4 // Each pixel is represented by 4 bytes in XRGB8888 format
    let numComponents = 3 // XRGB format has three components per pixel (Red, Green, Blue)
    let bitsPerComponent = 8
    
    let colorspace = CGColorSpaceCreateDeviceRGB()
    
    guard let rgbData = CFDataCreate(nil, pixels, numBytes) else {
        return nil
    }
    
    guard let provider = CGDataProvider(data: rgbData) else {
        return nil
    }
    
    return CGImage(
        width: width,
        height: height,
        bitsPerComponent: bitsPerComponent,
        bitsPerPixel: bytesPerPixel * bitsPerComponent,
        bytesPerRow: width * bytesPerPixel,
        space: colorspace,
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue), // Skip the first byte (alpha)
        provider: provider,
        decode: nil,
        shouldInterpolate: true,
        intent: CGColorRenderingIntent.defaultIntent)
}




@Observable public class iRetroGBC: iRetroCoreProtocol {
    
    public static let sharedInstance = iRetroGBC()
    
    public var width = 160
    public var height = 144
    public var pitch = 2048
    public var mainBuffer = [UInt8]()
    public var currentFrame : CGImage? {
        createCGImageFromXRGB8888(pixels: self.mainBuffer, width: 320, height: 144)
    }
    public var buttonsPressed : [Int] = []

        
    public init() {

        retro_set_environment(libretro_environment_callback)
        retro_init()
        load_rom()
        retro_set_video_refresh(libretro_video_refresh_callback)
        retro_set_audio_sample(libretro_audio_sample_callback)
        retro_set_audio_sample_batch(libretro_audio_sample_batch_callback)
        retro_set_input_poll(libretro_input_poll_callback)
        retro_set_input_state(libretro_input_state_callback)
        
    }
    
    public func pressButton(button: Int) {
        iRetroGBC.sharedInstance.buttonsPressed.append(button)
    }
    
    public func runRom() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            retro_run()
        }
        RunLoop.current.add(timer, forMode: .common)
        RunLoop.current.run()
    }
    
    public func startGameLoop() {
        let gameLoopTimer = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(gameLoop), userInfo: nil, repeats: true)
        RunLoop.current.add(gameLoopTimer, forMode: .default)
    }
    
    @objc func gameLoop() {
        retro_run()
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
            let format = retro_pixel_format(rawValue: data!.load(as: UInt32.self))
            print("Environment Pixel format set as \(data!.load(as: UInt32.self))")
            return true
        default:
            return false
        }
    }
    
    let libretro_video_refresh_callback: retro_video_refresh_t = {frameBufferData, width, height, pitch  in
        guard let frameBufferPtr = frameBufferData else {
            print("frame_buffer_data was null")
            return
        }
        

        print("Width: \(width), Height: \(height), Pitch: \(pitch)")
        
        let height = Int(height)
        let width = Int(width) * 2 //TODO: Understand why I need to multiply the width by two
        let pitch = pitch

        let bytesPerPixel = 4 // Assuming XRGB8888 format
        let lengthOfFrameBuffer = height * pitch

        var pixelArray = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        for y in 0..<height {
            let rowOffset = y * pitch
            for x in 0..<width {
                let pixelOffset = rowOffset + x * bytesPerPixel
                let rgbaOffset = y * width * bytesPerPixel + x * bytesPerPixel

                // Assuming XRGB8888 format where each pixel is 4 bytes
                let blue = frameBufferPtr.load(fromByteOffset: pixelOffset, as: UInt8.self)
                let green = frameBufferPtr.load(fromByteOffset: pixelOffset + 1, as: UInt8.self)
                let red = frameBufferPtr.load(fromByteOffset: pixelOffset + 2, as: UInt8.self)
                let alpha = frameBufferPtr.load(fromByteOffset: pixelOffset + 3, as: UInt8.self)


                pixelArray[rgbaOffset] = alpha
                pixelArray[rgbaOffset + 1] = red
                pixelArray[rgbaOffset + 2] = green
                pixelArray[rgbaOffset + 3] = blue
            }
        }
        sharedInstance.mainBuffer = pixelArray
                  
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
    
    let libretro_input_state_callback: retro_input_state_t = {port,device,index,id in
        print("libretro_set_input_state_callback port: \(port) device: \(device) index: \(index) id: \(id)")
        if !iRetroGBC.sharedInstance.buttonsPressed.isEmpty {
            if iRetroGBC.sharedInstance.buttonsPressed[0] == Int(id) {
                iRetroGBC.sharedInstance.buttonsPressed.remove(at: 0)
                return Int16(1)
            }
        }
        return Int16(0)
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
