import { useAccountToken, useAccountUser } from "@avalsys/account-av-web";
import { useQuery } from "@tanstack/react-query";
import { ConvexReactClient } from "convex/react";
import { makeFunctionReference } from "convex/server";
import { useEffect, useMemo, useState } from "react";
import { getMomentsApiBaseUrl, getMomentsConvexUrl } from "@/lib/moments-config";
import { MomentsApiClient } from "@/lib/moments-api";
import type { InProgressMoment, MomentWorkspace } from "@/lib/moments-types";

type Collection = "in_progress" | "gallery";
type SubscriptionState<T> =
  | { status: "missing-config"; data: T | null; error: null }
  | { status: "loading"; data: T | null; error: null }
  | { status: "ready"; data: T; error: null }
  | { status: "error"; data: T | null; error: Error };

const EMPTY_MOMENTS: InProgressMoment[] = [];

export function useMomentsApiClient() {
  const getToken = useAccountToken();
  return useMemo(() => new MomentsApiClient(getMomentsApiBaseUrl(), getToken), [getToken]);
}

export function useMomentsOwnerUserId() {
  const accountUser = useAccountUser();
  const user = accountUser.data as { id?: string; userId?: string; ownerUserId?: string } | undefined;
  return user?.id ?? user?.userId ?? user?.ownerUserId ?? null;
}

export function useMomentsRealtimeSession() {
  const client = useMomentsApiClient();
  const ownerUserId = useMomentsOwnerUserId();
  const convexUrl = getMomentsConvexUrl();

  return useQuery({
    enabled: Boolean(ownerUserId && convexUrl),
    queryFn: () => client.createRealtimeSession(),
    queryKey: ["moments-av", "realtime-session", ownerUserId, convexUrl],
    staleTime: 4 * 60 * 1000
  });
}

export function useMomentsList(collection: Collection): SubscriptionState<InProgressMoment[]> {
  const ownerUserId = useMomentsOwnerUserId();
  const convexUrl = getMomentsConvexUrl();
  const realtimeSession = useMomentsRealtimeSession();
  const args = useMemo(() => {
    if (!ownerUserId || !realtimeSession.data?.realtimeSessionId) {
      return null;
    }
    return {
      ownerUserId,
      realtimeSessionId: realtimeSession.data.realtimeSessionId,
      collection
    };
  }, [collection, ownerUserId, realtimeSession.data?.realtimeSessionId]);

  return useConvexSubscription<InProgressMoment[]>(convexUrl, "moments:listMoments", args, EMPTY_MOMENTS);
}

export function useMomentWorkspace(momentId: string | null): SubscriptionState<MomentWorkspace | null> {
  const ownerUserId = useMomentsOwnerUserId();
  const convexUrl = getMomentsConvexUrl();
  const realtimeSession = useMomentsRealtimeSession();
  const args = useMemo(() => {
    if (!ownerUserId || !momentId || !realtimeSession.data?.realtimeSessionId) {
      return null;
    }
    return {
      ownerUserId,
      realtimeSessionId: realtimeSession.data.realtimeSessionId,
      momentId
    };
  }, [momentId, ownerUserId, realtimeSession.data?.realtimeSessionId]);

  return useConvexSubscription<MomentWorkspace | null>(convexUrl, "moments:getMomentWorkspace", args, null);
}

function useConvexSubscription<T>(convexUrl: string, functionName: string, args: Record<string, unknown> | null, initialData: T): SubscriptionState<T> {
  const [state, setState] = useState<SubscriptionState<T>>(
    convexUrl ? { status: "loading", data: initialData, error: null } : { status: "missing-config", data: initialData, error: null }
  );

  useEffect(() => {
    if (!convexUrl) {
      setState({ status: "missing-config", data: initialData, error: null });
      return undefined;
    }
    if (!args) {
      setState({ status: "loading", data: initialData, error: null });
      return undefined;
    }

    const client = new ConvexReactClient(convexUrl);
    const watch = client.watchQuery(makeFunctionReference<"query">(functionName), args);
    const unsubscribe = watch.onUpdate(() => {
      try {
        setState({ status: "ready", data: watch.localQueryResult() as T, error: null });
      } catch (caught) {
        setState({ status: "error", data: initialData, error: caught instanceof Error ? caught : new Error(String(caught)) });
      }
    });

    return () => {
      unsubscribe();
      void client.close();
    };
  }, [args, convexUrl, functionName, initialData]);

  return state;
}
