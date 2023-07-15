import SearchResults from './SearchResults';
// Wrap this calendar in a component. So we can feed state into it.
import FullCalendar from '@fullcalendar/react';
import timeGridPlugin from '@fullcalendar/timegrid'
import { useDispatch } from 'react-redux';
import { fetchResults } from './features/search';
import { useEffect } from 'react';
import { AppDispatch } from './store';

const Sandbox = () => {
  const dispatch = useDispatch<AppDispatch>()

  useEffect(() => {
    dispatch(fetchResults({}))
  }, [])
  return (<div>
    <h1>Sandbox!</h1><br/>
    <div className='flex-auto bg-red-950 h-auto w-auto'>
      <div className='flex'>
        <FullCalendar
            plugins={[ timeGridPlugin ]}
            initialView='timeGridWeek'
            allDaySlot={false}
            headerToolbar={false}
            initialDate={'2022-01-01'}
            dayHeaderFormat={{weekday: 'short'}}
            height={'auto'}
            aspectRatio={1.35}
            events={[
                { title: 'CS 101', daysOfWeek: [ '1', '3', '5' ], startTime: '08:00', endTime: '09:00' }
            ]}
          />
        <div className=''>
          <SearchResults />
        </div>
      </div>
    </div>
  </div>)
}

export default Sandbox