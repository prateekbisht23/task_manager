import { createClient } from "@supabase/supabase-js";

export default async function handler(req: any, res: any) {
    if (req.method !== "GET") {
        return res.status(405).json({ error: "Method Not Allowed" });
    }

    const supabaseUrl = process.env.SUPABASE_URL!;
    const supabaseAnonKey = process.env.SUPABASE_ANON_KEY!;

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
        auth: { persistSession: false },
    });

    const token = req.headers.authorization?.split(" ")[1];
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    const { data, error: queryError } = await supabase
        .from("tasks")
        .select("*")
        .eq("user_id", user.id)
        .eq("status", "completed")
        .order("due_date", { ascending: false })
        .limit(5);

    if (queryError) {
        return res.status(500).json({ error: queryError.message });
    }

    return res.status(200).json({ recommendations: data });
}
