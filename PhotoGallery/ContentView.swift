//
//  ContentView.swift
//  PhotoGallery
//
//  Created by Alexey Primechaev on 22.06.2023.
//

import SwiftUI


@Observable
class ScrollState {
    var offset: CGPoint = .zero
    var progress: CGFloat = .zero
    
    var currentIndex: Int {
        if progress.isFinite {
            Int(progress.rounded(.toNearestOrEven))
        } else {
            0
        }
    }
}


struct ContentView: View {
    @State var isGrid = false
    
    
    var body: some View {
       
            
               

        StackView(images: ["IMG_5242", "IMG_5727", "IMG_7116", "IMG_7172", "IMG_7178", "IMG_7359", "IMG_7404"])
            .padding(40)
                            
              
            
        
        
    }
    
}


struct StackView: View {
    
    
        
    private var scrollState: ScrollState = ScrollState()
    
    @State var actualWidth: CGFloat = 0

    @State var scrolledIndex: Int? = 0
    
    @State var totalWidth: CGFloat = 300
    
    struct ImageWrapper: Identifiable, Transferable, Codable, Hashable {
        
        var id: Int
        var image: String
        
        static var transferRepresentation: some TransferRepresentation {
            CodableRepresentation(contentType: .text)
        }
    }
    
    private var images: [ImageWrapper]
    
    init(images: [String]) {
        
        var _images: [ImageWrapper] = []
        
        for index in images.indices {
            _images.append(ImageWrapper(id: index, image: images[index]))
        }
        self.images = _images
    }
    
    
    var body: some View {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(images) { wrapper in
                        
                        Image(wrapper.image)
                            .resizable()
                            .aspectRatio(3/4, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: actualWidth*0.1))
                            .drawingGroup()
                            .background {
                                if wrapper.id == 0 {
                                    GeometryReader { geo in
                                        Color.clear.onAppear {
                                            print(geo.size.width, "GEO")
                                            actualWidth = geo.size.width
                                        }
                                        .onChange(of: geo.size.width) {
                                            print(geo.size.width, "GEO")
                                            actualWidth = geo.size.width
                                        }
                                    }
                                }
                            }
                                
                            .containerRelativeFrame([.horizontal], count: 7, span: 6, spacing: 0)
                            .containerRelativeFrame([.horizontal])
                            .zIndex(zIndex(index: wrapper.id))
                            .visualEffect { view, proxy in
                                view
                                    .offset(x: regularOffset(proxy, index: wrapper.id))
                                    .rotationEffect(rotation(proxy, index: wrapper.id))
                                    .scaleEffect(scale(proxy, index: wrapper.id))
                                //.scaleEffect(additionalScale(proxy, index: index))
                                    .offset(x: offset(proxy, index: wrapper.id))
                                    .rotation3DEffect(swipeRotation(proxy, index: wrapper.id), axis: (x: 0, y: 1, z: 0))
                                
                            }
                            .scrollTargetLayout()
                            
                            
                        
                    }
                    
                }
                
                
                
                
            }
            .scrollPosition(id: $scrolledIndex)
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .aspectRatio(1, contentMode: .fit)
        
        
    }
    
    func zIndex(index: Int) -> Double {

        
      
        
       
        if index == scrollState.currentIndex {
            return .infinity
        } else {
            if index == scrollState.currentIndex + 1 {
                if scrollState.progress - Double(scrollState.currentIndex) > 0 {
                    return 1000
                } else {
                    return Double(-index)
                }
            } else if index == scrollState.currentIndex - 1 {
                if scrollState.progress - Double(scrollState.currentIndex) < 0 {
                    return 1000
                } else {
                    return Double(index)
                }
            } else {
                
                if index < scrollState.currentIndex {
                    return Double(index)
                } else {
                    return Double(-index)
                }
            }
        }
    }
    
    func rotation(_ proxy: GeometryProxy, index: Int) -> Angle {
        
        let progress = minX(proxy) / proxy.size.width
        if index == 0 {
            
            scrollState.progress = progress
        }
        let maxAngle: CGFloat = max(min(-(scrollState.progress - CGFloat(index))*3, 120), -120)
        return Angle(degrees: maxAngle)
    }
    
    func scale(_ proxy: GeometryProxy, index: Int) -> CGFloat {
        let scale: CGFloat = 1 - abs((abs(scrollState.progress) - CGFloat(index))*0.08)
        
        return abs(scale)
        //return min(max(scale, 0.8), 1)
    }
    
    
    func progress(_ proxy: GeometryProxy) -> CGFloat {
        let progress = minX(proxy) / proxy.size.width
        
        return max(min(progress, 1), -1)
    }
    

    
    func regularOffset(_ proxy: GeometryProxy, index: Int) -> CGFloat {
        
        let maxOffset: CGFloat = -(scrollState.progress - CGFloat(index))*actualWidth*0.065
        
        
        return maxOffset
    }
    
    func swipeRotation(_ proxy: GeometryProxy, index: Int) -> Angle {
        
        
        let maxRotation: CGFloat = 60
        
        let progress = max(min(scrollState.progress - Double(index), 1), -1)
        
        var currentOffset: CGFloat {
            if index == scrollState.currentIndex {
               
                if progress <= 0 {
                    return maxRotation*progress * 0.5
                } else {
                    return maxRotation*progress
                }
            } else {
                return 0
            }
        }
        
        var nextOffset: CGFloat {
            if index == scrollState.currentIndex + 1 {
                
                if progress <= -0.5 {
                    return -maxRotation*(1 + progress) * 0.5
                } else {
                    return -maxRotation*(1 + progress)
                }
            } else {
                return 0
            }
        }
        
        var previousOffset: CGFloat {
            
            if index == scrollState.currentIndex - 1 {
                if progress >= 0.5 {
                    return maxRotation*(1 - progress)
                } else {
                    return maxRotation*(1 - progress)
                }
            } else {
                return 0
            }
        }
        
        
        return Angle(degrees: currentOffset + nextOffset + previousOffset)
    }
    
    func offset(_ proxy: GeometryProxy, index: Int) -> CGFloat {
                
        let maxOffset = actualWidth
        
        let progress = max(min(scrollState.progress - Double(index), 1), -1)
        
        var currentOffset: CGFloat {
            if index == scrollState.currentIndex {
                
                if progress > 0 {
                    return -maxOffset*progress
                } else {
                    return 0
                }
            } else {
                return 0
            }
        }
        
        var nextOffset: CGFloat {
            if index == scrollState.currentIndex + 1 {
                if progress < -0.5 {
                    return 0
                } else {
                    return 0
                }
            } else {
                return 0
            }
        }
        
        var previousOffset: CGFloat {
            if index == scrollState.currentIndex - 1 {
                
                if progress > 0.5 {
                    return -maxOffset*(1 - progress)
                } else {
                    return 0
                }
            } else {
                return 0
            }
        }
        
        
        
        return minX(proxy) + currentOffset + nextOffset + previousOffset
    }
    
    func additionalScale(_ proxy: GeometryProxy, index: Int) -> CGFloat {
        
        
        let maxScale = 0.15
        
        
        
        var currentOffset: CGFloat {
            if index == scrollState.currentIndex {
                return abs(maxScale*progress(proxy))
            } else {
                return 0
            }
        }
        
        var nextOffset: CGFloat {
            if index == scrollState.currentIndex + 1 {
                return abs(maxScale*(1+progress(proxy)))
            } else {
                return 0
            }
        }
        
        var previousOffset: CGFloat {
            
            if index == scrollState.currentIndex - 1 {
                return abs(maxScale*(1-progress(proxy)))
            } else {
                return 0
            }
        }
        
        return 1 - (currentOffset + nextOffset + previousOffset)
    }
    func minX(_ proxy: GeometryProxy) -> CGFloat {
        return proxy.bounds(of: .scrollView)?.minX ?? 0
    }
    
}


