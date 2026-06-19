import { AccountUserButton, useAccountAppAccess } from "@avalsys/account-av-web";
import { AppShell, useAppsAvLocale } from "@avalsys/apps-av-web";
import { createFileRoute } from "@tanstack/react-router";
import { Film, Images, Sparkles, WalletCards } from "lucide-react";
import type { ReactNode } from "react";
import { ProtectedRoute } from "@/components/protected-route";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { momentsBrandAssets } from "@/lib/moments-config";
import { useMomentsList } from "@/lib/moments-hooks";
import { localizedAppPath, useMomentsNavLinks, useMomentsProductConfig, useMomentsShellLabels, useMomentsText } from "@/lib/moments-i18n";

export const Route = createFileRoute("/avi")({
  component: AviRoute
});

function AviRoute() {
  return (
    <ProtectedRoute>
      <AviAuthed />
    </ProtectedRoute>
  );
}

function AviAuthed() {
  const text = useMomentsText();
  const ui = text.aviDashboard;
  const locale = useAppsAvLocale();
  const navLinks = useMomentsNavLinks();
  const productConfig = useMomentsProductConfig();
  const shellLabels = useMomentsShellLabels();
  const inProgress = useMomentsList("in_progress");
  const gallery = useMomentsList("gallery");
  const access = useAccountAppAccess("momentsav");
  const proStatus = access.data?.planTier === "pro" ? "active" : "free";
  const activeCount = inProgress.status === "ready" ? inProgress.data.length : null;
  const galleryCount = gallery.status === "ready" ? gallery.data.length : null;

  return (
    <AppShell accountArea={<AccountUserButton />} footerLabels={text.footer} labels={shellLabels} navLinks={navLinks} product={productConfig}>
        <section className="grid gap-5 lg:grid-cols-[1.05fr_0.95fr]">
          <Card className="moments-canvas gap-0 overflow-hidden rounded-lg border-[#e5c1c7] p-0 text-[#20242e] shadow-sm">
            <div className="grid min-h-[30rem] lg:grid-cols-[0.95fr_1.05fr]">
              <div className="flex flex-col justify-between gap-8 p-6 sm:p-8">
                <div>
                  <p className="flex items-center gap-2 text-sm font-semibold text-[#b94e70]"><Sparkles className="size-4" /> Avi</p>
                  <h1 className="mt-3 text-4xl font-semibold leading-tight">{headline(activeCount, galleryCount, ui)}</h1>
                  <p className="mt-4 text-base leading-7 text-[#4d5563]">{guidance(activeCount, galleryCount, proStatus, ui)}</p>
                </div>
                <div className="flex flex-wrap gap-3">
                  <Button asChild className="bg-[#7c2947] text-white hover:bg-[#963956]">
                    <a href={localizedAppPath("/create", locale)}><Images className="size-4" /> {ui.create}</a>
                  </Button>
                  <Button asChild variant="outline">
                    <a href={localizedAppPath(activeCount && activeCount > 0 ? "/in-progress" : "/gallery", locale)}>
                      {activeCount && activeCount > 0 ? ui.continue : ui.openGallery}
                    </a>
                  </Button>
                </div>
              </div>
              <div className="relative min-h-80 overflow-hidden bg-[#20242e]">
                <img className="h-full w-full object-cover object-bottom" src={momentsBrandAssets.aviLoginPeek} alt="" />
              </div>
            </div>
          </Card>

          <div className="grid content-start gap-4">
            <AviCard icon={<WalletCards className="size-4" />} title={ui.creditsTitle} text={proStatus === "active" ? ui.creditsActive : ui.creditsBlocked} />
            <AviCard icon={<Film className="size-4" />} title={ui.inProgressTitle} text={activeCount === null ? ui.inProgressLoading : `${activeCount} ${ui.inProgressReady}`} />
            <AviCard icon={<Images className="size-4" />} title={ui.galleryTitle} text={galleryCount === null ? ui.galleryLoading : `${galleryCount} ${ui.galleryReady}`} />
          </div>
        </section>
    </AppShell>
  );
}

function AviCard({ icon, text, title }: { icon: ReactNode; text: string; title: string }) {
  return (
    <Card className="gap-2 rounded-lg border-[#e5c1c7] bg-[#fff8f3]/88 p-5 text-[#20242e] shadow-sm">
      <div className="flex items-center gap-2 text-sm font-semibold"><span className="text-[#b94e70]">{icon}</span>{title}</div>
      <p className="text-sm leading-6 text-[#6d5960]">{text}</p>
    </Card>
  );
}

function headline(activeCount: number | null, galleryCount: number | null, ui: ReturnType<typeof useMomentsText>["aviDashboard"]) {
  if (activeCount && activeCount > 0) return ui.activeHeadline;
  if (galleryCount && galleryCount > 0) return ui.readyGalleryHeadline;
  return ui.newHeadline;
}

function guidance(activeCount: number | null, galleryCount: number | null, proStatus: string, ui: ReturnType<typeof useMomentsText>["aviDashboard"]) {
  if (activeCount && activeCount > 0) return ui.activeText;
  if (galleryCount && galleryCount > 0) return ui.readyGalleryText;
  if (proStatus !== "active") return ui.newText;
  return ui.proNewText;
}
