"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  FileText,
  MessageSquare,
  Upload,
  BarChart3,
  Clock,
  TrendingUp,
  Search,
  Plus,
  Home,
  Settings,
} from "lucide-react";
import Link from "next/link";

export default function DashboardPage() {
  const [stats, setStats] = useState({
    totalDocuments: 0,
    totalQueries: 0,
    avgResponseTime: 0,
  });

  useEffect(() => {
    // 백엔드에서 통계 데이터 가져오기
    fetch("/api/vectors")
      .then((res) => res.json())
      .then((data) => {
        setStats({
          totalDocuments: data.sources?.length || 0,
          totalQueries: 0,
          avgResponseTime: 1.2,
        });
      })
      .catch((error) => {
        console.log("Stats loading failed:", error);
      });
  }, []);

  return (
    <div className="min-h-screen bg-background">
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
            <Button variant="ghost" className="w-full justify-start">
              <Settings className="w-4 h-4 mr-2" />
              설정
            </Button>
          </Link>
        </nav>

        <div className="absolute bottom-6 left-6 right-6">
          <Card className="bg-gradient-to-br from-blue-500/10 to-purple-600/10 border-primary/20">
            <CardContent className="p-4">
              <p className="text-sm font-medium mb-2">🎉 새로운 기능</p>
              <p className="text-xs text-muted-foreground mb-3">
                Cmd+K로 빠른 검색을 사용해보세요
              </p>
              <Button size="sm" className="w-full">
                자세히 보기
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* 메인 콘텐츠 */}
      <div className="ml-64 p-8">
        {/* 헤더 */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold mb-2">대시보드</h1>
            <p className="text-muted-foreground">
              DocuNova에 오신 것을 환영합니다
            </p>
          </div>
          <div className="flex gap-3">
            <Button variant="outline">
              <Search className="w-4 h-4 mr-2" />
              검색
            </Button>
            <Link href="/documents">
              <Button>
                <Upload className="w-4 h-4 mr-2" />
                문서 업로드
              </Button>
            </Link>
          </div>
        </div>

        {/* 통계 카드 */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">총 문서 수</CardTitle>
              <FileText className="w-4 h-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.totalDocuments}</div>
              <p className="text-xs text-muted-foreground mt-1">
                <span className="text-green-500">+12%</span> 지난 주 대비
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">총 질문 수</CardTitle>
              <MessageSquare className="w-4 h-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.totalQueries}</div>
              <p className="text-xs text-muted-foreground mt-1">
                <span className="text-green-500">+8%</span> 지난 주 대비
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">평균 응답 시간</CardTitle>
              <Clock className="w-4 h-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.avgResponseTime}s</div>
              <p className="text-xs text-muted-foreground mt-1">
                <span className="text-green-500">-5%</span> 지난 주 대비
              </p>
            </CardContent>
          </Card>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* 최근 활동 */}
          <Card>
            <CardHeader>
              <CardTitle>최근 활동</CardTitle>
              <CardDescription>최근 질문과 문서 활동</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="flex items-start gap-4 pb-4 border-b last:border-0">
                    <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
                      <MessageSquare className="w-5 h-5 text-primary" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">
                        문서 내용에 대한 질문
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {i}분 전
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* 자주 사용하는 문서 */}
          <Card>
            <CardHeader>
              <CardTitle>자주 사용하는 문서</CardTitle>
              <CardDescription>가장 많이 조회된 문서</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {[
                  { name: "제품 매뉴얼.pdf", count: 45 },
                  { name: "기술 문서.docx", count: 38 },
                  { name: "사용자 가이드.pdf", count: 32 },
                  { name: "FAQ 문서.md", count: 28 },
                ].map((doc) => (
                  <div key={doc.name} className="flex items-center justify-between pb-4 border-b last:border-0">
                    <div className="flex items-center gap-3">
                      <FileText className="w-4 h-4 text-muted-foreground" />
                      <span className="text-sm font-medium">{doc.name}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs text-muted-foreground">{doc.count}회</span>
                      <TrendingUp className="w-3 h-3 text-green-500" />
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* 빠른 시작 */}
        <Card className="mt-6">
          <CardHeader>
            <CardTitle>빠른 시작</CardTitle>
            <CardDescription>자주 사용하는 작업</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <Link href="/chat">
                <Button variant="outline" className="w-full h-24 flex flex-col gap-2">
                  <MessageSquare className="w-6 h-6" />
                  <span>새 질문</span>
                </Button>
              </Link>
              <Link href="/documents">
                <Button variant="outline" className="w-full h-24 flex flex-col gap-2">
                  <Upload className="w-6 h-6" />
                  <span>문서 업로드</span>
                </Button>
              </Link>
              <Link href="/documents">
                <Button variant="outline" className="w-full h-24 flex flex-col gap-2">
                  <Search className="w-6 h-6" />
                  <span>문서 검색</span>
                </Button>
              </Link>
              <Link href="/settings">
                <Button variant="outline" className="w-full h-24 flex flex-col gap-2">
                  <Settings className="w-6 h-6" />
                  <span>설정</span>
                </Button>
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
