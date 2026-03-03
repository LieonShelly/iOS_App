import json
from openai import OpenAI

client = OpenAI(
    base_url='http://localhost:11434/v1',
    api_key='ollama'
)

MODEL_NAME = "llama3.2"

def get_weather(location, date):
    print(f"⚙️ [本地系统执行] 正在查询 {date} {location} 的天气...")
    if "北京" in location:
        return "北京明天晴朗，气温15度，微风。"
    return f"未知城市 {location} 的天气。"

def save_meeting(date, topic, attendees):
    print(f"⚙️ [本地系统执行] 正在保存会议: 时间={date}, 主题={topic}, 参会人={attendees}")
    return "会议保存成功！"

tools = [
    {
        "type": "function",
        "function": {
            "name" : "get_weather",
            "description": "获取指定城市的天气信息",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {"type": "string", "description": "城市名称，例如：北京"},
                    "date": {"type": "string", "description": "日期，例如：2026-03-01"},
                },
                "required": ["location", "date"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name" : "save_meeting",
            "description": "保存会议安排",
            "parameters": {
                "type": "object",
                "properties": {
                    "date": {"type": "string", "description": "会议时间，格式 YYYY-MM-DD HH:MM"},
                    "topic": {"type": "string", "description": "会议主题"},
                    "attendees": {"type": "array", "items": {"type": "string"}}
                },
                "required": ["date", "topic", "attendees"]
            }
        }
    }
]


def run_local_agent():
    messages = [
        {"role": "system", "content": "你是一个高效的智能助理。你需要调用提供的工具来帮助用户安排会议并查询天气。如果用户一次性提出多个需求，请尽可能调用多个工具。"},
        {"role": "user", "content": "帮我定一个明天下午 3 点的会议，主题是讨论 iOS 架构迁移，记得邀请张三和李四，顺便查一下明天北京的天气怎么样。今天是2026年2月28日。"}
    ]
    print("🗣️ [用户输入]:", messages[1]["content"])
    print("-" * 50)
    response = client.chat.completions.create(
        model=MODEL_NAME,
        messages=messages,
        tools=tools,
        tool_choice='auto'
    )
    response_message = response.choices[0].message
    if response_message.tool_calls:
        print(f"🤖 [Llama 3.2 思考]: 需要调用本地函数...")
        messages.append(response_message)
        for tool_call in response_message.tool_calls:
            function_name = tool_call.function.name
            try:
                function_args = json.loads(tool_call.function.arguments)
                print(f"   -> 请求调用: {function_name}, 参数: {function_args}")
            except json.JSONDecodeError:
                print(f"   ⚠️ [解析警告]: 模型输出了不合法的 JSON 参数: {tool_call.function.arguments}")
                function_args = {} #
            result = '执行失败'
            if function_name == "get_weather":
                result = get_weather(function_args.get('location', "未知"), function_args.get('date', "未知"))
            elif function_name == "save_meeting":
                result = save_meeting(function_args.get("date", "未知"), function_args.get("topic", "未知"), function_args.get("attendees", []))
            # 将结果塞回给本地模型
            messages.append(
                {
                    "tool_call_id": tool_call.id,
                    "role": "tool",
                    "name": function_name,
                    "content": result,
                }
            )
        print("-" * 50)
        print(f"🤖 [Llama 3.2 二次思考]: 拿到本地数据了，正在生成最终自然语言回复...")
        
        # 添加明确的指示，要求用自然语言总结
        messages.append({
            "role": "user",
            "content": "请用自然、友好的中文语言总结上述工具调用的结果，不要输出 JSON 或代码格式。"
        })
        second_response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=messages,
            temperature=0.3
        )
        print("✨ [最终回复]:\n", second_response.choices[0].message.content)
    else:
        print("✨ [直接回复]:\n", response_message.content)


if __name__ == "__main__":
    run_local_agent()