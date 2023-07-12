import { createSlice } from "@reduxjs/toolkit";
import { Section } from '../catalog'
import testData from '../test-state.json'

/**
 * The state represented from performing a search.
 * Holds the current page of results.
 */

interface SearchState {
    results: Section[],
    page: number,
    perPage: number,
}

const initialState : SearchState = {
    results: testData.search_results as Section[],
    page: 1,
    perPage: 10,
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
        doSearch(state) {
            state.results = testData.search_results as Section[]
        }
    }
})

export const { nextPage, prevPage, changePerPage, doSearch } = searchSlice.actions;

export default searchSlice.reducer