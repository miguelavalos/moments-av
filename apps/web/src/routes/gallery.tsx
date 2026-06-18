import { AccountUserButton } from "@avalsys/account-av-web";
import { AppShell } from "@avalsys/apps-av-web";
import { createFileRoute } from "@tanstack/react-router";
import { Download, Film, Loader2, RotateCw } from "lucide-react";
import { useState } from "react";
import { ProtectedRoute } from "@/components/protected-route";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { useMomentsApiClient, useMomentsList } from "@/lib/moments-hooks";
import { useMomentsNavLinks, useMomentsProductConfig, useMomentsShellLabels, useMomentsText } from "@/lib/moments-i18n";
import type { InProgressMoment, MomentArtifact } from "@/lib/moments-types";

export const Route = createFileRoute("/gallery")({
  component: GalleryRoute
});

function GalleryRoute() {
  return (
    <ProtectedRoute>
      <GalleryAuthed />
    </ProtectedRoute>
  );
}

function GalleryAuthed() {
  const text = useMomentsText();
  const navLinks = useMomentsNavLinks();
  const productConfig = useMomentsProductConfig();
  const shellLabels = useMomentsShellLabels();
  const gallery = useMomentsList("gallery");

  return (
    <AppShell accountArea={<AccountUserButton />} footerLabels={text.footer} labels={shellLabels} navLinks={navLinks} product={productConfig}>
        <section className="grid gap-5">
          <Card className="moments-canvas gap-3 rounded-lg border-[#e5c1c7] p-5 text-[#20242e] shadow-sm">
            <p className="text-sm font-semibold uppercase text-[#b94e70]">{text.gallery.kicker}</p>
            <h1 className="text-3xl font-semibold">{text.gallery.title}</h1>
            <p className="max-w-2xl text-sm leading-6 text-[#4d5563]">{text.gallery.body}</p>
          </Card>

          {gallery.status === "missing-config" ? <StateCard title="Convex cloud URL missing" body="Run the preview Varlock wrapper so VITE_MOMENTSAV_CONVEX_URL points at the cloud dev/preview deployment." /> : null}
          {gallery.status === "loading" ? <StateCard title="Loading gallery" body="Opening a backend-issued realtime session and subscribing to Gallery Moments." loading /> : null}
          {gallery.status === "error" ? <StateCard title="Gallery unavailable" body={gallery.error.message} /> : null}

          {gallery.status === "ready" && gallery.data.length === 0 ? (
            <Card className="rounded-lg border-dashed border-[#d3aab2] bg-[#fff8f3]/70 p-6 text-center">
              <Film className="mx-auto size-8 text-[#b94e70]" />
              <h2 className="mt-4 text-xl font-semibold">{text.gallery.emptyTitle}</h2>
              <p className="mx-auto mt-2 max-w-md text-sm leading-6 text-[#6d5960]">{text.gallery.emptyBody}</p>
            </Card>
          ) : null}

          {gallery.status === "ready" && gallery.data.length > 0 ? (
            <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
              {gallery.data.map((moment) => <GalleryMomentCard key={moment._id} moment={moment} />)}
            </div>
          ) : null}
        </section>
    </AppShell>
  );
}

function GalleryMomentCard({ moment }: { moment: InProgressMoment }) {
  const client = useMomentsApiClient();
  const artifact = moment.finalExport;
  const [busy, setBusy] = useState(false);
  const [status, setStatus] = useState(localAvailabilityCopy(artifact));

  async function download() {
    if (!artifact) return;
    const artifactId = artifact._id ?? artifact.workflowArtifactId;
    if (!artifactId) return;
    setBusy(true);
    try {
      const prepared = await client.prepareArtifactDownload(moment._id, artifactId);
      const response = await fetch(prepared.downloadUrl, { method: prepared.method, headers: prepared.headers });
      if (!response.ok) {
        throw new Error("The prepared download did not complete.");
      }
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = url;
      anchor.download = `${moment.title || "moment"}.mp4`;
      anchor.click();
      URL.revokeObjectURL(url);
      setStatus("Downloaded in this browser session. Finish to Gallery keeps the cloud record visible even if the local file is later missing.");
    } catch (caught) {
      setStatus(caught instanceof Error ? caught.message : String(caught));
    } finally {
      setBusy(false);
    }
  }

  return (
    <Card className="gap-4 rounded-lg border-[#e5c1c7] bg-[#fff8f3]/88 p-5 text-[#20242e] shadow-sm">
      <div>
        <h2 className="truncate text-lg font-semibold">{moment.title}</h2>
        <p className="mt-1 text-xs uppercase text-[#b94e70]">{moment.status}</p>
      </div>
      <dl className="grid grid-cols-2 gap-3 text-sm">
        <div><dt className="text-[#6d5960]">Duration</dt><dd>{Math.round(moment.durationSeconds)}s</dd></div>
        <div><dt className="text-[#6d5960]">Credits</dt><dd>{moment.creditCost}</dd></div>
        <div><dt className="text-[#6d5960]">Media</dt><dd>{moment.mediaCount ?? moment.mediaPreview?.length ?? 0}</dd></div>
        <div><dt className="text-[#6d5960]">Artifact</dt><dd>{artifact?.status ?? "missing"}</dd></div>
      </dl>
      <p className="min-h-12 text-sm leading-6 text-[#6d5960]">{status}</p>
      <Button variant="outline" disabled={!artifact || busy} onClick={() => void download()}>
        {busy ? <Loader2 className="size-4 animate-spin" /> : <Download className="size-4" />}
        Prepare download
      </Button>
    </Card>
  );
}

function StateCard({ body, loading = false, title }: { body: string; loading?: boolean; title: string }) {
  return (
    <Card className="rounded-lg border-[#e5c1c7] bg-[#fff8f3]/88 p-5 text-[#20242e]">
      <p className="flex items-center gap-2 font-semibold">{loading ? <RotateCw className="size-4 animate-spin" /> : null}{title}</p>
      <p className="mt-2 text-sm leading-6 text-[#6d5960]">{body}</p>
    </Card>
  );
}

function localAvailabilityCopy(artifact: MomentArtifact | null | undefined) {
  if (!artifact) {
    return "Gallery metadata exists, but no final artifact is currently projected for download.";
  }
  if (artifact.status !== "ready") {
    return "Final artifact metadata is present, but the backend has not marked it ready for download.";
  }
  if (artifact.expiresAt && artifact.expiresAt < Date.now()) {
    return "The cloud record is visible, but this artifact may need backend refresh before download.";
  }
  return "Remote download metadata is available. This browser has no saved local file until you download it here.";
}
