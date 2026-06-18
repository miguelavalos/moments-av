import { r as createMiddleware, t as getGlobalStartContext } from "../server.js";
import React, { createContext, useEffect, useMemo, useRef, useTransition } from "react";
import { ScriptOnce, useLocation, useNavigate, useParams } from "@tanstack/react-router";
import { Fragment, jsx, jsxs } from "react/jsx-runtime";
import { buildErrorThrower } from "@clerk/shared/error";
import { AuthStatus, constants, createClerkRequest, debugRequestState } from "@clerk/backend/internal";
import { getEnvVariable } from "@clerk/shared/getEnvVariable";
import { isTruthy } from "@clerk/shared/underscore";
import { apiUrlFromPublishableKey } from "@clerk/shared/apiUrlFromPublishableKey";
import { createClerkClient } from "@clerk/backend";
import { isAutomatedEnvironment, isDevelopmentEnvironment } from "@clerk/shared/utils";
import { createKeylessService, createNodeFileStorage, resolveKeysWithKeylessFallback } from "@clerk/shared/keyless";
import * as fs from "node:fs";
import * as path from "node:path";
import { isDevelopmentFromSecretKey } from "@clerk/shared/keys";
import { isHttpOrHttps, isProxyUrlRelative } from "@clerk/shared/proxy";
import { handleNetlifyCacheInDevInstance } from "@clerk/shared/netlifyCacheHandler";
import { InternalClerkProvider, setErrorThrowerOptions, useRoutingProps } from "@clerk/react/internal";
import { OrganizationList, OrganizationProfile, SignIn, SignUp, UserProfile } from "@clerk/react";
import { getToken } from "@clerk/shared/getToken";
//#region \0rolldown/runtime.js
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __exportAll = (all, no_symbols) => {
	let target = {};
	for (var name in all) __defProp(target, name, {
		get: all[name],
		enumerable: true
	});
	if (!no_symbols) __defProp(target, Symbol.toStringTag, { value: "Module" });
	return target;
};
var __copyProps = (to, from, except, desc) => {
	if (from && typeof from === "object" || typeof from === "function") for (var keys = __getOwnPropNames(from), i = 0, n = keys.length, key; i < n; i++) {
		key = keys[i];
		if (!__hasOwnProp.call(to, key) && key !== except) __defProp(to, key, {
			get: ((k) => from[k]).bind(null, key),
			enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable
		});
	}
	return to;
};
var __reExport = (target, mod, secondTarget) => (__copyProps(target, mod, "default"), secondTarget && __copyProps(secondTarget, mod, "default"));
//#endregion
//#region node_modules/@avalsys/account-av-web/src/account-api-client.ts
var AccountAvApiClient = class {
	baseUrl;
	appId;
	getToken;
	constructor(baseUrl, appId, getToken) {
		this.baseUrl = baseUrl;
		this.appId = appId;
		this.getToken = getToken;
	}
	async getMe() {
		return this.fetchJson("/v1/me");
	}
	async getAccess() {
		return this.fetchJson("/v1/me/access");
	}
	async getAppAccess(appId) {
		return (await this.getAccess()).apps.find((app) => app.appId === appId) ?? null;
	}
	async fetchJson(path) {
		const token = await this.getToken();
		const response = await fetch(`${this.baseUrl}${path}`, { headers: {
			"x-appsav-app-id": this.appId,
			...token ? { Authorization: `Bearer ${token}` } : {}
		} });
		if (!response.ok) throw new Error(`Account AV request failed: ${response.status}`);
		return response.json();
	}
};
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/utils/index.js
var isClient = () => typeof window !== "undefined";
var errorThrower = buildErrorThrower({ packageName: "@clerk/tanstack-react-start" });
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/utils/env.js
var getPublicEnvVariables = () => {
	const getValue = (name) => {
		return getEnvVariable(`VITE_${name}`) || getEnvVariable(name);
	};
	return {
		publishableKey: getValue("CLERK_PUBLISHABLE_KEY"),
		domain: getValue("CLERK_DOMAIN"),
		isSatellite: isTruthy(getValue("CLERK_IS_SATELLITE")),
		proxyUrl: getValue("CLERK_PROXY_URL"),
		signInUrl: getValue("CLERK_SIGN_IN_URL"),
		signUpUrl: getValue("CLERK_SIGN_UP_URL"),
		clerkJsUrl: getValue("CLERK_JS_URL") || getValue("CLERK_JS"),
		clerkJsVersion: getValue("CLERK_JS_VERSION"),
		clerkUIUrl: getValue("CLERK_UI_URL"),
		clerkUIVersion: getValue("CLERK_UI_VERSION"),
		prefetchUI: getValue("CLERK_PREFETCH_UI") === "false" ? false : void 0,
		telemetryDisabled: isTruthy(getValue("CLERK_TELEMETRY_DISABLED")),
		telemetryDebug: isTruthy(getValue("CLERK_TELEMETRY_DEBUG")),
		unsafeDisableDevelopmentModeConsoleWarning: isTruthy(getValue("CLERK_UNSAFE_DISABLE_DEVELOPMENT_MODE_CONSOLE_WARNING")),
		afterSignInUrl: getValue("CLERK_AFTER_SIGN_IN_URL"),
		afterSignUpUrl: getValue("CLERK_AFTER_SIGN_UP_URL"),
		newSubscriptionRedirectUrl: getValue("CLERK_CHECKOUT_CONTINUE_URL")
	};
};
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/server/constants.js
var commonEnvs = () => {
	const publicEnvs = getPublicEnvVariables();
	return {
		CLERK_JS_VERSION: publicEnvs.clerkJsVersion,
		CLERK_JS_URL: publicEnvs.clerkJsUrl,
		CLERK_UI_URL: publicEnvs.clerkUIUrl,
		CLERK_UI_VERSION: publicEnvs.clerkUIVersion,
		PREFETCH_UI: publicEnvs.prefetchUI,
		PUBLISHABLE_KEY: publicEnvs.publishableKey,
		DOMAIN: publicEnvs.domain,
		PROXY_URL: publicEnvs.proxyUrl,
		IS_SATELLITE: publicEnvs.isSatellite,
		SIGN_IN_URL: publicEnvs.signInUrl,
		SIGN_UP_URL: publicEnvs.signUpUrl,
		TELEMETRY_DISABLED: publicEnvs.telemetryDisabled,
		TELEMETRY_DEBUG: publicEnvs.telemetryDebug,
		API_VERSION: getEnvVariable("CLERK_API_VERSION") || "v1",
		SECRET_KEY: getEnvVariable("CLERK_SECRET_KEY"),
		MACHINE_SECRET_KEY: getEnvVariable("CLERK_MACHINE_SECRET_KEY"),
		ENCRYPTION_KEY: getEnvVariable("CLERK_ENCRYPTION_KEY"),
		CLERK_JWT_KEY: getEnvVariable("CLERK_JWT_KEY"),
		API_URL: getEnvVariable("CLERK_API_URL") || apiUrlFromPublishableKey(publicEnvs.publishableKey),
		SDK_METADATA: {
			name: "@clerk/tanstack-react-start",
			version: "1.4.4",
			environment: getEnvVariable("NODE_ENV")
		}
	};
};
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/server/clerkClient.js
var clerkClient = (options) => {
	const commonEnv = commonEnvs();
	return createClerkClient({
		secretKey: commonEnv.SECRET_KEY,
		machineSecretKey: commonEnv.MACHINE_SECRET_KEY,
		publishableKey: commonEnv.PUBLISHABLE_KEY,
		apiUrl: commonEnv.API_URL,
		apiVersion: commonEnv.API_VERSION,
		userAgent: `@clerk/tanstack-react-start@1.4.4`,
		proxyUrl: commonEnv.PROXY_URL,
		domain: commonEnv.DOMAIN,
		isSatellite: commonEnv.IS_SATELLITE,
		sdkMetadata: commonEnv.SDK_METADATA,
		telemetry: {
			disabled: commonEnv.TELEMETRY_DISABLED,
			debug: commonEnv.TELEMETRY_DEBUG
		},
		...options
	});
};
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/utils/feature-flags.js
var KEYLESS_DISABLED = isTruthy(getEnvVariable("VITE_CLERK_KEYLESS_DISABLED")) || isTruthy(getEnvVariable("CLERK_KEYLESS_DISABLED")) || false;
/**
* Whether keyless mode can be used in the current environment.
* Keyless mode is only available in development, when not explicitly disabled,
* and when not running in an automated/CI environment.
*
* To disable keyless mode, set either:
* - `VITE_CLERK_KEYLESS_DISABLED=1` (for Vite-based projects)
* - `CLERK_KEYLESS_DISABLED=1` (generic)
*/
var canUseKeyless = isDevelopmentEnvironment() && !isAutomatedEnvironment() && !KEYLESS_DISABLED;
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/server/keyless/fileStorage.js
function createFileStorage(options = {}) {
	const { cwd = () => process.cwd() } = options;
	return createNodeFileStorage(fs, path, {
		cwd,
		frameworkPackageName: "@clerk/tanstack-react-start"
	});
}
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/server/keyless/index.js
var keylessServiceInstance = null;
function keyless() {
	if (!keylessServiceInstance) keylessServiceInstance = createKeylessService({
		storage: createFileStorage(),
		api: {
			async createAccountlessApplication(requestHeaders, source) {
				try {
					return await clerkClient().__experimental_accountlessApplications.createAccountlessApplication({
						requestHeaders,
						source
					});
				} catch {
					return null;
				}
			},
			async completeOnboarding(requestHeaders, source) {
				try {
					return await clerkClient().__experimental_accountlessApplications.completeAccountlessApplicationOnboarding({
						requestHeaders,
						source
					});
				} catch {
					return null;
				}
			}
		},
		framework: "tanstack-react-start"
	});
	return keylessServiceInstance;
}
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/server/keyless/utils.js
/**
* Resolves Clerk keys, falling back to keyless mode in development if configured keys are missing.
*
* @param configuredPublishableKey - The publishable key from options or environment
* @param configuredSecretKey - The secret key from options or environment
* @returns The resolved keys (either configured or from keyless mode)
*/
function resolveKeysWithKeylessFallback$1(configuredPublishableKey, configuredSecretKey) {
	return resolveKeysWithKeylessFallback(configuredPublishableKey, configuredSecretKey, keyless(), canUseKeyless);
}
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/server/loadOptions.js
var loadOptions = (request, overrides = {}) => {
	const commonEnv = commonEnvs();
	const secretKey = overrides.secretKey || commonEnv.SECRET_KEY;
	const machineSecretKey = overrides.machineSecretKey || commonEnv.MACHINE_SECRET_KEY;
	const publishableKey = overrides.publishableKey || commonEnv.PUBLISHABLE_KEY;
	const jwtKey = overrides.jwtKey || commonEnv.CLERK_JWT_KEY;
	const apiUrl = getEnvVariable("CLERK_API_URL") || apiUrlFromPublishableKey(publishableKey);
	const domain = overrides.domain || commonEnv.DOMAIN;
	const isSatellite = overrides.isSatellite || commonEnv.IS_SATELLITE;
	const relativeOrAbsoluteProxyUrl = overrides.proxyUrl || commonEnv.PROXY_URL;
	const signInUrl = overrides.signInUrl || commonEnv.SIGN_IN_URL;
	const signUpUrl = overrides.signUpUrl || commonEnv.SIGN_UP_URL;
	const satelliteAutoSync = overrides.satelliteAutoSync;
	let proxyUrl;
	if (!!relativeOrAbsoluteProxyUrl && isProxyUrlRelative(relativeOrAbsoluteProxyUrl)) proxyUrl = new URL(relativeOrAbsoluteProxyUrl, request.clerkUrl).toString();
	else proxyUrl = relativeOrAbsoluteProxyUrl;
	if (!secretKey && !canUseKeyless) throw errorThrower.throw("Clerk: no secret key provided");
	if (isSatellite && !proxyUrl && !domain) throw errorThrower.throw("Clerk: satellite mode requires a proxy URL or domain");
	if (isSatellite && secretKey && !isHttpOrHttps(signInUrl) && isDevelopmentFromSecretKey(secretKey)) throw errorThrower.throw("Clerk: satellite mode requires a sign-in URL in production");
	return {
		...overrides,
		secretKey,
		machineSecretKey,
		publishableKey,
		jwtKey,
		apiUrl,
		domain,
		isSatellite,
		proxyUrl,
		signInUrl,
		signUpUrl,
		satelliteAutoSync
	};
};
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/server/utils/index.js
/**
* Wraps obscured clerk internals with a readable `clerkState` key.
* This is intended to be passed into <ClerkProvider>
*
* @internal
*/
var wrapWithClerkState = (data) => {
	return { __internal_clerk_state: { ...data } };
};
/**
* Returns the prefetchUI config from environment variables.
*
* @internal
*/
function getPrefetchUIFromEnv() {
	if (getEnvVariable("CLERK_PREFETCH_UI") === "false") return false;
}
function getUnsafeDisableDevelopmentModeConsoleWarningFromEnv() {
	const value = getEnvVariable("VITE_CLERK_UNSAFE_DISABLE_DEVELOPMENT_MODE_CONSOLE_WARNING") || getEnvVariable("CLERK_UNSAFE_DISABLE_DEVELOPMENT_MODE_CONSOLE_WARNING");
	return value ? isTruthy(value) : void 0;
}
function getResponseClerkState(requestState, additionalStateOptions = {}) {
	const { reason, message, isSignedIn, ...rest } = requestState;
	return wrapWithClerkState({
		__clerk_ssr_state: rest.toAuth(),
		__publishableKey: requestState.publishableKey,
		__proxyUrl: requestState.proxyUrl,
		__domain: requestState.domain,
		__isSatellite: requestState.isSatellite,
		__signInUrl: requestState.signInUrl,
		__signUpUrl: requestState.signUpUrl,
		__afterSignInUrl: requestState.afterSignInUrl,
		__afterSignUpUrl: requestState.afterSignUpUrl,
		__clerk_debug: debugRequestState(requestState),
		__clerkJSUrl: getEnvVariable("CLERK_JS") || getEnvVariable("CLERK_JS_URL"),
		__clerkJSVersion: getEnvVariable("CLERK_JS_VERSION"),
		__clerkUIUrl: getEnvVariable("CLERK_UI_URL"),
		__clerkUIVersion: getEnvVariable("CLERK_UI_VERSION"),
		__prefetchUI: getPrefetchUIFromEnv(),
		__telemetryDisabled: isTruthy(getEnvVariable("CLERK_TELEMETRY_DISABLED")),
		__telemetryDebug: isTruthy(getEnvVariable("CLERK_TELEMETRY_DEBUG")),
		__unsafeDisableDevelopmentModeConsoleWarning: getUnsafeDisableDevelopmentModeConsoleWarningFromEnv(),
		__signInForceRedirectUrl: additionalStateOptions.signInForceRedirectUrl || getEnvVariable("CLERK_SIGN_IN_FORCE_REDIRECT_URL") || "",
		__signUpForceRedirectUrl: additionalStateOptions.signUpForceRedirectUrl || getEnvVariable("CLERK_SIGN_UP_FORCE_REDIRECT_URL") || "",
		__signInFallbackRedirectUrl: additionalStateOptions.signInFallbackRedirectUrl || getEnvVariable("CLERK_SIGN_IN_FALLBACK_REDIRECT_URL") || "",
		__signUpFallbackRedirectUrl: additionalStateOptions.signUpFallbackRedirectUrl || getEnvVariable("CLERK_SIGN_UP_FALLBACK_REDIRECT_URL") || ""
	});
}
/**
* Patches request to avoid duplex issues with unidici
* For more information, see:
* https://github.com/nodejs/node/issues/46221
* https://github.com/whatwg/fetch/pull/1457
* @internal
*/
var patchRequest = (request) => {
	const clonedRequest = new Request(request.url, {
		headers: request.headers,
		method: request.method,
		redirect: request.redirect,
		cache: request.cache
	});
	if (clonedRequest.method !== "GET" && clonedRequest.body !== null && !("duplex" in clonedRequest)) clonedRequest.duplex = "half";
	return clonedRequest;
};
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/server/clerkMiddleware.js
var clerkMiddleware = (options) => {
	return createMiddleware().server(async ({ request, next }) => {
		const clerkRequest = createClerkRequest(patchRequest(request));
		const resolvedOptions = typeof options === "function" ? await options({ url: clerkRequest.clerkUrl }) : options;
		const loadedOptions = loadOptions(clerkRequest, {
			...resolvedOptions,
			publishableKey: resolvedOptions?.publishableKey,
			secretKey: resolvedOptions?.secretKey
		});
		const { publishableKey, secretKey, claimUrl: keylessClaimUrl, apiKeysUrl: keylessApiKeysUrl } = await resolveKeysWithKeylessFallback$1(loadedOptions.publishableKey, loadedOptions.secretKey);
		if (publishableKey) loadedOptions.publishableKey = publishableKey;
		if (secretKey) loadedOptions.secretKey = secretKey;
		const requestState = await clerkClient().authenticateRequest(clerkRequest, {
			...loadedOptions,
			acceptsToken: "any"
		});
		const locationHeader = requestState.headers.get(constants.Headers.Location);
		if (locationHeader) {
			handleNetlifyCacheInDevInstance({
				locationHeader,
				requestStateHeaders: requestState.headers,
				publishableKey: requestState.publishableKey
			});
			throw new Response(null, {
				status: 307,
				headers: requestState.headers
			});
		}
		if (requestState.status === AuthStatus.Handshake) throw new Error("Clerk: handshake status without redirect");
		const clerkInitialState = getResponseClerkState(requestState, loadedOptions);
		if (canUseKeyless && keylessClaimUrl) clerkInitialState.__internal_clerk_state = {
			...clerkInitialState.__internal_clerk_state,
			__keylessClaimUrl: keylessClaimUrl,
			__keylessApiKeysUrl: keylessApiKeysUrl
		};
		const result = await next({ context: {
			clerkInitialState,
			auth: (opts) => requestState.toAuth(opts)
		} });
		if (requestState.headers) requestState.headers.forEach((value, key) => {
			result.response.headers.append(key, value);
		});
		return result;
	});
};
//#endregion
//#region node_modules/@avalsys/account-av-web/src/account-av-middleware.ts
function accountAvMiddleware() {
	return clerkMiddleware({
		publishableKey: process.env?.CLERK_PUBLISHABLE_KEY ?? "pk_test_bGVnaWJsZS1jcmF5ZmlzaC01OC5jbGVyay5hY2NvdW50cy5kZXYk",
		secretKey: process.env?.CLERK_SECRET_KEY
	});
}
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/client/OptionsContext.js
var ClerkOptionsCtx = React.createContext(void 0);
ClerkOptionsCtx.displayName = "ClerkOptionsCtx";
var ClerkOptionsProvider = (props) => {
	const { children, options } = props;
	return /* @__PURE__ */ jsx(ClerkOptionsCtx.Provider, {
		value: { value: options },
		children
	});
};
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/client/useAwaitableNavigate.js
var useAwaitableNavigate = () => {
	const navigate = useNavigate();
	const location = useLocation();
	const resolveFunctionsRef = React.useRef([]);
	const resolveAll = () => {
		resolveFunctionsRef.current.forEach((resolve) => resolve());
		resolveFunctionsRef.current.splice(0, resolveFunctionsRef.current.length);
	};
	const [_, startTransition] = useTransition();
	React.useEffect(() => {
		resolveAll();
	}, [location]);
	return (options) => {
		return new Promise((res) => {
			startTransition(() => {
				resolveFunctionsRef.current.push(res);
				res(navigate(options));
			});
		});
	};
};
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/client/utils.js
var pickFromClerkInitState = (clerkInitState) => {
	const { __clerk_ssr_state, __publishableKey, __proxyUrl, __domain, __isSatellite, __signInUrl, __signUpUrl, __clerkJSUrl, __clerkJSVersion, __clerkUIUrl, __clerkUIVersion, __telemetryDisabled, __telemetryDebug, __unsafeDisableDevelopmentModeConsoleWarning, __signInForceRedirectUrl, __signUpForceRedirectUrl, __signInFallbackRedirectUrl, __signUpFallbackRedirectUrl, __keylessClaimUrl, __keylessApiKeysUrl, __prefetchUI } = clerkInitState || {};
	return {
		clerkSsrState: __clerk_ssr_state,
		publishableKey: __publishableKey,
		proxyUrl: __proxyUrl,
		domain: __domain,
		isSatellite: !!__isSatellite,
		signInUrl: __signInUrl,
		signUpUrl: __signUpUrl,
		__internal_clerkJSUrl: __clerkJSUrl,
		__internal_clerkJSVersion: __clerkJSVersion,
		__internal_clerkUIUrl: __clerkUIUrl,
		__internal_clerkUIVersion: __clerkUIVersion,
		prefetchUI: __prefetchUI,
		telemetry: {
			disabled: __telemetryDisabled,
			debug: __telemetryDebug
		},
		unsafe_disableDevelopmentModeConsoleWarning: __unsafeDisableDevelopmentModeConsoleWarning,
		signInForceRedirectUrl: __signInForceRedirectUrl,
		signUpForceRedirectUrl: __signUpForceRedirectUrl,
		signInFallbackRedirectUrl: __signInFallbackRedirectUrl,
		signUpFallbackRedirectUrl: __signUpFallbackRedirectUrl,
		__keylessClaimUrl,
		__keylessApiKeysUrl
	};
};
var mergeWithPublicEnvs = (restInitState) => {
	const envVars = getPublicEnvVariables();
	return {
		...restInitState,
		publishableKey: restInitState.publishableKey || envVars.publishableKey,
		domain: restInitState.domain || envVars.domain,
		isSatellite: restInitState.isSatellite || envVars.isSatellite,
		signInUrl: restInitState.signInUrl || envVars.signInUrl,
		signUpUrl: restInitState.signUpUrl || envVars.signUpUrl,
		__internal_clerkJSUrl: restInitState.__internal_clerkJSUrl || envVars.clerkJsUrl,
		__internal_clerkJSVersion: restInitState.__internal_clerkJSVersion || envVars.clerkJsVersion,
		__internal_clerkUIUrl: restInitState.__internal_clerkUIUrl || envVars.clerkUIUrl,
		__internal_clerkUIVersion: restInitState.__internal_clerkUIVersion || envVars.clerkUIVersion,
		signInForceRedirectUrl: restInitState.signInForceRedirectUrl,
		prefetchUI: restInitState.prefetchUI ?? envVars.prefetchUI,
		unsafe_disableDevelopmentModeConsoleWarning: restInitState.unsafe_disableDevelopmentModeConsoleWarning ?? envVars.unsafeDisableDevelopmentModeConsoleWarning
	};
};
/**
* Parses a URL string into TanStack Router navigation options.
* TanStack Router doesn't parse query strings from the `to` parameter,
* so we need to extract pathname, search params, and hash separately.
*/
function parseUrlForNavigation(to, baseUrl) {
	const url = new URL(to, baseUrl);
	const searchParams = Object.fromEntries(url.searchParams);
	return {
		to: url.pathname,
		search: Object.keys(searchParams).length > 0 ? searchParams : void 0,
		hash: url.hash ? url.hash.slice(1) : void 0
	};
}
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/client/ClerkProvider.js
var SDK_METADATA = {
	name: "@clerk/tanstack-react-start",
	version: "1.4.4"
};
var awaitableNavigateRef = { current: void 0 };
function ClerkProvider({ children, ...providerProps }) {
	const awaitableNavigate = useAwaitableNavigate();
	const clerkInitialState = getGlobalStartContext()?.clerkInitialState ?? {};
	useEffect(() => {
		awaitableNavigateRef.current = awaitableNavigate;
	}, [awaitableNavigate]);
	const { clerkSsrState, __keylessClaimUrl, __keylessApiKeysUrl, ...restInitState } = pickFromClerkInitState((isClient() ? window.__clerk_init_state : clerkInitialState)?.__internal_clerk_state);
	const mergedProps = {
		...mergeWithPublicEnvs(restInitState),
		...providerProps
	};
	const keylessProps = __keylessClaimUrl ? {
		__internal_keyless_claimKeylessApplicationUrl: __keylessClaimUrl,
		__internal_keyless_copyInstanceKeysUrl: __keylessApiKeysUrl
	} : {};
	return /* @__PURE__ */ jsxs(Fragment, { children: [/* @__PURE__ */ jsx(ScriptOnce, { children: `window.__clerk_init_state = ${JSON.stringify(clerkInitialState)};` }), /* @__PURE__ */ jsx(ClerkOptionsProvider, {
		options: mergedProps,
		children: /* @__PURE__ */ jsx(InternalClerkProvider, {
			initialState: clerkSsrState,
			sdkMetadata: SDK_METADATA,
			routerPush: (to) => {
				const { search, hash, ...rest } = parseUrlForNavigation(to, window.location.origin);
				return awaitableNavigateRef.current?.({
					...rest,
					search,
					hash,
					replace: false
				});
			},
			routerReplace: (to) => {
				const { search, hash, ...rest } = parseUrlForNavigation(to, window.location.origin);
				return awaitableNavigateRef.current?.({
					...rest,
					search,
					hash,
					replace: true
				});
			},
			...mergedProps,
			...keylessProps,
			children
		})
	})] });
}
ClerkProvider.displayName = "ClerkProvider";
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/client/uiComponents.js
var usePathnameWithoutSplatRouteParams = () => {
	const { _splat } = useParams({ strict: false });
	const { pathname } = useLocation();
	const splatRouteParam = _splat || "";
	return useRef(`/${pathname.replace(splatRouteParam, "").replace(/\/$/, "").replace(/^\//, "").trim()}`).current;
};
var UserProfile$1 = Object.assign((props) => {
	return /* @__PURE__ */ jsx(UserProfile, { ...useRoutingProps("UserProfile", props, { path: usePathnameWithoutSplatRouteParams() }) });
}, { ...UserProfile });
var OrganizationProfile$1 = Object.assign((props) => {
	return /* @__PURE__ */ jsx(OrganizationProfile, { ...useRoutingProps("OrganizationProfile", props, { path: usePathnameWithoutSplatRouteParams() }) });
}, { ...OrganizationProfile });
var OrganizationList$1 = Object.assign((props) => {
	return /* @__PURE__ */ jsx(OrganizationList, { ...useRoutingProps("OrganizationList", props, { path: usePathnameWithoutSplatRouteParams() }) });
}, { ...OrganizationList });
var SignIn$1 = (props) => {
	return /* @__PURE__ */ jsx(SignIn, { ...useRoutingProps("SignIn", props, { path: usePathnameWithoutSplatRouteParams() }) });
};
var SignUp$1 = (props) => {
	return /* @__PURE__ */ jsx(SignUp, { ...useRoutingProps("SignUp", props, { path: usePathnameWithoutSplatRouteParams() }) });
};
//#endregion
//#region node_modules/@clerk/tanstack-react-start/dist/index.js
var dist_exports = /* @__PURE__ */ __exportAll({
	ClerkProvider: () => ClerkProvider,
	OrganizationList: () => OrganizationList$1,
	OrganizationProfile: () => OrganizationProfile$1,
	SignIn: () => SignIn$1,
	SignUp: () => SignUp$1,
	UserProfile: () => UserProfile$1,
	getToken: () => getToken
});
import * as import__clerk_react from "@clerk/react";
__reExport(dist_exports, import__clerk_react);
setErrorThrowerOptions({ packageName: "@clerk/tanstack-react-start" });
//#endregion
//#region node_modules/@avalsys/account-av-web/src/account-av-provider.tsx
var AccountAvContext = createContext(null);
function AccountAvProvider({ accountApiBaseUrl, afterSignOutUrl, appDisplayName, appId, children, localization, publishableKey, signInUrl, signUpUrl }) {
	const defaultLocalization = appDisplayName ? { signIn: { start: {
		title: `Sign in to ${appDisplayName}`,
		subtitle: "Welcome back. Please sign in to continue."
	} } } : void 0;
	return /* @__PURE__ */ jsx(ClerkProvider, {
		afterSignOutUrl,
		localization: localization ?? defaultLocalization,
		publishableKey,
		signInUrl,
		signUpUrl,
		children: /* @__PURE__ */ jsx(AccountAvRuntimeProvider, {
			accountApiBaseUrl,
			appId,
			children
		})
	});
}
function AccountAvRuntimeProvider({ accountApiBaseUrl, appId, children }) {
	const { getToken } = (0, dist_exports.useAuth)();
	const value = useMemo(() => {
		const tokenProvider = () => getToken();
		return {
			client: new AccountAvApiClient(accountApiBaseUrl, appId, tokenProvider),
			getToken: tokenProvider
		};
	}, [
		accountApiBaseUrl,
		appId,
		getToken
	]);
	return /* @__PURE__ */ jsx(AccountAvContext.Provider, {
		value,
		children
	});
}
function useAccountSession() {
	const auth = (0, dist_exports.useAuth)();
	return {
		isLoaded: auth.isLoaded,
		isSignedIn: auth.isSignedIn,
		sessionId: auth.sessionId,
		userId: auth.userId
	};
}
//#endregion
//#region node_modules/@avalsys/account-av-web/src/auth-actions.tsx
function AccountSignIn({ fallbackRedirectUrl = "/", path, signUpUrl }) {
	return /* @__PURE__ */ jsx(SignIn$1, {
		fallbackRedirectUrl,
		path,
		routing: "path",
		signUpUrl
	});
}
function AccountUserButton() {
	return /* @__PURE__ */ jsx(dist_exports.UserButton, {});
}
//#endregion
//#region node_modules/@avalsys/account-av-web/src/auth-states.tsx
function AuthLoading({ children }) {
	return !useAccountSession().isLoaded ? /* @__PURE__ */ jsx(Fragment, { children }) : null;
}
function SignedIn({ children }) {
	const session = useAccountSession();
	return session.isLoaded && session.isSignedIn ? /* @__PURE__ */ jsx(Fragment, { children }) : null;
}
function SignedOut({ children }) {
	const session = useAccountSession();
	return session.isLoaded && !session.isSignedIn ? /* @__PURE__ */ jsx(Fragment, { children }) : null;
}
//#endregion
export { AccountUserButton as a, AccountSignIn as i, SignedIn as n, AccountAvProvider as o, SignedOut as r, accountAvMiddleware as s, AuthLoading as t };
