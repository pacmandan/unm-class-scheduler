import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import { Section, Semester, Campus, Subject } from '../catalog'
import testData from '../test-state.json'
import client from "../api/client"

export const fetchResults = createAsyncThunk('search/fetchResults', async (params: any) => {
  const response = await client.search(params)
  console.log("IN THUNK")
  console.log(response)
  return response.data
})

/**
 * The state represented from performing a search.
 * Holds the current page of results.
 */

interface SearchState {
    results: Section[],
    page: number,
    perPage: number,
    reference: {
        semesters: Semester[],
        campuses: Campus[],
        subjects: Subject[],
    }
    form: {
        semester?: string,
        campus?: string,
        subject?: string,
    },
}

const initialState : SearchState = {
    results: testData.search_results as Section[],
    page: 1,
    perPage: 10,
    reference: {
        semesters: [],
        campuses: [],
        subjects: [],
    },
    form: {},
}

export const searchSlice = createSlice({
    name: 'search',
    initialState,
    reducers: {
        nextPage(state) {
            state
        },
        prevPage(state) {
            state
        },
        changePerPage(state) {
            state
        },
    },
    extraReducers: builder => {
        builder
        .addCase(fetchResults.fulfilled, (state, action) => {
            //TODO: Change /search endpoint to include current page and current per-page.
            /*
            {results: [], page: 1, per_page: 10, total_pages: 3}
            */
            // Then update the full state to include current page number.
            // Not really sure how I'm going to do total pages...
            // Might want to put some more thought into pagination.
            console.log("IN REDUCER!")
            console.log(action.payload)
            state.results = action.payload
            //state.results = action.payload
        })
    }
})

export const { nextPage, prevPage, changePerPage } = searchSlice.actions;

export default searchSlice.reducer