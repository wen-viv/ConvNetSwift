//
//  ConvNetSwiftTests.swift
//  ConvNetSwiftTests
//
//  Created by Alex Sosnovshchenko on 10/22/15.
//  Copyright © 2015 OWL. All rights reserved.
//

import XCTest

class ConvNetSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test2LayerNNPerformance() {
        // Here's a minimum example of defining a 2-layer neural network and training it on a single data point:
        self.measureBlock {
            // species a 2-layer neural network with one hidden layer of 20 neurons
            // input layer declares size of input. here: 2-D data
            // ConvNetJS works on 3-Dimensional volumes (sx, sy, depth), but if you're not dealing with images
            // then the first two dimensions (sx, sy) will always be kept at size 1
            let input = InputLayerOpt(outSx: 1, outSy: 1, outDepth: 2)
            // declare 20 neurons, followed by ReLU (rectified linear unit non-linearity)
            let fc = FullyConnectedLayerOpt(numNeurons: 20, activation: .ReLU)
            // declare the linear classifier on top of the previous hidden layer
            let softmax = SoftmaxLayerOpt(numClasses: 10)
            
            let layerDefs: [LayerOptTypeProtocol] = [input, fc, softmax]
            let net = Net()
            net.makeLayers(layerDefs)
            
            // forward a random data point through the network
            var x = Vol(array: [0.3, -0.5])
            let prob = net.forward(&x)
            
            // prob is a Vol. Vols have a field .w that stores the raw data, and .dw that stores gradients
            print("probability that x is class 0: \(prob.w[0])") // prints 0.50101
            XCTAssertEqualWithAccuracy(prob.w[0], 0.50101, accuracy: 0.1)
            
            var traindef = TrainerOpt()
            traindef.learningRate = 0.01
            traindef.l2Decay = 0.001
            
            let trainer = Trainer(net: net, options: traindef)
            trainer.train(x: &x, y: 0) // train the network, specifying that x is class zero
            
            let prob2 = net.forward(&x)
            print("probability that x is class 0: \(prob2.w[0])")
            // now prints 0.50374, slightly higher than previous 0.50101: the networks
            // weights have been adjusted by the Trainer to give a higher probability to
            // the class we trained the network with (zero)
            XCTAssertEqualWithAccuracy(prob2.w[0], 0.50374, accuracy: 0.1)
            
        }
    }
    
    func testConvolutionalNN() {
        // Small Convolutional Neural Network if you wish to predict on images
        self.measureBlock {
            let input = InputLayerOpt(outSx: 32, outSy: 32, outDepth: 3)// declare size of input
            // output Vol is of size 32x32x3 here
            let conv1 = ConvLayerOpt(sx: 5, filters: 16, stride: 1, pad: 2, activation: .ReLU)
            // the layer will perform convolution with 16 kernels, each of size 5x5.
            // the input will be padded with 2 pixels on all sides to make the output Vol of the same size
            // output Vol will thus be 32x32x16 at this point
            let pool1 = PoolLayerOpt(sx: 2, stride: 2)
            // output Vol is of size 16x16x16 here
            let conv2 = ConvLayerOpt(sx: 5, filters: 20, stride: 1, pad: 2, activation: .ReLU)
            // output Vol is of size 16x16x20 here
            let pool2 = PoolLayerOpt(sx: 2, stride: 2)
            // output Vol is of size 8x8x20 here
            let conv3 = ConvLayerOpt(sx: 5, filters: 20, stride: 1, pad: 2, activation: .ReLU)
            // output Vol is of size 8x8x20 here
            let pool3 = PoolLayerOpt(sx: 2, stride: 2)
            // output Vol is of size 4x4x20 here
            let softmax = SoftmaxLayerOpt(numClasses: 10)
            // output Vol is of size 1x1x10 here

            let layerDefs: [LayerOptTypeProtocol] = [input, conv1, pool1, conv2, pool2, conv3, pool3, softmax]

            let net = Net()
            net.makeLayers(layerDefs)

            // helpful utility for converting images into Vols is included
            let img = UIImage(named: "Nyura")!
            var x = img.toVol(convert_grayscale: false)
            let output_probabilities_vol = net.forward(&x)
            print(output_probabilities_vol.w)
        }
    }
    
}
