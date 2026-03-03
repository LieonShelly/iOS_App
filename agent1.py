import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import TypedDict, Annotated
import uvicorn

# LangChain & LangGraph 核心库
from langgraph.graph import StateGraph, END
from langgraph.graph.message import add_messages
from langgraph.checkpoint.memory import MemorySaver
from langchain_ollama import ChatOllama
from langchain_core.messages import ToolMessage, HumanMessage, SystemMessage

# 定义数据模型
class ChatRequest(BaseModel):
    session_id: str
    message: str

class ChatResponse(BaseModel):
    reply: str

# 定义Agent的工具与大模型
def get_weather(location: str, date: str) -> str:
    """获取指定城市的天气信息"""
    print(f"⚙️ [工具执行] 查询 {date} {location} 的天气...")
    if "北京" in location:
        return "北京明天晴朗，气温15度，微风。"
    return f"未知城市 {location} 的天气。"

tools = [get_weather]

# 初始化本地 Llama 3.2模型
llm = ChatOllama(model='llama3.2', base_url="http://localhost:11434", temperature=0.3)
llm_with_tools = llm.bind_tools(tools)

# 构建 LangGraph 状态机
class AgentState(TypedDict):
    messages: Annotated[list, add_messages]

def chatbot_node(state: AgentState):
    # 大模型思考节点
    response = llm_with_tools.invoke(state['messages'])
    return {"messages": [response]}

def tool_node(state: AgentState):
    # 工具执行节点
    last_message = state["messages"][-1]
    tool_responses = []
    for tool_call in last_message.tool_calls:
        if tool_call["name"] == 'get_weather':
            args = tool_call['args']
            result = get_weather(args.get("location", "未知"), args.get("date", "未知"))
            tool_responses.append(ToolMessage(content=result, tool_call_id=tool_call["id"]))
    return {"messages": tool_responses}


def should_continue(state: AgentState):
    # 条件路由：判断是否调用工具
    last_message = state['messages'][-1]
    if last_message.tool_calls:
        return "tools"
    return END

# 编译图并注入 MemorySaver（这就是Agent的记忆模块）
workflow = StateGraph(AgentState)
workflow.add_node('chatbot', chatbot_node)
workflow.add_node('tools', tool_node)
workflow.set_entry_point('chatbot')
workflow.add_conditional_edges('chatbot', should_continue)
workflow.add_edge('tools', 'chatbot')

memory = MemorySaver()
agent_app = workflow.compile(checkpointer=memory)

api_app = FastAPI(title="OmniFlow Copilot API")

@api_app.post('/chat', response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    print(f"\n [收到请求] Session: {request.session_id} | Message: {request.message}")
    config = {"configurable": {"thread_id": request.session_id}}
    currrent_state = agent_app.get_state(config=config)
    if not currrent_state.values.get('messages'):
        system_msg = SystemMessage(content="你是一个高效的个人助理。请用简短的中文回复，必要时调用工具。")
        agent_app.update_state(config, {"messages": [system_msg]})
    try:
        events = agent_app.stream(
            {"messages": [HumanMessage(content=request.message)]},
            config=config,
            stream_mode="values"
        )
        final_message = None
        for event in events:
            final_message = event["messages"][-1]
        return ChatResponse(reply=final_message.content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(api_app, host='0.0.0.0', port=8000)