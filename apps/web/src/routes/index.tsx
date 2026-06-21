import { SignedIn, SignedOut } from "@avalsys/account-av-web";
import { useAppsAvLocale } from "@avalsys/apps-av-web";
import { createFileRoute } from "@tanstack/react-router";
import { ArrowRight, Film, Images, SlidersHorizontal, Sparkles } from "lucide-react";
import type { ReactNode } from "react";
import { MomentsAppShell } from "@/components/moments-app-shell";
import { MomentsLoginPage } from "@/components/moments-login-page";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { isMomentsWebAppComingSoon, momentsBrandAssets } from "@/lib/moments-config";
import { localizedAppPath, useMomentsText } from "@/lib/moments-i18n";

export const Route = createFileRoute("/")({
  component: IndexRoute
});

function IndexRoute() {
  if (isMomentsWebAppComingSoon()) {
    return <MomentsLoginPage comingSoon />;
  }

  const text = useMomentsText();
  const locale = useAppsAvLocale();
  const homeIcons = [<Images className="size-4" />, <SlidersHorizontal className="size-4" />, <Film className="size-4" />];

  return (
    <>
      <SignedOut>
        <MomentsLoginPage />
      </SignedOut>
      <SignedIn>
        <MomentsAppShell>
          <main className="mx-auto flex w-full max-w-6xl flex-col gap-8">
            <section className="moments-public-hero">
              <img className="moments-public-hero-image" src={momentsBrandAssets.guestHomeMemory} alt="" />
              <div className="moments-public-hero-shade" />
              <div className="moments-public-hero-copy">
                <img className="h-auto w-56 max-w-full sm:w-64" src={momentsBrandAssets.logo} alt="Moments AV" />
                <h1 className="mt-8 max-w-3xl text-5xl font-semibold leading-tight text-[#20242e] sm:text-6xl">{text.home.title}</h1>
                <p className="mt-5 max-w-2xl text-base leading-7 text-[#4d5563]">{text.home.body}</p>
                <div className="mt-7 flex flex-wrap gap-3">
                  <Button asChild className="h-11 rounded-full bg-[#7c2947] px-5 text-white shadow-lg shadow-[#7c2947]/18 hover:bg-[#963956]">
                    <a href={localizedAppPath("/create", locale)}>
                      {text.home.cta}
                      <ArrowRight className="size-4" aria-hidden="true" />
                    </a>
                  </Button>
                  <Button asChild variant="outline" className="h-11 rounded-full border-[#d8bbc0] bg-white/72 px-5 text-[#20242e] backdrop-blur hover:bg-white">
                    <a href={localizedAppPath("/avi", locale)}>{text.nav.avi}</a>
                  </Button>
                </div>
                <div className="mt-8 grid gap-3 sm:grid-cols-3">
                  {text.home.items.map((item, index) => (
                    <NotebookItem key={item.label} icon={homeIcons[index]} label={item.label} value={item.value} />
                  ))}
                </div>
              </div>
            </section>

            <section className="grid gap-5 lg:grid-cols-[0.88fr_1.12fr]">
              <Card className="moments-public-copy-card gap-0 rounded-[1.25rem] border-[#e5c1c7] p-6 py-6 shadow-lg shadow-[#7b233f]/8">
                <h2 className="max-w-lg text-3xl font-semibold leading-tight text-[#20242e] sm:text-4xl">{text.login.heroTitle}</h2>
                <p className="mt-4 max-w-xl text-base leading-7 text-[#4d5563]">{text.login.heroBody}</p>
                <div className="mt-6 grid gap-3 sm:grid-cols-3 lg:grid-cols-1">
                  <NotebookItem icon={<Images className="size-4" />} label={text.login.search} value={text.home.items[0]?.value ?? text.login.cardBody} />
                  <NotebookItem icon={<Sparkles className="size-4" />} label={text.login.aviGuidance} value={text.home.items[1]?.value ?? text.login.cardBody} />
                  <NotebookItem icon={<Film className="size-4" />} label={text.login.notebook} value={text.home.items[2]?.value ?? text.login.cardBody} />
                </div>
              </Card>
              <div className="moments-public-scene">
                <img className="moments-public-scene-image" src={momentsBrandAssets.guestHomePath} alt="" />
                <div className="moments-public-scene-card">
                  <p className="font-serif text-3xl leading-tight text-[#20242e]">{text.login.mapTitle}</p>
                  <p className="mt-3 text-sm leading-6 text-[#4d5563]">{text.login.mapBody}</p>
                </div>
              </div>
            </section>

            <section className="moments-public-review">
              <img className="moments-public-review-image" src={momentsBrandAssets.guestHomeAlbum} alt="" />
              <div className="moments-public-review-card">
                <p className="flex items-center gap-2 text-sm font-semibold text-[#20242e]">
                  <Sparkles className="size-4 text-[#b94e70]" aria-hidden="true" />
                  {text.home.aviTitle}
                </p>
                <ul className="mt-3 grid gap-2 text-sm leading-6 text-[#4d5563] sm:grid-cols-3">
                  {text.home.aviBody.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </div>
            </section>
          </main>
        </MomentsAppShell>
      </SignedIn>
    </>
  );
}

function NotebookItem({ icon, label, value }: { icon: ReactNode; label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-[#e5c1c7] bg-[#fff8f3]/76 p-4 text-[#20242e]">
      <div className="flex items-center gap-2 text-sm font-semibold">
        <span className="text-[#b94e70]">{icon}</span>
        {label}
      </div>
      <p className="mt-2 text-sm text-[#6d5960]">{value}</p>
    </div>
  );
}
