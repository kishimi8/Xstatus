import Foundation

public class LLDB {
    private var db: OpaquePointer?
    
    public init?(_ path: String) {
        let options = leveldb_options_create()
        leveldb_options_set_create_if_missing(options, 1)
        
        var error: UnsafeMutablePointer<Int8>?
        self.db = leveldb_open(options, path, &error)
        leveldb_options_destroy(options)
        
        if let error = error {
            print("ERROR: Unable to open/create database: \(String(cString: error))")
            leveldb_free(error)
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    public func keys(_ key: String) -> [String] {
        guard let db = self.db else { return [] }
        
        let readOptions = leveldb_readoptions_create()
        let it = leveldb_create_iterator(db, readOptions)
        leveldb_readoptions_destroy(readOptions)
        
        var array: [String] = []
        let keyData = key.data(using: .utf8)!
        
        keyData.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            let baseAddress = ptr.baseAddress?.assumingMemoryBound(to: Int8.self)
            leveldb_iter_seek(it, baseAddress, keyData.count)
        }
        
        while leveldb_iter_valid(it) != 0 {
            var klen: Int = 0
            if let kptr = leveldb_iter_key(it, &klen) {
                let kstr = kptr.withMemoryRebound(to: UInt8.self, capacity: klen) {
                    String(bytes: UnsafeBufferPointer(start: $0, count: klen), encoding: .utf8) ?? ""
                }
                if !kstr.hasPrefix(key) {
                    break
                }
                array.append(kstr)
            }
            leveldb_iter_next(it)
        }
        
        leveldb_iter_destroy(it)
        return array
    }
    
    public func insert(_ key: String, value: String) -> Bool {
        guard let db = self.db else { return false }
        
        let writeOptions = leveldb_writeoptions_create()
        var error: UnsafeMutablePointer<Int8>?
        
        let keyData = key.data(using: .utf8)!
        let valData = value.data(using: .utf8)!
        
        keyData.withUnsafeBytes { kPtr in
            valData.withUnsafeBytes { vPtr in
                leveldb_put(db, writeOptions, 
                            kPtr.baseAddress?.assumingMemoryBound(to: Int8.self), keyData.count, 
                            vPtr.baseAddress?.assumingMemoryBound(to: Int8.self), valData.count, 
                            &error)
            }
        }
        
        leveldb_writeoptions_destroy(writeOptions)
        
        if let error = error {
            print("ERROR: Unable to insert: \(String(cString: error))")
            leveldb_free(error)
            return false
        }
        
        return true
    }
    
    public func findOne(_ key: String) -> String? {
        guard let db = self.db else { return nil }
        
        let readOptions = leveldb_readoptions_create()
        var vlen: Int = 0
        var error: UnsafeMutablePointer<Int8>?
        
        let keyData = key.data(using: .utf8)!
        var result: String? = nil
        
        keyData.withUnsafeBytes { kPtr in
            if let vptr = leveldb_get(db, readOptions, kPtr.baseAddress?.assumingMemoryBound(to: Int8.self), keyData.count, &vlen, &error) {
                result = vptr.withMemoryRebound(to: UInt8.self, capacity: vlen) {
                    String(bytes: UnsafeBufferPointer(start: $0, count: vlen), encoding: .utf8)
                }
                leveldb_free(vptr)
            }
        }
        
        leveldb_readoptions_destroy(readOptions)
        
        if let error = error {
            print("ERROR: Unable to findOne: \(String(cString: error))")
            leveldb_free(error)
        }
        
        return result?.trimmingCharacters(in: .whitespaces)
    }
    
    public func findLast(_ prefix: String) -> String? {
        guard let db = self.db else { return nil }
        
        let readOptions = leveldb_readoptions_create()
        let it = leveldb_create_iterator(db, readOptions)
        leveldb_readoptions_destroy(readOptions)
        
        leveldb_iter_seek_to_last(it)
        
        var result: String? = nil
        while leveldb_iter_valid(it) != 0 {
            var klen: Int = 0
            if let kptr = leveldb_iter_key(it, &klen) {
                let kstr = kptr.withMemoryRebound(to: UInt8.self, capacity: klen) {
                    String(bytes: UnsafeBufferPointer(start: $0, count: klen), encoding: .utf8) ?? ""
                }
                if kstr.hasPrefix(prefix) {
                    var vlen: Int = 0
                    if let vptr = leveldb_iter_value(it, &vlen) {
                        result = vptr.withMemoryRebound(to: UInt8.self, capacity: vlen) {
                            String(bytes: UnsafeBufferPointer(start: $0, count: vlen), encoding: .utf8)
                        }
                    }
                    break
                }
            }
            leveldb_iter_prev(it)
        }
        
        leveldb_iter_destroy(it)
        return result
    }
    
    public func findMany(_ prefix: String) -> [String] {
        guard let db = self.db else { return [] }
        
        let readOptions = leveldb_readoptions_create()
        let it = leveldb_create_iterator(db, readOptions)
        leveldb_readoptions_destroy(readOptions)
        
        var array: [String] = []
        let keyData = prefix.data(using: .utf8)!
        
        keyData.withUnsafeBytes { kPtr in
            leveldb_iter_seek(it, kPtr.baseAddress?.assumingMemoryBound(to: Int8.self), keyData.count)
        }
        
        while leveldb_iter_valid(it) != 0 {
            var klen: Int = 0
            if let kptr = leveldb_iter_key(it, &klen) {
                let kstr = kptr.withMemoryRebound(to: UInt8.self, capacity: klen) {
                    String(bytes: UnsafeBufferPointer(start: $0, count: klen), encoding: .utf8) ?? ""
                }
                if !kstr.hasPrefix(prefix) {
                    break
                }
                
                var vlen: Int = 0
                if let vptr = leveldb_iter_value(it, &vlen) {
                    let vstr = vptr.withMemoryRebound(to: UInt8.self, capacity: vlen) {
                        String(bytes: UnsafeBufferPointer(start: $0, count: vlen), encoding: .utf8) ?? ""
                    }
                    array.append(vstr)
                }
            }
            leveldb_iter_next(it)
        }
        
        leveldb_iter_destroy(it)
        return array
    }
    
    public func deleteOne(_ key: String) -> Bool {
        guard let db = self.db else { return false }
        
        let writeOptions = leveldb_writeoptions_create()
        var error: UnsafeMutablePointer<Int8>?
        let keyData = key.data(using: .utf8)!
        
        keyData.withUnsafeBytes { kPtr in
            leveldb_delete(db, writeOptions, kPtr.baseAddress?.assumingMemoryBound(to: Int8.self), keyData.count, &error)
        }
        
        leveldb_writeoptions_destroy(writeOptions)
        
        if let error = error {
            print("ERROR: Unable to deleteOne: \(String(cString: error))")
            leveldb_free(error)
            return false
        }
        
        return true
    }
    
    public func deleteMany(_ keys: [String]) -> Bool {
        guard let db = self.db else { return false }
        
        let batch = leveldb_writebatch_create()
        for key in keys {
            let keyData = key.data(using: .utf8)!
            keyData.withUnsafeBytes { kPtr in
                leveldb_writebatch_delete(batch, kPtr.baseAddress?.assumingMemoryBound(to: Int8.self), keyData.count)
            }
        }
        
        let writeOptions = leveldb_writeoptions_create()
        var error: UnsafeMutablePointer<Int8>?
        leveldb_write(db, writeOptions, batch, &error)
        
        leveldb_writebatch_destroy(batch)
        leveldb_writeoptions_destroy(writeOptions)
        
        if let error = error {
            print("ERROR: Unable to deleteMany: \(String(cString: error))")
            leveldb_free(error)
            return false
        }
        
        return true
    }
    
    public func close() {
        if let db = self.db {
            leveldb_close(db)
            self.db = nil
        }
    }
}
