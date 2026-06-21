import { ArrowRight, Film, Images, ListChecks, Sparkles } from "lucide-react";
import type { ReactNode } from "react";
import { AvAppFooter, useAppsAvLocale } from "@avalsys/apps-av-web";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { momentsBrandAssets } from "@/lib/moments-config";
import { localizedAppPath, useMomentsProductConfig, useMomentsText } from "@/lib/moments-i18n";

export function MomentsLoginPage({ comingSoon = false, compact = false }: { comingSoon?: boolean; compact?: boolean }) {
  const text = useMomentsText();
  const locale = useAppsAvLocale();
  const productConfig = useMomentsProductConfig();
  const signInHref = localizedAppPath("/sign-in", locale);

  if (compact) {
    return (
      <div className="overflow-hidden rounded-lg border border-[#e5c1c7] bg-[#fff8f3]/90 shadow-lg shadow-[#7b233f]/10">
        <LoginContent comingSoon={comingSoon} locale={locale} signInHref={signInHref} text={text} />
      </div>
    );
  }

  return (
    <div className="moments-canvas min-h-screen overflow-hidden px-5 pt-5 sm:px-8">
      <LoginContent comingSoon={comingSoon} locale={locale} signInHref={signInHref} text={text} />
      <AvAppFooter className="mt-4 border-transparent bg-transparent px-0 pb-4 pt-2" labels={text.footer} product={productConfig} />
    </div>
  );
}

function LoginContent({ comingSoon, locale, signInHref, text }: { comingSoon: boolean; locale: ReturnType<typeof useAppsAvLocale>; signInHref: string; text: ReturnType<typeof useMomentsText> }) {
  const guestScenes = [
    {
      body: text.login.mapBody,
      src: momentsBrandAssets.guestHomePath,
      title: text.login.mapTitle
    },
    {
      body: text.login.cardBody,
      src: momentsBrandAssets.guestHomeAlbum,
      title: text.login.cardTitle
    }
  ];

  return (
    <main className="moments-guest-stage mx-auto min-h-[32rem] max-w-6xl overflow-hidden rounded-[1.75rem] border border-[#e5c1c7] shadow-2xl shadow-[#7b233f]/14">
      <img className="moments-guest-backdrop" src={momentsBrandAssets.guestHomeMemory} alt="" />
      <div className="moments-guest-shade" />
      <section className="moments-guest-copy">
        <div>
          <img className="h-auto w-56 max-w-full sm:w-64" src={momentsBrandAssets.logo} alt="Moments AV" />
          <p className="mt-4 max-w-sm text-sm leading-6 text-[#314568]">
            {text.login.intro}
          </p>
        </div>

        <div className="max-w-xl">
          <h1 className="moments-guest-title text-5xl font-semibold leading-[1.02] text-[#112a55] sm:text-6xl">
            {text.login.heroTitle}
          </h1>
          <p className="moments-guest-body mt-6 max-w-lg text-base leading-7 text-[#334766]">
            {text.login.heroBody}
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            {comingSoon ? (
              <Button disabled className="h-12 rounded-full bg-[#7c2947] px-5 text-white shadow-lg shadow-[#7c2947]/18 disabled:opacity-100">
                {comingSoonLabel(locale)}
              </Button>
            ) : (
              <Button asChild className="h-12 rounded-full bg-[#7c2947] px-5 text-white shadow-lg shadow-[#7c2947]/18 hover:bg-[#963956]">
                <a href={signInHref} onClick={(event) => {
                  event.preventDefault();
                  window.location.assign(signInHref);
                }}>
                  {text.login.cta}
                  <ArrowRight className="size-4" aria-hidden="true" />
                </a>
              </Button>
            )}
          </div>
        </div>

        <div className="grid gap-3 text-sm text-[#334766] sm:grid-cols-3 lg:grid-cols-1 xl:grid-cols-3">
          <LoginMetric icon={<Images className="size-4" aria-hidden="true" />} label={text.login.search} />
          <LoginMetric icon={<Sparkles className="size-4" aria-hidden="true" />} label={text.login.aviGuidance} />
          <LoginMetric icon={<Film className="size-4" aria-hidden="true" />} label={text.login.notebook} />
        </div>
      </section>

      <section className="moments-guest-gallery" aria-hidden="true">
        {guestScenes.map((scene, index) => (
          <article className={`moments-guest-scene moments-guest-scene-${index + 1}`} key={scene.src}>
            <img src={scene.src} alt="" />
            <div>
              <p className="font-serif text-2xl leading-tight text-[#20242e]">{scene.title}</p>
              <p className="mt-2 text-sm leading-6 text-[#4d5563]">{scene.body}</p>
            </div>
          </article>
        ))}
        <Card className="moments-guest-note relative gap-2 rounded-2xl border-[#e5c1c7] bg-[#fff8f3]/92 p-5 py-5 text-[#20242e] shadow-xl shadow-[#7c2947]/12">
          <p className="flex items-center gap-2 text-sm font-semibold">
            <ListChecks className="size-4 text-[#b94e70]" aria-hidden="true" />
            {text.login.cardTitle}
          </p>
          <p className="mt-2 text-sm leading-6 text-[#47566f]">
            {text.login.cardBody}
          </p>
        </Card>
      </section>
    </main>
  );
}

function comingSoonLabel(locale: ReturnType<typeof useAppsAvLocale>) {
  return ({ ca: "Properament", de: "Demnächst", en: "Coming soon", es: "Próximamente", fr: "Prochainement" } as const)[locale] ?? "Coming soon";
}

function LoginMetric({ icon, label }: { icon: ReactNode; label: string }) {
  return (
    <div className="flex min-h-12 items-center gap-2 rounded-xl border border-[#e5c1c7] bg-[#fff8f3]/72 px-3 shadow-sm shadow-[#7b233f]/5">
      <span className="text-[#b94e70]">{icon}</span>
      <span className="font-medium text-[#4d5563]">{label}</span>
    </div>
  );
}
