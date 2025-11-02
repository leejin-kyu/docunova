"""
DocuNova Backend - Main Application Entry Point
FastAPI 기반 RAG 시스템
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging
import os
from contextlib import asynccontextmanager

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
log = logging.getLogger(__name__)

# Global services (initialized in lifespan)
embedding_service = None
vector_service = None
llm_service = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """애플리케이션 시작/종료 시 실행되는 lifespan 이벤트"""

    # Startup
    log.info("🚀 DocuNova Backend 시작 중...")

    try:
        # 서비스 초기화
        from app.services.embedding_service import EmbeddingService
        from app.services.vector_service import VectorService
        from app.services.llm_service import LLMService

        global embedding_service, vector_service, llm_service

        # Embedding 서비스 초기화
        log.info("Embedding 서비스 초기화 중...")
        embedding_service = EmbeddingService(
            model_name=os.getenv("EMBEDDING_MODEL", "BAAI/bge-small-en-v1.5"),
            cache_dir="./embedding_models"
        )
        await embedding_service.initialize()
        log.info("✅ Embedding 서비스 초기화 완료")

        # Vector 서비스 초기화
        log.info("Vector 서비스 초기화 중...")
        vector_service = VectorService(
            host=os.getenv("QDRANT_HOST", "localhost"),
            port=int(os.getenv("QDRANT_PORT", "6333")),
            collection_name=os.getenv("COLLECTION_NAME", "docunova_documents"),
            vector_size=384  # bge-small-en-v1.5 dimension
        )
        vector_service.initialize_collection()
        log.info("✅ Vector 서비스 초기화 완료")

        # LLM 서비스 초기화
        log.info("LLM 서비스 초기화 중...")
        llm_service = LLMService(
            host=os.getenv("OLLAMA_HOST", "localhost"),
            port=int(os.getenv("OLLAMA_PORT", "11434")),
            model=os.getenv("OLLAMA_MODEL", "llama3.1:8b")
        )
        health = await llm_service.health_check()
        if health["status"] == "healthy":
            log.info("✅ LLM 서비스 초기화 완료")
        else:
            log.warning(f"⚠️ LLM 서비스 상태 불안정: {health}")

        log.info("✅ 모든 서비스 초기화 완료")

    except Exception as e:
        log.error(f"❌ 서비스 초기화 실패: {e}", exc_info=True)
        raise

    yield  # 애플리케이션 실행

    # Shutdown
    log.info("🛑 DocuNova Backend 종료 중...")

# FastAPI 앱 생성
app = FastAPI(
    title="DocuNova API",
    description="AI-Powered Document Analysis & Q&A System",
    version="1.0.0",
    lifespan=lifespan
)

# CORS 설정
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")

if ENVIRONMENT == "production":
    allowed_origins = os.getenv("CORS_ORIGINS", "").split(",")
else:
    allowed_origins = ["http://localhost:3000", "http://127.0.0.1:3000"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Content-Type", "Authorization", "X-Request-ID"],
    max_age=600
)

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    log.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "message": "예상치 못한 오류가 발생했습니다.",
            "detail": str(exc) if ENVIRONMENT == "development" else None
        }
    )

# Health check endpoint
@app.get("/health")
async def health_check():
    """시스템 전체 헬스 체크"""

    health_status = {
        "status": "healthy",
        "services": {}
    }

    # Embedding service
    if embedding_service:
        emb_health = embedding_service.health_check()
        health_status["services"]["embedding"] = emb_health
        if emb_health["status"] != "healthy":
            health_status["status"] = "degraded"

    # Vector service
    if vector_service:
        vec_health = vector_service.health_check()
        health_status["services"]["vector"] = vec_health
        if vec_health["status"] != "healthy":
            health_status["status"] = "degraded"

    # LLM service
    if llm_service:
        llm_health = await llm_service.health_check()
        health_status["services"]["llm"] = llm_health
        if llm_health["status"] != "healthy":
            health_status["status"] = "degraded"

    return health_status

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "DocuNova API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
        "health": "/health"
    }

# API 라우터 등록
from app.api.v1 import chat, documents, collections

app.include_router(chat.router, prefix="/api/v1", tags=["chat"])
app.include_router(documents.router, prefix="/api/v1", tags=["documents"])
app.include_router(collections.router, prefix="/api/v1", tags=["collections"])

if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", "8000"))

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=ENVIRONMENT == "development",
        log_level="info"
    )
