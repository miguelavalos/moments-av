import { a as AccountUserButton, n as SignedIn, r as SignedOut } from "./src-BT1bYzoz.js";
import { a as useMomentsShellLabels, f as AppShell, i as useMomentsProductConfig, l as momentsBrandAssets, m as useAppsAvLocale, o as useMomentsText, r as useMomentsNavLinks, t as localizedAppPath } from "./moments-i18n-DYJ5dSz9.js";
import { t as Card } from "./card-dEqfm8WK.js";
import { Navigate } from "@tanstack/react-router";
import { Fragment, jsx, jsxs } from "react/jsx-runtime";
import { ArrowRight, Film, Images, SlidersHorizontal, Sparkles } from "lucide-react";
//#region src/routes/index.tsx?tsr-split=component
function IndexRoute() {
	const text = useMomentsText();
	const locale = useAppsAvLocale();
	const navLinks = useMomentsNavLinks();
	const productConfig = useMomentsProductConfig();
	const shellLabels = useMomentsShellLabels();
	const homeIcons = [
		/* @__PURE__ */ jsx(Images, { className: "size-4" }),
		/* @__PURE__ */ jsx(SlidersHorizontal, { className: "size-4" }),
		/* @__PURE__ */ jsx(Film, { className: "size-4" })
	];
	return /* @__PURE__ */ jsxs(Fragment, { children: [/* @__PURE__ */ jsx(SignedOut, { children: /* @__PURE__ */ jsx(Navigate, { to: "/sign-in" }) }), /* @__PURE__ */ jsx(SignedIn, { children: /* @__PURE__ */ jsx(AppShell, {
		accountArea: /* @__PURE__ */ jsx(AccountUserButton, {}),
		footerLabels: text.footer,
		labels: shellLabels,
		navLinks,
		product: productConfig,
		children: /* @__PURE__ */ jsxs("section", {
			className: "grid gap-6 lg:grid-cols-[1fr_22rem]",
			children: [/* @__PURE__ */ jsxs(Card, {
				className: "moments-canvas gap-0 overflow-hidden rounded-[1.5rem] border-[#e5c1c7] p-6 py-6 shadow-lg shadow-[#7b233f]/8 sm:p-8 sm:py-8",
				children: [/* @__PURE__ */ jsxs("div", {
					className: "flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between",
					children: [/* @__PURE__ */ jsxs("div", { children: [/* @__PURE__ */ jsx("h1", {
						className: "max-w-2xl text-4xl font-semibold leading-tight text-[#20242e]",
						children: text.home.title
					}), /* @__PURE__ */ jsx("p", {
						className: "mt-4 max-w-2xl text-base leading-7 text-[#4d5563]",
						children: text.home.body
					})] }), /* @__PURE__ */ jsxs("a", {
						href: localizedAppPath("/create", locale),
						children: [text.home.cta, /* @__PURE__ */ jsx(ArrowRight, {
							className: "size-4",
							"aria-hidden": "true"
						})]
					})]
				}), /* @__PURE__ */ jsx("div", {
					className: "mt-8 grid gap-3 sm:grid-cols-3",
					children: text.home.items.map((item, index) => /* @__PURE__ */ jsx(NotebookItem, {
						icon: homeIcons[index],
						label: item.label,
						value: item.value
					}, item.label))
				})]
			}), /* @__PURE__ */ jsxs(Card, {
				className: "gap-0 overflow-hidden rounded-[1.5rem] border-[#e5c1c7] bg-[#20242e] p-0 text-white shadow-lg shadow-[#7b233f]/14",
				children: [/* @__PURE__ */ jsxs("div", {
					className: "p-5",
					children: [/* @__PURE__ */ jsxs("div", {
						className: "flex items-center gap-2 text-sm font-semibold text-[#f3b1bf]",
						children: [/* @__PURE__ */ jsx(Sparkles, {
							className: "size-4",
							"aria-hidden": "true"
						}), text.home.aviTitle]
					}), /* @__PURE__ */ jsx("ul", {
						className: "mt-4 flex flex-col gap-3 text-sm leading-6 text-white/74",
						children: text.home.aviBody.map((item) => /* @__PURE__ */ jsx("li", { children: item }, item))
					})]
				}), /* @__PURE__ */ jsx("img", {
					className: "mt-auto h-56 w-full object-cover object-bottom",
					src: momentsBrandAssets.onboarding,
					alt: ""
				})]
			})]
		})
	}) })] });
}
function NotebookItem({ icon, label, value }) {
	return /* @__PURE__ */ jsxs("div", {
		className: "rounded-2xl border border-[#e5c1c7] bg-[#fff8f3]/76 p-4 text-[#20242e]",
		children: [/* @__PURE__ */ jsxs("div", {
			className: "flex items-center gap-2 text-sm font-semibold",
			children: [/* @__PURE__ */ jsx("span", {
				className: "text-[#b94e70]",
				children: icon
			}), label]
		}), /* @__PURE__ */ jsx("p", {
			className: "mt-2 text-sm text-[#6d5960]",
			children: value
		})]
	});
}
//#endregion
export { IndexRoute as component };
