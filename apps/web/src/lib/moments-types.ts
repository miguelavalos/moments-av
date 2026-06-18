export type MomentCreationMode = "quick" | "guided";
export type MomentLook = "real" | "cinematic" | "clay";
export type MomentTheme = "celebration" | "birthdayMessage" | "travel" | "milestone";
export type MomentMood = "warm" | "playful" | "cinematic" | "calm" | "upbeat";
export type MomentDuration = "auto" | "short" | "medium" | "long";
export type MomentMediaUse = "aviPick" | "useAll";

export interface MomentSetupForm {
  creationMode: MomentCreationMode;
  look: MomentLook;
  theme: MomentTheme;
  mood: MomentMood;
  duration: MomentDuration;
  mediaUse: MomentMediaUse;
  title: string;
  occasion: string;
  details: string;
}

export interface WebSelectedMedia {
  id: string;
  file: File;
  kind: "photo" | "video";
  sourceLocalIdentifier: string;
  originalFilename: string;
  contentType: string;
  byteSize: number;
  sha256: string;
  sortOrder: number;
  selected: boolean;
  uploadId?: string;
}

export interface MomentMediaAsset {
  _id: string;
  platformMediaAssetId?: string | null;
  uploadId?: string | null;
  kind: string;
  r2Key?: string | null;
  thumbnailR2Key?: string | null;
  sortOrder: number;
  selected: boolean;
  moderationStatus: string;
  uploadedAt?: number | null;
  sourceExpiresAt?: number | null;
}

export interface MomentArtifact {
  _id?: string;
  workflowArtifactId?: string | null;
  kind: string;
  r2Key: string;
  status: string;
  hasWatermark?: boolean | null;
  expiresAt?: number;
  createdAt?: number;
}

export interface MomentRenderJob {
  _id: string;
  kind: string;
  status: string;
  phase?: string | null;
  progressPercent?: number | null;
  userMessage?: string | null;
  canEditMoment?: boolean | null;
  canRetry?: boolean | null;
  totalCreditCost?: number | null;
  workflowRunId?: string | null;
  errorCode?: string | null;
  errorMessage?: string | null;
  createdAt: number;
  updatedAt: number;
}

export interface InProgressMoment {
  _id: string;
  template?: string;
  creationMode: string;
  look: string;
  theme: string;
  mood?: string | null;
  duration: string;
  mediaUse: string;
  status: string;
  title: string;
  tone?: string | null;
  tempo?: string | null;
  occasion?: string | null;
  details?: string | null;
  storyInputSignature?: string | null;
  durationSeconds: number;
  creditCost: number;
  updatedAt: number;
  mediaCount?: number;
  mediaPreview?: MomentMediaAsset[];
  finalExport?: MomentArtifact | null;
}

export interface MomentStoryScene {
  sceneIndex: number;
  mediaAssetIds: string[];
  caption: string;
  narrationText: string;
  mood?: string | null;
  tone?: string | null;
  musicCue?: string | null;
  durationMs: number;
  createdBy: string;
  editable: boolean;
}

export interface MomentWorkspace {
  moment: InProgressMoment;
  mediaAssets: MomentMediaAsset[];
  storyScenes: MomentStoryScene[];
  renderJobs: MomentRenderJob[];
  artifacts: MomentArtifact[];
}

export interface MomentsCreditBalance {
  proMonthly: number;
  promotional: number;
  purchased: number;
  availableCredits?: number;
  watermarkRemovalCreditCost?: number;
  watermarkFreeIncluded?: boolean;
}

export interface MomentsCreditSpendPlan {
  proMonthly: number;
  promotional: number;
  purchased: number;
}

export interface MomentsPreparedUpload {
  uploadId: string;
  uploadUrl?: string;
  completionUrl?: string;
  method: string;
  headers: Record<string, string>;
}

export interface MomentsUploadCompletion {
  uploadId: string;
  mediaAssetId?: string;
  status?: string;
}

export interface MomentsStoryMedia {
  mediaAssetId: string;
  mediaKind: string;
  sortOrder: number;
  selected: boolean;
  moderationStatus: string;
}

export interface MomentsStoryResponse {
  appId: string;
  momentId: string;
  workflowRunId: string;
  status: string;
  provider?: string | null;
  model?: string | null;
  moderationStatus: string;
  errorCode?: string | null;
  errorMessage?: string | null;
  narrationVoice: string;
  helperCopy: string;
  scenes: MomentStoryScene[];
  generatedAt: string;
}

export interface MomentsRenderPlan {
  targetDurationMs: number;
  creditCost: number;
  totalCreditCost: number;
  secondsPerCredit: number;
  plannedAssetCount: number;
  usedAssetCount: number;
  rejectedAssetCount: number;
  rendererMode: string;
  renderOptionId?: string | null;
  renderOptionTitle?: string | null;
  userMessage: string;
  qualityWarnings: string[];
}

export interface MomentsRenderPlanResponse {
  appId: string;
  momentId: string;
  planId: string;
  plan: MomentsRenderPlan;
  watermark?: {
    includedForPro: boolean;
    userHasWatermarkFree: boolean;
    nonProRemovalCreditCost: number;
    selectedRemoveWatermark: boolean;
    watermarkCreditCost: number;
  } | null;
  canCreateVideo: boolean;
  createVideoBlockers: string[];
  generatedAt: string;
}

export interface MomentsConfirmFinalRenderResponse {
  appId: string;
  momentId: string;
  planId: string;
  reservation: { id: string; amount: number; status: string };
  workflow: { renderJobId: string; workflowRunId: string; status: string };
  renderPlan: MomentsRenderPlanResponse;
  confirmedAt: string;
}

export interface MomentsArtifactDownloadResponse {
  appId: string;
  momentId: string;
  artifactId: string;
  artifactKind: string;
  downloadUrl: string;
  method: string;
  headers: Record<string, string>;
  r2Key?: string | null;
  expiresAt: string;
  generatedAt: string;
}
