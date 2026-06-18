import { useEffect, useMemo, useState } from "react";
import { Fragment, jsx, jsxs } from "react/jsx-runtime";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import { MenuIcon } from "lucide-react";
import { Toaster } from "sonner";
import { caES, deDE, enUS, esES, frFR } from "@clerk/localizations";
//#region node_modules/@avalsys/apps-av-web/src/config/product-config.ts
var appsAvLocales = [
	"en",
	"es",
	"fr",
	"de",
	"ca"
];
var appsAvLocaleNames = {
	ca: "Català",
	de: "Deutsch",
	en: "English",
	es: "Español",
	fr: "Français"
};
var appsAvLocaleCookieName = "preferred_locale";
var appsAvLocaleChangeEvent = "apps-av-locale-change";
//#endregion
//#region node_modules/@avalsys/apps-av-web/src/lib/cn.ts
function cn(...inputs) {
	return twMerge(clsx(inputs));
}
//#endregion
//#region node_modules/@avalsys/apps-av-web/src/lib/locale.ts
function useAppsAvLocale() {
	const [locale, setLocaleState] = useState("en");
	useEffect(() => {
		const handleLocaleChange = (event) => {
			const locale = event.detail;
			if (appsAvLocales.includes(locale)) setLocaleState(locale);
		};
		window.addEventListener(appsAvLocaleChangeEvent, handleLocaleChange);
		const locale = getAppsAvLocale();
		applyAppsAvLocale(locale);
		setLocaleState(locale);
		return () => window.removeEventListener(appsAvLocaleChangeEvent, handleLocaleChange);
	}, []);
	return locale;
}
function setAppsAvLocale(locale) {
	applyAppsAvLocale(locale);
	window.dispatchEvent(new CustomEvent(appsAvLocaleChangeEvent, { detail: locale }));
}
function applyAppsAvLocale(locale) {
	document.cookie = `${appsAvLocaleCookieName}=${locale}; path=/; max-age=31536000; SameSite=Lax`;
	document.documentElement.lang = locale;
}
function getAppsAvLocale() {
	if (typeof document === "undefined") return "en";
	const requestedLocale = getRequestedLocale();
	if (requestedLocale) return requestedLocale;
	const cookie = document.cookie.split("; ").find((entry) => entry.startsWith(`${appsAvLocaleCookieName}=`))?.split("=")[1];
	return appsAvLocales.includes(cookie) ? cookie : "en";
}
function getRequestedLocale() {
	if (typeof window === "undefined") return;
	const locale = new URLSearchParams(window.location.search).get("lang");
	return appsAvLocales.includes(locale) ? locale : void 0;
}
//#endregion
//#region node_modules/@avalsys/apps-av-web/src/components/av-app-footer.tsx
function AvAppFooter({ className, labels, product }) {
	const activeLocale = useAppsAvLocale();
	const links = getFooterLinks(product, labels, activeLocale);
	return /* @__PURE__ */ jsx("footer", {
		className: cn("border-t border-border/35 bg-background/82 px-4 py-3 text-xs text-muted-foreground backdrop-blur", className),
		children: /* @__PURE__ */ jsxs("div", {
			className: "mx-auto flex max-w-6xl flex-col gap-2 sm:flex-row sm:items-center sm:justify-between",
			children: [/* @__PURE__ */ jsx("div", {
				className: "flex flex-wrap items-center gap-x-3 gap-y-1",
				children: links.map((link) => /* @__PURE__ */ jsx("a", {
					className: "transition hover:text-foreground",
					href: link.href,
					rel: link.external ? "noreferrer" : void 0,
					target: link.external ? "_blank" : void 0,
					children: link.label
				}, link.href))
			}), /* @__PURE__ */ jsx("nav", {
				className: "flex flex-wrap items-center gap-x-2 gap-y-1",
				"aria-label": labels?.language ?? "Language",
				children: appsAvLocales.map((locale) => /* @__PURE__ */ jsx("button", {
					className: cn("cursor-pointer transition hover:text-foreground", locale === activeLocale ? "font-semibold text-foreground" : ""),
					type: "button",
					onClick: () => setAppsAvLocale(locale),
					children: appsAvLocaleNames[locale]
				}, locale))
			})]
		})
	});
}
function getFooterLinks(product, labels, locale) {
	return [
		withLocalizedLink(product.links.support, labels?.support, locale),
		withLocalizedLink(product.links.privacy, labels?.privacy, locale),
		withLocalizedLink(product.links.terms, labels?.terms, locale),
		withLocalizedLink(product.links.deleteAccount, labels?.deleteAccount, locale)
	].filter(Boolean);
}
function withLocalizedLink(link, label, locale) {
	if (!link) return;
	return {
		...link,
		href: localizeOwnedHref(link.href, locale),
		label: label ?? link.label
	};
}
function localizeOwnedHref(href, locale) {
	if (locale === "en") return stripLocalePrefix(href);
	try {
		const url = new URL(href);
		if (!isOwnedHost(url.hostname)) return href;
		url.pathname = localizePath(url.pathname, locale);
		return url.toString().replace(/\/$/, "");
	} catch {
		return href;
	}
}
function localizePath(pathname, locale) {
	const normalizedPath = stripLocalePrefix(pathname || "/");
	return `/${locale}${normalizedPath === "/" ? "" : normalizedPath}`;
}
function stripLocalePrefix(value) {
	return value.replace(/^\/(es|fr|de|ca)(?=\/|$)/, "") || "/";
}
function isOwnedHost(hostname) {
	return hostname === "avalsys.com" || hostname.endsWith(".avalsys.com");
}
//#endregion
//#region node_modules/@avalsys/apps-av-web/src/components/mobile-drawer-nav.tsx
function MobileDrawerNav({ label = "Mobile navigation", links, triggerLabel = "Open navigation" }) {
	return /* @__PURE__ */ jsxs("details", {
		className: "md:hidden",
		children: [/* @__PURE__ */ jsxs("summary", {
			className: "inline-flex size-10 cursor-pointer list-none items-center justify-center rounded-md border bg-background",
			children: [/* @__PURE__ */ jsx(MenuIcon, { "aria-hidden": "true" }), /* @__PURE__ */ jsx("span", {
				className: "sr-only",
				children: triggerLabel
			})]
		}), /* @__PURE__ */ jsx("nav", {
			className: "absolute left-4 right-4 top-16 z-20 rounded-lg border bg-background p-3 shadow-lg",
			"aria-label": label,
			children: /* @__PURE__ */ jsx("div", {
				className: "flex flex-col gap-1",
				children: links.map((link) => /* @__PURE__ */ jsx("a", {
					className: "rounded-md px-3 py-2 text-sm font-medium hover:bg-muted",
					href: link.href,
					children: link.label
				}, link.href))
			})
		})]
	});
}
//#endregion
//#region node_modules/@avalsys/apps-av-web/src/components/app-shell.tsx
function AppShell({ product, navLinks, accountArea, children, footerLabels, labels }) {
	return /* @__PURE__ */ jsxs("div", {
		className: "min-h-screen bg-background text-foreground",
		children: [
			/* @__PURE__ */ jsx("header", {
				className: "sticky top-0 z-10 border-b bg-background/88 backdrop-blur",
				children: /* @__PURE__ */ jsxs("div", {
					className: "mx-auto flex h-16 max-w-6xl items-center justify-between px-4",
					children: [
						/* @__PURE__ */ jsx("a", {
							className: "flex min-w-0 items-center gap-3",
							href: "/",
							"aria-label": labels?.home ?? `${product.name} home`,
							children: product.logoSrc ? /* @__PURE__ */ jsx("img", {
								alt: "",
								className: "h-9 w-auto max-w-36 object-contain",
								src: product.logoSrc
							}) : /* @__PURE__ */ jsxs(Fragment, { children: [product.iconSrc ? /* @__PURE__ */ jsx("img", {
								alt: "",
								className: "size-8 rounded-md",
								src: product.iconSrc
							}) : null, /* @__PURE__ */ jsx("span", {
								className: "text-sm font-semibold",
								children: product.name
							})] })
						}),
						/* @__PURE__ */ jsx("nav", {
							className: "hidden items-center gap-1 md:flex",
							"aria-label": labels?.primaryNavigation ?? "Primary navigation",
							children: navLinks.map((link) => /* @__PURE__ */ jsx("a", {
								className: "rounded-full px-3 py-2 text-sm font-medium text-muted-foreground hover:bg-muted hover:text-foreground",
								href: link.href,
								children: link.label
							}, link.href))
						}),
						/* @__PURE__ */ jsxs("div", {
							className: "flex items-center gap-3",
							children: [accountArea, /* @__PURE__ */ jsx(MobileDrawerNav, {
								label: labels?.mobileNavigation,
								links: navLinks,
								triggerLabel: labels?.openNavigation
							})]
						})
					]
				})
			}),
			/* @__PURE__ */ jsx("main", {
				className: "mx-auto max-w-6xl px-4 py-8",
				children
			}),
			product.assistant ? /* @__PURE__ */ jsxs("a", {
				className: "fixed bottom-5 right-4 z-20 flex items-center gap-2 rounded-full border bg-background/92 px-3 py-2 text-sm font-semibold shadow-lg shadow-black/10 backdrop-blur transition hover:-translate-y-0.5 hover:bg-background",
				href: product.assistant.href,
				"aria-label": labels?.assistant ?? product.assistant.label,
				children: [product.assistant.imageSrc ? /* @__PURE__ */ jsx("img", {
					alt: "",
					className: "size-10 rounded-full border object-cover object-[78%_68%]",
					src: product.assistant.imageSrc
				}) : null, /* @__PURE__ */ jsx("span", { children: product.assistant.name })]
			}) : null,
			/* @__PURE__ */ jsx(AvAppFooter, {
				labels: footerLabels,
				product
			})
		]
	});
}
//#endregion
//#region node_modules/@avalsys/apps-av-web/src/components/auth-skeleton.tsx
function AuthSkeleton() {
	return /* @__PURE__ */ jsx("div", {
		className: "min-h-screen bg-background px-5 py-6 text-foreground",
		children: /* @__PURE__ */ jsxs("div", {
			className: "mx-auto flex max-w-6xl flex-col gap-8",
			children: [/* @__PURE__ */ jsx("div", { className: "h-12 rounded-2xl border bg-card" }), /* @__PURE__ */ jsxs("div", {
				className: "grid gap-4 md:grid-cols-[0.8fr_1.2fr]",
				children: [/* @__PURE__ */ jsx("div", { className: "h-72 rounded-2xl border bg-card" }), /* @__PURE__ */ jsx("div", { className: "h-72 rounded-2xl border bg-card" })]
			})]
		})
	});
}
//#endregion
//#region node_modules/@avalsys/apps-av-web/src/providers/apps-av-web-provider.tsx
function AppsAvWebProvider({ children, queryClient }) {
	const [client] = useState(() => queryClient ?? new QueryClient({ defaultOptions: { queries: {
		refetchOnWindowFocus: false,
		retry: 1,
		staleTime: 3e4
	} } }));
	return /* @__PURE__ */ jsxs(QueryClientProvider, {
		client,
		children: [children, /* @__PURE__ */ jsx(Toaster, { richColors: true })]
	});
}
//#endregion
//#region src/lib/moments-config.ts
var momentsProductConfig = {
	appId: "momentsav",
	accentColor: "#B94E70",
	assistant: {
		href: "/avi",
		imageSrc: "/assets/avi-footer-icon.png",
		label: "Open Avi guidance",
		name: "Avi"
	},
	iconSrc: "/assets/moments-av-icon.png",
	logoSrc: "/assets/moments-av-logo.png",
	logoDarkSrc: "/assets/moments-av-logo.png",
	name: "Moments AV",
	links: {
		deleteAccount: externalLink(accountManagementUrl("/account/delete"), "Delete account"),
		privacy: externalLink("https://moments-av-preview.avalsys.com/privacy", "Privacy"),
		suite: externalLink("https://account-av-preview.avalsys.com", "Apps"),
		support: externalLink(supportUrl(), "Support"),
		terms: externalLink("https://moments-av-preview.avalsys.com/terms", "Terms")
	}
};
var momentsBrandAssets = {
	aviFullBody: "/assets/avi-full-body.png",
	aviLoginPeek: "/assets/moments-splash-hero.jpg",
	aviLoginSheetPeek: "/assets/avi-login-sheet-peek.png",
	aviOnboardingCta: "/assets/avi-onboarding-cta.png",
	hero: "/assets/moments-splash-hero.jpg",
	logo: "/assets/moments-av-logo.png",
	onboarding: "/assets/moments-onboarding-hero.jpg",
	wordmark: "/assets/moments-av-wordmark.png"
};
function getAccountApiBaseUrl() {
	return requiredUrl("http://127.0.0.1:8788", "VITE_ACCOUNTAV_API_BASE_URL");
}
function getAccountPublishableKey() {
	return "pk_test_bGVnaWJsZS1jcmF5ZmlzaC01OC5jbGVyay5hY2NvdW50cy5kZXYk";
}
function requiredUrl(value, key) {
	const normalized = trimTrailingSlash(value);
	if (!normalized) throw new Error(`${key} is required.`);
	return normalized;
}
function accountManagementUrl(path) {
	const baseUrl = trimTrailingSlash("https://account-av-preview.avalsys.com");
	return baseUrl ? `${baseUrl}${path}` : void 0;
}
function supportUrl() {
	return trimTrailingSlash("https://support-av-preview.avalsys.com") || commercialSiteUrl("/support");
}
function commercialSiteUrl(path) {
	const privacyUrl = trimTrailingSlash("https://moments-av-preview.avalsys.com/privacy");
	return `${(privacyUrl ? new URL(privacyUrl) : new URL("https://moments-av.avalsys.com")).origin}${path}`;
}
function externalLink(href, label) {
	const normalized = normalizeHref(href);
	return normalized ? {
		href: normalized,
		label,
		external: true
	} : void 0;
}
function normalizeHref(value) {
	if (!value) return "";
	return value.startsWith("mailto:") ? value.trim() : trimTrailingSlash(value);
}
function trimTrailingSlash(value) {
	return value?.trim().replace(/\/+$/, "") ?? "";
}
//#endregion
//#region src/lib/moments-i18n.ts
var translations = {
	en: {
		account: {
			signInTitle: "Sign in to Moments AV",
			signInSubtitle: "Welcome back. Sign in to keep your memory projects connected."
		},
		avi: {
			body: "Avi helps shape selected photos and clips into a private story: structure, tone, pacing, and the next step stay clear before export.",
			cards: [
				{
					title: "Shape the story",
					text: "Avi keeps the selected moments organized around the template and occasion."
				},
				{
					title: "Tune the mood",
					text: "Style, length, and warmth stay visible so the video feels personal before rendering."
				},
				{
					title: "Prepare export",
					text: "The final review flow keeps control with the user before the saved video leaves the app."
				}
			],
			createCta: "Create a moment",
			galleryCta: "Open gallery",
			title: "A guided way to turn moments into a memory video."
		},
		config: {
			body: "Run the web app through the Varlock wrapper so Account AV configuration is available. Web access starts with sign-in.",
			eyebrow: "Configuration required",
			title: "Moments AV Web needs Clerk configuration."
		},
		create: {
			body: "Choose selected photos and clips, pick a story format, adjust mood and length, then review the memory before final render.",
			cta: "Start with selected media",
			flow: [
				{
					title: "Choose moments",
					text: "Use only the photos and clips selected for this project."
				},
				{
					title: "Edit options",
					text: "Pick the occasion, mood, visual look, and length that fit the story."
				},
				{
					title: "Review and render",
					text: "Confirm credits, review the plan, and create the final export."
				}
			],
			title: "Create a private memory video."
		},
		footer: {
			deleteAccount: "Delete account",
			language: "Language",
			privacy: "Privacy",
			support: "Support",
			terms: "Terms"
		},
		gallery: {
			body: "Finished videos stay easy to find, download locally, and revisit from the same signed-in account.",
			emptyBody: "Create a memory video and the final export will appear here for review and download.",
			emptyTitle: "Your gallery is ready for the first memory.",
			filters: [
				"All",
				"Rendering",
				"Ready",
				"Downloaded"
			],
			hints: [
				{
					title: "Review",
					text: "Keep the story visible before you save or share the result."
				},
				{
					title: "Download",
					text: "Final videos are saved by the user when they are ready."
				},
				{
					title: "History",
					text: "Completed projects stay tied to the account for a calmer return flow."
				}
			],
			kicker: "Gallery",
			title: "Your memory videos, gathered in one place."
		},
		home: {
			aviBody: [
				"Turn a selected group of photos and clips into a clear story.",
				"Keep tone, length, and style visible before final render.",
				"Return to finished exports from the gallery."
			],
			aviTitle: "Avi shapes the story",
			body: "Create private memory videos from selected photos and clips, review them carefully, and export when they are ready.",
			cta: "Create video",
			items: [
				{
					label: "Selected media",
					value: "Start from moments you choose"
				},
				{
					label: "Story options",
					value: "Adjust template, mood, look, and length"
				},
				{
					label: "Gallery",
					value: "Review completed exports"
				}
			],
			title: "Make a memory video from the moments that matter."
		},
		login: {
			aviGuidance: "Avi guidance",
			cardBody: "Move from chosen media to story options, review, render, and final export without losing context.",
			cardTitle: "A calm creation flow",
			cta: "Sign in",
			heroBody: "Sign in to create private memory videos, keep projects connected, and let Avi help shape the story before export.",
			heroTitle: "Your memories, shaped into a video with care.",
			intro: "Bring selected photos and clips into a guided flow for birthdays, celebrations, trips, milestones, and small personal stories.",
			mapBody: "The web experience carries over the iOS onboarding idea: warm memory visuals, a guided creation path, and Avi close enough to help without taking over.",
			mapTitle: "A guided path from selected moments to final video.",
			notebook: "Memory projects",
			search: "Selected media"
		},
		nav: {
			avi: "Avi",
			aviLabel: "Open Avi guidance",
			create: "Create",
			createLabel: "Create memory video",
			gallery: "Gallery",
			galleryLabel: "Open Moments AV gallery",
			home: "Home",
			homeLabel: "Moments AV home",
			mobileNavigation: "Mobile navigation",
			openNavigation: "Open navigation",
			primaryNavigation: "Primary navigation"
		},
		protected: {
			body: "Sign in to create private memory videos, review projects, and keep Avi guidance connected with your account.",
			cta: "Sign in",
			title: "Keep your memory projects with you."
		},
		signIn: {
			aviPanelBody: "Avi helps keep the story warm, clear, and ready for review.",
			body: "Sign in to keep selected media, creation options, render status, and final exports connected with your AV account.",
			continue: "Continue",
			signedIn: "You are signed in.",
			title: "Moments AV is ready for your next memory."
		}
	},
	es: {
		account: {
			signInTitle: "Inicia sesión en Moments AV",
			signInSubtitle: "Vuelve para mantener conectados tus proyectos de recuerdos."
		},
		avi: {
			body: "Avi ayuda a convertir las fotos y clips seleccionados en una historia privada: estructura, tono, ritmo y siguiente paso permanecen claros antes de exportar.",
			cards: [
				{
					title: "Dar forma a la historia",
					text: "Avi mantiene los momentos elegidos organizados según la plantilla y la ocasión."
				},
				{
					title: "Ajustar el ambiente",
					text: "Estilo, duración y calidez permanecen visibles para que el video se sienta personal antes del render."
				},
				{
					title: "Preparar la exportación",
					text: "La revisión final mantiene el control en manos de la persona usuaria antes de que el video guardado salga de la app."
				}
			],
			createCta: "Crear un recuerdo",
			galleryCta: "Abrir galería",
			title: "Una forma guiada de convertir momentos en un video de recuerdo."
		},
		config: {
			body: "Ejecuta la web mediante el wrapper de Varlock para que la configuración de Account AV esté disponible. El acceso web empieza con inicio de sesión.",
			eyebrow: "Configuración requerida",
			title: "Moments AV Web necesita configuración de Clerk."
		},
		create: {
			body: "Elige fotos y clips seleccionados, escoge un formato de historia, ajusta ambiente y duración, y revisa el recuerdo antes del render final.",
			cta: "Empezar con medios seleccionados",
			flow: [
				{
					title: "Elegir momentos",
					text: "Usa solo las fotos y clips seleccionados para este proyecto."
				},
				{
					title: "Editar opciones",
					text: "Escoge la ocasión, el ambiente, el aspecto visual y la duración que encajan con la historia."
				},
				{
					title: "Revisar y renderizar",
					text: "Confirma créditos, revisa el plan y crea la exportación final."
				}
			],
			title: "Crea un video privado de recuerdos."
		},
		footer: {
			deleteAccount: "Eliminar cuenta",
			language: "Idioma",
			privacy: "Privacidad",
			support: "Soporte",
			terms: "Condiciones"
		},
		gallery: {
			body: "Los videos terminados quedan fáciles de encontrar, descargar localmente y volver a ver desde la misma cuenta.",
			emptyBody: "Crea un video de recuerdo y la exportación final aparecerá aquí para revisarla y descargarla.",
			emptyTitle: "Tu galería está lista para el primer recuerdo.",
			filters: [
				"Todos",
				"Renderizando",
				"Listos",
				"Descargados"
			],
			hints: [
				{
					title: "Revisar",
					text: "Mantén la historia visible antes de guardar o compartir el resultado."
				},
				{
					title: "Descargar",
					text: "Los videos finales se guardan cuando están listos."
				},
				{
					title: "Historial",
					text: "Los proyectos completados siguen vinculados a la cuenta para volver con calma."
				}
			],
			kicker: "Galería",
			title: "Tus videos de recuerdos, reunidos en un lugar."
		},
		home: {
			aviBody: [
				"Convierte un grupo seleccionado de fotos y clips en una historia clara.",
				"Mantén visibles tono, duración y estilo antes del render final.",
				"Vuelve a las exportaciones terminadas desde la galería."
			],
			aviTitle: "Avi da forma a la historia",
			body: "Crea videos privados de recuerdos a partir de fotos y clips seleccionados, revísalos con cuidado y expórtalos cuando estén listos.",
			cta: "Crear video",
			items: [
				{
					label: "Medios seleccionados",
					value: "Empieza desde los momentos que eliges"
				},
				{
					label: "Opciones de historia",
					value: "Ajusta plantilla, ambiente, aspecto y duración"
				},
				{
					label: "Galería",
					value: "Revisa exportaciones completadas"
				}
			],
			title: "Haz un video de recuerdo con los momentos importantes."
		},
		login: {
			aviGuidance: "Guía de Avi",
			cardBody: "Avanza de los medios elegidos a opciones de historia, revisión, render y exportación final sin perder contexto.",
			cardTitle: "Un flujo de creación tranquilo",
			cta: "Iniciar sesión",
			heroBody: "Inicia sesión para crear videos privados de recuerdos, mantener proyectos conectados y dejar que Avi ayude a dar forma a la historia antes de exportar.",
			heroTitle: "Tus recuerdos, convertidos en video con cuidado.",
			intro: "Lleva fotos y clips seleccionados a un flujo guiado para cumpleaños, celebraciones, viajes, hitos y pequeñas historias personales.",
			mapBody: "La experiencia web traslada la idea del onboarding de iOS: visuales cálidos de recuerdos, un camino de creación guiado y Avi cerca para ayudar sin tomar el control.",
			mapTitle: "Un camino guiado desde momentos seleccionados hasta el video final.",
			notebook: "Proyectos de recuerdos",
			search: "Medios seleccionados"
		},
		nav: {
			avi: "Avi",
			aviLabel: "Abrir guía de Avi",
			create: "Crear",
			createLabel: "Crear video de recuerdo",
			gallery: "Galería",
			galleryLabel: "Abrir galería de Moments AV",
			home: "Inicio",
			homeLabel: "Inicio de Moments AV",
			mobileNavigation: "Navegación móvil",
			openNavigation: "Abrir navegación",
			primaryNavigation: "Navegación principal"
		},
		protected: {
			body: "Inicia sesión para crear videos privados de recuerdos, revisar proyectos y mantener la guía de Avi conectada con tu cuenta.",
			cta: "Iniciar sesión",
			title: "Lleva tus proyectos de recuerdos contigo."
		},
		signIn: {
			aviPanelBody: "Avi ayuda a mantener la historia cálida, clara y lista para revisar.",
			body: "Inicia sesión para mantener medios seleccionados, opciones de creación, estado de render y exportaciones finales conectados con tu cuenta AV.",
			continue: "Continuar",
			signedIn: "Has iniciado sesión.",
			title: "Moments AV está listo para tu próximo recuerdo."
		}
	},
	fr: {
		account: {
			signInTitle: "Connectez-vous à Moments AV",
			signInSubtitle: "Gardez vos projets souvenirs connectés."
		},
		avi: {
			body: "Avi aide à transformer les photos et clips sélectionnés en histoire privée : structure, ton, rythme et prochaine étape restent clairs avant l’export.",
			cards: [
				{
					title: "Structurer l’histoire",
					text: "Avi garde les moments choisis organisés autour du modèle et de l’occasion."
				},
				{
					title: "Ajuster l’ambiance",
					text: "Style, durée et chaleur restent visibles afin que la vidéo paraisse personnelle avant le rendu."
				},
				{
					title: "Préparer l’export",
					text: "Le flux de révision final garde le contrôle côté utilisateur avant que la vidéo enregistrée ne quitte l’app."
				}
			],
			createCta: "Créer un souvenir",
			galleryCta: "Ouvrir la galerie",
			title: "Une façon guidée de transformer des moments en vidéo souvenir."
		},
		config: {
			body: "Lancez l’app web via le wrapper Varlock afin que la configuration Account AV soit disponible. L’accès web commence par la connexion.",
			eyebrow: "Configuration requise",
			title: "Moments AV Web nécessite une configuration Clerk."
		},
		create: {
			body: "Choisissez des photos et clips sélectionnés, définissez un format d’histoire, ajustez l’ambiance et la durée, puis relisez le souvenir avant le rendu final.",
			cta: "Commencer avec les médias choisis",
			flow: [
				{
					title: "Choisir les moments",
					text: "Utilisez uniquement les photos et clips sélectionnés pour ce projet."
				},
				{
					title: "Modifier les options",
					text: "Choisissez l’occasion, l’ambiance, le style visuel et la durée adaptés à l’histoire."
				},
				{
					title: "Relire et rendre",
					text: "Confirmez les crédits, relisez le plan et créez l’export final."
				}
			],
			title: "Créez une vidéo souvenir privée."
		},
		footer: {
			deleteAccount: "Supprimer le compte",
			language: "Langue",
			privacy: "Confidentialité",
			support: "Aide",
			terms: "Conditions"
		},
		gallery: {
			body: "Les vidéos terminées restent faciles à retrouver, à télécharger localement et à consulter depuis le même compte connecté.",
			emptyBody: "Créez une vidéo souvenir et l’export final apparaîtra ici pour révision et téléchargement.",
			emptyTitle: "Votre galerie est prête pour le premier souvenir.",
			filters: [
				"Tous",
				"Rendu",
				"Prêts",
				"Téléchargés"
			],
			hints: [
				{
					title: "Relire",
					text: "Gardez l’histoire visible avant d’enregistrer ou de partager le résultat."
				},
				{
					title: "Télécharger",
					text: "Les vidéos finales sont enregistrées par l’utilisateur lorsqu’elles sont prêtes."
				},
				{
					title: "Historique",
					text: "Les projets terminés restent liés au compte pour un retour plus serein."
				}
			],
			kicker: "Galerie",
			title: "Vos vidéos souvenirs, réunies au même endroit."
		},
		home: {
			aviBody: [
				"Transformez un groupe sélectionné de photos et clips en histoire claire.",
				"Gardez le ton, la durée et le style visibles avant le rendu final.",
				"Retrouvez les exports terminés depuis la galerie."
			],
			aviTitle: "Avi structure l’histoire",
			body: "Créez des vidéos souvenirs privées à partir de photos et clips sélectionnés, relisez-les avec soin et exportez-les lorsqu’elles sont prêtes.",
			cta: "Créer une vidéo",
			items: [
				{
					label: "Médias choisis",
					value: "Commencez avec les moments que vous sélectionnez"
				},
				{
					label: "Options d’histoire",
					value: "Ajustez modèle, ambiance, style et durée"
				},
				{
					label: "Galerie",
					value: "Relisez les exports terminés"
				}
			],
			title: "Créez une vidéo souvenir avec les moments importants."
		},
		login: {
			aviGuidance: "Conseils d’Avi",
			cardBody: "Passez des médias choisis aux options d’histoire, à la révision, au rendu et à l’export final sans perdre le contexte.",
			cardTitle: "Un flux de création calme",
			cta: "Se connecter",
			heroBody: "Connectez-vous pour créer des vidéos souvenirs privées, garder vos projets liés et laisser Avi aider à structurer l’histoire avant l’export.",
			heroTitle: "Vos souvenirs, transformés en vidéo avec soin.",
			intro: "Ajoutez des photos et clips sélectionnés dans un flux guidé pour anniversaires, célébrations, voyages, étapes importantes et petites histoires personnelles.",
			mapBody: "L’expérience web reprend l’idée d’onboarding iOS : des visuels chaleureux, un parcours de création guidé et Avi assez proche pour aider sans prendre la main.",
			mapTitle: "Un chemin guidé des moments choisis à la vidéo finale.",
			notebook: "Projets souvenirs",
			search: "Médias choisis"
		},
		nav: {
			avi: "Avi",
			aviLabel: "Ouvrir les conseils d’Avi",
			create: "Créer",
			createLabel: "Créer une vidéo souvenir",
			gallery: "Galerie",
			galleryLabel: "Ouvrir la galerie Moments AV",
			home: "Accueil",
			homeLabel: "Accueil Moments AV",
			mobileNavigation: "Navigation mobile",
			openNavigation: "Ouvrir la navigation",
			primaryNavigation: "Navigation principale"
		},
		protected: {
			body: "Connectez-vous pour créer des vidéos souvenirs privées, relire vos projets et garder les conseils d’Avi liés à votre compte.",
			cta: "Se connecter",
			title: "Gardez vos projets souvenirs avec vous."
		},
		signIn: {
			aviPanelBody: "Avi aide à garder l’histoire chaleureuse, claire et prête pour la révision.",
			body: "Connectez-vous pour garder les médias choisis, les options de création, l’état du rendu et les exports finaux liés à votre compte AV.",
			continue: "Continuer",
			signedIn: "Vous êtes connecté.",
			title: "Moments AV est prêt pour votre prochain souvenir."
		}
	},
	de: {
		account: {
			signInTitle: "Bei Moments AV anmelden",
			signInSubtitle: "Halte deine Erinnerungsprojekte verbunden."
		},
		avi: {
			body: "Avi hilft, ausgewählte Fotos und Clips in eine private Geschichte zu formen: Struktur, Ton, Tempo und der nächste Schritt bleiben vor dem Export klar.",
			cards: [
				{
					title: "Geschichte formen",
					text: "Avi hält die ausgewählten Momente passend zu Vorlage und Anlass organisiert."
				},
				{
					title: "Stimmung abstimmen",
					text: "Stil, Länge und Wärme bleiben sichtbar, damit sich das Video vor dem Rendering persönlich anfühlt."
				},
				{
					title: "Export vorbereiten",
					text: "Die finale Prüfung lässt die Kontrolle bei der nutzenden Person, bevor das gespeicherte Video die App verlässt."
				}
			],
			createCta: "Moment erstellen",
			galleryCta: "Galerie öffnen",
			title: "Eine geführte Art, Momente in ein Erinnerungsvideo zu verwandeln."
		},
		config: {
			body: "Starte die Web-App über den Varlock-Wrapper, damit die Account AV Konfiguration verfügbar ist. Webzugriff beginnt mit der Anmeldung.",
			eyebrow: "Konfiguration erforderlich",
			title: "Moments AV Web benötigt Clerk-Konfiguration."
		},
		create: {
			body: "Wähle ausgewählte Fotos und Clips, entscheide dich für ein Geschichtenformat, passe Stimmung und Länge an und prüfe die Erinnerung vor dem finalen Rendern.",
			cta: "Mit ausgewählten Medien starten",
			flow: [
				{
					title: "Momente wählen",
					text: "Verwende nur die Fotos und Clips, die für dieses Projekt ausgewählt wurden."
				},
				{
					title: "Optionen bearbeiten",
					text: "Wähle Anlass, Stimmung, visuellen Look und Länge passend zur Geschichte."
				},
				{
					title: "Prüfen und rendern",
					text: "Bestätige Credits, prüfe den Plan und erstelle den finalen Export."
				}
			],
			title: "Erstelle ein privates Erinnerungsvideo."
		},
		footer: {
			deleteAccount: "Konto löschen",
			language: "Sprache",
			privacy: "Datenschutz",
			support: "Support",
			terms: "Bedingungen"
		},
		gallery: {
			body: "Fertige Videos bleiben leicht auffindbar, lokal herunterladbar und vom selben angemeldeten Konto erneut aufrufbar.",
			emptyBody: "Erstelle ein Erinnerungsvideo, dann erscheint der finale Export hier zur Prüfung und zum Download.",
			emptyTitle: "Deine Galerie ist bereit für die erste Erinnerung.",
			filters: [
				"Alle",
				"Wird gerendert",
				"Bereit",
				"Heruntergeladen"
			],
			hints: [
				{
					title: "Prüfen",
					text: "Halte die Geschichte sichtbar, bevor du das Ergebnis speicherst oder teilst."
				},
				{
					title: "Download",
					text: "Finale Videos werden gespeichert, wenn sie bereit sind."
				},
				{
					title: "Verlauf",
					text: "Abgeschlossene Projekte bleiben für eine ruhigere Rückkehr mit dem Konto verbunden."
				}
			],
			kicker: "Galerie",
			title: "Deine Erinnerungsvideos an einem Ort."
		},
		home: {
			aviBody: [
				"Verwandle eine ausgewählte Gruppe von Fotos und Clips in eine klare Geschichte.",
				"Halte Ton, Länge und Stil vor dem finalen Rendern sichtbar.",
				"Kehre über die Galerie zu fertigen Exporten zurück."
			],
			aviTitle: "Avi formt die Geschichte",
			body: "Erstelle private Erinnerungsvideos aus ausgewählten Fotos und Clips, prüfe sie sorgfältig und exportiere sie, wenn sie bereit sind.",
			cta: "Video erstellen",
			items: [
				{
					label: "Ausgewählte Medien",
					value: "Beginne mit den Momenten, die du auswählst"
				},
				{
					label: "Story-Optionen",
					value: "Passe Vorlage, Stimmung, Look und Länge an"
				},
				{
					label: "Galerie",
					value: "Prüfe abgeschlossene Exporte"
				}
			],
			title: "Mache aus wichtigen Momenten ein Erinnerungsvideo."
		},
		login: {
			aviGuidance: "Avi-Begleitung",
			cardBody: "Wechsle von ausgewählten Medien zu Story-Optionen, Prüfung, Rendering und finalem Export, ohne den Kontext zu verlieren.",
			cardTitle: "Ein ruhiger Erstellungsfluss",
			cta: "Anmelden",
			heroBody: "Melde dich an, um private Erinnerungsvideos zu erstellen, Projekte verbunden zu halten und Avi vor dem Export bei der Geschichte helfen zu lassen.",
			heroTitle: "Deine Erinnerungen, sorgsam als Video gestaltet.",
			intro: "Führe ausgewählte Fotos und Clips in einen geführten Ablauf für Geburtstage, Feiern, Reisen, Meilensteine und kleine persönliche Geschichten.",
			mapBody: "Die Web-Erfahrung übernimmt die iOS-Onboarding-Idee: warme Erinnerungsbilder, ein geführter Erstellungsweg und Avi nah genug, um zu helfen, ohne zu übernehmen.",
			mapTitle: "Ein geführter Weg von ausgewählten Momenten zum finalen Video.",
			notebook: "Erinnerungsprojekte",
			search: "Ausgewählte Medien"
		},
		nav: {
			avi: "Avi",
			aviLabel: "Avi-Begleitung öffnen",
			create: "Erstellen",
			createLabel: "Erinnerungsvideo erstellen",
			gallery: "Galerie",
			galleryLabel: "Moments AV Galerie öffnen",
			home: "Start",
			homeLabel: "Moments AV Start",
			mobileNavigation: "Mobile Navigation",
			openNavigation: "Navigation öffnen",
			primaryNavigation: "Hauptnavigation"
		},
		protected: {
			body: "Melde dich an, um private Erinnerungsvideos zu erstellen, Projekte zu prüfen und Avis Begleitung mit deinem Konto verbunden zu halten.",
			cta: "Anmelden",
			title: "Nimm deine Erinnerungsprojekte mit."
		},
		signIn: {
			aviPanelBody: "Avi hilft, die Geschichte warm, klar und bereit zur Prüfung zu halten.",
			body: "Melde dich an, um ausgewählte Medien, Erstellungsoptionen, Renderstatus und finale Exporte mit deinem AV Konto verbunden zu halten.",
			continue: "Weiter",
			signedIn: "Du bist angemeldet.",
			title: "Moments AV ist bereit für deine nächste Erinnerung."
		}
	},
	ca: {
		account: {
			signInTitle: "Inicia sessió a Moments AV",
			signInSubtitle: "Mantingues connectats els teus projectes de records."
		},
		avi: {
			body: "L’Avi ajuda a convertir les fotos i els clips seleccionats en una història privada: estructura, to, ritme i següent pas es mantenen clars abans d’exportar.",
			cards: [
				{
					title: "Donar forma a la història",
					text: "L’Avi manté els moments seleccionats organitzats al voltant de la plantilla i l’ocasió."
				},
				{
					title: "Ajustar l’ambient",
					text: "L’estil, la durada i la calidesa es mantenen visibles perquè el vídeo se senti personal abans del render."
				},
				{
					title: "Preparar l’exportació",
					text: "El flux de revisió final manté el control en mans de la persona usuària abans que el vídeo desat surti de l’app."
				}
			],
			createCta: "Crea un record",
			galleryCta: "Obre la galeria",
			title: "Una manera guiada de convertir moments en un vídeo de record."
		},
		config: {
			body: "Executa la web mitjançant el wrapper de Varlock perquè la configuració d’Account AV estigui disponible. L’accés web comença amb l’inici de sessió.",
			eyebrow: "Configuració requerida",
			title: "Moments AV Web necessita configuració de Clerk."
		},
		create: {
			body: "Tria fotos i clips seleccionats, escull un format d’història, ajusta ambient i durada, i revisa el record abans del render final.",
			cta: "Comença amb mitjans seleccionats",
			flow: [
				{
					title: "Triar moments",
					text: "Fes servir només les fotos i els clips seleccionats per a aquest projecte."
				},
				{
					title: "Editar opcions",
					text: "Escull l’ocasió, l’ambient, l’aspecte visual i la durada que encaixen amb la història."
				},
				{
					title: "Revisar i renderitzar",
					text: "Confirma crèdits, revisa el pla i crea l’exportació final."
				}
			],
			title: "Crea un vídeo privat de records."
		},
		footer: {
			deleteAccount: "Eliminar compte",
			language: "Idioma",
			privacy: "Privacitat",
			support: "Ajuda",
			terms: "Condicions"
		},
		gallery: {
			body: "Els vídeos acabats són fàcils de trobar, descarregar localment i tornar a veure des del mateix compte amb sessió iniciada.",
			emptyBody: "Crea un vídeo de record i l’exportació final apareixerà aquí per revisar-la i descarregar-la.",
			emptyTitle: "La teva galeria està preparada per al primer record.",
			filters: [
				"Tots",
				"Renderitzant",
				"A punt",
				"Descarregats"
			],
			hints: [
				{
					title: "Revisar",
					text: "Mantén la història visible abans de desar o compartir el resultat."
				},
				{
					title: "Descarregar",
					text: "Els vídeos finals es desen quan estan preparats."
				},
				{
					title: "Historial",
					text: "Els projectes completats continuen vinculats al compte per tornar-hi amb calma."
				}
			],
			kicker: "Galeria",
			title: "Els teus vídeos de records, reunits en un lloc."
		},
		home: {
			aviBody: [
				"Converteix un grup seleccionat de fotos i clips en una història clara.",
				"Mantén visibles el to, la durada i l’estil abans del render final.",
				"Torna a les exportacions acabades des de la galeria."
			],
			aviTitle: "L’Avi dona forma a la història",
			body: "Crea vídeos privats de records a partir de fotos i clips seleccionats, revisa’ls amb cura i exporta’ls quan estiguin a punt.",
			cta: "Crea vídeo",
			items: [
				{
					label: "Mitjans seleccionats",
					value: "Comença pels moments que tries"
				},
				{
					label: "Opcions d’història",
					value: "Ajusta plantilla, ambient, aspecte i durada"
				},
				{
					label: "Galeria",
					value: "Revisa exportacions completades"
				}
			],
			title: "Fes un vídeo de record amb els moments importants."
		},
		login: {
			aviGuidance: "Guia de l’Avi",
			cardBody: "Avança dels mitjans triats a les opcions d’història, revisió, render i exportació final sense perdre context.",
			cardTitle: "Un flux de creació tranquil",
			cta: "Inicia sessió",
			heroBody: "Inicia sessió per crear vídeos privats de records, mantenir projectes connectats i deixar que l’Avi ajudi a donar forma a la història abans d’exportar.",
			heroTitle: "Els teus records, convertits en vídeo amb cura.",
			intro: "Porta fotos i clips seleccionats a un flux guiat per a aniversaris, celebracions, viatges, fites i petites històries personals.",
			mapBody: "L’experiència web trasllada la idea de l’onboarding d’iOS: visuals càlids de records, un camí de creació guiat i l’Avi prou a prop per ajudar sense prendre el control.",
			mapTitle: "Un camí guiat des dels moments seleccionats fins al vídeo final.",
			notebook: "Projectes de records",
			search: "Mitjans seleccionats"
		},
		nav: {
			avi: "Avi",
			aviLabel: "Obre la guia de l’Avi",
			create: "Crea",
			createLabel: "Crea vídeo de record",
			gallery: "Galeria",
			galleryLabel: "Obre la galeria de Moments AV",
			home: "Inici",
			homeLabel: "Inici de Moments AV",
			mobileNavigation: "Navegació mòbil",
			openNavigation: "Obre la navegació",
			primaryNavigation: "Navegació principal"
		},
		protected: {
			body: "Inicia sessió per crear vídeos privats de records, revisar projectes i mantenir la guia de l’Avi connectada amb el teu compte.",
			cta: "Inicia sessió",
			title: "Porta els teus projectes de records amb tu."
		},
		signIn: {
			aviPanelBody: "L’Avi ajuda a mantenir la història càlida, clara i preparada per revisar.",
			body: "Inicia sessió per mantenir mitjans seleccionats, opcions de creació, estat de render i exportacions finals connectats amb el teu compte AV.",
			continue: "Continua",
			signedIn: "Has iniciat sessió.",
			title: "Moments AV està a punt per al teu proper record."
		}
	}
};
function useMomentsText() {
	return translations[useAppsAvLocale()];
}
function useMomentsAccountLocalization() {
	const locale = useAppsAvLocale();
	const text = translations[locale];
	const base = {
		ca: caES,
		de: deDE,
		en: enUS,
		es: esES,
		fr: frFR
	}[locale];
	return {
		...base,
		signIn: {
			...base.signIn,
			start: {
				...base.signIn?.start,
				subtitle: text.account.signInSubtitle,
				title: text.account.signInTitle
			}
		}
	};
}
function useMomentsShellLabels() {
	const text = useMomentsText();
	return {
		assistant: text.nav.aviLabel,
		home: text.nav.homeLabel,
		mobileNavigation: text.nav.mobileNavigation,
		openNavigation: text.nav.openNavigation,
		primaryNavigation: text.nav.primaryNavigation
	};
}
function useMomentsNavLinks() {
	const locale = useAppsAvLocale();
	const text = useMomentsText();
	return [
		{
			href: localizedAppPath("/", locale),
			label: text.nav.home
		},
		{
			href: localizedAppPath("/create", locale),
			label: text.nav.create
		},
		{
			href: localizedAppPath("/gallery", locale),
			label: text.nav.gallery
		},
		{
			href: localizedAppPath("/avi", locale),
			label: text.nav.avi
		}
	];
}
function useMomentsProductConfig() {
	const locale = useAppsAvLocale();
	const text = useMomentsText();
	return useMemo(() => ({
		...momentsProductConfig,
		assistant: momentsProductConfig.assistant ? {
			...momentsProductConfig.assistant,
			href: localizedAppPath(momentsProductConfig.assistant.href, locale),
			label: text.nav.aviLabel
		} : void 0
	}), [locale, text.nav.aviLabel]);
}
function localizedAppPath(path, locale) {
	if (locale === "en") return path;
	return `${path}${path.includes("?") ? "&" : "?"}lang=${locale}`;
}
//#endregion
export { useMomentsShellLabels as a, getAccountPublishableKey as c, AuthSkeleton as d, AppShell as f, useMomentsProductConfig as i, momentsBrandAssets as l, useAppsAvLocale as m, useMomentsAccountLocalization as n, useMomentsText as o, AvAppFooter as p, useMomentsNavLinks as r, getAccountApiBaseUrl as s, localizedAppPath as t, AppsAvWebProvider as u };
