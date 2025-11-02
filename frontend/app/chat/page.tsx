"use client";

import { useState, useRef, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import {
  Send,
  FileText,
  MessageSquare,
  Home,
  Settings,
  Loader2,
  Upload,
  Sparkles,
} from "lucide-react";
import Link from "next/link";

interface Message {
  role: "user" | "assistant";
  content: string;
  sources?: Array<{
    filename: string;
    similarity: number;
    preview: string;
  }>;
}

export default function ChatPage() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [mode, setMode] = useState<"rag" | "llm">("rag");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const userMessage: Message = { role: "user", content: input };
    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setIsLoading(true);

    try {
      const response = await fetch("/api/query_stream", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          question: input,
          mode: mode,
          top_k: 5,
          language: "ko",
        }),
      });

      if (!response.ok) {
        throw new Error("Failed to get response");
      }

      const reader = response.body?.getReader();
      const decoder = new TextDecoder();
      let assistantMessage = "";
      let sources: any[] = [];

      if (reader) {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          const chunk = decoder.decode(value);
          const lines = chunk.split("\n").filter((line) => line.trim());

          for (const line of lines) {
            try {
              const event = JSON.parse(line);
              if (event.event === "token") {
                assistantMessage += event.text;
                setMessages((prev) => {
                  const newMessages = [...prev];
                  const lastMessage = newMessages[newMessages.length - 1];
                  if (lastMessage && lastMessage.role === "assistant") {
                    lastMessage.content = assistantMessage;
                  } else {
                    newMessages.push({
                      role: "assistant",
                      content: assistantMessage,
                      sources,
                    });
                  }
                  return newMessages;
                });
              } else if (event.event === "sources") {
                // source 경로에서 filename 추출
                sources = (event.items || []).map((item: any) => ({
                  ...item,
                  filename: item.filename || item.source?.split('\\').pop() || item.source?.split('/').pop() || 'Unknown'
                }));
              }
            } catch (e) {
              // JSON 파싱 실패 무시
            }
          }
        }
      }
    } catch (error) {
      console.error("Chat error:", error);
      setMessages((prev) => [
        ...prev,
        {
          role: "assistant",
          content: "죄송합니다. 오류가 발생했습니다. 나중에 다시 시도해주세요.",
        },
      ]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background flex">
      {/* 사이드바 */}
      <div className="fixed left-0 top-0 h-full w-64 border-r bg-card p-6">
        <div className="flex items-center gap-2 mb-8">
          <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
            <FileText className="w-6 h-6 text-white" />
          </div>
          <span className="text-xl font-bold">DocuNova</span>
        </div>

        <nav className="space-y-2">
          <Link href="/dashboard">
            <Button variant="ghost" className="w-full justify-start">
              <Home className="w-4 h-4 mr-2" />
              대시보드
            </Button>
          </Link>
          <Link href="/chat">
            <Button variant="default" className="w-full justify-start">
              <MessageSquare className="w-4 h-4 mr-2" />
              채팅
            </Button>
          </Link>
          <Link href="/documents">
            <Button variant="ghost" className="w-full justify-start">
              <FileText className="w-4 h-4 mr-2" />
              문서 관리
            </Button>
          </Link>
          <Link href="/settings">
            <Button variant="ghost" className="w-full justify-start">
              <Settings className="w-4 h-4 mr-2" />
              설정
            </Button>
          </Link>
        </nav>

        {/* 모드 전환 */}
        <div className="mt-8">
          <p className="text-sm font-medium mb-3">응답 모드</p>
          <div className="space-y-2">
            <Button
              variant={mode === "rag" ? "default" : "outline"}
              className="w-full justify-start"
              onClick={() => setMode("rag")}
            >
              <Sparkles className="w-4 h-4 mr-2" />
              RAG 모드
            </Button>
            <Button
              variant={mode === "llm" ? "default" : "outline"}
              className="w-full justify-start"
              onClick={() => setMode("llm")}
            >
              <MessageSquare className="w-4 h-4 mr-2" />
              LLM 모드
            </Button>
          </div>
          <p className="text-xs text-muted-foreground mt-2">
            {mode === "rag"
              ? "문서 기반 정확한 답변"
              : "일반 대화 모드"}
          </p>
        </div>
      </div>

      {/* 채팅 영역 */}
      <div className="ml-64 flex-1 flex flex-col">
        {/* 헤더 */}
        <div className="border-b px-8 py-4">
          <h1 className="text-2xl font-bold">AI 어시스턴트와 대화</h1>
          <p className="text-sm text-muted-foreground mt-1">
            문서에 대해 질문하거나 자유롭게 대화하세요
          </p>
        </div>

        {/* 메시지 목록 */}
        <div className="flex-1 overflow-y-auto px-8 py-6">
          {messages.length === 0 ? (
            <div className="flex items-center justify-center h-full">
              <div className="text-center max-w-md space-y-4">
                <div className="w-16 h-16 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mx-auto">
                  <Sparkles className="w-8 h-8 text-white" />
                </div>
                <h2 className="text-2xl font-bold">무엇을 도와드릴까요?</h2>
                <p className="text-muted-foreground">
                  업로드한 문서에 대해 질문하거나 일반적인 대화를 시작해보세요
                </p>
                <div className="grid grid-cols-2 gap-3 mt-6">
                  <Card className="p-4 hover:bg-accent cursor-pointer transition-colors">
                    <p className="text-sm font-medium">문서 요약</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      주요 내용을 간단히 설명해줘
                    </p>
                  </Card>
                  <Card className="p-4 hover:bg-accent cursor-pointer transition-colors">
                    <p className="text-sm font-medium">핵심 키워드</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      중요한 용어를 추출해줘
                    </p>
                  </Card>
                  <Card className="p-4 hover:bg-accent cursor-pointer transition-colors">
                    <p className="text-sm font-medium">특정 정보 검색</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      ~에 대해 알려줘
                    </p>
                  </Card>
                  <Card className="p-4 hover:bg-accent cursor-pointer transition-colors">
                    <p className="text-sm font-medium">비교 분석</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      두 개념을 비교해줘
                    </p>
                  </Card>
                </div>
              </div>
            </div>
          ) : (
            <div className="max-w-3xl mx-auto space-y-6">
              {messages.map((message, index) => (
                <div
                  key={index}
                  className={`flex gap-4 ${
                    message.role === "user" ? "justify-end" : "justify-start"
                  }`}
                >
                  {message.role === "assistant" && (
                    <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center flex-shrink-0">
                      <Sparkles className="w-4 h-4 text-white" />
                    </div>
                  )}
                  <div
                    className={`max-w-[80%] ${
                      message.role === "user"
                        ? "bg-primary text-primary-foreground"
                        : "bg-muted"
                    } rounded-2xl px-4 py-3`}
                  >
                    <p className="whitespace-pre-wrap">{message.content}</p>
                    {message.sources && message.sources.length > 0 && (
                      <div className="mt-3 pt-3 border-t border-border/30">
                        <p className="text-xs font-medium mb-2">
                          📚 참고 문서
                        </p>
                        <div className="space-y-1">
                          {message.sources.map((source, i) => (
                            <div
                              key={i}
                              className="text-xs bg-background/50 rounded px-2 py-1"
                            >
                              <span className="font-medium">
                                {source.filename || 'Unknown'}
                              </span>
                              <span className="text-muted-foreground ml-2">
                                ({Math.round((source.similarity || 0) * 100)}% 유사)
                              </span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                  {message.role === "user" && (
                    <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center flex-shrink-0">
                      <span className="text-sm font-bold text-primary-foreground">
                        U
                      </span>
                    </div>
                  )}
                </div>
              ))}
              <div ref={messagesEndRef} />
            </div>
          )}
        </div>

        {/* 입력 영역 */}
        <div className="border-t px-8 py-4">
          <form onSubmit={handleSubmit} className="max-w-3xl mx-auto">
            <div className="flex gap-3">
              <Input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="메시지를 입력하세요..."
                disabled={isLoading}
                className="flex-1 h-12"
              />
              <Button
                type="submit"
                disabled={isLoading || !input.trim()}
                size="lg"
              >
                {isLoading ? (
                  <Loader2 className="w-4 h-4 animate-spin" />
                ) : (
                  <Send className="w-4 h-4" />
                )}
              </Button>
            </div>
            <p className="text-xs text-muted-foreground mt-2 text-center">
              Enter로 전송 • Shift+Enter로 줄바꿈
            </p>
          </form>
        </div>
      </div>
    </div>
  );
}
