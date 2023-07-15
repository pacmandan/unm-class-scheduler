import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import { Section } from '../catalog'
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
        doSearch(state, _params) {
            state.results = testData.search_results as Section[]
        }
    },
    extraReducers: builder => {
        builder
        .addCase(fetchResults.fulfilled, (state, action) => {
            console.log("IN REDUCER!")
            console.log(action.payload)
            state.results = action.payload
            //state.results = action.payload
        })
    }
})

export const { nextPage, prevPage, changePerPage, doSearch } = searchSlice.actions;

export default searchSlice.reducer