import { configureStore } from "@reduxjs/toolkit";
import searchReducer from "./features/search";
import scheduleReducer from "./features/schedule";

export default configureStore({
    reducer: {
        search: searchReducer,
        schedule: scheduleReducer,
    }
})