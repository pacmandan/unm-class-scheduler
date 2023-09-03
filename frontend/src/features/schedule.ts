import { PayloadAction, createSlice } from "@reduxjs/toolkit";
import { Section, SelectedSection } from "@/catalog";

/**
 * Holds the sections that the user has selected for their schedule.
 */

interface ScheduleState {
  selected: {[key: string]: SelectedSection},
  availableColors: Array<string>,
  usedColors: Array<string>,
  defaultColor: string
}

const initialState: ScheduleState = {
  selected: {},
  availableColors: [
    '#155e75',
    '#14532d',
    '#581c87',
    '#7c2d12',
    '#ca8a04',
    '#7f1d1d',
  ],
  usedColors: [],
  defaultColor: '#7f1d1d'
}

export const scheduleSlice = createSlice({
  name: 'schedule',
  initialState,
  reducers: {
    addSection: (state, action: PayloadAction<Section>) => {
      const color = state.availableColors.find((c) => {
        return !state.usedColors.includes(c)
      }) || state.defaultColor

      state.selected[action.payload.crn] = {
        color: color,
        section: action.payload
      }

      state.usedColors.push(color)
    },
    removeSection: (state, action: PayloadAction<Section>) => {
      const index = state.usedColors.indexOf(state.selected[action.payload.crn].color)
      if (index > -1) { state.usedColors.splice(index, 1)}

      delete state.selected[action.payload.crn]
    },
  }
})

export const { addSection, removeSection } = scheduleSlice.actions;

export default scheduleSlice.reducer