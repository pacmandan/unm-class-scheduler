import { createSlice } from "@reduxjs/toolkit";

/**
 * The state represented from performing a search.
 * Holds the current page of results.
 */

const initialState = {
    results: [],
    page: 1,
    perPage: 10,
}

export const searchSlice = createSlice({
    name: 'search',
    initialState,
    reducers: {
    }
})

export const {} = searchSlice.actions;

export default searchSlice.reducer