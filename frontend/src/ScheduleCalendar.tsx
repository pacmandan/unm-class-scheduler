import FullCalendar from '@fullcalendar/react';
import timeGridPlugin from '@fullcalendar/timegrid'
import { MeetingTime, Section, Day } from './catalog';
import { useSelector } from 'react-redux';
import { RootState } from './store';

const daysMap: any = {
  'U': '0',
  'M': '1',
  'T': '2',
  'W': '3',
  'R': '4',
  'F': '5',
  'S': '6',
}

const meetingTimeToEvent = (section: Section, meetingTime: MeetingTime) => {
  console.log(section)
  let mt = {
    title: `${section.subject.code} ${section.course.title}.${section.number}`,
    startTime: meetingTime.start_time.slice(0, 5),
    endTime: meetingTime.end_time.slice(0, 5),
    daysOfWeek: meetingTime.days.map((day: Day) => daysMap[day])
  }
  console.log(mt)
  return mt;
}

const ScheduleCalendar = () => {
  const schedule = useSelector((state: RootState) => state.schedule)
  const events = Object.entries(schedule.selected).map(([_crn, section]) => {
    return section.meeting_times.map((meetingTime) => {
      return meetingTimeToEvent(section, meetingTime)
    })
  }).flat()
  console.log(events)
  return (<FullCalendar
    plugins={[ timeGridPlugin ]}
    initialView='timeGridWeek'
    allDaySlot={false}
    headerToolbar={false}
    initialDate={'2022-01-01'}
    dayHeaderFormat={{weekday: 'short'}}
    height={"auto"}
    aspectRatio={1.35}
    events={events}
  />)
}

export default ScheduleCalendar