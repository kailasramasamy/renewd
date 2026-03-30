import { query } from "@/lib/db";
import { TicketList } from "./ticket-list";

interface Ticket {
  id: string;
  user_name: string | null;
  user_email: string | null;
  type: string;
  subject: string;
  description: string;
  status: string;
  device_info: string | null;
  reply_count: number;
  needs_response: boolean;
  created_at: string;
  updated_at: string;
}

async function getTickets(): Promise<Ticket[]> {
  return query<Ticket>(`
    SELECT t.id, u.name AS user_name, u.email AS user_email,
           t.type, t.subject, t.description, t.status, t.device_info,
           (SELECT COUNT(*)::int FROM ticket_replies r WHERE r.ticket_id = t.id) AS reply_count,
           (
             t.status IN ('open', 'in_progress') AND (
               NOT EXISTS (SELECT 1 FROM ticket_replies r WHERE r.ticket_id = t.id)
               OR (SELECT sender FROM ticket_replies r WHERE r.ticket_id = t.id ORDER BY r.created_at DESC LIMIT 1) = 'user'
             )
           ) AS needs_response,
           t.created_at::text, t.updated_at::text
    FROM support_tickets t
    JOIN users u ON u.id = t.user_id
    ORDER BY
      CASE t.status WHEN 'open' THEN 0 WHEN 'in_progress' THEN 1 ELSE 2 END,
      t.updated_at DESC
  `);
}

export const dynamic = "force-dynamic";

export default async function SupportPage() {
  const tickets = await getTickets();
  const needsResponse = tickets.filter((t) => t.needs_response).length;

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">
        Support Tickets ({needsResponse} need response)
      </h2>
      <TicketList tickets={tickets} />
    </div>
  );
}
