import { useEffect, useState } from 'react'
import NoteForm from './components/NoteForm.jsx'
import NoteList from './components/NoteList.jsx'
import { getNotes, createNote, deleteNote } from './api.js'

export default function App() {
  const [notes, setNotes] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    loadNotes()
  }, [])

  async function loadNotes() {
    setLoading(true)
    setError(null)
    try {
      const data = await getNotes()
      // Newest first
      setNotes(data.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)))
    } catch (err) {
      setError('Could not reach the backend. Is it running?')
    } finally {
      setLoading(false)
    }
  }

  async function handleCreate(note) {
    const created = await createNote(note)
    setNotes((prev) => [created, ...prev])
  }

  async function handleDelete(id) {
    await deleteNote(id)
    setNotes((prev) => prev.filter((n) => n.id !== id))
  }

  return (
    <div className="app">
      <header>
        <h1>Notes</h1>
        <p className="subtitle">Kubernetes lab - Spring Boot + React + Postgres</p>
      </header>

      <NoteForm onCreate={handleCreate} />

      {loading && <p>Loading notes...</p>}
      {error && <p className="error">{error}</p>}
      {!loading && !error && <NoteList notes={notes} onDelete={handleDelete} />}
    </div>
  )
}
