"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";

interface Banner {
  id: string;
  title: string;
  subtitle: string | null;
  type: string;
  bg_color: string | null;
  bg_gradient_start: string | null;
  bg_gradient_end: string | null;
  icon: string | null;
  deeplink: string | null;
  external_url: string | null;
  is_active: boolean;
  priority: number;
  starts_at: string | null;
  ends_at: string | null;
}

const typeColors: Record<string, string> = {
  info: "bg-blue-500/20 text-blue-400",
  promo: "bg-amber-500/20 text-amber-400",
  feature: "bg-purple-500/20 text-purple-400",
  announcement: "bg-green-500/20 text-green-400",
};

const defaultBanner = {
  title: "",
  subtitle: "",
  type: "info",
  bg_color: "#3B82F6",
  bg_gradient_start: "#1E3A5F",
  bg_gradient_end: "#3B82F6",
  icon: "sparkles",
  image_url: "",
  deeplink: "",
  external_url: "",
  priority: 0,
  starts_at: "",
  ends_at: "",
};

export function BannerList({ banners }: { banners: Banner[] }) {
  const [showForm, setShowForm] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [form, setForm] = useState(defaultBanner);
  const [saving, setSaving] = useState(false);
  const router = useRouter();

  const [uploading, setUploading] = useState(false);

  async function handleImageUpload(file: File) {
    setUploading(true);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res = await fetch("/api/banners/upload", {
        method: "POST",
        body: formData,
      });
      const data = await res.json();
      if (data.image_url) {
        setForm((f) => ({ ...f, image_url: data.image_url }));
      }
    } catch {
      alert("Upload failed");
    }
    setUploading(false);
  }

  function startEdit(b: Banner) {
    setForm({
      title: b.title,
      subtitle: b.subtitle ?? "",
      type: b.type,
      bg_color: b.bg_color ?? "#3B82F6",
      bg_gradient_start: b.bg_gradient_start ?? "",
      bg_gradient_end: b.bg_gradient_end ?? "",
      icon: b.icon ?? "",
      image_url: "",
      deeplink: b.deeplink ?? "",
      external_url: b.external_url ?? "",
      priority: b.priority,
      starts_at: b.starts_at ?? "",
      ends_at: b.ends_at ?? "",
    });
    setEditId(b.id);
    setShowForm(true);
  }

  function startCreate() {
    setForm(defaultBanner);
    setEditId(null);
    setShowForm(true);
  }

  async function handleSave() {
    setSaving(true);
    const method = editId ? "PUT" : "POST";
    const url = editId ? `/api/banners/${editId}` : "/api/banners";
    await fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form),
    });
    setSaving(false);
    setShowForm(false);
    router.refresh();
  }

  async function handleToggle(id: string, active: boolean) {
    await fetch(`/api/banners/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ is_active: !active }),
    });
    router.refresh();
  }

  async function handleDelete(id: string) {
    if (!confirm("Delete this banner?")) return;
    await fetch(`/api/banners/${id}`, { method: "DELETE" });
    router.refresh();
  }

  const inputClass =
    "w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm";

  return (
    <div className="space-y-4">
      <button
        onClick={startCreate}
        className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium"
      >
        + New Banner
      </button>

      {showForm && (
        <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-6 space-y-4">
          <h3 className="text-lg font-semibold">
            {editId ? "Edit Banner" : "Create Banner"}
          </h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-gray-400 mb-1">Title *</label>
              <input className={inputClass} value={form.title}
                onChange={(e) => setForm({ ...form, title: e.target.value })} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Subtitle</label>
              <input className={inputClass} value={form.subtitle}
                onChange={(e) => setForm({ ...form, subtitle: e.target.value })} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Type</label>
              <select className={inputClass} value={form.type}
                onChange={(e) => setForm({ ...form, type: e.target.value })}>
                <option value="info">Info</option>
                <option value="promo">Promo</option>
                <option value="feature">Feature</option>
                <option value="announcement">Announcement</option>
              </select>
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Banner Image</label>
              <div className="flex items-center gap-3">
                <label className="cursor-pointer bg-[#38383A] hover:bg-[#48484A] text-gray-300 px-4 py-2.5 rounded-lg text-sm">
                  {uploading ? "Uploading..." : form.image_url ? "Replace Image" : "Upload Image"}
                  <input type="file" accept="image/*" className="hidden"
                    onChange={(e) => e.target.files?.[0] && handleImageUpload(e.target.files[0])} />
                </label>
                {form.image_url && (
                  <span className="text-xs text-green-400">Image uploaded</span>
                )}
              </div>
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Icon (lucide name)</label>
              <input className={inputClass} value={form.icon} placeholder="sparkles"
                onChange={(e) => setForm({ ...form, icon: e.target.value })} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Gradient Start</label>
              <input className={inputClass} value={form.bg_gradient_start} placeholder="#1E3A5F"
                onChange={(e) => setForm({ ...form, bg_gradient_start: e.target.value })} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Gradient End</label>
              <input className={inputClass} value={form.bg_gradient_end} placeholder="#3B82F6"
                onChange={(e) => setForm({ ...form, bg_gradient_end: e.target.value })} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Deeplink (in-app route)</label>
              <input className={inputClass} value={form.deeplink} placeholder="/premium"
                onChange={(e) => setForm({ ...form, deeplink: e.target.value })} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">External URL</label>
              <input className={inputClass} value={form.external_url} placeholder="https://..."
                onChange={(e) => setForm({ ...form, external_url: e.target.value })} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Priority</label>
              <input className={inputClass} type="number" value={form.priority}
                onChange={(e) => setForm({ ...form, priority: parseInt(e.target.value) || 0 })} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Starts At</label>
              <input className={inputClass} type="datetime-local" value={form.starts_at}
                onChange={(e) => setForm({ ...form, starts_at: e.target.value })} />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Ends At</label>
              <input className={inputClass} type="datetime-local" value={form.ends_at}
                onChange={(e) => setForm({ ...form, ends_at: e.target.value })} />
            </div>
          </div>
          <div className="flex gap-3 pt-2">
            <button onClick={handleSave} disabled={saving}
              className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg text-sm font-medium disabled:opacity-50">
              {saving ? "Saving..." : "Save"}
            </button>
            <button onClick={() => setShowForm(false)}
              className="text-gray-400 hover:text-white px-4 py-2 text-sm">
              Cancel
            </button>
          </div>
        </div>
      )}

      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-visible">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#38383A] text-gray-500 text-left">
              <th className="px-5 py-3">Banner</th>
              <th className="px-5 py-3">Type</th>
              <th className="px-5 py-3">Deeplink</th>
              <th className="px-5 py-3">Priority</th>
              <th className="px-5 py-3">Status</th>
              <th className="px-5 py-3">Schedule</th>
              <th className="px-5 py-3"></th>
            </tr>
          </thead>
          <tbody>
            {banners.map((b) => (
              <tr key={b.id} className="border-b border-[#38383A] hover:bg-[#2C2C2E]">
                <td className="px-5 py-3">
                  <div className="font-medium">{b.title}</div>
                  {b.subtitle && (
                    <div className="text-xs text-gray-500">{b.subtitle}</div>
                  )}
                </td>
                <td className="px-5 py-3">
                  <span className={`px-2 py-0.5 rounded-full text-xs ${typeColors[b.type] || typeColors.info}`}>
                    {b.type}
                  </span>
                </td>
                <td className="px-5 py-3 text-gray-400 text-xs">
                  {b.deeplink || b.external_url || "—"}
                </td>
                <td className="px-5 py-3 text-gray-400">{b.priority}</td>
                <td className="px-5 py-3">
                  <button onClick={() => handleToggle(b.id, b.is_active)}
                    className={`px-2 py-0.5 rounded-full text-xs ${b.is_active ? "bg-green-500/20 text-green-400" : "bg-gray-500/20 text-gray-400"}`}>
                    {b.is_active ? "Active" : "Inactive"}
                  </button>
                </td>
                <td className="px-5 py-3 text-xs text-gray-500">
                  {b.starts_at || b.ends_at
                    ? `${b.starts_at ? new Date(b.starts_at).toLocaleDateString() : "—"} → ${b.ends_at ? new Date(b.ends_at).toLocaleDateString() : "∞"}`
                    : "Always"}
                </td>
                <td className="px-5 py-3">
                  <div className="flex gap-2">
                    <button onClick={() => startEdit(b)}
                      className="text-xs text-blue-400 hover:text-blue-300">Edit</button>
                    <button onClick={() => handleDelete(b.id)}
                      className="text-xs text-gray-500 hover:text-red-400">Delete</button>
                  </div>
                </td>
              </tr>
            ))}
            {banners.length === 0 && (
              <tr>
                <td colSpan={7} className="px-5 py-8 text-center text-gray-500">
                  No banners yet. Click "+ New Banner" to create one.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
