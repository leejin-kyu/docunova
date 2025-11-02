"use client";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  FileText,
  MessageSquare,
  Home,
  Settings as SettingsIcon,
  Moon,
  Sun,
  Zap,
} from "lucide-react";
import Link from "next/link";

export default function SettingsPage() {
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
            <Button variant="ghost" className="w-full justify-start">
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
            <Button variant="default" className="w-full justify-start">
              <SettingsIcon className="w-4 h-4 mr-2" />
              설정
            </Button>
          </Link>
        </nav>
      </div>

      {/* 메인 콘텐츠 */}
      <div className="ml-64 flex-1 p-8">
        <div className="max-w-4xl">
          <h1 className="text-3xl font-bold mb-2">설정</h1>
          <p className="text-muted-foreground mb-8">
            애플리케이션 설정을 관리하세요
          </p>

          <div className="space-y-6">
            {/* 외관 */}
            <Card>
              <CardHeader>
                <CardTitle>외관</CardTitle>
                <CardDescription>테마 및 표시 설정</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium">다크 모드</p>
                    <p className="text-sm text-muted-foreground">
                      현재 다크 모드가 활성화되어 있습니다
                    </p>
                  </div>
                  <Button variant="outline">
                    <Moon className="w-4 h-4 mr-2" />
                    활성화됨
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* AI 모델 설정 */}
            <Card>
              <CardHeader>
                <CardTitle>AI 모델</CardTitle>
                <CardDescription>답변 생성 모델 설정</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <label className="text-sm font-medium">모델</label>
                  <p className="text-sm text-muted-foreground mt-1">
                    llama3.1:8b
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium">Temperature</label>
                  <p className="text-sm text-muted-foreground mt-1">0.7</p>
                </div>
                <div>
                  <label className="text-sm font-medium">Top-K</label>
                  <p className="text-sm text-muted-foreground mt-1">5</p>
                </div>
              </CardContent>
            </Card>

            {/* 성능 */}
            <Card>
              <CardHeader>
                <CardTitle>성능</CardTitle>
                <CardDescription>시스템 성능 설정</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium">빠른 응답 모드</p>
                    <p className="text-sm text-muted-foreground">
                      정확도를 약간 희생하여 응답 속도 향상
                    </p>
                  </div>
                  <Button variant="outline">
                    <Zap className="w-4 h-4 mr-2" />
                    비활성화
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* 시스템 정보 */}
            <Card>
              <CardHeader>
                <CardTitle>시스템 정보</CardTitle>
                <CardDescription>현재 시스템 상태</CardDescription>
              </CardHeader>
              <CardContent className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">버전</span>
                  <span className="font-medium">1.0.0</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">프론트엔드</span>
                  <span className="font-medium">Next.js 16</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">백엔드</span>
                  <span className="font-medium">FastAPI</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">벡터 DB</span>
                  <span className="font-medium">Qdrant (Embedded)</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
