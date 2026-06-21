import { readFileSync } from "node:fs";
import { describe, expect, it } from "bun:test";

describe("Moments in-progress destructive actions", () => {
  const routeSource = readFileSync(new URL("./in-progress.tsx", import.meta.url), "utf8");
  const textSource = readFileSync(new URL("../lib/moments-i18n.ts", import.meta.url), "utf8");

  it("confirms before deleting a Moment workspace", () => {
    expect(routeSource).toContain("window.confirm(ui.confirmDelete)");
    expect(routeSource).toContain("client.deleteMoment(moment._id)");
    expect(textSource).toContain("confirmDelete");
  });
});
