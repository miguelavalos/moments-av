import { a as AccountUserButton } from "./src-BT1bYzoz.js";
import { a as useMomentsShellLabels, f as AppShell, i as useMomentsProductConfig, l as momentsBrandAssets, o as useMomentsText, r as useMomentsNavLinks } from "./moments-i18n-DYJ5dSz9.js";
import { t as ProtectedRoute } from "./protected-route-ArOj3QAi.js";
import { t as Card } from "./card-dEqfm8WK.js";
import { t as Button } from "./button-B9bYYP8r.js";
import { jsx, jsxs } from "react/jsx-runtime";
import { Film, Images, SlidersHorizontal } from "lucide-react";
//#region src/routes/create.tsx?tsr-split=component
function CreateRoute() {
	const text = useMomentsText();
	const navLinks = useMomentsNavLinks();
	const productConfig = useMomentsProductConfig();
	const shellLabels = useMomentsShellLabels();
	const icons = [
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
			className: "grid gap-6 lg:grid-cols-[1fr_23rem]",
			children: [/* @__PURE__ */ jsxs(Card, {
				className: "moments-canvas gap-0 overflow-hidden rounded-[1.5rem] border-[#e5c1c7] p-6 py-6 text-[#20242e] shadow-lg shadow-[#7b233f]/8 sm:p-8 sm:py-8",
				children: [
					/* @__PURE__ */ jsxs("div", {
						className: "max-w-3xl",
						children: [/* @__PURE__ */ jsx("h1", {
							className: "text-4xl font-semibold leading-tight",
							children: text.create.title
						}), /* @__PURE__ */ jsx("p", {
							className: "mt-4 max-w-2xl text-base leading-7 text-[#4d5563]",
							children: text.create.body
						})]
					}),
					/* @__PURE__ */ jsx("div", {
						className: "mt-8 grid gap-4 md:grid-cols-3",
						children: text.create.flow.map((step, index) => /* @__PURE__ */ jsx(StepCard, {
							icon: icons[index],
							title: step.title,
							text: step.text
						}, step.title))
					}),
					/* @__PURE__ */ jsxs(Button, {
						className: "mt-8 w-fit rounded-full bg-[#7c2947] px-5 text-white hover:bg-[#963956]",
						children: [/* @__PURE__ */ jsx(Images, {
							className: "size-4",
							"aria-hidden": "true"
						}), text.create.cta]
					})
				]
			}), /* @__PURE__ */ jsx(Card, {
				className: "gap-0 overflow-hidden rounded-[1.5rem] border-[#e5c1c7] bg-[#20242e] p-0 text-white shadow-lg shadow-[#7b233f]/14",
				children: /* @__PURE__ */ jsx("img", {
					className: "h-72 w-full object-cover object-center lg:h-full",
					src: momentsBrandAssets.hero,
					alt: ""
				})
			})]
		})
	}) });
}
function StepCard({ icon, text, title }) {
	return /* @__PURE__ */ jsxs("div", {
		className: "rounded-2xl border border-[#e5c1c7] bg-[#fff8f3]/78 p-4",
		children: [/* @__PURE__ */ jsxs("div", {
			className: "flex items-center gap-2 text-sm font-semibold",
			children: [/* @__PURE__ */ jsx("span", {
				className: "text-[#b94e70]",
				children: icon
			}), title]
		}), /* @__PURE__ */ jsx("p", {
			className: "mt-3 text-sm leading-6 text-[#6d5960]",
			children: text
		})]
	});
}
//#endregion
export { CreateRoute as component };
