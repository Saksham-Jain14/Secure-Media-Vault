import { createClient } from "@supabase/supabase-js";

export const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export type Context = {
  userId: string;
  supabase: typeof supabase;
};

export async function context({ request }: any): Promise<Context> {
  const token = request.headers.get("authorization")?.replace("Bearer ", "");
  if (!token) throw new Error("UNAUTHENTICATED");
  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data.user) throw new Error("UNAUTHENTICATED");

  return { userId: data.user.id, supabase };
}
