import { AppShell } from "@avalsys/apps-av-web";
import { useRouterState } from "@tanstack/react-router";
import type { ReactNode } from "react";
import { useMomentsNavLinks, useMomentsProductConfig, useMomentsShellLabels, useMomentsText } from "@/lib/moments-i18n";

export function MomentsAppShell({ children }: { children: ReactNode }) {
  const text = useMomentsText();
  const navLinks = useMomentsNavLinks();
  const productConfig = useMomentsProductConfig();
  const shellLabels = useMomentsShellLabels();
  const pathname = useRouterState({ select: (state) => state.location.pathname });

  return (
    <AppShell
      currentPath={pathname}
      footerLabels={text.footer}
      labels={shellLabels}
      navLinks={navLinks}
      product={productConfig}
    >
      {children}
    </AppShell>
  );
}
