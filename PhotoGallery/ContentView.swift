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
       
 
            StackView()
        
    }
    
}



struct GridView: View {
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .cyan, .indigo, .brown, .orange]
    let columns = [
            GridItem(.adaptive(minimum: 80))
        ]
    
    var namespace: Namespace.ID
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(colors.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 20)
                    .fill(colors[index])
                    .matchedGeometryEffect(id: index, in: namespace)
                
            }
        }
    }
}
struct StackView: View {
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .cyan, .indigo, .brown, .orange]
    
    var scrollState: ScrollState = ScrollState()
    
    @State var actualWidth: CGFloat = 0

    @State var scrolledIndex: Int? = 0
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
                            .onTapGesture {
                                if scrolledIndex != nil {
                                    if index > Int(scrollState.progress.rounded(.toNearestOrEven)) {
                                        withAnimation {
                                            scrolledIndex! += 1
                                        }
                                    } else {
                                        withAnimation {
                                            scrolledIndex! -= 1
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 60)
                            .containerRelativeFrame([.horizontal, .vertical])
                            .zIndex(zIndex(index: index))
                            .visualEffect { view, proxy in
                                view
                                    .offset(x: regularOffset(proxy, index: index))
                                    .rotationEffect(rotation(proxy, index: index))
                                    .scaleEffect(scale(proxy, index: index))
                                    //.scaleEffect(additionalScale(proxy, index: index))
                                    .offset(x: offset(proxy, index: index))
                                    .rotation3D(swipeRotation(proxy, index: index), axis: (x: 0, y: 1, z: 0))
                                    
                            }
                            .scrollTargetLayout()
                            
                    }
                
            }
            
                
            
            
        }
        .scrollPosition(id: $scrolledIndex)
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .padding(20)
            
        
        
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
        print(minX(proxy), "min")
        if index == 0 {
            
            scrollState.progress = progress
        }
        let maxAngle: CGFloat = max(min(-(scrollState.progress - CGFloat(index))*3, 120), -120)
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
        
        
        let maxRotation: CGFloat = 60
        
        let progress = max(min(scrollState.progress - Double(index), 1), -1)
        
        var currentOffset: CGFloat {
            if index == scrollState.currentIndex {
               
                if progress < 0 {
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
                
                if progress < -0.5 {
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
                if progress > 0.5 {
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
                
        let maxOffset = proxy.size.width/1.5
        
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
        
        if index == 0 {
            print(progress(proxy))
        }
        
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


