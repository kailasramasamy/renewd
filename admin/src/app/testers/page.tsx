import { query } from "@/lib/db";
import { ProgramList } from "./program-list";

interface Program {
  id: string;
  app_name: string;
  description: string | null;
  reward: string;
  platforms: string[];
  tester_cap: number;
  status: string;
  test_duration_days: number;
  android_test_link: string | null;
  ios_test_link: string | null;
  tester_count: number;
  feedback_count: number;
  created_at: string;
}

export const dynamic = "force-dynamic";

export default async function TestersPage() {
  const programs = await query<Program>(
    `SELECT p.*,
            (SELECT COUNT(*)::int FROM testers t WHERE t.program_id = p.id) AS tester_count,
            (SELECT COUNT(*)::int FROM tester_feedback f WHERE f.program_id = p.id) AS feedback_count
     FROM tester_programs p
     ORDER BY p.created_at DESC`
  );

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Tester Recruitment</h2>
      <ProgramList programs={programs} />
    </div>
  );
}
