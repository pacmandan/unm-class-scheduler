import FullCalendar from '@fullcalendar/react';
import timeGridPlugin from '@fullcalendar/timegrid'
import { MeetingTime, SelectedSection, Day } from '@/catalog';
import { useSelector } from 'react-redux';
import { RootState } from '@/store';

const daysMap: any = {
  'U': '0',
  'M': '1',
  'T': '2',
  'W': '3',
  'R': '4',
  'F': '5',
  'S': '6',
}

const meetingTimeToEvent = (selected: SelectedSection, meetingTime: MeetingTime) => {
  console.log(selected)
  let mt = {
    title: `${selected.section.subject.code}${selected.section.course.number} ${selected.section.number}`,
    startTime: meetingTime.start_time.slice(0, 5),
    endTime: meetingTime.end_time.slice(0, 5),
    daysOfWeek: meetingTime.days.map((day: Day) => daysMap[day]),
    backgroundColor: selected.color
  }
  console.log(mt)
  return mt;
}

const ScheduleCalendar = () => {
  const schedule = useSelector((state: RootState) => state.schedule)
  const events = Object.entries(schedule.selected).map(([_crn, selected]) => {
    return selected.section.meeting_times.map((meetingTime) => {
      return meetingTimeToEvent(selected, meetingTime)
    })
  }).flat()
  return (<FullCalendar
    plugins={[ timeGridPlugin ]}
    initialView='timeGridWeek'
    //slotDuration={'01:00:00'}
    allDaySlot={false}
    headerToolbar={false}
    initialDate={'2022-01-01'}
    dayHeaderFormat={{weekday: 'short'}}
    height={"100%"}
    events={events}
    //displayEventTime={false}
  />)
}

export default ScheduleCalendar