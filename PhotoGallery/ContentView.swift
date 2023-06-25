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
}

struct ContentView: View {
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .cyan, .indigo, .brown, .orange]
    
    var scrollState: ScrollState = ScrollState()
    
    @State var actualWidth: CGFloat = 0

    
    var body: some View {
        ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(colors.indices, id: \.self) { index in
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colors[index])
                            .aspectRatio(3/4, contentMode: .fit)
                        
                            .contextMenu {
                                Text("Meow")
                            }
                            .padding(.horizontal, 60)
                            .containerRelativeFrame([.horizontal, .vertical])
                            .zIndex(zIndex(index: index))
                            .visualEffect { view, proxy in
                                view
                                    .offset(x: regularOffset(proxy, index: index))
                                    .rotationEffect(rotation(proxy, index: index))
                                    .scaleEffect(scale(proxy, index: index))
                                    .offset(x: offset(proxy, index: index))
                                    .rotation3D(swipeRotation(proxy, index: index), axis: (x: 0, y: 1, z: 0))
                                    
                            }
                            .scrollTargetLayout()
                            
                    }
                
            }
            
                
            
            
        }
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .padding(20)
        
        
    }
    
    func zIndex(index: Int) -> Double {

        
        let currentIndex: Int = Int(scrollState.progress.rounded(.toNearestOrEven))
      
        
       
        if index == currentIndex {
            return .infinity
        } else {
            if index == currentIndex + 1 {
                if scrollState.progress - Double(currentIndex) > 0 {
                    return 1000
                } else {
                    return Double(-index)
                }
            } else if index == currentIndex - 1 {
                if scrollState.progress - Double(currentIndex) < 0 {
                    return 1000
                } else {
                    return Double(index)
                }
            } else {
                
                if index < currentIndex {
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
        print(index, maxAngle)
        return Angle(degrees: maxAngle)
    }
    
    func scale(_ proxy: GeometryProxy, index: Int) -> CGFloat {
        let scale: CGFloat = 1 - abs((abs(scrollState.progress) - CGFloat(index))*0.065)
        
        return abs(scale)
        //return min(max(scale, 0.8), 1)
    }
    
    func brightness(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy) * (-0.2)
        return min(max(progress, -0.2), 0)
    }
    func progress(_ proxy: GeometryProxy) -> CGFloat {
        let progress = minX(proxy) / proxy.size.width
        
        return max(min(progress, 1), -1)
    }
    

    
    func regularOffset(_ proxy: GeometryProxy, index: Int) -> CGFloat {
        
        let maxOffset: CGFloat = -(scrollState.progress - CGFloat(index))*20
        
        
        return maxOffset
    }
    
    func swipeRotation(_ proxy: GeometryProxy, index: Int) -> Angle {
        
        let currentIndex: Int = Int(scrollState.progress.rounded(.toNearestOrEven))
        
        let maxRotation: CGFloat = 35
        
        var currentOffset: CGFloat {
            if index == currentIndex {
                return maxRotation*progress(proxy)
            } else {
                return 0
            }
        }
        
        var nextOffset: CGFloat {
            if index == currentIndex + 1 {
                if progress(proxy) < -0.5 {
                    return -maxRotation*(1 + progress(proxy))
                } else {
                    return -maxRotation*(1 + progress(proxy))
                }
            } else {
                return 0
            }
        }
        
        var previousOffset: CGFloat {
            
            if index == currentIndex - 1 {
                if progress(proxy) > 0.5 {
                    return maxRotation*(1 - progress(proxy))
                } else {
                    return maxRotation*(1 - progress(proxy))
                }
            } else {
                return 0
            }
        }
        
        
        
        return Angle(degrees: currentOffset + nextOffset + previousOffset)
    }
    
    func offset(_ proxy: GeometryProxy, index: Int) -> CGFloat {
        
        let currentIndex: Int = Int(scrollState.progress.rounded(.toNearestOrEven))
        
        let maxOffset = proxy.size.width/2
        
        var currentOffset: CGFloat {
            if index == currentIndex {
                if progress(proxy) < 0.5 {
                    return -maxOffset*progress(proxy)
                } else {
                    return -maxOffset*progress(proxy)
                }
            } else {
                return 0
            }
        }
        
        var nextOffset: CGFloat {
            if index == currentIndex + 1 {
                if progress(proxy) < -0.5 {
                    return maxOffset*(1 + progress(proxy))
                } else {
                    return maxOffset*(1 + progress(proxy))
                }
            } else {
                return 0
            }
        }
        
        var previousOffset: CGFloat {
            
            if index == currentIndex - 1 {
                if progress(proxy) > 0.5 {
                    return -maxOffset*(1 - progress(proxy))
                } else {
                    return -maxOffset*(1 - progress(proxy))
                }
            } else {
                return 0
            }
        }
        
        
        
        return minX(proxy) + currentOffset + nextOffset + previousOffset
    }
    
    func additionalScale(_ proxy: GeometryProxy, index: Int) -> CGFloat {
        
        let currentIndex: Int = Int(scrollState.progress.rounded(.toNearestOrEven))
        
        let maxScale = 0.2
        
        var currentOffset: CGFloat {
            if index == currentIndex {
                return abs(maxScale*progress(proxy))
            } else {
                return 0
            }
        }
        
        var nextOffset: CGFloat {
            if index == currentIndex + 1 {
                return abs(maxScale*(1+progress(proxy)))
            } else {
                return 0
            }
        }
        
        var previousOffset: CGFloat {
            
            if index == currentIndex - 1 {
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


