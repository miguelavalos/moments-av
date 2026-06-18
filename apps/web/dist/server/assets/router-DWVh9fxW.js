import { o as AccountAvProvider } from "./src-BT1bYzoz.js";
import { c as getAccountPublishableKey, m as useAppsAvLocale, n as useMomentsAccountLocalization, o as useMomentsText, s as getAccountApiBaseUrl, t as localizedAppPath, u as AppsAvWebProvider } from "./moments-i18n-DYJ5dSz9.js";
import { HeadContent, Outlet, Scripts, createFileRoute, createRootRoute, createRouter, lazyRouteComponent } from "@tanstack/react-router";
import { jsx, jsxs } from "react/jsx-runtime";
//#region src/routes/__root.tsx
var Route$5 = createRootRoute({
	component: RootComponent,
	head: () => ({ meta: [
		{ charSet: "utf-8" },
		{
			name: "viewport",
			content: "width=device-width, initial-scale=1"
		},
		{ title: "Moments AV" }
	] })
});
function RootComponent() {
	return /* @__PURE__ */ jsx(RootDocument, { children: /* @__PURE__ */ jsx(Outlet, {}) });
}
function RootDocument({ children }) {
	const publishableKey = getAccountPublishableKey();
	const locale = useAppsAvLocale();
	const localization = useMomentsAccountLocalization();
	return /* @__PURE__ */ jsxs("html", {
		lang: locale,
		children: [/* @__PURE__ */ jsx("head", { children: /* @__PURE__ */ jsx(HeadContent, {}) }), /* @__PURE__ */ jsxs("body", { children: [/* @__PURE__ */ jsx(AppsAvWebProvider, { children: publishableKey ? /* @__PURE__ */ jsx(AccountAvProvider, {
			accountApiBaseUrl: getAccountApiBaseUrl(),
			afterSignOutUrl: localizedAppPath("/sign-in", locale),
			appDisplayName: "Moments AV",
			appId: "momentsav",
			localization,
			publishableKey,
			signInUrl: localizedAppPath("/sign-in", locale),
			signUpUrl: localizedAppPath("/sign-in", locale),
			children
		}) : /* @__PURE__ */ jsx(MissingAuthConfiguration, {}) }), /* @__PURE__ */ jsx(Scripts, {})] })]
	});
}
function MissingAuthConfiguration() {
	const text = useMomentsText();
	return /* @__PURE__ */ jsx("main", {
		className: "mx-auto flex min-h-screen max-w-3xl flex-col justify-center px-6",
		children: /* @__PURE__ */ jsxs("div", {
			className: "rounded-lg border bg-card p-6 text-card-foreground shadow-sm",
			children: [
				/* @__PURE__ */ jsx("p", {
					className: "text-sm font-semibold uppercase tracking-[0.18em] text-muted-foreground",
					children: text.config.eyebrow
				}),
				/* @__PURE__ */ jsx("h1", {
					className: "mt-4 text-3xl font-semibold text-foreground",
					children: text.config.title
				}),
				/* @__PURE__ */ jsx("p", {
					className: "mt-3 text-sm leading-6 text-muted-foreground",
					children: text.config.body
				})
			]
		})
	});
}
//#endregion
//#region src/routes/sign-in.tsx
var $$splitComponentImporter$4 = () => import("./sign-in-CVjo7dgp.js");
var Route$4 = createFileRoute("/sign-in")({ component: lazyRouteComponent($$splitComponentImporter$4, "component") });
//#endregion
//#region src/routes/gallery.tsx
var $$splitComponentImporter$3 = () => import("./gallery-DYodUhR1.js");
var Route$3 = createFileRoute("/gallery")({ component: lazyRouteComponent($$splitComponentImporter$3, "component") });
//#endregion
//#region src/routes/create.tsx
var $$splitComponentImporter$2 = () => import("./create-Dvhl4fzB.js");
var Route$2 = createFileRoute("/create")({ component: lazyRouteComponent($$splitComponentImporter$2, "component") });
//#endregion
//#region src/routes/avi.tsx
var $$splitComponentImporter$1 = () => import("./avi-CQ2qZhBG.js");
var Route$1 = createFileRoute("/avi")({ component: lazyRouteComponent($$splitComponentImporter$1, "component") });
//#endregion
//#region src/routes/index.tsx
var $$splitComponentImporter = () => import("./routes-Kuz0ynYY.js");
var Route = createFileRoute("/")({ component: lazyRouteComponent($$splitComponentImporter, "component") });
//#endregion
//#region src/routeTree.gen.ts
var SignInRoute = Route$4.update({
	id: "/sign-in",
	path: "/sign-in",
	getParentRoute: () => Route$5
});
var GalleryRoute = Route$3.update({
	id: "/gallery",
	path: "/gallery",
	getParentRoute: () => Route$5
});
var CreateRoute = Route$2.update({
	id: "/create",
	path: "/create",
	getParentRoute: () => Route$5
});
var AviRoute = Route$1.update({
	id: "/avi",
	path: "/avi",
	getParentRoute: () => Route$5
});
var rootRouteChildren = {
	IndexRoute: Route.update({
		id: "/",
		path: "/",
		getParentRoute: () => Route$5
	}),
	AviRoute,
	CreateRoute,
	GalleryRoute,
	SignInRoute
};
var routeTree = Route$5._addFileChildren(rootRouteChildren)._addFileTypes();
//#endregion
//#region src/router.tsx
function getRouter() {
	return createRouter({
		routeTree,
		scrollRestoration: true
	});
}
//#endregion
export { getRouter };
