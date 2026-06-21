#!/usr/bin/env node

import { runSharedWebSmokeQa } from "../../../../apps-av/web/scripts/shared-web-smoke-qa.mjs";

const result = await runSharedWebSmokeQa({
  baseUrl: process.env.MOMENTSAV_WEB_QA_BASE_URL ?? "http://localhost:5195",
  guestCopyPattern: /\b(guest-mode|invitado|invitada|convidat|convidada|gastmodus)\b/i,
  expectations: {
    ca: {
      protectedTitle: "Porta els teus projectes de records amb tu",
      publicCopy: "Fes un video de record",
      signInCopy: "Inicia sessio",
      signInRouteCopy: "Inicia sessio per mantenir"
    },
    de: {
      protectedTitle: "Nimm deine Erinnerungsprojekte mit",
      publicCopy: "Mache aus wichtigen Momenten",
      signInCopy: "Anmelden",
      signInRouteCopy: "Melde dich an"
    },
    en: {
      protectedTitle: "Keep your memory projects with you",
      publicCopy: "Make a memory video",
      signInCopy: "Sign in",
      signInRouteCopy: "Sign in to keep"
    },
    es: {
      protectedTitle: "Lleva tus proyectos de recuerdos contigo",
      publicCopy: "Haz un video de recuerdo",
      signInCopy: "Iniciar sesion",
      signInRouteCopy: "Inicia sesion para mantener"
    },
    fr: {
      protectedTitle: "Gardez vos projets souvenirs avec vous",
      publicCopy: "Creez une video souvenir",
      signInCopy: "Se connecter",
      signInRouteCopy: "Connectez-vous pour garder"
    }
  },
  name: "Moments AV",
  ownRoutePrefixes: ["/", "/create", "/in-progress", "/gallery", "/avi", "/sign-in"],
  productIdentity: "Moments AV",
  routes: ["/", "/sign-in", "/create", "/in-progress", "/gallery", "/avi"],
  signInRoutes: ["/sign-in"]
});

if (!result.passed) {
  process.exit(1);
}
