import type {
  MomentSetupForm,
  MomentsArtifactDownloadResponse,
  MomentsConfirmFinalRenderResponse,
  MomentsPreparedUpload,
  MomentsRenderPlanResponse,
  MomentsStoryMedia,
  MomentsStoryResponse,
  MomentsUploadCompletion,
  WebSelectedMedia
} from "@/lib/moments-types";

export class MomentsApiError extends Error {
  readonly code: string;
  readonly status: number;

  constructor(message: string, code = "moments_api_error", status = 0) {
    super(message);
    this.name = "MomentsApiError";
    this.code = code;
    this.status = status;
  }
}

export class MomentsApiClient {
  constructor(
    private readonly baseUrl: string,
    private readonly getToken: () => Promise<string | null>
  ) {}

  async createMoment(form: MomentSetupForm) {
    const response = await this.send<{ momentId: string }>("/workspace/moments", {
      method: "POST",
      body: JSON.stringify(setupCommand(form))
    });
    return response.momentId;
  }

  updateMomentSetup(momentId: string, form: MomentSetupForm) {
    return this.send<{ momentId: string }>(`/workspace/moments/${encodeURIComponent(momentId)}/setup`, {
      method: "PATCH",
      body: JSON.stringify(setupCommand(form))
    });
  }

  updateMomentTitle(momentId: string, title: string) {
    return this.send<{ momentId: string }>(`/workspace/moments/${encodeURIComponent(momentId)}/title`, {
      method: "PATCH",
      body: JSON.stringify({ title })
    });
  }

  deleteMoment(momentId: string) {
    return this.send<{ momentId: string }>(`/workspace/moments/${encodeURIComponent(momentId)}`, {
      method: "DELETE",
      body: JSON.stringify({
        deleteSourceMedia: true,
        deleteGeneratedArtifacts: true,
        reason: "user request"
      })
    });
  }

  async prepareUpload(momentId: string, media: WebSelectedMedia) {
    return this.send<MomentsPreparedUpload>("/media/prepare-upload", {
      method: "POST",
      body: JSON.stringify({
        appId: "momentsav",
        momentId,
        mediaKind: media.kind,
        sourceLocalIdentifier: media.sourceLocalIdentifier,
        originalFilename: media.originalFilename,
        contentType: media.contentType,
        byteSize: media.byteSize,
        sha256: media.sha256
      })
    });
  }

  async uploadMedia(media: WebSelectedMedia, preparedUpload: MomentsPreparedUpload) {
    if (!preparedUpload.uploadUrl) {
      throw new MomentsApiError("Signed upload storage is not enabled for this build.", "moments_signed_upload_unavailable");
    }

    const uploadResponse = await fetch(preparedUpload.uploadUrl, {
      method: preparedUpload.method,
      headers: {
        ...preparedUpload.headers,
        "x-appsav-moments-selected": media.selected ? "true" : "false",
        "x-appsav-moments-sort-order": String(media.sortOrder)
      },
      body: media.file
    });
    const uploadText = await uploadResponse.text();
    if (!uploadResponse.ok) {
      throw decodeApiError(uploadText, uploadResponse.status, "moments_upload_failed", "Media upload failed.");
    }

    if (preparedUpload.completionUrl) {
      const completionResponse = await fetch(preparedUpload.completionUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ sortOrder: media.sortOrder, selected: media.selected })
      });
      const completionText = await completionResponse.text();
      if (!completionResponse.ok) {
        throw decodeApiError(completionText, completionResponse.status, "moments_upload_complete_failed", "Media upload completion failed.");
      }
      return parseJson<MomentsUploadCompletion>(completionText);
    }

    return parseJson<MomentsUploadCompletion>(uploadText);
  }

  generateStoryPlan(momentId: string, form: MomentSetupForm, media: MomentsStoryMedia[]) {
    return this.send<MomentsStoryResponse>("/story/plans", {
      method: "POST",
      body: JSON.stringify({
        appId: "momentsav",
        momentId,
        creationMode: form.creationMode,
        look: form.look,
        theme: form.theme,
        mood: form.mood,
        duration: form.duration,
        mediaUse: form.mediaUse,
        occasion: form.occasion,
        details: form.details,
        narrationVoice: "avi_clear",
        media,
        safetyAcknowledged: true,
        idempotencyKey: `story:${momentId}:${storyInputSignature(momentId, form, media)}`
      })
    });
  }

  prepareRenderPlan(momentId: string, form: MomentSetupForm, selectedSourceLocalIdentifiers: string[], removeWatermark: boolean) {
    return this.send<MomentsRenderPlanResponse>("/renders/plan", {
      method: "POST",
      body: JSON.stringify(renderPlanCommand(momentId, form, selectedSourceLocalIdentifiers, removeWatermark))
    });
  }

  confirmFinalRender(momentId: string, form: MomentSetupForm, selectedSourceLocalIdentifiers: string[], planId: string, renderOptionId: string | null | undefined, removeWatermark: boolean) {
    return this.send<MomentsConfirmFinalRenderResponse>("/renders/final/confirm", {
      method: "POST",
      body: JSON.stringify({
        ...renderPlanCommand(momentId, form, selectedSourceLocalIdentifiers, removeWatermark),
        renderOptionId: renderOptionId ?? null,
        planId,
        idempotencyKey: `final-confirm:${momentId}:${planId}:${form.theme}:${removeWatermark ? "clean" : "watermarked"}`
      })
    });
  }

  prepareArtifactDownload(momentId: string, artifactId: string) {
    return this.send<MomentsArtifactDownloadResponse>(`/artifacts/${encodeURIComponent(artifactId)}/download`, {
      method: "POST",
      body: JSON.stringify({ appId: "momentsav", momentId, artifactId })
    });
  }

  createRealtimeSession() {
    return this.send<{ realtimeSessionId: string }>("/workspace/realtime-sessions", {
      method: "POST",
      body: "{}"
    });
  }

  private async send<T>(path: string, init: RequestInit) {
    const token = await this.getToken();
    if (!token) {
      throw new MomentsApiError("Sign in is required.", "moments_auth_required", 401);
    }

    const response = await fetch(`${this.baseUrl}/v1/apps/momentsav${path}`, {
      ...init,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        ...init.headers
      }
    });
    const text = await response.text();
    if (!response.ok) {
      throw decodeApiError(text, response.status, "moments_request_failed", "Moment request failed.");
    }
    return parseJson<T>(text);
  }
}

export async function fileSha256(file: File) {
  const digest = await crypto.subtle.digest("SHA-256", await file.arrayBuffer());
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

export function creditSpendPlan(cost: number, balance: { proMonthly: number; promotional: number; purchased: number; availableCredits?: number }) {
  const spendable = balance.availableCredits ?? balance.proMonthly + balance.promotional + balance.purchased;
  if (cost <= 0 || spendable < cost) {
    return null;
  }
  const proMonthly = Math.min(balance.proMonthly, cost);
  const afterPro = cost - proMonthly;
  const promotional = Math.min(balance.promotional, afterPro);
  return {
    proMonthly,
    promotional,
    purchased: afterPro - promotional
  };
}

function setupCommand(form: MomentSetupForm) {
  return {
    creationMode: form.creationMode,
    look: form.look,
    theme: form.theme,
    mood: form.mood,
    duration: form.duration,
    mediaUse: form.mediaUse,
    title: nonBlank(form.title),
    occasion: nonBlank(form.occasion),
    details: nonBlank(form.details)
  };
}

function renderPlanCommand(momentId: string, form: MomentSetupForm, selectedSourceLocalIdentifiers: string[], removeWatermark: boolean) {
  return {
    appId: "momentsav",
    momentId,
    creationMode: form.creationMode,
    look: form.look,
    theme: form.theme,
    mood: form.mood,
    duration: form.duration,
    mediaUse: form.mediaUse,
    selectedSourceLocalIdentifiers: selectedSourceLocalIdentifiers.map((value) => value.trim()).filter(Boolean),
    occasion: nonBlank(form.occasion),
    details: nonBlank(form.details),
    creditCost: null,
    removeWatermark,
    renderOptionId: null
  };
}

function nonBlank(value: string) {
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function storyInputSignature(momentId: string, form: MomentSetupForm, media: MomentsStoryMedia[]) {
  const mediaSignature = media
    .filter((item) => item.selected)
    .toSorted((left, right) => left.sortOrder - right.sortOrder || left.mediaAssetId.localeCompare(right.mediaAssetId))
    .map((item) => `${item.sortOrder}:${item.mediaAssetId}:${item.mediaKind}`)
    .join("|");
  const input = [momentId, form.creationMode, form.look, form.theme, form.mood, form.duration, form.mediaUse, form.occasion.trim(), form.details.trim(), mediaSignature].join("\u001f");
  let hash = 0x811c9dc5;
  for (let index = 0; index < input.length; index += 1) {
    hash ^= input.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193);
  }
  return Math.abs(hash).toString(16).padStart(8, "0");
}

function parseJson<T>(text: string) {
  return (text ? JSON.parse(text) : {}) as T;
}

function decodeApiError(text: string, status: number, fallbackCode: string, fallbackMessage: string) {
  try {
    const body = JSON.parse(text) as { code?: string; message?: string; error?: { code?: string; message?: string } };
    return new MomentsApiError(body.error?.message ?? body.message ?? fallbackMessage, body.error?.code ?? body.code ?? fallbackCode, status);
  } catch {
    return new MomentsApiError(fallbackMessage, fallbackCode, status);
  }
}
