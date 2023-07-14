import { configureStore } from "@reduxjs/toolkit";
import searchReducer from "./features/search";
import scheduleReducer from "./features/schedule";

const store = configureStore({
    reducer: {
        search: searchReducer,
        schedule: scheduleReducer,
    }
})

export type RootState = ReturnType<typeof store.getState>

export default store;