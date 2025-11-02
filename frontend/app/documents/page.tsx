"use client";

import { useState, useEffect, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import {
  FileText,
  MessageSquare,
  Home,
  Settings,
  Upload,
  Trash2,
  Search,
  File,
  FileSpreadsheet,
  FileCode,
  Loader2,
  X,
  Check,
  AlertCircle,
  Eye,
  Download,
  RefreshCw,
} from "lucide-react";
import Link from "next/link";

interface Document {
  source: string;
  filename: string;
  points: number;
  selected?: boolean;
}

interface UploadProgress {
  filename: string;
  progress: number;
  status: "uploading" | "processing" | "success" | "error";
  error?: string;
}

export default function DocumentsPage() {
  const [documents, setDocuments] = useState<Document[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [uploadError, setUploadError] = useState<string | null>(null);
  const [uploadSuccess, setUploadSuccess] = useState<string | null>(null);
  const [selectedDocuments, setSelectedDocuments] = useState<string[]>([]);
  const [uploadProgress, setUploadProgress] = useState<UploadProgress[]>([]);
  const [isDragging, setIsDragging] = useState(false);
  const [previewDocument, setPreviewDocument] = useState<Document | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const loadDocuments = async () => {
    setIsLoading(true);
    try {
      const response = await fetch("/api/vectors");
      if (response.ok) {
        const data = await response.json();
        const documentsWithFilename = (data.sources || []).map((doc: any) => ({
          ...doc,
          filename: doc.source.split('\\').pop() || doc.source.split('/').pop() || doc.source
        }));
        setDocuments(documentsWithFilename);
      }
    } catch (error) {
      console.error("Failed to load documents:", error);
      setUploadError("문서 목록을 불러오는데 실패했습니다");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadDocuments();
  }, []);

  const handleFileUpload = async (files: FileList | null) => {
    if (!files || files.length === 0) return;

    setIsUploading(true);
    setUploadError(null);
    setUploadSuccess(null);

    // 진행률 초기화
    const initialProgress: UploadProgress[] = Array.from(files).map(file => ({
      filename: file.name,
      progress: 0,
      status: "uploading" as const,
    }));
    setUploadProgress(initialProgress);

    const formData = new FormData();
    for (let i = 0; i < files.length; i++) {
      formData.append("files", files[i]);
    }

    try {
      // 업로드 진행률 시뮬레이션 (실제로는 XMLHttpRequest 사용)
      const progressInterval = setInterval(() => {
        setUploadProgress(prev => prev.map(p => {
          if (p.status === "uploading" && p.progress < 90) {
            return { ...p, progress: Math.min(p.progress + 10, 90) };
          }
          return p;
        }));
      }, 200);

      const response = await fetch("/api/upload", {
        method: "POST",
        body: formData,
      });

      clearInterval(progressInterval);

      const data = await response.json();

      if (response.ok) {
        // 업로드 성공
        setUploadProgress(prev => prev.map(p => ({
          ...p,
          progress: 100,
          status: "success" as const,
        })));

        setUploadSuccess(`✅ ${data.files}개 파일 업로드 완료 (${data.chunks}개 청크 생성)`);
        await loadDocuments();

        if (fileInputRef.current) {
          fileInputRef.current.value = "";
        }

        // 3초 후 진행률 및 메시지 제거
        setTimeout(() => {
          setUploadProgress([]);
          setUploadSuccess(null);
        }, 3000);
      } else {
        // 업로드 실패
        setUploadProgress(prev => prev.map(p => ({
          ...p,
          status: "error" as const,
          error: data.detail || "업로드 실패",
        })));
        setUploadError(data.detail || "업로드 실패");
      }
    } catch (error) {
      console.error("Upload failed:", error);
      setUploadProgress(prev => prev.map(p => ({
        ...p,
        status: "error" as const,
        error: error instanceof Error ? error.message : "알 수 없는 오류",
      })));
      setUploadError(`업로드 중 오류 발생: ${error instanceof Error ? error.message : '알 수 없는 오류'}`);
    } finally {
      setIsUploading(false);
    }
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    const files = e.dataTransfer.files;
    handleFileUpload(files);
  };

  const handleDelete = async (source: string) => {
    if (!confirm("이 문서를 삭제하시겠습니까?")) return;

    try {
      const response = await fetch(`/api/vectors?source=${encodeURIComponent(source)}`, {
        method: "DELETE",
      });

      if (response.ok) {
        setUploadSuccess("✅ 문서 삭제 완료");
        await loadDocuments();
        setTimeout(() => setUploadSuccess(null), 2000);
      } else {
        const data = await response.json();
        setUploadError(data.detail || "삭제 실패");
      }
    } catch (error) {
      console.error("Delete failed:", error);
      setUploadError("삭제 중 오류 발생");
    }
  };

  const toggleSelectDocument = (source: string) => {
    setSelectedDocuments(prev => {
      if (prev.includes(source)) {
        return prev.filter(s => s !== source);
      } else {
        return [...prev, source];
      }
    });
  };

  const toggleSelectAll = () => {
    if (selectedDocuments.length === filteredDocuments.length && filteredDocuments.length > 0) {
      setSelectedDocuments([]);
    } else {
      setSelectedDocuments(filteredDocuments.map(doc => doc.source));
    }
  };

  const handleDeleteSelected = async () => {
    if (selectedDocuments.length === 0) return;
    if (!confirm(`선택한 ${selectedDocuments.length}개 문서를 삭제하시겠습니까?`)) return;

    let successCount = 0;
    let failCount = 0;

    for (const source of selectedDocuments) {
      try {
        const response = await fetch(`/api/vectors?source=${encodeURIComponent(source)}`, {
          method: "DELETE",
        });
        if (response.ok) {
          successCount++;
        } else {
          failCount++;
        }
      } catch (error) {
        console.error("Delete failed:", error);
        failCount++;
      }
    }

    setSelectedDocuments([]);

    if (failCount === 0) {
      setUploadSuccess(`✅ ${successCount}개 문서 삭제 완료`);
    } else {
      setUploadError(`⚠️ ${successCount}개 삭제 완료, ${failCount}개 실패`);
    }

    await loadDocuments();
    setTimeout(() => {
      setUploadSuccess(null);
      setUploadError(null);
    }, 3000);
  };

  const getFileIcon = (filename: string) => {
    const ext = filename.split(".").pop()?.toLowerCase();
    switch (ext) {
      case "pdf":
        return <File className="w-5 h-5 text-red-500" />;
      case "docx":
      case "doc":
        return <FileText className="w-5 h-5 text-blue-500" />;
      case "xlsx":
      case "xls":
      case "csv":
        return <FileSpreadsheet className="w-5 h-5 text-green-500" />;
      case "md":
      case "txt":
        return <FileCode className="w-5 h-5 text-gray-500" />;
      default:
        return <FileText className="w-5 h-5" />;
    }
  };

  const filteredDocuments = documents.filter((doc) =>
    doc.filename?.toLowerCase().includes(searchQuery.toLowerCase())
  );

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
            <Button variant="default" className="w-full justify-start">
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

        {/* 퀵 스탯 */}
        <div className="mt-8 p-4 rounded-lg bg-primary/10 border border-primary/20">
          <p className="text-xs text-muted-foreground mb-2">문서 통계</p>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span>총 문서</span>
              <span className="font-bold">{documents.length}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span>총 청크</span>
              <span className="font-bold">{documents.reduce((sum, doc) => sum + doc.points, 0)}</span>
            </div>
            {selectedDocuments.length > 0 && (
              <div className="flex justify-between text-sm text-primary">
                <span>선택됨</span>
                <span className="font-bold">{selectedDocuments.length}</span>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* 메인 콘텐츠 */}
      <div className="ml-64 flex-1 p-8">
        {/* 헤더 */}
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-3xl font-bold mb-2">문서 관리</h1>
            <p className="text-muted-foreground">
              AI가 학습할 문서를 관리하세요
            </p>
          </div>
          <div className="flex gap-3">
            {selectedDocuments.length > 0 && (
              <Button
                variant="destructive"
                onClick={handleDeleteSelected}
              >
                <Trash2 className="w-4 h-4 mr-2" />
                선택 삭제 ({selectedDocuments.length})
              </Button>
            )}
            <Button
              onClick={loadDocuments}
              variant="outline"
              disabled={isLoading}
            >
              {isLoading ? (
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
              ) : (
                <RefreshCw className="w-4 h-4 mr-2" />
              )}
              새로고침
            </Button>
            <Button
              onClick={() => fileInputRef.current?.click()}
              disabled={isUploading}
            >
              <Upload className="w-4 h-4 mr-2" />
              문서 업로드
            </Button>
            <input
              ref={fileInputRef}
              type="file"
              multiple
              accept=".pdf,.docx,.xlsx,.txt,.md,.csv"
              onChange={(e) => handleFileUpload(e.target.files)}
              className="hidden"
            />
          </div>
        </div>

        {/* 알림 메시지 */}
        {uploadSuccess && (
          <div className="mb-4 p-4 bg-green-500/10 border border-green-500/20 rounded-lg flex items-center justify-between">
            <div className="flex items-center gap-2 text-green-600">
              <Check className="w-5 h-5" />
              <p className="text-sm font-medium">{uploadSuccess}</p>
            </div>
            <button
              onClick={() => setUploadSuccess(null)}
              className="text-green-600 hover:text-green-700"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        )}

        {uploadError && (
          <div className="mb-4 p-4 bg-red-500/10 border border-red-500/20 rounded-lg flex items-center justify-between">
            <div className="flex items-center gap-2 text-red-600">
              <AlertCircle className="w-5 h-5" />
              <p className="text-sm font-medium">{uploadError}</p>
            </div>
            <button
              onClick={() => setUploadError(null)}
              className="text-red-600 hover:text-red-700"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        )}

        {/* 업로드 진행률 */}
        {uploadProgress.length > 0 && (
          <Card className="mb-6">
            <CardContent className="p-4">
              <h3 className="text-sm font-medium mb-3">업로드 진행 중...</h3>
              <div className="space-y-3">
                {uploadProgress.map((progress, index) => (
                  <div key={index} className="space-y-1">
                    <div className="flex items-center justify-between text-sm">
                      <span className="truncate flex-1">{progress.filename}</span>
                      <span className="text-muted-foreground ml-2">
                        {progress.status === "success" && <Check className="w-4 h-4 text-green-500" />}
                        {progress.status === "error" && <AlertCircle className="w-4 h-4 text-red-500" />}
                        {progress.status === "uploading" && `${progress.progress}%`}
                      </span>
                    </div>
                    <div className="w-full bg-secondary rounded-full h-2">
                      <div
                        className={`h-2 rounded-full transition-all duration-300 ${
                          progress.status === "success"
                            ? "bg-green-500"
                            : progress.status === "error"
                            ? "bg-red-500"
                            : "bg-blue-500"
                        }`}
                        style={{ width: `${progress.progress}%` }}
                      />
                    </div>
                    {progress.error && (
                      <p className="text-xs text-red-500">{progress.error}</p>
                    )}
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        )}

        {/* 드래그 앤 드롭 영역 */}
        <div
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          className={`mb-6 border-2 border-dashed rounded-lg p-8 text-center transition-colors ${
            isDragging
              ? "border-primary bg-primary/5"
              : "border-border hover:border-primary/50"
          }`}
        >
          <Upload className={`w-12 h-12 mx-auto mb-4 ${isDragging ? "text-primary" : "text-muted-foreground"}`} />
          <h3 className="text-lg font-medium mb-2">
            {isDragging ? "파일을 여기에 놓으세요" : "파일을 드래그하여 업로드"}
          </h3>
          <p className="text-sm text-muted-foreground mb-4">
            또는{" "}
            <button
              onClick={() => fileInputRef.current?.click()}
              className="text-primary underline hover:text-primary/80"
            >
              클릭하여 선택
            </button>
          </p>
          <p className="text-xs text-muted-foreground">
            지원: PDF, DOCX, XLSX, TXT, MD, CSV (최대 10MB)
          </p>
        </div>

        {/* 검색 */}
        <div className="mb-6">
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="문서 검색..."
              className="pl-10"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery("")}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
              >
                <X className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>

        {/* 문서 목록 */}
        <Card>
          <CardContent className="p-6">
            {isLoading ? (
              <div className="flex flex-col items-center justify-center py-12">
                <Loader2 className="w-8 h-8 animate-spin text-primary mb-4" />
                <p className="text-sm text-muted-foreground">문서 목록 불러오는 중...</p>
              </div>
            ) : filteredDocuments.length === 0 ? (
              <div className="text-center py-12">
                <FileText className="w-16 h-16 text-muted-foreground mx-auto mb-4 opacity-50" />
                <h3 className="text-lg font-medium mb-2">
                  {searchQuery ? "검색 결과가 없습니다" : "문서가 없습니다"}
                </h3>
                <p className="text-sm text-muted-foreground mb-4">
                  {searchQuery
                    ? "다른 검색어를 시도해보세요"
                    : "문서를 업로드하여 AI 학습을 시작하세요"}
                </p>
                {!searchQuery && (
                  <Button onClick={() => fileInputRef.current?.click()}>
                    <Upload className="w-4 h-4 mr-2" />
                    첫 문서 업로드
                  </Button>
                )}
              </div>
            ) : (
              <>
                {/* 선택 헤더 */}
                <div className="flex items-center justify-between pb-4 border-b mb-4">
                  <div className="flex items-center gap-3">
                    <div className="flex items-center">
                      <input
                        type="checkbox"
                        id="select-all"
                        checked={selectedDocuments.length === filteredDocuments.length && filteredDocuments.length > 0}
                        onChange={toggleSelectAll}
                        className="w-4 h-4 rounded border-gray-300 text-primary focus:ring-2 focus:ring-primary cursor-pointer"
                      />
                    </div>
                    <label htmlFor="select-all" className="text-sm font-medium cursor-pointer">
                      {selectedDocuments.length > 0
                        ? `${selectedDocuments.length}개 선택됨`
                        : `전체 ${filteredDocuments.length}개`}
                    </label>
                  </div>
                  {selectedDocuments.length > 0 && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setSelectedDocuments([])}
                    >
                      선택 해제
                    </Button>
                  )}
                </div>

                {/* 문서 목록 */}
                <div className="space-y-2">
                  {filteredDocuments.map((doc) => (
                    <div
                      key={doc.source}
                      className={`flex items-center justify-between p-4 rounded-lg transition-all ${
                        selectedDocuments.includes(doc.source)
                          ? "bg-primary/10 border-2 border-primary/30 shadow-sm"
                          : "hover:bg-accent border-2 border-transparent"
                      }`}
                    >
                      <div className="flex items-center gap-4 flex-1 min-w-0">
                        <div className="flex items-center">
                          <input
                            type="checkbox"
                            id={`doc-${doc.source}`}
                            checked={selectedDocuments.includes(doc.source)}
                            onChange={() => toggleSelectDocument(doc.source)}
                            className="w-4 h-4 rounded border-gray-300 text-primary focus:ring-2 focus:ring-primary cursor-pointer"
                            onClick={(e) => e.stopPropagation()}
                          />
                        </div>
                        {getFileIcon(doc.filename)}
                        <div className="flex-1 min-w-0">
                          <p className="font-medium truncate">{doc.filename}</p>
                          <p className="text-sm text-muted-foreground">
                            {doc.points}개 청크 • 벡터화 완료
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            setPreviewDocument(doc);
                          }}
                        >
                          <Eye className="w-4 h-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            handleDelete(doc.source);
                          }}
                          className="hover:text-destructive"
                        >
                          <Trash2 className="w-4 h-4" />
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      {/* 문서 미리보기 모달 */}
      {previewDocument && (
        <div
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
          onClick={() => setPreviewDocument(null)}
        >
          <Card className="max-w-2xl w-full max-h-[80vh] overflow-hidden" onClick={(e) => e.stopPropagation()}>
            <div className="p-6 border-b flex items-center justify-between">
              <div>
                <h2 className="text-xl font-bold">{previewDocument.filename}</h2>
                <p className="text-sm text-muted-foreground mt-1">
                  {previewDocument.points}개 청크로 분할됨
                </p>
              </div>
              <button
                onClick={() => setPreviewDocument(null)}
                className="text-muted-foreground hover:text-foreground"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            <div className="p-6 overflow-y-auto max-h-[60vh]">
              <div className="space-y-4">
                <div>
                  <label className="text-sm font-medium">경로</label>
                  <p className="text-sm text-muted-foreground break-all">{previewDocument.source}</p>
                </div>
                <div>
                  <label className="text-sm font-medium">청크 정보</label>
                  <p className="text-sm text-muted-foreground">
                    총 {previewDocument.points}개의 벡터로 변환되어 검색 가능합니다
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium">상태</label>
                  <div className="flex items-center gap-2 mt-1">
                    <div className="w-2 h-2 rounded-full bg-green-500"></div>
                    <span className="text-sm text-green-600">벡터화 완료</span>
                  </div>
                </div>
              </div>
            </div>
            <div className="p-4 border-t flex justify-end gap-2">
              <Button variant="outline" onClick={() => setPreviewDocument(null)}>
                닫기
              </Button>
              <Button
                variant="destructive"
                onClick={() => {
                  handleDelete(previewDocument.source);
                  setPreviewDocument(null);
                }}
              >
                <Trash2 className="w-4 h-4 mr-2" />
                삭제
              </Button>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}
