import { a as AccountUserButton } from "./src-BT1bYzoz.js";
import { a as useMomentsShellLabels, f as AppShell, i as useMomentsProductConfig, l as momentsBrandAssets, m as useAppsAvLocale, o as useMomentsText, r as useMomentsNavLinks, t as localizedAppPath } from "./moments-i18n-DYJ5dSz9.js";
import { t as ProtectedRoute } from "./protected-route-ArOj3QAi.js";
import { t as Card } from "./card-dEqfm8WK.js";
import { t as Button } from "./button-B9bYYP8r.js";
import { jsx, jsxs } from "react/jsx-runtime";
import { Film, Images, SlidersHorizontal, Sparkles } from "lucide-react";
//#region src/routes/avi.tsx?tsr-split=component
function AviRoute() {
	const text = useMomentsText();
	const locale = useAppsAvLocale();
	const navLinks = useMomentsNavLinks();
	const productConfig = useMomentsProductConfig();
	const shellLabels = useMomentsShellLabels();
	const cardIcons = [
		/* @__PURE__ */ jsx(Images, { className: "size-4" }),
		/* @__PURE__ */ jsx(SlidersHorizontal, { className: "size-4" }),
		/* @__PURE__ */ jsx(Film, { className: "size-4" })
	];
	return /* @__PURE__ */ jsx(ProtectedRoute, { children: /* @__PURE__ */ jsx(AppShell, {
		accountArea: /* @__PURE__ */ jsx(AccountUserButton, {}),
		footerLabels: text.footer,
		labels: shellLabels,
		navLinks,
		product: productConfig,
		children: /* @__PURE__ */ jsxs("section", {
			className: "grid gap-6 lg:grid-cols-[1.05fr_0.95fr]",
			children: [/* @__PURE__ */ jsx(Card, {
				className: "moments-canvas gap-0 overflow-hidden rounded-[1.5rem] border-[#e5c1c7] p-0 text-[#20242e] shadow-lg shadow-[#7b233f]/8",
				children: /* @__PURE__ */ jsxs("div", {
					className: "grid min-h-[32rem] lg:grid-cols-[0.95fr_1.05fr]",
					children: [/* @__PURE__ */ jsxs("div", {
						className: "flex flex-col justify-between gap-8 p-6 sm:p-8",
						children: [/* @__PURE__ */ jsxs("div", { children: [
							/* @__PURE__ */ jsxs("p", {
								className: "flex items-center gap-2 text-sm font-semibold text-[#b94e70]",
								children: [/* @__PURE__ */ jsx(Sparkles, {
									className: "size-4",
									"aria-hidden": "true"
								}), "Avi"]
							}),
							/* @__PURE__ */ jsx("h1", {
								className: "mt-3 text-4xl font-semibold leading-tight",
								children: text.avi.title
							}),
							/* @__PURE__ */ jsx("p", {
								className: "mt-4 text-base leading-7 text-[#4d5563]",
								children: text.avi.body
							})
						] }), /* @__PURE__ */ jsxs("div", {
							className: "flex flex-wrap gap-3",
							children: [/* @__PURE__ */ jsx(Button, {
								asChild: true,
								className: "rounded-full bg-[#7c2947] text-white hover:bg-[#963956]",
								children: /* @__PURE__ */ jsxs("a", {
									href: localizedAppPath("/create", locale),
									children: [/* @__PURE__ */ jsx(Images, {
										className: "size-4",
										"aria-hidden": "true"
									}), text.avi.createCta]
								})
							}), /* @__PURE__ */ jsx(Button, {
								asChild: true,
								variant: "outline",
								className: "rounded-full border-[#e5c1c7] bg-[#fff8f3]/76",
								children: /* @__PURE__ */ jsx("a", {
									href: localizedAppPath("/gallery", locale),
									children: text.avi.galleryCta
								})
							})]
						})]
					}), /* @__PURE__ */ jsxs("div", {
						className: "relative min-h-80 overflow-hidden bg-[#20242e]",
						children: [/* @__PURE__ */ jsx("div", { className: "absolute inset-0 bg-[linear-gradient(160deg,#5e3041_0%,#20242e_56%,#11151d_100%)]" }), /* @__PURE__ */ jsx("img", {
							className: "relative h-full w-full object-cover object-bottom",
							src: momentsBrandAssets.aviLoginPeek,
							alt: ""
						})]
					})]
				})
			}), /* @__PURE__ */ jsx("div", {
				className: "grid gap-4",
				children: text.avi.cards.map((card, index) => /* @__PURE__ */ jsx(AviCard, {
					icon: cardIcons[index],
					title: card.title,
					text: card.text
				}, card.title))
			})]
		})
	}) });
}
function AviCard({ icon, text, title }) {
	return /* @__PURE__ */ jsxs(Card, {
		className: "gap-2 rounded-[1.25rem] border-[#e5c1c7] bg-[#fff8f3]/88 p-5 py-5 text-[#20242e] shadow-sm shadow-[#7b233f]/6",
		children: [/* @__PURE__ */ jsxs("div", {
			className: "flex items-center gap-2 text-sm font-semibold",
			children: [/* @__PURE__ */ jsx("span", {
				className: "text-[#b94e70]",
				children: icon
			}), title]
		}), /* @__PURE__ */ jsx("p", {
			className: "text-sm leading-6 text-[#6d5960]",
			children: text
		})]
	});
}
//#endregion
export { AviRoute as component };
