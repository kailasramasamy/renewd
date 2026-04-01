import { query } from "@/lib/db";
import { ProgramConfig } from "./program-config";
import { TesterList } from "./tester-list";

interface Program {
  id: string;
  app_name: string;
  description: string | null;
  reward: string;
  platforms: string[];
  tester_cap: number;
  status: string;
  android_test_link: string | null;
  ios_test_link: string | null;
  tester_count: number;
}

interface Tester {
  id: string;
  name: string;
  email: string;
  platform: string;
  device_info: string | null;
  status: string;
  created_at: string;
  feedback_count: number;
}

export const dynamic = "force-dynamic";

export default async function TestersPage() {
  const programs = await query<Program>(
    `SELECT p.*,
            (SELECT COUNT(*)::int FROM testers t WHERE t.program_id = p.id) AS tester_count
     FROM tester_programs p
     ORDER BY p.created_at DESC`
  );

  const program = programs[0] ?? null;

  let testers: Tester[] = [];
  if (program) {
    testers = await query<Tester>(
      `SELECT t.id, t.name, t.email, t.platform, t.device_info, t.status, t.created_at,
              (SELECT COUNT(*)::int FROM tester_feedback f WHERE f.tester_id = t.id) AS feedback_count
       FROM testers t
       WHERE t.program_id = $1
       ORDER BY t.created_at DESC`,
      [program.id]
    );
  }

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Tester Recruitment</h2>

      {program ? (
        <>
          <div className="grid grid-cols-4 gap-4 mb-8">
            <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
              <p className="text-gray-500 text-sm">Status</p>
              <p className={`text-2xl font-bold mt-2 ${program.status === "open" ? "text-green-400" : "text-red-400"}`}>
                {program.status.charAt(0).toUpperCase() + program.status.slice(1)}
              </p>
            </div>
            <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
              <p className="text-gray-500 text-sm">Testers</p>
              <p className="text-2xl font-bold mt-2">
                {program.tester_count} / {program.tester_cap}
              </p>
            </div>
            <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
              <p className="text-gray-500 text-sm">Platforms</p>
              <p className="text-2xl font-bold mt-2">
                {program.platforms.map((p) => p === "android" ? "Android" : "iOS").join(", ")}
              </p>
            </div>
            <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
              <p className="text-gray-500 text-sm">Reward</p>
              <p className="text-lg font-bold mt-2 text-yellow-400">{program.reward}</p>
            </div>
          </div>

          <ProgramConfig program={program} />

          <div className="mt-8">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold">Signup Link</h3>
            </div>
            <div className="bg-[#1C1C1E] rounded-xl border border-[#38383A] p-4">
              <code className="text-blue-400 text-sm break-all">
                https://renewd.app/testers.html?id={program.id}
              </code>
            </div>
          </div>

          <TesterList testers={testers} />
        </>
      ) : (
        <div className="bg-[#1C1C1E] rounded-2xl p-8 border border-[#38383A] text-center text-gray-500">
          No tester program configured yet.
        </div>
      )}
    </div>
  );
}
