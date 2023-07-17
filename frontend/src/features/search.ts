import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import { Section } from '../catalog'
import client from "../api/client"

interface SearchParams {
    semester?: string,
    campus?: string,
    subject?: string,
    page?: number,
    perPage?: number,
}

// interface ResultsThunkResponse {
//     results: Section[],
//     params: SearchParams
// }

// export const fetchResults = createAsyncThunk<ResultsThunkResponse, SearchParams, {state: RootState, dispatch: AppDispatch}>('search/fetchResults', async (params, thunkApi) => {
//     const state = thunkApi.getState()
//     console.log(state)
//     // TODO: Handle failure
//     const response = await client.search(params)
//     return {
//         results: response.data,
//         params: params
//     }
// })

export const fetchResults = createAsyncThunk('search/fetchResults', async (params: any) => {
    // TODO: Handle failure
    const response = await client.search(params)
    return {
        results: response.data,
        params: params
    }
})

/**
 * The state represented from performing a search.
 * Holds the current page of results.
 */

interface SearchState {
    results: Section[],
    page: number,
    perPage: number,
    lastSearchParams?: SearchParams,
}

const initialState : SearchState = {
    results: [],
    page: 1,
    perPage: 10,
    lastSearchParams: {},
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
            state.results = action.payload.results
            state.lastSearchParams = action.payload.params
            //state.results = action.payload
        })
    }
})

export const { nextPage, prevPage, changePerPage } = searchSlice.actions;

export default searchSlice.reducer