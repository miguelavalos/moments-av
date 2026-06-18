import { i as AccountSignIn, n as SignedIn, r as SignedOut } from "./src-BT1bYzoz.js";
import { i as useMomentsProductConfig, l as momentsBrandAssets, m as useAppsAvLocale, o as useMomentsText, p as AvAppFooter, t as localizedAppPath } from "./moments-i18n-DYJ5dSz9.js";
import { jsx, jsxs } from "react/jsx-runtime";
import { ArrowLeft } from "lucide-react";
//#region src/routes/sign-in.tsx?tsr-split=component
function SignInRoute() {
	const text = useMomentsText();
	const locale = useAppsAvLocale();
	const productConfig = useMomentsProductConfig();
	return /* @__PURE__ */ jsxs("div", {
		className: "moments-canvas flex min-h-screen flex-col bg-[#fbf7f2]",
		children: [/* @__PURE__ */ jsxs("main", {
			className: "grid flex-1 lg:grid-cols-[0.92fr_1.08fr]",
			children: [/* @__PURE__ */ jsxs("section", {
				className: "relative hidden min-h-screen overflow-hidden bg-[#20242e] p-10 text-white lg:flex lg:flex-col lg:justify-between",
				children: [
					/* @__PURE__ */ jsx("div", { className: "absolute inset-0 bg-[linear-gradient(160deg,#5e3041_0%,#20242e_54%,#11151d_100%)]" }),
					/* @__PURE__ */ jsxs("a", {
						className: "relative inline-flex items-center gap-2 text-sm font-medium text-white/76 transition hover:text-white",
						href: localizedAppPath("/", locale),
						children: [/* @__PURE__ */ jsx(ArrowLeft, {
							className: "size-4",
							"aria-hidden": "true"
						}), "Moments AV"]
					}),
					/* @__PURE__ */ jsxs("div", {
						className: "relative max-w-md",
						children: [
							/* @__PURE__ */ jsx("img", {
								className: "mb-10 h-auto w-64 brightness-0 invert",
								src: momentsBrandAssets.logo,
								alt: "Moments AV"
							}),
							/* @__PURE__ */ jsx("h1", {
								className: "text-4xl font-semibold leading-tight",
								children: text.signIn.title
							}),
							/* @__PURE__ */ jsx("p", {
								className: "mt-5 text-base leading-7 text-white/70",
								children: text.signIn.body
							})
						]
					}),
					/* @__PURE__ */ jsxs("div", {
						className: "relative overflow-hidden rounded-[1.5rem] border border-white/12 bg-[#fbf7f2] p-5 pb-0 text-[#20242e] shadow-2xl shadow-black/22",
						children: [/* @__PURE__ */ jsxs("div", {
							className: "relative z-10 max-w-xs pb-28",
							children: [/* @__PURE__ */ jsx("p", {
								className: "text-sm font-semibold text-[#b94e70]",
								children: "Avi"
							}), /* @__PURE__ */ jsx("p", {
								className: "mt-2 font-serif text-3xl leading-tight",
								children: text.signIn.aviPanelBody
							})]
						}), /* @__PURE__ */ jsx("img", {
							className: "absolute bottom-0 right-6 w-52 translate-y-8 drop-shadow-2xl",
							src: momentsBrandAssets.aviLoginSheetPeek,
							alt: "Avi"
						})]
					})
				]
			}), /* @__PURE__ */ jsx("section", {
				className: "flex min-h-screen items-center justify-center px-5 py-10",
				children: /* @__PURE__ */ jsxs("div", {
					className: "w-full max-w-md rounded-[1.5rem] border border-[#e5c1c7] bg-white/72 p-4 shadow-2xl shadow-[#7b233f]/10 backdrop-blur sm:p-6",
					children: [
						/* @__PURE__ */ jsxs("a", {
							className: "mb-8 inline-flex items-center gap-2 text-sm font-medium text-[#6d5960] transition hover:text-[#20242e] lg:hidden",
							href: localizedAppPath("/", locale),
							children: [/* @__PURE__ */ jsx(ArrowLeft, {
								className: "size-4",
								"aria-hidden": "true"
							}), "Moments AV"]
						}),
						/* @__PURE__ */ jsx("img", {
							className: "mb-8 h-auto w-64 lg:hidden",
							src: momentsBrandAssets.logo,
							alt: "Moments AV"
						}),
						/* @__PURE__ */ jsxs("div", {
							className: "mb-5 flex items-center gap-3 rounded-2xl border border-[#e5c1c7] bg-[#fff8f3]/82 p-3 shadow-sm shadow-[#7b233f]/8 lg:hidden",
							children: [/* @__PURE__ */ jsx("img", {
								className: "h-16 w-16 object-contain",
								src: momentsBrandAssets.aviFullBody,
								alt: "Avi"
							}), /* @__PURE__ */ jsx("p", {
								className: "text-sm font-medium leading-5 text-[#4d5563]",
								children: text.signIn.aviPanelBody
							})]
						}),
						/* @__PURE__ */ jsx(SignedIn, { children: /* @__PURE__ */ jsxs("div", {
							className: "rounded-2xl border border-[#e5c1c7] bg-[#fff8f3] p-6 text-center shadow-lg shadow-[#7b233f]/10",
							children: [/* @__PURE__ */ jsx("p", {
								className: "text-sm font-semibold text-[#20242e]",
								children: text.signIn.signedIn
							}), /* @__PURE__ */ jsx("a", {
								className: "mt-4 inline-flex h-10 items-center justify-center rounded-full bg-[#7c2947] px-4 text-sm font-semibold text-white",
								href: localizedAppPath("/", locale),
								children: text.signIn.continue
							})]
						}) }),
						/* @__PURE__ */ jsx(SignedOut, { children: /* @__PURE__ */ jsx(AccountSignIn, {
							fallbackRedirectUrl: "/",
							path: "/sign-in"
						}) })
					]
				})
			})]
		}), /* @__PURE__ */ jsx(AvAppFooter, {
			labels: text.footer,
			product: productConfig
		})]
	});
}
//#endregion
export { SignInRoute as component };
