import SwiftUI

// 朋友圈动态模型
struct Moment: Identifiable {
    let id = UUID()
    let userName: String
    let userAvatar: String
    let content: String
    let images: [String]
    let likes: Int
    let comments: [String]
}

// 朋友圈主视图
struct MomentsFeedView: View {
    @State private var moments: [Moment] = [
        Moment(userName: "张三", userAvatar: "avatar1", content: "今天天气真好！", images: ["image1", "image2"], likes: 5, comments: ["李四: 确实不错！", "王五: 羡慕啊~"]),
        Moment(userName: "李四", userAvatar: "avatar2", content: "刚刚吃了一顿美味的晚餐", images: ["image3"], likes: 8, comments: ["张三: 看起来很棒！", "赵六: 下次带我去！"])
    ]
    
    var body: some View {
        NavigationView {
            List(moments) { moment in
                MomentCell(moment: moment)
            }
            .navigationTitle("朋友圈")
        }
    }
}

// 单条朋友圈动态的视图
struct MomentCell: View {
    let moment: Moment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 用户信息
            HStack {
                Image(moment.userAvatar)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                Text(moment.userName)
                    .font(.headline)
            }
            
            // 动态内容
            Text(moment.content)
                .font(.body)
            
            // 图片
            if !moment.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(moment.images, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .aspectRatio(contentMode: .fill)
                                .clipped()
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
        .padding()
    }
}

// 预览
struct MomentsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        MomentsFeedView()
    }
}