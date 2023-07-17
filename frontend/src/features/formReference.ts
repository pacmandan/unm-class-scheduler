import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import { Semester, Campus, Subject } from '../catalog'
import client from "../api/client"

export const fetchInitReference = createAsyncThunk('search/fetchInitReference', async () => {
  // TODO: Handle failure
  const semesters = await client.get_semesters()
  const campuses = await client.get_campuses()
  const subjects = await client.get_subjects()

  return {
      semesters: semesters.data,
      campuses: campuses.data,
      subjects: subjects.data,
  }
})

export interface ReferenceState {
  semesters: Semester[],
  campuses: Campus[],
  subjects: Subject[],
}

const initialState : ReferenceState = {
  semesters: [],
  campuses: [],
  subjects: [],
}

export const referenceSlice = createSlice({
  name: 'formReference',
  initialState,
  reducers: {},
  extraReducers: builder => {
    builder.addCase(fetchInitReference.fulfilled, (state, action) => {
      state.semesters = action.payload.semesters
      state.campuses = action.payload.campuses
      state.subjects = action.payload.subjects
    })
  }
})

export const {} = referenceSlice.actions;

export default referenceSlice.reducer