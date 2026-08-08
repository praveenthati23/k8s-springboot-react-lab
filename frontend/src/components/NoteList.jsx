export default function NoteList({ notes, onDelete }) {
  if (notes.length === 0) {
    return <p className="empty-state">No notes yet - add one above.</p>
  }

  return (
    <div className="note-list">
      {notes.map((note) => (
        <div className="note-card" key={note.id}>
          <div className="note-card-header">
            <h3>{note.title}</h3>
            <button className="delete-btn" onClick={() => onDelete(note.id)}>
              Delete
            </button>
          </div>
          {note.content && <p>{note.content}</p>}
          <span className="note-date">
            {new Date(note.createdAt).toLocaleString()}
          </span>
        </div>
      ))}
    </div>
  )
}
