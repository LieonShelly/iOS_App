import os
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.documents import Document

print("⏳ 正在加载本地 Embeddings 模型...")
embeddings = HuggingFaceEmbeddings(model_name='sentence-transformers/all-MiniLM-L6-v2')
mock_documents = [
    Document(page_content="《OmniFlow Copilot 架构迁移指南》：在将 iOS 项目迁移到 Flutter 时，建议使用 Provider 或 Riverpod 进行状态管理，以替代原有的 RxSwift。"),
    Document(page_content="《公司 Q3 报销制度》：所有出差打车费用必须在回程后 3 个工作日内通过 OA 系统提交，单日上限为 150 元，超出部分需总监审批。"),
    Document(page_content="《开发部 WiFi 密码更新通知》：2026年3月份，办公室访客 WiFi 密码已更新为 OmniFlow2026!，请周知客户。")
]
text_spliter = RecursiveCharacterTextSplitter(chunk_size=100, chunk_overlap=20)
chunks = text_spliter.split_documents(mock_documents)
print("⏳ 正在将知识库向量化并存入本地数据库...")
vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db"
)
print("✅ 知识库录入成功！向量数据库已保存在 ./chroma_db 目录下。")