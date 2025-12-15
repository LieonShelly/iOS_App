//
//  DeviceSettingRow.swift
//  PageScrolllView
//
//  Created by Renjun Li on 2025/7/7.
//


import SwiftUI

struct DeviceSettingRow<T: View>: View {
    let title: String
    let subTitle: String?
    let traillingView: () -> T
    
    init(title: String,
         subTitle: String? = nil,
         @ViewBuilder traillingView: @escaping () -> T) {
        self.title = title
        self.subTitle = subTitle
        self.traillingView = traillingView
    }
    
    var body: some View {
        
        HStack(spacing: .zero) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.black)
                
                if let subTitle {
                    Text(subTitle)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
            traillingView()
                
        }
        .padding(.vertical, 12)
    }
}


#Preview {
    ScrollView {
        LazyVStack(spacing: .zero) {
            
            
            Section(content: {
                VStack(spacing: .zero) {
                    DeviceSettingRow(
                        title: "访问模式",
                        traillingView: {
                            HStack {
                                Text("受限")
                                    .font(.callout)
                                    .foregroundStyle(.gray)
                                
                                Image(systemName: "arrow.right")
                            }
                    })
                    Divider()
                    
                    DeviceSettingRow(
                        title: "设备信息",
                        traillingView: {
                            Image(systemName: "arrow.right")
                    })
                    
                    Divider()
                    DeviceSettingRow(
                        title: "软件更新",
                        traillingView: {
                            Image(systemName: "arrow.right")
                    })
                    Divider()
                    DeviceSettingRow(
                        title: "更多设置",
                        traillingView: {
                            Image(systemName: "arrow.right")
                    })
                }
                .padding(.horizontal, 20)
                .background(.white)
            }, header: {
                Rectangle().fill(.gray)
                    .frame(height: 8)
            })
            
            Section(content: {
                Rectangle()
                    .fill(.white)
                    .frame(height: 48)
                    .overlay {
                        Text("重启设备")
                            .foregroundStyle(.blue)
                            .onTapGesture {
                                
                            }
                    }
            }, header: {
                Rectangle().fill(.gray)
                    .frame(height: 8)
            })
            
            Section(content: {
                Rectangle()
                    .fill(.white)
                    .frame(height: 48)
                    .overlay {
                        Text("解绑设备")
                            .foregroundStyle(.blue)
                            .onTapGesture {
                                
                            }
                    }
            }, header: {
                Rectangle().fill(.gray)
                    .frame(height: 8)
            })
            
        }
    }
    .background(.red)

    
}
