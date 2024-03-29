import React from 'react'
import ReactDOM from 'react-dom/client'
import { Provider } from 'react-redux'
import store from './store'
import HomePage from './pages/Home'
import AboutPage from './pages/About'
import {
  createBrowserRouter,
  RouterProvider,
} from 'react-router-dom'
import './index.css'
import ScheduleBuilder from './pages/scheduleBuilder/ScheduleBuilder'
import Layout from './layout/Layout'

const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout><HomePage /></Layout>
  },
  {
    path: '/about',
    element: <Layout><AboutPage /></Layout>
  },
  {
    path: '/scheduleBuilder',
    element: <Layout><ScheduleBuilder /></Layout>
  },
]);

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <Provider store={store}>
      <RouterProvider router={router} />
    </Provider>
  </React.StrictMode>
);
