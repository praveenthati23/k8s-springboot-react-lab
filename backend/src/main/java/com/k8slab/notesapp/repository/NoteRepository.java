package com.k8slab.notesapp.repository;

import com.k8slab.notesapp.model.Note;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    // JpaRepository already gives us save, findAll, findById, deleteById -
    // no custom queries needed for this lab's CRUD scope
}
