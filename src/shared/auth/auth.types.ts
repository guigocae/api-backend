export type ClerkAuth = {
  clerkUserId: string;
  sessionId?: string;
  azp?: string;
};

export type RequestWithAuth = Request & { auth?: ClerkAuth };
