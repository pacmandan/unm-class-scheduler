import SearchResults from './SearchResults';
// Wrap this calendar in a component. So we can feed state into it.
import FullCalendar from '@fullcalendar/react';
import timeGridPlugin from '@fullcalendar/timegrid'
const ScheduleSearch = () => {
  return (<div className='flex'>
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
</div>)
}

export default ScheduleSearch;