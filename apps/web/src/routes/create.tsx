import { AccountUserButton } from "@avalsys/account-av-web";
import { AppShell } from "@avalsys/apps-av-web";
import { createFileRoute } from "@tanstack/react-router";
import { ArrowDown, ArrowUp, Film, Images, Loader2, UploadCloud } from "lucide-react";
import { useMemo, useState } from "react";
import { ProtectedRoute } from "@/components/protected-route";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { fileSha256, MomentsApiError } from "@/lib/moments-api";
import { useMomentsApiClient } from "@/lib/moments-hooks";
import { useMomentsNavLinks, useMomentsProductConfig, useMomentsShellLabels, useMomentsText } from "@/lib/moments-i18n";
import type { MomentSetupForm, MomentsRenderPlanResponse, MomentsStoryResponse, WebSelectedMedia } from "@/lib/moments-types";

export const Route = createFileRoute("/create")({
  component: CreateRoute
});

const defaultForm: MomentSetupForm = {
  creationMode: "quick",
  look: "real",
  theme: "celebration",
  mood: "warm",
  duration: "auto",
  mediaUse: "aviPick",
  title: "",
  occasion: "Birthday",
  details: ""
};

function CreateRoute() {
  return (
    <ProtectedRoute>
      <CreateAuthed />
    </ProtectedRoute>
  );
}

function CreateAuthed() {
  const text = useMomentsText();
  const ui = text.createUi;
  const navLinks = useMomentsNavLinks();
  const productConfig = useMomentsProductConfig();
  const shellLabels = useMomentsShellLabels();
  const client = useMomentsApiClient();
  const [form, setForm] = useState(defaultForm);
  const [media, setMedia] = useState<WebSelectedMedia[]>([]);
  const [momentId, setMomentId] = useState<string | null>(null);
  const [story, setStory] = useState<MomentsStoryResponse | null>(null);
  const [renderPlan, setRenderPlan] = useState<MomentsRenderPlanResponse | null>(null);
  const [confirmedPlanId, setConfirmedPlanId] = useState<string | null>(null);
  const [message, setMessage] = useState(ui.selectMediaToStart);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canStart = media.length > 0 && form.occasion.trim().length > 0 && !busy;
  const selectedIdentifiers = useMemo(() => media.filter((item) => item.selected).map((item) => item.sourceLocalIdentifier), [media]);

  async function addFiles(files: FileList | null) {
    if (!files) return;
    setBusy(true);
    setError(null);
    try {
      const prepared = await Promise.all(
        Array.from(files).map(async (file, index) => {
          const kind = file.type.startsWith("video/") ? "video" : "photo";
          const order = media.length + index;
          return {
            id: `${Date.now()}-${order}-${file.name}`,
            file,
            kind,
            sourceLocalIdentifier: `web:${file.name}:${file.size}:${file.lastModified}`,
            originalFilename: file.name,
            contentType: file.type || "application/octet-stream",
            byteSize: file.size,
            sha256: await fileSha256(file),
            sortOrder: order,
            selected: true
          } satisfies WebSelectedMedia;
        })
      );
      setMedia((current) => [...current, ...prepared]);
      setMessage(`${prepared.length} ${prepared.length === 1 ? ui.item : ui.items} ready for upload.`);
    } catch (caught) {
      setError(errorMessage(caught));
    } finally {
      setBusy(false);
    }
  }

  async function runCreateFlow() {
    setBusy(true);
    setError(null);
    setStory(null);
    setRenderPlan(null);
    try {
      setMessage(ui.creatingWorkspace);
      const newMomentId = momentId ?? await client.createMoment(form);
      setMomentId(newMomentId);
      await client.updateMomentSetup(newMomentId, form);

      setMessage(ui.preparingUploads);
      const uploaded = [];
      for (const item of media) {
        const preparedUpload = await client.prepareUpload(newMomentId, item);
        const completion = await client.uploadMedia(item, preparedUpload);
        uploaded.push({ item, completion });
      }

      setMessage("Planning story...");
      const storyResponse = await client.generateStoryPlan(
        newMomentId,
        form,
        uploaded.map(({ item, completion }) => ({
          mediaAssetId: completion.mediaAssetId ?? completion.uploadId,
          mediaKind: item.kind,
          sortOrder: item.sortOrder,
          selected: item.selected,
          moderationStatus: "approved"
        }))
      );
      setStory(storyResponse);

      setMessage("Checking final render cost...");
      const plan = await client.prepareRenderPlan(newMomentId, form, selectedIdentifiers, false);
      setRenderPlan(plan);
      setMessage(plan.canCreateVideo ? ui.renderPlanReady : plan.createVideoBlockers.join(" "));
    } catch (caught) {
      setError(errorMessage(caught));
      setMessage(ui.flowStopped);
    } finally {
      setBusy(false);
    }
  }

  async function confirmFinalRender() {
    if (!momentId || !renderPlan || confirmedPlanId === renderPlan.planId) return;
    setBusy(true);
    setError(null);
    try {
      setMessage("Confirming final render...");
      await client.confirmFinalRender(momentId, form, selectedIdentifiers, renderPlan.planId, renderPlan.plan.renderOptionId, false);
      setConfirmedPlanId(renderPlan.planId);
      setMessage(ui.finalVideoCreationConfirmed);
    } catch (caught) {
      setError(errorMessage(caught));
    } finally {
      setBusy(false);
    }
  }

  function moveMedia(index: number, direction: -1 | 1) {
    setMedia((current) => {
      const next = [...current];
      const target = index + direction;
      if (!next[index] || target < 0 || target >= next.length) return current;
      const currentItem = next[index];
      const targetItem = next[target];
      if (!currentItem || !targetItem) return current;
      next[index] = targetItem;
      next[target] = currentItem;
      return next.map((item, sortOrder) => ({ ...item, sortOrder }));
    });
  }

  return (
    <AppShell accountArea={<AccountUserButton />} footerLabels={text.footer} labels={shellLabels} navLinks={navLinks} product={productConfig}>
        <section className="grid gap-5 pb-24 sm:pb-0 xl:grid-cols-[minmax(0,1fr)_23rem]">
          <Card className="moments-canvas gap-6 rounded-lg border-[#e5c1c7] p-5 text-[#20242e] shadow-sm">
            <div>
              <h1 className="text-3xl font-semibold">{text.create.title}</h1>
              <p className="mt-2 max-w-2xl text-sm leading-6 text-[#4d5563]">{text.create.body}</p>
            </div>

            <div className="grid gap-4 lg:grid-cols-2">
              <label className="rounded-lg border border-dashed border-[#d3aab2] bg-white/70 p-5">
                <span className="flex items-center gap-2 text-sm font-semibold"><UploadCloud className="size-4" /> {ui.media}</span>
                <Input className="mt-4" multiple accept="image/*,video/*" type="file" onChange={(event) => void addFiles(event.target.files)} />
              </label>
              <div className="rounded-lg border border-[#e5c1c7] bg-white/70 p-5">
                <p className="text-sm font-semibold">{ui.setup}</p>
                <div className="mt-4 grid gap-3 sm:grid-cols-2">
                  <Input value={form.occasion} onChange={(event) => setForm({ ...form, occasion: event.target.value, title: event.target.value })} placeholder={ui.occasion} />
                  <Input value={form.details} onChange={(event) => setForm({ ...form, details: event.target.value })} placeholder={ui.details} />
                  <Select label={ui.mood} value={form.mood} values={["warm", "playful", "cinematic", "calm", "upbeat"]} onChange={(mood) => setForm({ ...form, mood })} />
                  <Select label={ui.duration} value={form.duration} values={["auto", "short", "medium", "long"]} onChange={(duration) => setForm({ ...form, duration })} />
                  <Select label={ui.look} value={form.look} values={["real", "cinematic", "clay"]} onChange={(look) => setForm({ ...form, look })} />
                  <Select label={ui.mediaUse} value={form.mediaUse} values={["aviPick", "useAll"]} onChange={(mediaUse) => setForm({ ...form, mediaUse })} />
                </div>
              </div>
            </div>

            <div className="rounded-lg border border-[#e5c1c7] bg-white/70">
              <div className="flex items-center justify-between border-b border-[#ead1d6] px-4 py-3">
                <p className="text-sm font-semibold">{ui.selectedMedia}</p>
                <span className="text-xs text-[#6d5960]">{media.length} {media.length === 1 ? ui.item : ui.items}</span>
              </div>
              <div className="divide-y divide-[#ead1d6]">
                {media.length === 0 ? <p className="p-4 text-sm text-[#6d5960]">{ui.noBrowserMedia}</p> : media.map((item, index) => (
                  <div key={item.id} className="grid gap-3 p-4 sm:grid-cols-[1fr_auto] sm:items-center">
                    <div>
                      <p className="truncate text-sm font-medium">{index + 1}. {item.originalFilename}</p>
                      <p className="text-xs text-[#6d5960]">{item.kind} · {(item.byteSize / 1024 / 1024).toFixed(1)} MB</p>
                    </div>
                    <div className="flex gap-2">
                      <Button type="button" variant="outline" size="icon" onClick={() => moveMedia(index, -1)} disabled={index === 0 || busy} aria-label="Move up"><ArrowUp className="size-4" /></Button>
                      <Button type="button" variant="outline" size="icon" onClick={() => moveMedia(index, 1)} disabled={index === media.length - 1 || busy} aria-label="Move down"><ArrowDown className="size-4" /></Button>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <Button className="bg-[#7c2947] text-white hover:bg-[#963956]" disabled={!canStart} onClick={() => void runCreateFlow()}>
                {busy ? <Loader2 className="size-4 animate-spin" /> : <Images className="size-4" />}
                {ui.prepareStoryAndCost}
              </Button>
              <Button variant="outline" disabled={!renderPlan?.canCreateVideo || busy || confirmedPlanId === renderPlan?.planId} onClick={() => void confirmFinalRender()}>
                <Film className="size-4" />
                {ui.confirmFinalVideo}
              </Button>
              <p className="text-sm text-[#4d5563]">{message}</p>
            </div>
            {error ? <p className="rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">{error}</p> : null}
          </Card>

          <aside className="grid content-start gap-4">
            <StatusCard title={ui.story} value={story ? `${story.scenes.length} scenes · ${story.status}` : ui.notPlanned} />
            <StatusCard title={ui.renderPlan} value={renderPlan ? `${renderPlan.plan.totalCreditCost} credits · ${renderPlan.plan.rendererMode}` : ui.notChecked} />
            <StatusCard title={ui.confirm} value={confirmedPlanId ? ui.finalVideoQueued : ui.waitingForConfirmation} />
          </aside>
        </section>
    </AppShell>
  );
}

function Select<T extends string>({ label, onChange, value, values }: { label: string; onChange: (value: T) => void; value: T; values: T[] }) {
  return (
    <label className="grid gap-1 text-xs font-semibold text-[#6d5960]">
      {label}
      <select className="h-10 rounded-md border border-[#e5c1c7] bg-white px-3 text-sm text-[#20242e]" value={value} onChange={(event) => onChange(event.target.value as T)}>
        {values.map((item) => <option key={item} value={item}>{item}</option>)}
      </select>
    </label>
  );
}

function StatusCard({ title, value }: { title: string; value: string }) {
  return (
    <Card className="gap-2 rounded-lg border-[#e5c1c7] bg-[#fff8f3]/88 p-5 text-[#20242e]">
      <p className="text-sm font-semibold">{title}</p>
      <p className="text-sm leading-6 text-[#6d5960]">{value}</p>
    </Card>
  );
}

function errorMessage(caught: unknown) {
  if (caught instanceof MomentsApiError) {
    return `${caught.message} (${caught.code})`;
  }
  return caught instanceof Error ? caught.message : String(caught);
}
