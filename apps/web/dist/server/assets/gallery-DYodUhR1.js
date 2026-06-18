import { a as AccountUserButton } from "./src-BT1bYzoz.js";
import { a as useMomentsShellLabels, f as AppShell, i as useMomentsProductConfig, o as useMomentsText, r as useMomentsNavLinks } from "./moments-i18n-DYJ5dSz9.js";
import { t as ProtectedRoute } from "./protected-route-ArOj3QAi.js";
import { t as Card } from "./card-dEqfm8WK.js";
import { jsx, jsxs } from "react/jsx-runtime";
import { Download, Film, History, PlayCircle } from "lucide-react";
//#region src/routes/gallery.tsx?tsr-split=component
function GalleryRoute() {
	const text = useMomentsText();
	const navLinks = useMomentsNavLinks();
	const productConfig = useMomentsProductConfig();
	const shellLabels = useMomentsShellLabels();
	const icons = [
		/* @__PURE__ */ jsx(PlayCircle, { className: "size-4" }),
		/* @__PURE__ */ jsx(Download, { className: "size-4" }),
		/* @__PURE__ */ jsx(History, { className: "size-4" })
	];
	return /* @__PURE__ */ jsx(ProtectedRoute, { children: /* @__PURE__ */ jsx(AppShell, {
		accountArea: /* @__PURE__ */ jsx(AccountUserButton, {}),
		footerLabels: text.footer,
		labels: shellLabels,
		navLinks,
		product: productConfig,
		children: /* @__PURE__ */ jsxs("section", {
			className: "grid gap-6 lg:grid-cols-[1fr_22rem]",
			children: [/* @__PURE__ */ jsxs(Card, {
				className: "moments-canvas gap-0 rounded-[1.5rem] border-[#e5c1c7] p-6 py-6 text-[#20242e] shadow-lg shadow-[#7b233f]/8 sm:p-8 sm:py-8",
				children: [
					/* @__PURE__ */ jsx("p", {
						className: "text-sm font-semibold uppercase tracking-[0.18em] text-[#b94e70]",
						children: text.gallery.kicker
					}),
					/* @__PURE__ */ jsx("h1", {
						className: "mt-4 max-w-3xl text-4xl font-semibold leading-tight",
						children: text.gallery.title
					}),
					/* @__PURE__ */ jsx("p", {
						className: "mt-4 max-w-2xl text-base leading-7 text-[#4d5563]",
						children: text.gallery.body
					}),
					/* @__PURE__ */ jsx("div", {
						className: "mt-8 flex flex-wrap gap-2",
						children: text.gallery.filters.map((filter) => /* @__PURE__ */ jsx("span", {
							className: "rounded-full border border-[#e5c1c7] bg-[#fff8f3]/80 px-3 py-1 text-sm font-medium text-[#6d5960]",
							children: filter
						}, filter))
					}),
					/* @__PURE__ */ jsxs("div", {
						className: "mt-8 rounded-2xl border border-dashed border-[#d3aab2] bg-[#fff8f3]/70 p-6 text-center",
						children: [
							/* @__PURE__ */ jsx(Film, {
								className: "mx-auto size-8 text-[#b94e70]",
								"aria-hidden": "true"
							}),
							/* @__PURE__ */ jsx("h2", {
								className: "mt-4 text-xl font-semibold",
								children: text.gallery.emptyTitle
							}),
							/* @__PURE__ */ jsx("p", {
								className: "mx-auto mt-2 max-w-md text-sm leading-6 text-[#6d5960]",
								children: text.gallery.emptyBody
							})
						]
					})
				]
			}), /* @__PURE__ */ jsx("div", {
				className: "grid gap-4",
				children: text.gallery.hints.map((hint, index) => /* @__PURE__ */ jsx(HintCard, {
					icon: icons[index],
					title: hint.title,
					text: hint.text
				}, hint.title))
			})]
		})
	}) });
}
function HintCard({ icon, text, title }) {
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
export { GalleryRoute as component };
