import { createSlice } from "@reduxjs/toolkit";

/**
 * Holds the sections that the user has selected for their schedule.
 */

export const scheduleSlice = createSlice({
    name: 'schedule',
    initialState: {
        selected: {},
    },
    reducers: {
        addSection: (state, _action) => {
            state
        },
        removeSection: (state, _action) => {
            state
        },
    }
})

export const { addSection, removeSection } = scheduleSlice.actions;

export default scheduleSlice.reducer