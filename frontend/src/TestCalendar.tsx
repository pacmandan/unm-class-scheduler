import React from 'react';
import FullCalendar from '@fullcalendar/react';
import timeGridPlugin from '@fullcalendar/timegrid'

export default class TestCalendar extends React.Component {
    render() {
        return (
            <FullCalendar
                plugins={[ timeGridPlugin ]}
                initialView='timeGridWeek'
                allDaySlot={false}
                headerToolbar={false}
                initialDate={'2022-01-01'}
                dayHeaderFormat={{weekday: 'short'}}
                height={'500px'}
                aspectRatio={1.35}
                events={[
                    { title: 'CS 101', daysOfWeek: [ '1', '3', '5' ], startTime: '08:00', endTime: '09:00' }
                ]}
            />
        )
    }
}