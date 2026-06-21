import { useMemo } from "react";
import { useAppsAvLocale, type AppsAvLocale, type AppsAvProductConfig, type AppsAvProductLink } from "@avalsys/apps-av-web";
import { caES } from "@clerk/localizations/ca-ES";
import { deDE } from "@clerk/localizations/de-DE";
import { enUS } from "@clerk/localizations/en-US";
import { esES } from "@clerk/localizations/es-ES";
import { frFR } from "@clerk/localizations/fr-FR";
import { momentsProductConfig } from "@/lib/moments-config";

const en = {
  account: {
    signInTitle: "Sign in to Moments AV",
    signInSubtitle: "Welcome back. Sign in to keep your memory projects connected."
  },
  avi: {
    body: "Avi helps shape selected photos and clips into a private story: structure, tone, pacing, and the next step stay clear before final video creation.",
    cards: [
      { title: "Shape the story", text: "Avi keeps the selected moments organized around the template and occasion." },
      { title: "Tune the mood", text: "Style, length, and warmth stay visible so the video feels personal before rendering." },
      { title: "Prepare final video", text: "The final review flow keeps control with you before credits are used and the video is created." }
    ],
    createCta: "Create a moment",
    galleryCta: "Open gallery",
    title: "A guided way to turn moments into a memory video."
  },
  config: {
    body: "Run the web app through the Varlock wrapper so Account AV configuration is available. Web access starts with sign-in.",
    eyebrow: "Configuration required",
    title: "Moments AV Web needs Clerk configuration."
  },
  create: {
    body: "Choose selected photos and clips, pick a story format, adjust mood and length, then review the memory before creating the final video.",
    cta: "Start with selected media",
    flow: [
      { title: "Choose moments", text: "Use only the photos and clips selected for this project." },
      { title: "Edit options", text: "Pick the occasion, mood, visual look, and length that fit the story." },
      { title: "Review and create", text: "Confirm credits, review the plan, and create the final video." }
    ],
    title: "Create a private memory video."
  },
  createUi: {
    confirm: "Confirm",
    confirmFinalVideo: "Confirm final video",
    creatingWorkspace: "Creating workspace...",
    details: "Details",
    duration: "Duration",
    finalVideoQueued: "Final video queued",
    finalVideoCreationConfirmed: "Final video creation confirmed. Follow progress in In Progress, then download when available and finish to Gallery.",
    flowStopped: "Create flow stopped.",
    look: "Look",
    media: "Media",
    mediaUse: "Media use",
    mood: "Mood",
    noBrowserMedia: "No browser media selected.",
    notChecked: "Not checked",
    notPlanned: "Not planned",
    occasion: "Occasion",
    prepareStoryAndCost: "Prepare story and cost",
    preparingUploads: "Preparing uploads...",
    renderPlan: "Render plan",
    renderPlanReady: "Render plan ready. Confirm once to create the final video.",
    selectMediaToStart: "Select media to start.",
    selectedMedia: "Selected media",
    setup: "Setup",
    story: "Story",
    item: "item",
    items: "items",
    waitingForConfirmation: "Waiting for explicit confirmation"
  },
  aviDashboard: {
    activeHeadline: "Avi is ready to continue your active Moment.",
    activeText: "Continue from In Progress to inspect media, story scenes, render jobs, artifacts, and finish into Gallery when the video is ready.",
    creditsActive: "Your account is active. The render plan still decides the credit cost before final video creation.",
    creditsBlocked: "Avi blocks final video creation when the render plan reports insufficient credits.",
    creditsTitle: "Credits",
    create: "Create",
    galleryLoading: "Gallery state is loading from the cloud projection.",
    galleryReady: "Gallery Moments with remote metadata.",
    galleryTitle: "Gallery",
    inProgressLoading: "Realtime state is loading from the cloud projection.",
    inProgressReady: "active Moments available to continue.",
    inProgressTitle: "In Progress",
    newHeadline: "Avi is ready to shape a new memory video.",
    newText: "Start with selected media. The render plan will decide cost and blockers before final confirmation.",
    openGallery: "Open gallery",
    continue: "Continue",
    readyGalleryHeadline: "Avi found finished Moments in your Gallery.",
    readyGalleryText: "Open Gallery to prepare a download. The cloud record stays separate from this browser's local file availability.",
    proNewText: "Choose browser media, upload it to the workspace, ask for a story plan, then confirm final video creation once."
  },
  footer: {
    deleteAccount: "Delete account",
    language: "Language",
    privacy: "Privacy",
    support: "Support",
    terms: "Terms"
  },
  gallery: {
    body: "Finished Moments stay visible from your signed-in account. Download availability and local files are shown separately.",
    emptyBody: "Create a memory video and its Gallery metadata will appear here when it is ready.",
    emptyTitle: "Your gallery is ready for the first memory.",
    filters: ["All", "Rendering", "Ready", "Available"],
    hints: [
      { title: "Review", text: "Keep the story visible before you save or share the result." },
      { title: "Download", text: "Download appears only when a remote artifact is available." },
      { title: "History", text: "Completed Moments stay tied to the account even when this browser has no local file." }
    ],
    kicker: "Gallery",
    title: "Your memory videos, gathered in one place."
  },
  galleryUi: {
    artifact: "Artifact",
    convexMissingBody: "Run the preview Varlock wrapper so VITE_MOMENTSAV_CONVEX_URL points at the cloud dev/preview deployment.",
    convexMissingTitle: "Convex cloud URL missing",
    credits: "Credits",
    downloadFailed: "The prepared download did not complete.",
    downloadReady: "Remote download metadata is available. This browser has no saved local file until you download it here.",
    downloaded: "Downloaded in this browser session. The Gallery cloud record remains visible even if this browser later loses the local file.",
    duration: "Duration",
    galleryLoadingBody: "Opening a backend-issued realtime session and subscribing to Gallery Moments.",
    galleryLoadingTitle: "Loading gallery",
    galleryUnavailableTitle: "Gallery unavailable",
    media: "Media",
    missing: "missing",
    noArtifact: "Gallery metadata exists, but no final artifact is currently projected for download.",
    prepareDownload: "Prepare download",
    refreshNeeded: "The cloud record is visible, but this artifact may need backend refresh before download.",
    waitingForReady: "Final artifact metadata is present, but the backend has not marked it ready for download."
  },
  inProgressUi: {
    artifacts: "Artifacts",
    body: "Active Moments recover here from the cloud projection.",
    continueInCreate: "Continue in Create",
    delete: "Delete",
    confirmDelete: "Delete this Moment, including source media and generated artifacts?",
    deleteSent: "Delete command sent. Source media and generated artifacts are requested for deletion.",
    loadingMoments: "Loading active Moments.",
    loadingWorkspace: "Loading workspace detail.",
    media: "Media",
    missingConfig: "Convex cloud URL is not configured for this preview session.",
    noActive: "No active Moments are projected right now.",
    noRecords: "No records projected.",
    rename: "Rename",
    renameSent: "Rename sent to workspace command API.",
    renderJobs: "Render jobs",
    selectMoment: "Select an active Moment to inspect workspace state.",
    storyScenes: "Story scenes",
    title: "In Progress"
  },
  home: {
    aviBody: [
      "Turn a selected group of photos and clips into a clear story.",
      "Keep tone, length, and style visible before final render.",
      "Return to finished Moments from Gallery."
    ],
    aviTitle: "Avi shapes the story",
    body: "Create private memory videos from selected photos and clips, review them carefully, and finish them into Gallery when they are ready.",
    cta: "Create video",
    items: [
      { label: "Selected media", value: "Start from moments you choose" },
      { label: "Story options", value: "Adjust template, mood, look, and length" },
      { label: "Gallery", value: "Review completed Moments" }
    ],
    title: "Make a memory video from the moments that matter."
  },
  login: {
    aviGuidance: "Avi guidance",
    cardBody: "Move from chosen media to story options, review, final video creation, and Gallery without losing context.",
    cardTitle: "A calm creation flow",
    cta: "Sign in",
    heroBody: "Sign in to create private memory videos, keep projects connected, and let Avi help shape the story before final video creation.",
    heroTitle: "Your memories, shaped into a video with care.",
    intro: "Bring selected photos and clips into a guided flow for birthdays, celebrations, trips, milestones, and small personal stories.",
    mapBody: "The web experience carries over the iOS onboarding idea: warm memory visuals, a guided creation path, and Avi close enough to help without taking over.",
    mapTitle: "A guided path from selected moments to Gallery.",
    notebook: "Memory projects",
    search: "Selected media"
  },
  nav: {
    avi: "Avi",
    aviLabel: "Open Avi guidance",
    create: "Create",
    createLabel: "Create memory video",
    gallery: "Gallery",
    galleryLabel: "Open Moments AV gallery",
    home: "Home",
    homeLabel: "Moments AV home",
    mobileNavigation: "Mobile navigation",
    openNavigation: "Open navigation",
    primaryNavigation: "Primary navigation"
  },
  protected: {
    body: "Sign in to create private memory videos, review projects, and keep Avi guidance connected with your account.",
    cta: "Sign in",
    title: "Keep your memory projects with you."
  },
  signIn: {
    aviPanelBody: "Avi helps keep the story warm, clear, and ready for review.",
    body: "Sign in to keep selected media, creation options, render status, and Gallery metadata connected with your AV account.",
    continue: "Continue",
    signedIn: "You are signed in.",
    title: "Moments AV is ready for your next memory."
  }
};

type MomentsText = typeof en;

const translations: Record<AppsAvLocale, MomentsText> = {
  en,
  es: {
    account: { signInTitle: "Inicia sesión en Moments AV", signInSubtitle: "Vuelve para mantener conectados tus proyectos de recuerdos." },
    avi: {
      body: "Avi ayuda a convertir las fotos y clips seleccionados en una historia privada: estructura, tono, ritmo y siguiente paso permanecen claros antes de crear el video final.",
      cards: [
        { title: "Dar forma a la historia", text: "Avi mantiene los momentos elegidos organizados según la plantilla y la ocasión." },
        { title: "Ajustar el ambiente", text: "Estilo, duración y calidez permanecen visibles para que el video se sienta personal antes del render." },
        { title: "Preparar video final", text: "La revisión final mantiene el control en tus manos antes de usar créditos y crear el video." }
      ],
      createCta: "Crear un recuerdo",
      galleryCta: "Abrir galería",
      title: "Una forma guiada de convertir momentos en un video de recuerdo."
    },
    config: {
      body: "Ejecuta la web mediante el wrapper de Varlock para que la configuración de Account AV esté disponible. El acceso web empieza con inicio de sesión.",
      eyebrow: "Configuración requerida",
      title: "Moments AV Web necesita configuración de Clerk."
    },
    create: {
      body: "Elige fotos y clips seleccionados, escoge un formato de historia, ajusta ambiente y duración, y revisa el recuerdo antes de crear el video final.",
      cta: "Empezar con medios seleccionados",
      flow: [
        { title: "Elegir momentos", text: "Usa solo las fotos y clips seleccionados para este proyecto." },
        { title: "Editar opciones", text: "Escoge la ocasión, el ambiente, el aspecto visual y la duración que encajan con la historia." },
        { title: "Revisar y crear", text: "Confirma créditos, revisa el plan y crea el video final." }
      ],
      title: "Crea un video privado de recuerdos."
    },
    createUi: {
      confirm: "Confirmar",
      confirmFinalVideo: "Confirmar video final",
      creatingWorkspace: "Creando espacio de trabajo...",
      details: "Detalles",
      duration: "Duración",
      finalVideoQueued: "Video final en cola",
      finalVideoCreationConfirmed: "Creación del video final confirmada. Sigue el progreso en En curso, descárgalo cuando esté disponible y termina moviéndolo a Galería.",
      flowStopped: "El flujo de creación se detuvo.",
      look: "Aspecto",
      media: "Medios",
      mediaUse: "Uso de medios",
      mood: "Ambiente",
      noBrowserMedia: "No hay medios seleccionados en este navegador.",
      notChecked: "Sin comprobar",
      notPlanned: "Sin planificar",
      occasion: "Ocasión",
      prepareStoryAndCost: "Preparar historia y coste",
      preparingUploads: "Preparando subidas...",
      renderPlan: "Plan de render",
      renderPlanReady: "Plan de render listo. Confirma una vez para crear el video final.",
      selectMediaToStart: "Selecciona medios para empezar.",
      selectedMedia: "Medios seleccionados",
      setup: "Configuración",
      story: "Historia",
      item: "elemento",
      items: "elementos",
      waitingForConfirmation: "Esperando confirmación explícita"
    },
    aviDashboard: {
      activeHeadline: "Avi está listo para continuar tu Moment activo.",
      activeText: "Continúa desde En curso para revisar medios, escenas de historia, trabajos de render, artefactos y terminar en Galería cuando el video esté listo.",
      creditsActive: "Tu cuenta está activa. El plan de render sigue decidiendo el coste en créditos antes de crear el video final.",
      creditsBlocked: "Avi bloquea la creación del video final cuando el plan de render informa créditos insuficientes.",
      creditsTitle: "Créditos",
      create: "Crear",
      galleryLoading: "El estado de Galería se está cargando desde la proyección cloud.",
      galleryReady: "Moments de Galería con metadatos remotos.",
      galleryTitle: "Galería",
      inProgressLoading: "El estado en tiempo real se está cargando desde la proyección cloud.",
      inProgressReady: "Moments activos disponibles para continuar.",
      inProgressTitle: "En curso",
      newHeadline: "Avi está listo para dar forma a un nuevo video de recuerdos.",
      newText: "Empieza con medios seleccionados. El plan de render decidirá coste y bloqueos antes de la confirmación final.",
      openGallery: "Abrir galería",
      continue: "Continuar",
      readyGalleryHeadline: "Avi encontró Moments terminados en tu Galería.",
      readyGalleryText: "Abre Galería para preparar una descarga. El registro cloud permanece separado de la disponibilidad del archivo local de este navegador.",
      proNewText: "Elige medios del navegador, súbelos al espacio de trabajo, pide un plan de historia y confirma la creación del video final una vez."
    },
    footer: { deleteAccount: "Eliminar cuenta", language: "Idioma", privacy: "Privacidad", support: "Soporte", terms: "Condiciones" },
    gallery: {
      body: "Los Moments terminados siguen visibles desde tu cuenta. La disponibilidad de descarga y los archivos locales se muestran por separado.",
      emptyBody: "Crea un video de recuerdo y sus metadatos de Galería aparecerán aquí cuando estén listos.",
      emptyTitle: "Tu galería está lista para el primer recuerdo.",
      filters: ["Todos", "Renderizando", "Listos", "Disponibles"],
      hints: [
        { title: "Revisar", text: "Mantén la historia visible antes de guardar o compartir el resultado." },
        { title: "Descargar", text: "La descarga aparece solo cuando hay un artefacto remoto disponible." },
        { title: "Historial", text: "Los Moments completados siguen vinculados a la cuenta aunque este navegador no tenga archivo local." }
      ],
      kicker: "Galería",
      title: "Tus videos de recuerdos, reunidos en un lugar."
    },
    galleryUi: {
      artifact: "Artefacto",
      convexMissingBody: "Ejecuta el wrapper preview de Varlock para que VITE_MOMENTSAV_CONVEX_URL apunte al despliegue cloud dev/preview.",
      convexMissingTitle: "Falta la URL cloud de Convex",
      credits: "Créditos",
      downloadFailed: "La descarga preparada no se completó.",
      downloadReady: "Los metadatos de descarga remota están disponibles. Este navegador no tiene archivo local guardado hasta que lo descargues aquí.",
      downloaded: "Descargado en esta sesión del navegador. El registro cloud de Galería sigue visible aunque este navegador pierda después el archivo local.",
      duration: "Duración",
      galleryLoadingBody: "Abriendo una sesión en tiempo real emitida por backend y suscribiendo Moments de Galería.",
      galleryLoadingTitle: "Cargando galería",
      galleryUnavailableTitle: "Galería no disponible",
      media: "Medios",
      missing: "faltante",
      noArtifact: "Los metadatos de Galería existen, pero no hay artefacto final proyectado para descarga.",
      prepareDownload: "Preparar descarga",
      refreshNeeded: "El registro cloud está visible, pero este artefacto puede necesitar refresco de backend antes de descargar.",
      waitingForReady: "Los metadatos del artefacto final están presentes, pero backend aún no lo marcó listo para descarga."
    },
    inProgressUi: {
      artifacts: "Artefactos",
      body: "Los Moments activos se recuperan aquí desde la proyección cloud.",
      continueInCreate: "Continuar en Crear",
      delete: "Eliminar",
      confirmDelete: "Eliminar este Moment, incluidos los medios de origen y artefactos generados?",
      deleteSent: "Comando de eliminación enviado. Se solicita eliminar medios de origen y artefactos generados.",
      loadingMoments: "Cargando Moments activos.",
      loadingWorkspace: "Cargando detalle del espacio de trabajo.",
      media: "Medios",
      missingConfig: "La URL cloud de Convex no está configurada para esta sesión preview.",
      noActive: "No hay Moments activos proyectados ahora.",
      noRecords: "No hay registros proyectados.",
      rename: "Renombrar",
      renameSent: "Renombre enviado a la API de comandos del espacio de trabajo.",
      renderJobs: "Trabajos de render",
      selectMoment: "Selecciona un Moment activo para inspeccionar el estado del espacio de trabajo.",
      storyScenes: "Escenas de historia",
      title: "En curso"
    },
    home: {
      aviBody: [
        "Convierte un grupo seleccionado de fotos y clips en una historia clara.",
        "Mantén visibles tono, duración y estilo antes del render final.",
        "Vuelve a los Moments terminados desde Galería."
      ],
      aviTitle: "Avi da forma a la historia",
      body: "Crea videos privados de recuerdos a partir de fotos y clips seleccionados, revísalos con cuidado y termínalos en Galería cuando estén listos.",
      cta: "Crear video",
      items: [
        { label: "Medios seleccionados", value: "Empieza desde los momentos que eliges" },
        { label: "Opciones de historia", value: "Ajusta plantilla, ambiente, aspecto y duración" },
        { label: "Galería", value: "Revisa Moments completados" }
      ],
      title: "Haz un video de recuerdo con los momentos importantes."
    },
    login: {
      aviGuidance: "Guía de Avi",
      cardBody: "Avanza de los medios elegidos a opciones de historia, revisión, creación del video final y Galería sin perder contexto.",
      cardTitle: "Un flujo de creación tranquilo",
      cta: "Iniciar sesión",
      heroBody: "Inicia sesión para crear videos privados de recuerdos, mantener proyectos conectados y dejar que Avi ayude a dar forma a la historia antes de crear el video final.",
      heroTitle: "Tus recuerdos, convertidos en video con cuidado.",
      intro: "Lleva fotos y clips seleccionados a un flujo guiado para cumpleaños, celebraciones, viajes, hitos y pequeñas historias personales.",
      mapBody: "La experiencia web traslada la idea del onboarding de iOS: visuales cálidos de recuerdos, un camino de creación guiado y Avi cerca para ayudar sin tomar el control.",
      mapTitle: "Un camino guiado desde momentos seleccionados hasta Galería.",
      notebook: "Proyectos de recuerdos",
      search: "Medios seleccionados"
    },
    nav: {
      avi: "Avi",
      aviLabel: "Abrir guía de Avi",
      create: "Crear",
      createLabel: "Crear video de recuerdo",
      gallery: "Galería",
      galleryLabel: "Abrir galería de Moments AV",
      home: "Inicio",
      homeLabel: "Inicio de Moments AV",
      mobileNavigation: "Navegación móvil",
      openNavigation: "Abrir navegación",
      primaryNavigation: "Navegación principal"
    },
    protected: {
      body: "Inicia sesión para crear videos privados de recuerdos, revisar proyectos y mantener la guía de Avi conectada con tu cuenta.",
      cta: "Iniciar sesión",
      title: "Lleva tus proyectos de recuerdos contigo."
    },
    signIn: {
      aviPanelBody: "Avi ayuda a mantener la historia cálida, clara y lista para revisar.",
      body: "Inicia sesión para mantener medios seleccionados, opciones de creación, estado de render y metadatos de Galería conectados con tu cuenta AV.",
      continue: "Continuar",
      signedIn: "Has iniciado sesión.",
      title: "Moments AV está listo para tu próximo recuerdo."
    }
  },
  fr: {
    account: { signInTitle: "Connectez-vous à Moments AV", signInSubtitle: "Gardez vos projets souvenirs connectés." },
    avi: {
      body: "Avi aide à transformer les photos et clips sélectionnés en histoire privée : structure, ton, rythme et prochaine étape restent clairs avant la création de la vidéo finale.",
      cards: [
        { title: "Structurer l’histoire", text: "Avi garde les moments choisis organisés autour du modèle et de l’occasion." },
        { title: "Ajuster l’ambiance", text: "Style, durée et chaleur restent visibles afin que la vidéo paraisse personnelle avant le rendu." },
        { title: "Préparer la vidéo finale", text: "Le flux de révision final te laisse le contrôle avant l’utilisation des crédits et la création de la vidéo." }
      ],
      createCta: "Créer un souvenir",
      galleryCta: "Ouvrir la galerie",
      title: "Une façon guidée de transformer des moments en vidéo souvenir."
    },
    config: {
      body: "Lancez l’app web via le wrapper Varlock afin que la configuration Account AV soit disponible. L’accès web commence par la connexion.",
      eyebrow: "Configuration requise",
      title: "Moments AV Web nécessite une configuration Clerk."
    },
    create: {
      body: "Choisissez des photos et clips sélectionnés, définissez un format d’histoire, ajustez l’ambiance et la durée, puis relisez le souvenir avant de créer la vidéo finale.",
      cta: "Commencer avec les médias choisis",
      flow: [
        { title: "Choisir les moments", text: "Utilisez uniquement les photos et clips sélectionnés pour ce projet." },
        { title: "Modifier les options", text: "Choisissez l’occasion, l’ambiance, le style visuel et la durée adaptés à l’histoire." },
        { title: "Relire et créer", text: "Confirmez les crédits, relisez le plan et créez la vidéo finale." }
      ],
      title: "Créez une vidéo souvenir privée."
    },
    createUi: {
      confirm: "Confirmer",
      confirmFinalVideo: "Confirmer la vidéo finale",
      creatingWorkspace: "Création de l’espace de travail...",
      details: "Détails",
      duration: "Durée",
      finalVideoQueued: "Vidéo finale en file d’attente",
      finalVideoCreationConfirmed: "Création de la vidéo finale confirmée. Suivez la progression dans En cours, téléchargez quand c’est disponible et terminez vers Galerie.",
      flowStopped: "Le flux de création s’est arrêté.",
      look: "Style",
      media: "Médias",
      mediaUse: "Utilisation des médias",
      mood: "Ambiance",
      noBrowserMedia: "Aucun média sélectionné dans ce navigateur.",
      notChecked: "Non vérifié",
      notPlanned: "Non planifié",
      occasion: "Occasion",
      prepareStoryAndCost: "Préparer l’histoire et le coût",
      preparingUploads: "Préparation des téléversements...",
      renderPlan: "Plan de rendu",
      renderPlanReady: "Plan de rendu prêt. Confirmez une fois pour créer la vidéo finale.",
      selectMediaToStart: "Sélectionnez des médias pour commencer.",
      selectedMedia: "Médias choisis",
      setup: "Configuration",
      story: "Histoire",
      item: "élément",
      items: "éléments",
      waitingForConfirmation: "En attente d’une confirmation explicite"
    },
    aviDashboard: {
      activeHeadline: "Avi est prêt à continuer votre Moment actif.",
      activeText: "Continuez depuis En cours pour inspecter médias, scènes, rendus, artefacts et terminer dans Galerie quand la vidéo est prête.",
      creditsActive: "Votre compte est actif. Le plan de rendu décide toujours le coût en crédits avant la création de la vidéo finale.",
      creditsBlocked: "Avi bloque la création de la vidéo finale quand le plan de rendu signale des crédits insuffisants.",
      creditsTitle: "Crédits",
      create: "Créer",
      galleryLoading: "L’état de Galerie se charge depuis la projection cloud.",
      galleryReady: "Moments de Galerie avec métadonnées distantes.",
      galleryTitle: "Galerie",
      inProgressLoading: "L’état en temps réel se charge depuis la projection cloud.",
      inProgressReady: "Moments actifs disponibles pour continuer.",
      inProgressTitle: "En cours",
      newHeadline: "Avi est prêt à structurer une nouvelle vidéo souvenir.",
      newText: "Commencez avec les médias choisis. Le plan de rendu décidera du coût et des blocages avant la confirmation finale.",
      openGallery: "Ouvrir la galerie",
      continue: "Continuer",
      readyGalleryHeadline: "Avi a trouvé des Moments terminés dans votre Galerie.",
      readyGalleryText: "Ouvrez Galerie pour préparer un téléchargement. L’enregistrement cloud reste séparé de la disponibilité du fichier local dans ce navigateur.",
      proNewText: "Choisissez les médias du navigateur, téléversez-les dans l’espace de travail, demandez un plan d’histoire, puis confirmez une seule fois la création de la vidéo finale."
    },
    footer: { deleteAccount: "Supprimer le compte", language: "Langue", privacy: "Confidentialité", support: "Aide", terms: "Conditions" },
    gallery: {
      body: "Les Moments terminés restent visibles depuis votre compte connecté. La disponibilité du téléchargement et les fichiers locaux sont indiqués séparément.",
      emptyBody: "Créez une vidéo souvenir et ses métadonnées de Galerie apparaîtront ici lorsqu’elles seront prêtes.",
      emptyTitle: "Votre galerie est prête pour le premier souvenir.",
      filters: ["Tous", "Rendu", "Prêts", "Disponibles"],
      hints: [
        { title: "Relire", text: "Gardez l’histoire visible avant d’enregistrer ou de partager le résultat." },
        { title: "Télécharger", text: "Le téléchargement apparaît seulement lorsqu’un artefact distant est disponible." },
        { title: "Historique", text: "Les Moments terminés restent liés au compte même si ce navigateur n’a pas de fichier local." }
      ],
      kicker: "Galerie",
      title: "Vos vidéos souvenirs, réunies au même endroit."
    },
    galleryUi: {
      artifact: "Artefact",
      convexMissingBody: "Lancez le wrapper preview de Varlock afin que VITE_MOMENTSAV_CONVEX_URL pointe vers le déploiement cloud dev/preview.",
      convexMissingTitle: "URL cloud Convex manquante",
      credits: "Crédits",
      downloadFailed: "Le téléchargement préparé ne s’est pas terminé.",
      downloadReady: "Les métadonnées de téléchargement distant sont disponibles. Ce navigateur n’a aucun fichier local enregistré tant que vous ne le téléchargez pas ici.",
      downloaded: "Téléchargé dans cette session du navigateur. L’enregistrement cloud de Galerie reste visible même si ce navigateur perd ensuite le fichier local.",
      duration: "Durée",
      galleryLoadingBody: "Ouverture d’une session temps réel émise par le backend et abonnement aux Moments de Galerie.",
      galleryLoadingTitle: "Chargement de la galerie",
      galleryUnavailableTitle: "Galerie indisponible",
      media: "Médias",
      missing: "manquant",
      noArtifact: "Les métadonnées de Galerie existent, mais aucun artefact final n’est actuellement projeté pour téléchargement.",
      prepareDownload: "Préparer le téléchargement",
      refreshNeeded: "L’enregistrement cloud est visible, mais cet artefact peut nécessiter un rafraîchissement backend avant téléchargement.",
      waitingForReady: "Les métadonnées de l’artefact final sont présentes, mais le backend ne l’a pas encore marqué prêt pour téléchargement."
    },
    inProgressUi: {
      artifacts: "Artefacts",
      body: "Les Moments actifs se récupèrent ici depuis la projection cloud.",
      continueInCreate: "Continuer dans Créer",
      delete: "Supprimer",
      confirmDelete: "Supprimer ce Moment, y compris les medias source et artefacts generes ?",
      deleteSent: "Commande de suppression envoyée. Les médias source et artefacts générés sont demandés pour suppression.",
      loadingMoments: "Chargement des Moments actifs.",
      loadingWorkspace: "Chargement du détail de l’espace de travail.",
      media: "Médias",
      missingConfig: "L’URL cloud Convex n’est pas configurée pour cette session preview.",
      noActive: "Aucun Moment actif n’est projeté pour le moment.",
      noRecords: "Aucun enregistrement projeté.",
      rename: "Renommer",
      renameSent: "Renommage envoyé à l’API de commande de l’espace de travail.",
      renderJobs: "Tâches de rendu",
      selectMoment: "Sélectionnez un Moment actif pour inspecter l’état de l’espace de travail.",
      storyScenes: "Scènes de l’histoire",
      title: "En cours"
    },
    home: {
      aviBody: [
        "Transformez un groupe sélectionné de photos et clips en histoire claire.",
        "Gardez le ton, la durée et le style visibles avant le rendu final.",
        "Retrouvez les Moments terminés depuis Galerie."
      ],
      aviTitle: "Avi structure l’histoire",
      body: "Créez des vidéos souvenirs privées à partir de photos et clips sélectionnés, relisez-les avec soin et terminez-les dans Galerie lorsqu’elles sont prêtes.",
      cta: "Créer une vidéo",
      items: [
        { label: "Médias choisis", value: "Commencez avec les moments que vous sélectionnez" },
        { label: "Options d’histoire", value: "Ajustez modèle, ambiance, style et durée" },
        { label: "Galerie", value: "Relisez les Moments terminés" }
      ],
      title: "Créez une vidéo souvenir avec les moments importants."
    },
    login: {
      aviGuidance: "Conseils d’Avi",
      cardBody: "Passez des médias choisis aux options d’histoire, à la révision, à la création de la vidéo finale et à Galerie sans perdre le contexte.",
      cardTitle: "Un flux de création calme",
      cta: "Se connecter",
      heroBody: "Connectez-vous pour créer des vidéos souvenirs privées, garder vos projets liés et laisser Avi aider à structurer l’histoire avant la création de la vidéo finale.",
      heroTitle: "Vos souvenirs, transformés en vidéo avec soin.",
      intro: "Ajoutez des photos et clips sélectionnés dans un flux guidé pour anniversaires, célébrations, voyages, étapes importantes et petites histoires personnelles.",
      mapBody: "L’expérience web reprend l’idée d’onboarding iOS : des visuels chaleureux, un parcours de création guidé et Avi assez proche pour aider sans prendre la main.",
      mapTitle: "Un chemin guidé des moments choisis à Galerie.",
      notebook: "Projets souvenirs",
      search: "Médias choisis"
    },
    nav: {
      avi: "Avi",
      aviLabel: "Ouvrir les conseils d’Avi",
      create: "Créer",
      createLabel: "Créer une vidéo souvenir",
      gallery: "Galerie",
      galleryLabel: "Ouvrir la galerie Moments AV",
      home: "Accueil",
      homeLabel: "Accueil Moments AV",
      mobileNavigation: "Navigation mobile",
      openNavigation: "Ouvrir la navigation",
      primaryNavigation: "Navigation principale"
    },
    protected: {
      body: "Connectez-vous pour créer des vidéos souvenirs privées, relire vos projets et garder les conseils d’Avi liés à votre compte.",
      cta: "Se connecter",
      title: "Gardez vos projets souvenirs avec vous."
    },
    signIn: {
      aviPanelBody: "Avi aide à garder l’histoire chaleureuse, claire et prête pour la révision.",
      body: "Connectez-vous pour garder les médias choisis, les options de création, l’état du rendu et les métadonnées de Galerie liés à votre compte AV.",
      continue: "Continuer",
      signedIn: "Vous êtes connecté.",
      title: "Moments AV est prêt pour votre prochain souvenir."
    }
  },
  de: {
    account: { signInTitle: "Bei Moments AV anmelden", signInSubtitle: "Halte deine Erinnerungsprojekte verbunden." },
    avi: {
      body: "Avi hilft, ausgewählte Fotos und Clips in eine private Geschichte zu formen: Struktur, Ton, Tempo und der nächste Schritt bleiben vor der finalen Videoerstellung klar.",
      cards: [
        { title: "Geschichte formen", text: "Avi hält die ausgewählten Momente passend zu Vorlage und Anlass organisiert." },
        { title: "Stimmung abstimmen", text: "Stil, Länge und Wärme bleiben sichtbar, damit sich das Video vor dem Rendering persönlich anfühlt." },
        { title: "Finales Video vorbereiten", text: "Die finale Prüfung lässt die Kontrolle bei dir, bevor Credits genutzt und das Video erstellt wird." }
      ],
      createCta: "Moment erstellen",
      galleryCta: "Galerie öffnen",
      title: "Eine geführte Art, Momente in ein Erinnerungsvideo zu verwandeln."
    },
    config: {
      body: "Starte die Web-App über den Varlock-Wrapper, damit die Account AV Konfiguration verfügbar ist. Webzugriff beginnt mit der Anmeldung.",
      eyebrow: "Konfiguration erforderlich",
      title: "Moments AV Web benötigt Clerk-Konfiguration."
    },
    create: {
      body: "Wähle ausgewählte Fotos und Clips, entscheide dich für ein Geschichtenformat, passe Stimmung und Länge an und prüfe die Erinnerung vor der finalen Videoerstellung.",
      cta: "Mit ausgewählten Medien starten",
      flow: [
        { title: "Momente wählen", text: "Verwende nur die Fotos und Clips, die für dieses Projekt ausgewählt wurden." },
        { title: "Optionen bearbeiten", text: "Wähle Anlass, Stimmung, visuellen Look und Länge passend zur Geschichte." },
        { title: "Prüfen und erstellen", text: "Bestätige Credits, prüfe den Plan und erstelle das finale Video." }
      ],
      title: "Erstelle ein privates Erinnerungsvideo."
    },
    createUi: {
      confirm: "Bestätigen",
      confirmFinalVideo: "Finales Video bestätigen",
      creatingWorkspace: "Arbeitsbereich wird erstellt...",
      details: "Details",
      duration: "Länge",
      finalVideoQueued: "Finales Video in Warteschlange",
      finalVideoCreationConfirmed: "Finale Videoerstellung bestätigt. Verfolge den Fortschritt unter In Arbeit, lade herunter, sobald es verfügbar ist, und schließe in Galerie ab.",
      flowStopped: "Der Erstellungsfluss wurde gestoppt.",
      look: "Look",
      media: "Medien",
      mediaUse: "Mediennutzung",
      mood: "Stimmung",
      noBrowserMedia: "Keine Medien in diesem Browser ausgewählt.",
      notChecked: "Nicht geprüft",
      notPlanned: "Nicht geplant",
      occasion: "Anlass",
      prepareStoryAndCost: "Story und Kosten vorbereiten",
      preparingUploads: "Uploads werden vorbereitet...",
      renderPlan: "Renderplan",
      renderPlanReady: "Renderplan bereit. Bestätige einmal, um das finale Video zu erstellen.",
      selectMediaToStart: "Wähle Medien aus, um zu starten.",
      selectedMedia: "Ausgewählte Medien",
      setup: "Einrichtung",
      story: "Story",
      item: "Element",
      items: "Elemente",
      waitingForConfirmation: "Warten auf ausdrückliche Bestätigung"
    },
    aviDashboard: {
      activeHeadline: "Avi ist bereit, deinen aktiven Moment fortzusetzen.",
      activeText: "Fahre unter In Arbeit fort, um Medien, Story-Szenen, Renderaufträge und Artefakte zu prüfen und in Galerie abzuschließen, wenn das Video bereit ist.",
      creditsActive: "Dein Konto ist aktiv. Der Renderplan entscheidet weiterhin die Credit-Kosten vor der finalen Videoerstellung.",
      creditsBlocked: "Avi blockiert die finale Videoerstellung, wenn der Renderplan unzureichende Credits meldet.",
      creditsTitle: "Credits",
      create: "Erstellen",
      galleryLoading: "Galerie-Status wird aus der Cloud-Projektion geladen.",
      galleryReady: "Galerie-Moments mit Remote-Metadaten.",
      galleryTitle: "Galerie",
      inProgressLoading: "Echtzeitstatus wird aus der Cloud-Projektion geladen.",
      inProgressReady: "aktive Moments zum Fortsetzen verfügbar.",
      inProgressTitle: "In Arbeit",
      newHeadline: "Avi ist bereit, ein neues Erinnerungsvideo zu formen.",
      newText: "Starte mit ausgewählten Medien. Der Renderplan entscheidet Kosten und Blocker vor der finalen Bestätigung.",
      openGallery: "Galerie öffnen",
      continue: "Fortsetzen",
      readyGalleryHeadline: "Avi hat fertige Moments in deiner Galerie gefunden.",
      readyGalleryText: "Öffne Galerie, um einen Download vorzubereiten. Der Cloud-Datensatz bleibt von der lokalen Dateiverfügbarkeit dieses Browsers getrennt.",
      proNewText: "Wähle Browser-Medien, lade sie in den Arbeitsbereich hoch, fordere einen Storyplan an und bestätige dann einmal die finale Videoerstellung."
    },
    footer: { deleteAccount: "Konto löschen", language: "Sprache", privacy: "Datenschutz", support: "Support", terms: "Bedingungen" },
    gallery: {
      body: "Fertige Moments bleiben über dein angemeldetes Konto sichtbar. Download-Verfügbarkeit und lokale Dateien werden separat angezeigt.",
      emptyBody: "Erstelle ein Erinnerungsvideo, dann erscheinen die Galerie-Metadaten hier, sobald sie bereit sind.",
      emptyTitle: "Deine Galerie ist bereit für die erste Erinnerung.",
      filters: ["Alle", "Wird gerendert", "Bereit", "Verfügbar"],
      hints: [
        { title: "Prüfen", text: "Halte die Geschichte sichtbar, bevor du das Ergebnis speicherst oder teilst." },
        { title: "Download", text: "Download erscheint nur, wenn ein Remote-Artefakt verfügbar ist." },
        { title: "Verlauf", text: "Abgeschlossene Moments bleiben mit dem Konto verbunden, auch wenn dieser Browser keine lokale Datei hat." }
      ],
      kicker: "Galerie",
      title: "Deine Erinnerungsvideos an einem Ort."
    },
    galleryUi: {
      artifact: "Artefakt",
      convexMissingBody: "Starte den Preview-Varlock-Wrapper, damit VITE_MOMENTSAV_CONVEX_URL auf das Cloud-Dev/Preview-Deployment zeigt.",
      convexMissingTitle: "Convex-Cloud-URL fehlt",
      credits: "Credits",
      downloadFailed: "Der vorbereitete Download wurde nicht abgeschlossen.",
      downloadReady: "Remote-Download-Metadaten sind verfügbar. Dieser Browser hat keine gespeicherte lokale Datei, bis du sie hier herunterlädst.",
      downloaded: "In dieser Browsersitzung heruntergeladen. Der Galerie-Cloud-Datensatz bleibt sichtbar, auch wenn dieser Browser später die lokale Datei verliert.",
      duration: "Länge",
      galleryLoadingBody: "Backend-Echtzeitsitzung wird geöffnet und Galerie-Moments werden abonniert.",
      galleryLoadingTitle: "Galerie wird geladen",
      galleryUnavailableTitle: "Galerie nicht verfügbar",
      media: "Medien",
      missing: "fehlt",
      noArtifact: "Galerie-Metadaten existieren, aber aktuell ist kein finales Artefakt für den Download projiziert.",
      prepareDownload: "Download vorbereiten",
      refreshNeeded: "Der Cloud-Datensatz ist sichtbar, aber dieses Artefakt benötigt vor dem Download möglicherweise eine Backend-Aktualisierung.",
      waitingForReady: "Metadaten des finalen Artefakts sind vorhanden, aber das Backend hat es noch nicht als downloadbereit markiert."
    },
    inProgressUi: {
      artifacts: "Artefakte",
      body: "Aktive Moments werden hier aus der Cloud-Projektion wiederhergestellt.",
      continueInCreate: "In Erstellen fortfahren",
      delete: "Löschen",
      confirmDelete: "Diesen Moment einschließlich Quellmedien und generierter Artefakte löschen?",
      deleteSent: "Löschbefehl gesendet. Quellmedien und generierte Artefakte werden zur Löschung angefordert.",
      loadingMoments: "Aktive Moments werden geladen.",
      loadingWorkspace: "Arbeitsbereichsdetails werden geladen.",
      media: "Medien",
      missingConfig: "Die Convex-Cloud-URL ist für diese Preview-Sitzung nicht konfiguriert.",
      noActive: "Derzeit sind keine aktiven Moments projiziert.",
      noRecords: "Keine Datensätze projiziert.",
      rename: "Umbenennen",
      renameSent: "Umbenennung an die Arbeitsbereichs-Command-API gesendet.",
      renderJobs: "Renderaufträge",
      selectMoment: "Wähle einen aktiven Moment aus, um den Arbeitsbereichsstatus zu prüfen.",
      storyScenes: "Story-Szenen",
      title: "In Arbeit"
    },
    home: {
      aviBody: [
        "Verwandle eine ausgewählte Gruppe von Fotos und Clips in eine klare Geschichte.",
        "Halte Ton, Länge und Stil vor dem finalen Rendern sichtbar.",
        "Kehre über Galerie zu fertigen Moments zurück."
      ],
      aviTitle: "Avi formt die Geschichte",
      body: "Erstelle private Erinnerungsvideos aus ausgewählten Fotos und Clips, prüfe sie sorgfältig und schließe sie in Galerie ab, wenn sie bereit sind.",
      cta: "Video erstellen",
      items: [
        { label: "Ausgewählte Medien", value: "Beginne mit den Momenten, die du auswählst" },
        { label: "Story-Optionen", value: "Passe Vorlage, Stimmung, Look und Länge an" },
        { label: "Galerie", value: "Prüfe abgeschlossene Moments" }
      ],
      title: "Mache aus wichtigen Momenten ein Erinnerungsvideo."
    },
    login: {
      aviGuidance: "Avi-Begleitung",
      cardBody: "Wechsle von ausgewählten Medien zu Story-Optionen, Prüfung, finaler Videoerstellung und Galerie, ohne den Kontext zu verlieren.",
      cardTitle: "Ein ruhiger Erstellungsfluss",
      cta: "Anmelden",
      heroBody: "Melde dich an, um private Erinnerungsvideos zu erstellen, Projekte verbunden zu halten und Avi vor der finalen Videoerstellung bei der Geschichte helfen zu lassen.",
      heroTitle: "Deine Erinnerungen, sorgsam als Video gestaltet.",
      intro: "Führe ausgewählte Fotos und Clips in einen geführten Ablauf für Geburtstage, Feiern, Reisen, Meilensteine und kleine persönliche Geschichten.",
      mapBody: "Die Web-Erfahrung übernimmt die iOS-Onboarding-Idee: warme Erinnerungsbilder, ein geführter Erstellungsweg und Avi nah genug, um zu helfen, ohne zu übernehmen.",
      mapTitle: "Ein geführter Weg von ausgewählten Momenten zu Galerie.",
      notebook: "Erinnerungsprojekte",
      search: "Ausgewählte Medien"
    },
    nav: {
      avi: "Avi",
      aviLabel: "Avi-Begleitung öffnen",
      create: "Erstellen",
      createLabel: "Erinnerungsvideo erstellen",
      gallery: "Galerie",
      galleryLabel: "Moments AV Galerie öffnen",
      home: "Start",
      homeLabel: "Moments AV Start",
      mobileNavigation: "Mobile Navigation",
      openNavigation: "Navigation öffnen",
      primaryNavigation: "Hauptnavigation"
    },
    protected: {
      body: "Melde dich an, um private Erinnerungsvideos zu erstellen, Projekte zu prüfen und Avis Begleitung mit deinem Konto verbunden zu halten.",
      cta: "Anmelden",
      title: "Nimm deine Erinnerungsprojekte mit."
    },
    signIn: {
      aviPanelBody: "Avi hilft, die Geschichte warm, klar und bereit zur Prüfung zu halten.",
      body: "Melde dich an, um ausgewählte Medien, Erstellungsoptionen, Renderstatus und Galerie-Metadaten mit deinem AV Konto verbunden zu halten.",
      continue: "Weiter",
      signedIn: "Du bist angemeldet.",
      title: "Moments AV ist bereit für deine nächste Erinnerung."
    }
  },
  ca: {
    account: { signInTitle: "Inicia sessió a Moments AV", signInSubtitle: "Mantingues connectats els teus projectes de records." },
    avi: {
      body: "L’Avi ajuda a convertir les fotos i els clips seleccionats en una història privada: estructura, to, ritme i següent pas es mantenen clars abans de crear el vídeo final.",
      cards: [
        { title: "Donar forma a la història", text: "L’Avi manté els moments seleccionats organitzats al voltant de la plantilla i l’ocasió." },
        { title: "Ajustar l’ambient", text: "L’estil, la durada i la calidesa es mantenen visibles perquè el vídeo se senti personal abans del render." },
        { title: "Preparar el vídeo final", text: "El flux de revisió final manté el control a les teves mans abans d’usar crèdits i crear el vídeo." }
      ],
      createCta: "Crea un record",
      galleryCta: "Obre la galeria",
      title: "Una manera guiada de convertir moments en un vídeo de record."
    },
    config: {
      body: "Executa la web mitjançant el wrapper de Varlock perquè la configuració d’Account AV estigui disponible. L’accés web comença amb l’inici de sessió.",
      eyebrow: "Configuració requerida",
      title: "Moments AV Web necessita configuració de Clerk."
    },
    create: {
      body: "Tria fotos i clips seleccionats, escull un format d’història, ajusta ambient i durada, i revisa el record abans de crear el vídeo final.",
      cta: "Comença amb mitjans seleccionats",
      flow: [
        { title: "Triar moments", text: "Fes servir només les fotos i els clips seleccionats per a aquest projecte." },
        { title: "Editar opcions", text: "Escull l’ocasió, l’ambient, l’aspecte visual i la durada que encaixen amb la història." },
        { title: "Revisar i crear", text: "Confirma crèdits, revisa el pla i crea el vídeo final." }
      ],
      title: "Crea un vídeo privat de records."
    },
    createUi: {
      confirm: "Confirmar",
      confirmFinalVideo: "Confirmar vídeo final",
      creatingWorkspace: "Creant espai de treball...",
      details: "Detalls",
      duration: "Durada",
      finalVideoQueued: "Vídeo final en cua",
      finalVideoCreationConfirmed: "Creació del vídeo final confirmada. Segueix el progrés a En curs, descarrega quan estigui disponible i acaba movent-lo a Galeria.",
      flowStopped: "El flux de creació s’ha aturat.",
      look: "Aspecte",
      media: "Mitjans",
      mediaUse: "Ús de mitjans",
      mood: "Ambient",
      noBrowserMedia: "No hi ha mitjans seleccionats en aquest navegador.",
      notChecked: "Sense comprovar",
      notPlanned: "Sense planificar",
      occasion: "Ocasió",
      prepareStoryAndCost: "Preparar història i cost",
      preparingUploads: "Preparant pujades...",
      renderPlan: "Pla de render",
      renderPlanReady: "Pla de render llest. Confirma una vegada per crear el vídeo final.",
      selectMediaToStart: "Selecciona mitjans per començar.",
      selectedMedia: "Mitjans seleccionats",
      setup: "Configuració",
      story: "Història",
      item: "element",
      items: "elements",
      waitingForConfirmation: "Esperant confirmació explícita"
    },
    aviDashboard: {
      activeHeadline: "L’Avi està a punt per continuar el teu Moment actiu.",
      activeText: "Continua des d’En curs per inspeccionar mitjans, escenes, renders, artefactes i acabar a Galeria quan el vídeo estigui llest.",
      creditsActive: "El teu compte està actiu. El pla de render encara decideix el cost en crèdits abans de crear el vídeo final.",
      creditsBlocked: "L’Avi bloqueja la creació del vídeo final quan el pla de render informa crèdits insuficients.",
      creditsTitle: "Crèdits",
      create: "Crear",
      galleryLoading: "L’estat de Galeria es carrega des de la projecció cloud.",
      galleryReady: "Moments de Galeria amb metadades remotes.",
      galleryTitle: "Galeria",
      inProgressLoading: "L’estat en temps real es carrega des de la projecció cloud.",
      inProgressReady: "Moments actius disponibles per continuar.",
      inProgressTitle: "En curs",
      newHeadline: "L’Avi està a punt per donar forma a un nou vídeo de record.",
      newText: "Comença amb mitjans seleccionats. El pla de render decidirà cost i bloquejos abans de la confirmació final.",
      openGallery: "Obrir galeria",
      continue: "Continuar",
      readyGalleryHeadline: "L’Avi ha trobat Moments acabats a la teva Galeria.",
      readyGalleryText: "Obre Galeria per preparar una descàrrega. El registre cloud es manté separat de la disponibilitat del fitxer local d’aquest navegador.",
      proNewText: "Tria mitjans del navegador, puja’ls a l’espai de treball, demana un pla d’història i confirma una vegada la creació del vídeo final."
    },
    footer: { deleteAccount: "Eliminar compte", language: "Idioma", privacy: "Privacitat", support: "Ajuda", terms: "Condicions" },
    gallery: {
      body: "Els Moments acabats continuen visibles des del teu compte. La disponibilitat de descàrrega i els fitxers locals es mostren per separat.",
      emptyBody: "Crea un vídeo de record i les seves metadades de Galeria apareixeran aquí quan estiguin a punt.",
      emptyTitle: "La teva galeria està preparada per al primer record.",
      filters: ["Tots", "Renderitzant", "A punt", "Disponibles"],
      hints: [
        { title: "Revisar", text: "Mantén la història visible abans de desar o compartir el resultat." },
        { title: "Descarregar", text: "La descàrrega apareix només quan hi ha un artefacte remot disponible." },
        { title: "Historial", text: "Els Moments completats continuen vinculats al compte encara que aquest navegador no tingui cap fitxer local." }
      ],
      kicker: "Galeria",
      title: "Els teus vídeos de records, reunits en un lloc."
    },
    galleryUi: {
      artifact: "Artefacte",
      convexMissingBody: "Executa el wrapper preview de Varlock perquè VITE_MOMENTSAV_CONVEX_URL apunti al desplegament cloud dev/preview.",
      convexMissingTitle: "Falta l’URL cloud de Convex",
      credits: "Crèdits",
      downloadFailed: "La descàrrega preparada no s’ha completat.",
      downloadReady: "Les metadades de descàrrega remota estan disponibles. Aquest navegador no té cap fitxer local desat fins que el descarreguis aquí.",
      downloaded: "Descarregat en aquesta sessió del navegador. El registre cloud de Galeria continua visible encara que aquest navegador perdi després el fitxer local.",
      duration: "Durada",
      galleryLoadingBody: "Obrint una sessió en temps real emesa pel backend i subscrivint Moments de Galeria.",
      galleryLoadingTitle: "Carregant galeria",
      galleryUnavailableTitle: "Galeria no disponible",
      media: "Mitjans",
      missing: "falta",
      noArtifact: "Les metadades de Galeria existeixen, però no hi ha cap artefacte final projectat per descarregar.",
      prepareDownload: "Preparar descàrrega",
      refreshNeeded: "El registre cloud és visible, però aquest artefacte pot necessitar refresc del backend abans de descarregar.",
      waitingForReady: "Les metadades de l’artefacte final són presents, però el backend encara no l’ha marcat llest per descarregar."
    },
    inProgressUi: {
      artifacts: "Artefactes",
      body: "Els Moments actius es recuperen aquí des de la projecció cloud.",
      continueInCreate: "Continuar a Crea",
      delete: "Eliminar",
      confirmDelete: "Eliminar aquest Moment, inclosos els mitjans d'origen i artefactes generats?",
      deleteSent: "Comanda d’eliminació enviada. Es demana eliminar mitjans d’origen i artefactes generats.",
      loadingMoments: "Carregant Moments actius.",
      loadingWorkspace: "Carregant detall de l’espai de treball.",
      media: "Mitjans",
      missingConfig: "L’URL cloud de Convex no està configurada per a aquesta sessió preview.",
      noActive: "Ara mateix no hi ha Moments actius projectats.",
      noRecords: "No hi ha registres projectats.",
      rename: "Reanomenar",
      renameSent: "Canvi de nom enviat a l’API de comandes de l’espai de treball.",
      renderJobs: "Tasques de render",
      selectMoment: "Selecciona un Moment actiu per inspeccionar l’estat de l’espai de treball.",
      storyScenes: "Escenes de la història",
      title: "En curs"
    },
    home: {
      aviBody: [
        "Converteix un grup seleccionat de fotos i clips en una història clara.",
        "Mantén visibles el to, la durada i l’estil abans del render final.",
        "Torna als Moments acabats des de Galeria."
      ],
      aviTitle: "L’Avi dona forma a la història",
      body: "Crea vídeos privats de records a partir de fotos i clips seleccionats, revisa’ls amb cura i acaba’ls a Galeria quan estiguin a punt.",
      cta: "Crea vídeo",
      items: [
        { label: "Mitjans seleccionats", value: "Comença pels moments que tries" },
        { label: "Opcions d’història", value: "Ajusta plantilla, ambient, aspecte i durada" },
        { label: "Galeria", value: "Revisa Moments completats" }
      ],
      title: "Fes un vídeo de record amb els moments importants."
    },
    login: {
      aviGuidance: "Guia de l’Avi",
      cardBody: "Avança dels mitjans triats a les opcions d’història, revisió, creació del vídeo final i Galeria sense perdre context.",
      cardTitle: "Un flux de creació tranquil",
      cta: "Inicia sessió",
      heroBody: "Inicia sessió per crear vídeos privats de records, mantenir projectes connectats i deixar que l’Avi ajudi a donar forma a la història abans de crear el vídeo final.",
      heroTitle: "Els teus records, convertits en vídeo amb cura.",
      intro: "Porta fotos i clips seleccionats a un flux guiat per a aniversaris, celebracions, viatges, fites i petites històries personals.",
      mapBody: "L’experiència web trasllada la idea de l’onboarding d’iOS: visuals càlids de records, un camí de creació guiat i l’Avi prou a prop per ajudar sense prendre el control.",
      mapTitle: "Un camí guiat des dels moments seleccionats fins a Galeria.",
      notebook: "Projectes de records",
      search: "Mitjans seleccionats"
    },
    nav: {
      avi: "Avi",
      aviLabel: "Obre la guia de l’Avi",
      create: "Crea",
      createLabel: "Crea vídeo de record",
      gallery: "Galeria",
      galleryLabel: "Obre la galeria de Moments AV",
      home: "Inici",
      homeLabel: "Inici de Moments AV",
      mobileNavigation: "Navegació mòbil",
      openNavigation: "Obre la navegació",
      primaryNavigation: "Navegació principal"
    },
    protected: {
      body: "Inicia sessió per crear vídeos privats de records, revisar projectes i mantenir la guia de l’Avi connectada amb el teu compte.",
      cta: "Inicia sessió",
      title: "Porta els teus projectes de records amb tu."
    },
    signIn: {
      aviPanelBody: "L’Avi ajuda a mantenir la història càlida, clara i preparada per revisar.",
      body: "Inicia sessió per mantenir mitjans seleccionats, opcions de creació, estat de render i metadades de Galeria connectats amb el teu compte AV.",
      continue: "Continua",
      signedIn: "Has iniciat sessió.",
      title: "Moments AV està a punt per al teu proper record."
    }
  }
};

export function useMomentsText() {
  return translations[useAppsAvLocale()];
}

export function useMomentsAccountLocalization() {
  const locale = useAppsAvLocale();
  const text = translations[locale];
  const base = { ca: caES, de: deDE, en: enUS, es: esES, fr: frFR }[locale];

  return {
    ...base,
    signIn: {
      ...base.signIn,
      start: {
        ...base.signIn?.start,
        subtitle: text.account.signInSubtitle,
        title: text.account.signInTitle
      }
    }
  };
}

export function useMomentsShellLabels() {
  const text = useMomentsText();
  return {
    assistant: text.nav.aviLabel,
    home: text.nav.homeLabel,
    mobileNavigation: text.nav.mobileNavigation,
    openNavigation: text.nav.openNavigation,
    primaryNavigation: text.nav.primaryNavigation
  };
}

export function useMomentsNavLinks(): AppsAvProductLink[] {
  const locale = useAppsAvLocale();
  const text = useMomentsText();
  const inProgress = {
    ca: "En curs",
    de: "In Arbeit",
    en: "In Progress",
    es: "En curso",
    fr: "En cours"
  }[locale];
  return [
    { href: localizedAppPath("/", locale), label: text.nav.home },
    { href: localizedAppPath("/create", locale), label: text.nav.create },
    { href: localizedAppPath("/in-progress", locale), label: inProgress },
    { href: localizedAppPath("/gallery", locale), label: text.nav.gallery }
  ];
}

export function useMomentsProductConfig(): AppsAvProductConfig {
  const locale = useAppsAvLocale();
  const text = useMomentsText();

  return useMemo(() => ({
    ...momentsProductConfig,
    links: Object.fromEntries(
      Object.entries(momentsProductConfig.links).map(([key, link]) => [
        key,
        link ? { ...link, href: localizedProductHref(link.href, locale) } : link
      ])
    ) as AppsAvProductConfig["links"],
    assistant: momentsProductConfig.assistant
      ? {
        ...momentsProductConfig.assistant,
        href: localizedAppPath(momentsProductConfig.assistant.href, locale),
        label: text.nav.aviLabel
      }
      : undefined
  }), [locale, text.nav.aviLabel]);
}

export function localizedAppPath(path: string, locale: AppsAvLocale): string {
  if (locale === "en") {
    return path;
  }

  const separator = path.includes("?") ? "&" : "?";
  return `${path}${separator}lang=${locale}`;
}

function preserveLangForLocalHref(href: string, locale: AppsAvLocale) {
  if (locale === "en") {
    return href;
  }

  if (href.startsWith("/") && !href.startsWith("//")) {
    return localizedAppPath(href, locale);
  }

  return href;
}

function localizedProductHref(href: string, locale: AppsAvLocale) {
  if (href.startsWith("/") && !href.startsWith("//")) {
    return preserveLangForLocalHref(href, locale);
  }

  if (locale === "en") {
    return href;
  }

  try {
    const url = new URL(href);
    const path = url.pathname === "/" ? "" : url.pathname.replace(/^\/(en|es|fr|de|ca)(?=\/|$)/, "");
    url.pathname = `/${locale}${path}`;
    return url.toString().replace(/\/$/, "");
  } catch {
    return href;
  }
}
