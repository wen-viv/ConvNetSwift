import Foundation

infix operator | { associativity left }

func | (x: Double, y: Double) -> Int {
    if Int(x) != 0 {
        return Int(x)
    } else {
        return Int(y)
    }
}

func | (x: Int, y: Int) -> Int {
    return x != 0 ? x : y
}


// Random number utilities

class RandUtils {
    
    static var return_v = false
    static var v_val = 0.0
    
    static func gaussRandom() -> Double {
        if(return_v) {
            return_v = false
            return v_val
        }
        
        let u = 2*random_js()-1
        let v = 2*random_js()-1
        let r = u*u + v*v
        if(r == 0 || r > 1) { return gaussRandom() }
        let c = sqrt(-2*log(r)/r)
        v_val = v*c // cache this
        return_v = true
        return u*c
    }
    
    static func random_js() -> Double {
        return drand48()
        // should be [0 .. 1)
    }
    
    static func randf(a: Double, _ b: Double) -> Double {
        return random_js()*(b-a)+a
    }
    static func randi(a: Int, _ b: Int) -> Int {
        return Int(floor(random_js()))*(b-a)+a
    }
    
    static func randn(mu: Double, std: Double) -> Double {
        return mu+gaussRandom()*std
    }
    
}
// Array utilities
func zerosInt(n: Int) -> [Int] {
    return [Int](count: n, repeatedValue: 0)
}

func zerosDouble(n: Int) -> [Double] {
    return [Double](count: n, repeatedValue: 0.0)
}

func zerosBool(n: Int) -> [Bool] {
    return [Bool](count: n, repeatedValue: false)
}

func arrUnique(arr: [Int]) -> [Int] {
    return Array(Set(arr))
}

// return max and min of a given non-empty array.
struct Maxmin {
    var maxi: Int
    var maxv: Double
    var mini: Int
    var minv: Double
    var dv: Double
}

func maxmin(w: [Double]) -> Maxmin? {
    guard (w.count > 0),
        let maxv = w.maxElement(),
        let maxi = w.indexOf(maxv),
        let minv = w.minElement(),
        let mini = w.indexOf(minv)
        else {
            return nil
    }
    return Maxmin(maxi: maxi, maxv: maxv, mini: mini, minv: minv, dv: maxv-minv)
}

// create random permutation of numbers, in range [0...n-1]
func randperm(n: Int) -> [Int]{
    var j = 0
    var temp: Int = 0
    var array: [Int] = []
    for q in 0 ..< n {
        array[q]=q
    }
    for (var i = n; i != 0; i--) {
        j = Int(floor(RandUtils.random_js())) * (i+1)
        temp = array[i]
        array[i] = array[j]
        array[j] = temp
    }
    return array
}

// sample from list lst according to probabilities in list probs
// the two lists are of same size, and probs adds up to 1
func weightedSample(lst: [Double], probs: [Double]) -> Double? {
    let p = RandUtils.randf(0, 1.0)
    var cumprob = 0.0
    let n=lst.count
    for k in 0 ..< n {
        cumprob += probs[k]
        if(p < cumprob) { return lst[k] }
    }
    return nil
}

// syntactic sugar function for getting default parameter values
func getopt(opt: [String: AnyObject], _ field_name: String, _ default_value: AnyObject) -> AnyObject {
    // case of single string
    return opt[field_name] ?? default_value
}

func getopt(opt: [String: AnyObject], _ field_names: [String], _ default_value: AnyObject) -> AnyObject {
    // assume we are given a list of string instead
    var ret = default_value
    for i in 0 ..< field_names.count {
        
        let f = field_names[i]
        ret = opt[f] ?? ret // overwrite return value
    }
    return ret
}

