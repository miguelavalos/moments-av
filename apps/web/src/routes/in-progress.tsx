import { createFileRoute } from "@tanstack/react-router";
import { ArrowRight, Loader2, Trash2 } from "lucide-react";
import { useState } from "react";
import { MomentsAppShell } from "@/components/moments-app-shell";
import { ProtectedRoute } from "@/components/protected-route";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useMomentsApiClient, useMomentWorkspace, useMomentsList } from "@/lib/moments-hooks";
import { localizedAppPath, useMomentsText } from "@/lib/moments-i18n";
import type { InProgressMoment } from "@/lib/moments-types";
import { useAppsAvLocale } from "@avalsys/apps-av-web";

export const Route = createFileRoute("/in-progress")({
  component: InProgressRoute
});

function InProgressRoute() {
  return (
    <ProtectedRoute>
      <InProgressAuthed />
    </ProtectedRoute>
  );
}

function InProgressAuthed() {
  const text = useMomentsText();
  const ui = text.inProgressUi;
  const locale = useAppsAvLocale();
  const moments = useMomentsList("in_progress");
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const selected = selectedId ?? (moments.status === "ready" ? moments.data[0]?._id ?? null : null);
  const workspace = useMomentWorkspace(selected);

  return (
    <MomentsAppShell>
        <section className="grid gap-5 xl:grid-cols-[22rem_minmax(0,1fr)]">
          <Card className="moments-canvas gap-4 rounded-lg border-[#e5c1c7] p-5 text-[#20242e] shadow-sm">
            <div>
              <h1 className="text-3xl font-semibold">{ui.title}</h1>
              <p className="mt-2 text-sm leading-6 text-[#4d5563]">{ui.body}</p>
            </div>
            {moments.status === "missing-config" ? <p className="text-sm text-[#6d5960]">{ui.missingConfig}</p> : null}
            {moments.status === "loading" ? <p className="flex items-center gap-2 text-sm text-[#6d5960]"><Loader2 className="size-4 animate-spin" /> {ui.loadingMoments}</p> : null}
            {moments.status === "error" ? <p className="text-sm text-red-700">{moments.error.message}</p> : null}
            {moments.status === "ready" && moments.data.length === 0 ? <p className="text-sm text-[#6d5960]">{ui.noActive}</p> : null}
            <div className="grid gap-2">
              {moments.status === "ready" ? moments.data.map((moment) => (
                <button
                  key={moment._id}
                  className={`rounded-lg border p-3 text-left text-sm ${selected === moment._id ? "border-[#7c2947] bg-white" : "border-[#e5c1c7] bg-white/60"}`}
                  type="button"
                  onClick={() => setSelectedId(moment._id)}
                >
                  <span className="block truncate font-semibold">{moment.title}</span>
                  <span className="mt-1 block text-xs uppercase text-[#b94e70]">{moment.status}</span>
                </button>
              )) : null}
            </div>
            <Button asChild variant="outline">
              <a href={localizedAppPath("/create", locale)}>{ui.continueInCreate} <ArrowRight className="size-4" /></a>
            </Button>
          </Card>

          <WorkspacePanel moment={moments.status === "ready" ? moments.data.find((item) => item._id === selected) : undefined} status={workspace} />
        </section>
    </MomentsAppShell>
  );
}

function WorkspacePanel({ moment, status }: { moment?: InProgressMoment; status: ReturnType<typeof useMomentWorkspace> }) {
  const text = useMomentsText();
  const ui = text.inProgressUi;
  const client = useMomentsApiClient();
  const [title, setTitle] = useState(moment?.title ?? "");
  const [message, setMessage] = useState("");
  const workspace = status.data;

  async function rename() {
    if (!moment || !title.trim()) return;
    await client.updateMomentTitle(moment._id, title.trim());
    setMessage(ui.renameSent);
  }

  async function remove() {
    if (!moment) return;
    await client.deleteMoment(moment._id);
    setMessage(ui.deleteSent);
  }

  if (!moment) {
    return <Card className="rounded-lg border-[#e5c1c7] bg-[#fff8f3]/88 p-5 text-[#20242e]">{ui.selectMoment}</Card>;
  }

  return (
    <Card className="gap-5 rounded-lg border-[#e5c1c7] bg-[#fff8f3]/88 p-5 text-[#20242e] shadow-sm">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="text-2xl font-semibold">{moment.title}</h2>
          <p className="mt-1 text-sm uppercase text-[#b94e70]">{moment.status}</p>
        </div>
        <div className="flex gap-2">
          <Input className="w-56" value={title} onChange={(event) => setTitle(event.target.value)} />
          <Button variant="outline" onClick={() => void rename()}>{ui.rename}</Button>
          <Button variant="outline" onClick={() => void remove()}><Trash2 className="size-4" /> {ui.delete}</Button>
        </div>
      </div>
      {message ? <p className="text-sm text-[#6d5960]">{message}</p> : null}
      {status.status === "loading" ? <p className="flex items-center gap-2 text-sm text-[#6d5960]"><Loader2 className="size-4 animate-spin" /> {ui.loadingWorkspace}</p> : null}
      {status.status === "error" ? <p className="text-sm text-red-700">{status.error.message}</p> : null}
      {workspace ? (
        <div className="grid gap-4 lg:grid-cols-2">
          <Section title={ui.media} rows={workspace.mediaAssets.map((item) => `${item.sortOrder + 1}. ${item.kind} · ${item.moderationStatus}`)} noRecords={ui.noRecords} />
          <Section title={ui.storyScenes} rows={workspace.storyScenes.map((item) => `${item.sceneIndex + 1}. ${item.caption}`)} noRecords={ui.noRecords} />
          <Section title={ui.renderJobs} rows={workspace.renderJobs.map((item) => `${item.kind} · ${item.status}${item.phase ? ` · ${item.phase}` : ""}`)} noRecords={ui.noRecords} />
          <Section title={ui.artifacts} rows={workspace.artifacts.map((item) => `${item.kind} · ${item.status}`)} noRecords={ui.noRecords} />
        </div>
      ) : null}
    </Card>
  );
}

function Section({ noRecords, rows, title }: { noRecords: string; rows: string[]; title: string }) {
  return (
    <div className="rounded-lg border border-[#e5c1c7] bg-white/70 p-4">
      <h3 className="font-semibold">{title}</h3>
      {rows.length === 0 ? <p className="mt-2 text-sm text-[#6d5960]">{noRecords}</p> : null}
      <ul className="mt-2 grid gap-2 text-sm text-[#4d5563]">
        {rows.map((row) => <li key={row} className="truncate">{row}</li>)}
      </ul>
    </div>
  );
}
