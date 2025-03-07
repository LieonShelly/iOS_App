
import SwiftUI
import Combine

// 朋友圈主视图
struct MomentListView: View {
    @StateObject private var viewModel = MomentListViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.moments.isEmpty && !viewModel.isLoading {
                    VStack {
                        Text("暂无朋友圈内容")
                            .font(.headline)
                        
                        if viewModel.errorMessage != nil {
                            Button("重新加载") {
                                viewModel.refresh()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top)
                        }
                    }
                } else {
                    List(viewModel.moments) { moment in
                        MomentCell(moment: moment)
                    }
                    .refreshable {
                        await viewModel.loadDataAsync()
                    }
                }

                if viewModel.isLoading {
                    ProgressView("加载中...")
                        .progressViewStyle(CircularProgressViewStyle())
                .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.8))
                .shadow(radius: 5)
                                .frame(width: 120, height: 120)
                        )
                }
            }
            .navigationTitle("朋友圈")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refresh()
                    }) {
                        Image(systemName: "arrow.clockwise") }
                }
            }
        }
        .alert(
            "错误",
            isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            ),
            actions: {
                Button("重试") {
                    viewModel.refresh()
                }
                Button("取消", role: .cancel) {}
            },
            message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        )
    }
}

// 单条朋友圈动态的视图
struct MomentCell: View {
    let moment: Moment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 用户信息
            HStack {
                AsyncImage(url: URL(string: moment.userAvatar)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else if phase.error != nil {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                    } else {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                }
                Text(moment.userName)
                Text(moment.userName)
                    .font(.headline)
            }
            
            // 动态内容
            if !moment.content.isEmpty {
                Text(moment.content)
                    .font(.body)
            }
            
            // 图片
            if !moment.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(moment.images, id: \.self) { imageUrl in
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipped()
.cornerRadius(5)
                                } else if phase.error != nil {
                                    Image(systemName: "photo")
                                        .frame(width: 100, height: 100)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(5)
                                } else {
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                }
                            }
.padding(2)
                        }
                    }
                }
            }

            // 点赞和评论
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(moment.likes)")
                Spacer()
                Image(systemName: "message.fill")
                    .foregroundColor(.blue)
                Text("\(moment.comments.count)")
            }

            // 评论
            ForEach(moment.comments, id: \.self) { comment in
                Text(comment)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 10)
    }
}

// 预览
struct MomentListView_Previews: PreviewProvider {
    static var previews: some View {
        MomentListView()
    }
}
