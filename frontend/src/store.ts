import { configureStore } from "@reduxjs/toolkit";
import searchReducer from "./features/search";
import scheduleReducer from "./features/schedule";
import formReferenceReducer from "./features/formReference";

const store = configureStore({
    reducer: {
        search: searchReducer,
        schedule: scheduleReducer,
        formReference: formReferenceReducer,
    }
})

export type RootState = ReturnType<typeof store.getState>

export type AppDispatch = typeof store.dispatch

export default store;