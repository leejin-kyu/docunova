"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  FileText,
  MessageSquare,
  Upload,
  BarChart3,
  Zap,
  Shield,
  ArrowRight,
} from "lucide-react";
import Link from "next/link";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-background to-secondary/20">
      {/* 헤더 */}
      <header className="border-b">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
              <FileText className="w-6 h-6 text-white" />
            </div>
            <span className="text-xl font-bold">DocuNova</span>
          </div>
          <Link href="/dashboard">
            <Button>
              대시보드 <ArrowRight className="w-4 h-4 ml-2" />
            </Button>
          </Link>
        </div>
      </header>

      {/* 히어로 섹션 */}
      <section className="container mx-auto px-4 py-20 text-center">
        <div className="max-w-3xl mx-auto space-y-6">
          <h1 className="text-5xl font-bold tracking-tight">
            기업 문서를 <span className="text-primary">AI로 분석</span>하세요
          </h1>
          <p className="text-xl text-muted-foreground">
            100% 로컬 환경에서 안전하게 문서를 학습하고
            <br />
            정확한 답변을 얻는 Private RAG 시스템
          </p>
          <div className="flex gap-4 justify-center pt-4">
            <Link href="/dashboard">
              <Button size="lg" className="text-base">
                지금 시작하기 <ArrowRight className="w-5 h-5 ml-2" />
              </Button>
            </Link>
            <Link href="/chat">
              <Button size="lg" variant="outline" className="text-base">
                <MessageSquare className="w-5 h-5 mr-2" />
                채팅 시작
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* 특징 섹션 */}
      <section className="container mx-auto px-4 py-16">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card>
            <CardHeader>
              <Shield className="w-12 h-12 text-primary mb-4" />
              <CardTitle>100% 보안</CardTitle>
              <CardDescription>
                모든 데이터가 로컬 환경에서만 처리되어 외부 유출 걱정 없음
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <Zap className="w-12 h-12 text-primary mb-4" />
              <CardTitle>빠른 검색</CardTitle>
              <CardDescription>
                벡터 기반 의미론적 검색으로 관련 문서를 즉시 찾아냄
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <BarChart3 className="w-12 h-12 text-primary mb-4" />
              <CardTitle>스마트 분석</CardTitle>
              <CardDescription>
                AI가 문서를 이해하고 정확한 답변과 인사이트 제공
              </CardDescription>
            </CardHeader>
          </Card>
        </div>
      </section>

      {/* 주요 기능 */}
      <section className="container mx-auto px-4 py-16">
        <h2 className="text-3xl font-bold text-center mb-12">주요 기능</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
          <Card className="p-6">
            <div className="flex items-start gap-4">
              <Upload className="w-8 h-8 text-primary flex-shrink-0" />
              <div>
                <h3 className="font-semibold text-lg mb-2">다양한 문서 지원</h3>
                <p className="text-sm text-muted-foreground">
                  PDF, DOCX, XLSX, TXT, MD, CSV 등 모든 문서 형식 자동 인식
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-start gap-4">
              <MessageSquare className="w-8 h-8 text-primary flex-shrink-0" />
              <div>
                <h3 className="font-semibold text-lg mb-2">자연스러운 대화</h3>
                <p className="text-sm text-muted-foreground">
                  ChatGPT처럼 질문하면 문서 기반 정확한 답변 실시간 생성
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-start gap-4">
              <FileText className="w-8 h-8 text-primary flex-shrink-0" />
              <div>
                <h3 className="font-semibold text-lg mb-2">출처 표시</h3>
                <p className="text-sm text-muted-foreground">
                  답변의 근거가 된 문서와 위치를 명확하게 표시
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-start gap-4">
              <BarChart3 className="w-8 h-8 text-primary flex-shrink-0" />
              <div>
                <h3 className="font-semibold text-lg mb-2">사용 통계</h3>
                <p className="text-sm text-muted-foreground">
                  문서 사용 패턴과 인사이트를 시각화된 대시보드로 확인
                </p>
              </div>
            </div>
          </Card>
        </div>
      </section>

      {/* CTA */}
      <section className="container mx-auto px-4 py-20">
        <Card className="max-w-2xl mx-auto bg-gradient-to-r from-blue-500/10 to-purple-600/10 border-primary/20">
          <CardContent className="pt-6 text-center space-y-4">
            <h2 className="text-3xl font-bold">지금 바로 시작하세요</h2>
            <p className="text-muted-foreground">
              설치 없이 바로 사용 가능한 웹 기반 플랫폼
            </p>
            <Link href="/dashboard">
              <Button size="lg" className="mt-4">
                무료로 시작하기
              </Button>
            </Link>
          </CardContent>
        </Card>
      </section>

      {/* 푸터 */}
      <footer className="border-t mt-20">
        <div className="container mx-auto px-4 py-8 text-center text-sm text-muted-foreground">
          © 2025 DocuNova. All rights reserved.
        </div>
      </footer>
    </div>
  );
}
