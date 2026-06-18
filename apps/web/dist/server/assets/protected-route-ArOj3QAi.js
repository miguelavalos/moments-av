import { n as SignedIn, r as SignedOut, t as AuthLoading } from "./src-BT1bYzoz.js";
import { d as AuthSkeleton, i as useMomentsProductConfig, l as momentsBrandAssets, m as useAppsAvLocale, o as useMomentsText, p as AvAppFooter, t as localizedAppPath } from "./moments-i18n-DYJ5dSz9.js";
import { Fragment, jsx, jsxs } from "react/jsx-runtime";
//#region src/components/protected-route.tsx
function ProtectedRoute({ children }) {
	const text = useMomentsText();
	const productConfig = useMomentsProductConfig();
	const signInHref = localizedAppPath("/sign-in", useAppsAvLocale());
	return /* @__PURE__ */ jsxs(Fragment, { children: [
		/* @__PURE__ */ jsx(AuthLoading, { children: /* @__PURE__ */ jsx(AuthSkeleton, {}) }),
		/* @__PURE__ */ jsx(SignedIn, { children }),
		/* @__PURE__ */ jsx(SignedOut, { children: /* @__PURE__ */ jsxs("div", {
			className: "moments-canvas flex min-h-screen flex-col",
			children: [/* @__PURE__ */ jsx("main", {
				className: "flex flex-1 items-center justify-center px-6 py-10 text-center",
				children: /* @__PURE__ */ jsxs("div", {
					className: "relative max-w-3xl overflow-hidden rounded-[1.75rem] border border-[#e5c1c7] bg-[#fff8f3]/88 p-8 pb-28 shadow-2xl shadow-[#7b233f]/12 sm:p-10 sm:pb-10",
					children: [
						/* @__PURE__ */ jsx("img", {
							className: "mx-auto h-auto w-64",
							src: momentsBrandAssets.logo,
							alt: "Moments AV"
						}),
						/* @__PURE__ */ jsx("h1", {
							className: "mt-8 text-4xl font-semibold text-[#20242e]",
							children: text.protected.title
						}),
						/* @__PURE__ */ jsx("p", {
							className: "mx-auto mt-4 max-w-xl text-base leading-7 text-[#4d5563]",
							children: text.protected.body
						}),
						/* @__PURE__ */ jsx("a", {
							className: "mt-8 inline-flex h-11 items-center justify-center rounded-full bg-[#7c2947] px-5 text-sm font-semibold text-white shadow-lg shadow-[#7c2947]/18 transition hover:bg-[#963956]",
							href: signInHref,
							children: text.protected.cta
						}),
						/* @__PURE__ */ jsx("img", {
							className: "absolute bottom-0 right-5 w-28 translate-y-6 sm:hidden",
							src: momentsBrandAssets.aviFullBody,
							alt: "Avi"
						})
					]
				})
			}), /* @__PURE__ */ jsx(AvAppFooter, {
				className: "border-transparent bg-transparent",
				labels: text.footer,
				product: productConfig
			})]
		}) })
	] });
}
//#endregion
export { ProtectedRoute as t };
