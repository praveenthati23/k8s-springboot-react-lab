// All requests go through a relative /api path. In production, nginx
// (see nginx.conf) reverse-proxies /api/* to the backend Service inside
// the cluster. In local dev, Vite's dev server proxy does the same
// thing (see vite.config.js). Either way, this file never needs to
// know the backend's actual hostname or port - same code, any
// environment.

const BASE_URL = '/api/notes'

export async function getNotes() {
  const res = await fetch(BASE_URL)
  if (!res.ok) throw new Error('Failed to fetch notes')
  return res.json()
}

export async function createNote(note) {
  const res = await fetch(BASE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(note)
  })
  if (!res.ok) {
    const err = await res.json().catch(() => ({}))
    throw new Error(err.message || 'Failed to create note')
  }
  return res.json()
}

export async function deleteNote(id) {
  const res = await fetch(`${BASE_URL}/${id}`, { method: 'DELETE' })
  if (!res.ok) throw new Error('Failed to delete note')
}
