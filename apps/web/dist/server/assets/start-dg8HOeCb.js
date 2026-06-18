import { s as accountAvMiddleware } from "./src-BT1bYzoz.js";
import { n as createStart } from "../server.js";
//#region src/start.ts
var startInstance = createStart(() => ({ requestMiddleware: [accountAvMiddleware()] }));
//#endregion
export { startInstance };
