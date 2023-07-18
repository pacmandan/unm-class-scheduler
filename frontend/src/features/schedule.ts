import { PayloadAction, createSlice } from "@reduxjs/toolkit";
import { Section } from "../catalog";

/**
 * Holds the sections that the user has selected for their schedule.
 */

// interface SelectedSection {
//     index: number,
//     color: string,
//     section: Section
// }

interface ScheduleState {
    selected: {[key: string]: Section}
}

const initialState: ScheduleState = {
    selected: {}
}

export const scheduleSlice = createSlice({
    name: 'schedule',
    initialState,
    reducers: {
        addSection: (state, action: PayloadAction<Section>) => {
            state.selected[action.payload.crn] = action.payload
        },
        removeSection: (state, action: PayloadAction<Section>) => {
            delete state.selected[action.payload.crn]
        },
    }
})

export const { addSection, removeSection } = scheduleSlice.actions;

export default scheduleSlice.reducer