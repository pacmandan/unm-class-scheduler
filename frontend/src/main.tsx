import React from 'react'
import ReactDOM from 'react-dom/client'
import { Provider } from 'react-redux'
import store from './store'
import App from './App'
import HomePage from './Home'
import AboutPage from './About'
import {
  createBrowserRouter,
  RouterProvider,
} from 'react-router-dom'
import './index.css'
import Sandbox from './Sandbox'
import { fetchInitReference } from './features/formReference'
import ScheduleBuilder from './ScheduleBuilder'

const router = createBrowserRouter([
  {
    path: '/',
    element: <HomePage />
  },
  {
    path: '/about',
    element: <AboutPage />
  },
  {
    path: '/app',
    element: <App />
  },
  {
    path: '/scheduleBuilder',
    element: <ScheduleBuilder />
  },
  // TODO: Find a way to ONLY include this in dev environment.
  {
    path: '/sandbox',
    element: <Sandbox />
  }
]);

// Fetch initial state
store.dispatch(fetchInitReference())

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <Provider store={store}>
      <RouterProvider router={router} />
    </Provider>
  </React.StrictMode>
);
