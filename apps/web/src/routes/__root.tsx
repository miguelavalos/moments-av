import { AccountAvProvider } from "@avalsys/account-av-web";
import { AppsAvWebProvider, getAppsAvLocaleFromSearch, useAppsAvLocale } from "@avalsys/apps-av-web";
import { HeadContent, Outlet, Scripts, createRootRoute, useRouterState } from "@tanstack/react-router";
import type { ReactNode } from "react";
import { useEffect, useRef } from "react";
import { getAccountApiBaseUrl, getAccountPublishableKey, isMomentsWebAppComingSoon } from "@/lib/moments-config";
import { localizedAppPath, useMomentsAccountLocalization, useMomentsText } from "@/lib/moments-i18n";
import "../styles.css";

const faviconUrl = "https://cdn.avalsys.com/apps-av/moments-av/favicon-32x32.png?v=20260619b";
const appleTouchIconUrl = "https://cdn.avalsys.com/apps-av/moments-av/apple-touch-icon.png?v=20260619b";

export const Route = createRootRoute({
  component: RootComponent,
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: "Moments AV" }
    ],
    links: [
      { rel: "icon", type: "image/png", sizes: "32x32", href: faviconUrl },
      { rel: "apple-touch-icon", href: appleTouchIconUrl }
    ]
  })
});

function RootComponent() {
  return (
    <RootDocument>
      <Outlet />
    </RootDocument>
  );
}

function RootDocument({ children }: Readonly<{ children: ReactNode }>) {
  const search = useRouterState({ select: (state) => state.location.searchStr });
  const initialLocale = getAppsAvLocaleFromSearch(search);

  return (
    <html lang={initialLocale}>
      <head>
        <HeadContent />
      </head>
      <body>
        <AppsAvWebProvider initialLocale={initialLocale}>
          <LocaleUrlSync />
          <ComingSoonRouteGate />
          <AccountBoundary>{children}</AccountBoundary>
        </AppsAvWebProvider>
        <Scripts />
      </body>
    </html>
  );
}

function ComingSoonRouteGate() {
  const locale = useAppsAvLocale();
  const pathname = useRouterState({ select: (state) => state.location.pathname });

  useEffect(() => {
    if (isMomentsWebAppComingSoon() && pathname !== "/") {
      window.location.replace(localizedAppPath("/", locale));
    }
  }, [locale, pathname]);

  return null;
}

function LocaleUrlSync() {
  const locale = useAppsAvLocale();
  const didSync = useRef(false);

  useEffect(() => {
    const url = new URL(window.location.href);
    let changed = false;
    if (locale === "en") {
      if (url.searchParams.has("lang")) {
        url.searchParams.delete("lang");
        changed = true;
      }
    } else {
      if (url.searchParams.get("lang") !== locale) {
        url.searchParams.set("lang", locale);
        changed = true;
      }
    }
    if (!changed) {
      didSync.current = true;
      return;
    }
    const nextUrl = `${url.pathname}${url.search}${url.hash}`;
    if (didSync.current) {
      window.history.pushState(window.history.state, "", nextUrl);
    } else {
      window.history.replaceState(window.history.state, "", nextUrl);
      didSync.current = true;
    }
  }, [locale]);

  return null;
}

function AccountBoundary({ children }: Readonly<{ children: ReactNode }>) {
  const publishableKey = getAccountPublishableKey();
  const locale = useAppsAvLocale();
  const localization = useMomentsAccountLocalization();

  if (!publishableKey) {
    return <MissingAuthConfiguration />;
  }

  return (
    <AccountAvProvider
      accountApiBaseUrl={getAccountApiBaseUrl()}
      afterSignOutUrl={localizedAppPath("/sign-in", locale)}
      appDisplayName="Moments AV"
      appId="momentsav"
      localization={localization}
      publishableKey={publishableKey}
      signInUrl={localizedAppPath("/sign-in", locale)}
      signUpUrl={localizedAppPath("/sign-in", locale)}
    >
      {children}
    </AccountAvProvider>
  );
}

function MissingAuthConfiguration() {
  const text = useMomentsText();

  return (
    <main className="mx-auto flex min-h-screen max-w-3xl flex-col justify-center px-6">
      <div className="rounded-lg border bg-card p-6 text-card-foreground shadow-sm">
        <p className="text-sm font-semibold uppercase tracking-[0.18em] text-muted-foreground">{text.config.eyebrow}</p>
        <h1 className="mt-4 text-3xl font-semibold text-foreground">{text.config.title}</h1>
        <p className="mt-3 text-sm leading-6 text-muted-foreground">{text.config.body}</p>
      </div>
    </main>
  );
}
