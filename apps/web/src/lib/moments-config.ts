import type { AppsAvProductConfig } from "@avalsys/apps-av-web";

const momentsCommercialWordmarkUrl = "https://cdn.avalsys.com/apps-av/moments-av/web-v2/moments-av-wordmark.webp";

export const momentsProductConfig: AppsAvProductConfig = {
  appId: "momentsav",
  accentColor: "#B94E70",
  assistant: {
    href: "/avi",
    imageSrc: "/assets/avi-footer-icon.png",
    label: "Open Avi guidance",
    name: "Avi"
  },
  iconSrc: "/assets/moments-av-icon.webp",
  logoSrc: momentsCommercialWordmarkUrl,
  logoDarkSrc: momentsCommercialWordmarkUrl,
  name: "Moments AV",
  links: {
    deleteAccount: externalLink(accountManagementUrl("/account/delete"), "Delete account"),
    privacy: externalLink(import.meta.env.VITE_MOMENTSAV_PRIVACY_URL, "Privacy"),
    suite: externalLink(import.meta.env.VITE_ACCOUNTAV_MANAGEMENT_URL, "Apps"),
    support: externalLink(supportUrl(), "Support"),
    terms: externalLink(import.meta.env.VITE_MOMENTSAV_TERMS_URL, "Terms")
  }
};

export const momentsBrandAssets = {
  aviFullBody: "/assets/avi-full-body.png",
  aviLoginPeek: "/assets/moments-splash-hero.webp",
  aviLoginSheetPeek: "/assets/avi-login-sheet-peek.png",
  aviOnboardingCta: "/assets/avi-onboarding-cta.png",
  guestHomeMemory: "/assets/moments-av-guest-home-1.webp",
  guestHomePath: "/assets/moments-av-guest-home-2.webp",
  guestHomeAlbum: "/assets/moments-av-guest-home-3.webp",
  hero: "/assets/moments-splash-hero.webp",
  logo: "/assets/moments-av-logo.webp",
  onboarding: "/assets/moments-onboarding-hero.webp",
  wordmark: "/assets/moments-av-wordmark.webp"
} as const;

export function getMomentsApiBaseUrl() {
  return requiredUrl(import.meta.env.VITE_MOMENTSAV_API_BASE_URL, "VITE_MOMENTSAV_API_BASE_URL");
}

export function getAccountApiBaseUrl() {
  return requiredUrl(import.meta.env.VITE_ACCOUNTAV_API_BASE_URL, "VITE_ACCOUNTAV_API_BASE_URL");
}

export function getAccountPublishableKey() {
  return import.meta.env.VITE_ACCOUNTAV_PUBLISHABLE_KEY as string | undefined;
}

export function isMomentsWebAppComingSoon() {
  return import.meta.env.VITE_MOMENTSAV_WEBAPP_COMING_SOON === "true";
}

export function getMomentsConvexUrl() {
  return trimTrailingSlash(import.meta.env.VITE_MOMENTSAV_CONVEX_URL);
}

function requiredUrl(value: string | undefined, key: string) {
  const normalized = trimTrailingSlash(value);
  if (!normalized) {
    throw new Error(`${key} is required.`);
  }
  return normalized;
}

function accountManagementUrl(path: string) {
  const baseUrl = trimTrailingSlash(import.meta.env.VITE_ACCOUNTAV_MANAGEMENT_URL);
  return baseUrl ? `${baseUrl}${path}` : undefined;
}

function supportUrl() {
  return trimTrailingSlash(import.meta.env.VITE_SUPPORTAV_BASE_URL) || commercialSiteUrl("/support");
}

function commercialSiteUrl(path: string) {
  const privacyUrl = trimTrailingSlash(import.meta.env.VITE_MOMENTSAV_PRIVACY_URL);
  const url = privacyUrl ? new URL(privacyUrl) : new URL("https://moments-av.avalsys.com");
  return `${url.origin}${path}`;
}

function externalLink(href: string | undefined, label: string) {
  const normalized = normalizeHref(href);
  return normalized ? { href: normalized, label, external: true } : undefined;
}

function normalizeHref(value: string | undefined) {
  if (!value) {
    return "";
  }

  return value.startsWith("mailto:") ? value.trim() : trimTrailingSlash(value);
}

function trimTrailingSlash(value: string | undefined) {
  return value?.trim().replace(/\/+$/, "") ?? "";
}
