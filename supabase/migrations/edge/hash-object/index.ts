import { createClient } from "@supabase/supabase-js";
import crypto from "crypto";

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function hashObject(path: string) {
  const { data, error } = await supabase.storage.from("private").download(path);
  if (error || !data) throw new Error("Failed to read object");

  const hash = crypto.createHash("sha256");
  const buffer = await data.arrayBuffer();
  hash.update(Buffer.from(buffer));

  return { sha256: hash.digest("hex"), size: buffer.byteLength };
}
