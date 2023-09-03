import { useState } from 'react'
import { Section, Day, MeetingTime, Instructor, Building, Crosslist } from '@/catalog'

function circle(filled:boolean, letter:string) {
    let colors = filled ? 'bg-red-400 text-black' : 'bg-white text-black'
    return (<div key={letter} className={`m-1 w-6 h-6 leading-6 rounded-[50%] text-center ${colors}`}>
        {letter}
    </div>)
}

const all_days: Day[] = ['U', 'M', 'T', 'W', 'R', 'F', 'S']

const formatTimeSeconds = (time: string) => {
  return formatTimeNumber(time.split(":").slice(0,2).join(""));
}

const formatTimeNumber = (time: string) => {
  // Time string format is "HHMM" in 24hr format. I want to return "HH:MM AM/PM" (12hr format).
  // JS only does full Date objects, not just Time, so "Fine. I guess I'll do it myself."
  let hh24 = parseInt(time.slice(0,2));
  let mm = time.slice(2,4);
  // I doubt we'll ever have any midnight classes,
  // and if there are, it'll probably be 0000, not 2400,
  // but just in case, mod24 this.
  let ampm = hh24 % 24 >= 12 ? "PM" : "AM";
  // Javascript modulo isn't actually a modulo (it's a remainder), and we want a range from 1 - 12, not 0 - 12.
  // Hence the convoluted weirdness here.
  let hh12 = ((hh24 - 1) % 12 + 12) % 12 + 1;
  // Leaving this here in case I want to pad the hour.
  // let hh = hh12 < 10 ? hh12.toString().padStart(2, '0') : hh12.toString();
  let hh = hh12.toString();
  return `${hh}:${mm} ${ampm}`
}

const formatTime = (time: string) => {
  if (!time) {
    return null
  }

  if(time.match(/[0-9][0-9][0-9][0-9]/)) {
    return formatTimeNumber(time)
  } else if(time.match(/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/)) {
    return formatTimeSeconds(time)
  } else {
    return time
  }
}

const buildingRender = (building: Building, room: String) => {
  if(!building) {
    return <p></p>;
  }
  return (
    <p className='mt-2 text-sm' title={`${building.name} ${room}`}>
      {building.code} {room}
    </p>
  )
}

const instructorString = (instructor: Instructor) => {
  let mi = instructor.middle ? ` ${instructor.middle} ` : ' '
  let primary = instructor.primary ? '* ' : '- ';
  return `${primary}${instructor.first}${mi}${instructor.last} (${instructor.email})`
}

const crosslists = (crosslists: Array<Crosslist>) => {
  if (crosslists.length === 0) { return null }
  return (<>
    <div>Crosslist CRNS:</div>
    {crosslists.map((crosslist: Crosslist) => {
      return (<div>- {crosslist.crn}</div>)
    })}
  </>)
}

function ResultRow({section}: {section: Section}) {
  const [open, setOpen] = useState(false)

  const toggleDescription = () => { setOpen(!open) }

  return (<div style={
      {'gridTemplateAreas': '\
        "status name name name crn" \
        "campus schedule schedule list btn" \
        "details details details details details"\
      '}}
      className='grid grid-cols-[40px_1fr_1fr_1fr_auto] grid-rows-[1fr_auto_auto] m-1 p-2 border-black border-2'>

    <p style={{'gridArea': 'status'}} className='break-all text-xl font-bold' title={`${section.status.name}`}>{section.status.code}</p>
    <p style={{'gridArea': 'name'}} className='font-bold text-lg ml-3'>{section.subject.code} {section.course.number}.{section.number} - {section.course.title}</p>
    <p style={{'gridArea': 'crn'}} className='font-bold text-lg'>{section.crn}</p>

    <p style={{'gridArea': 'campus'}} className='leading-8' title={section.campus.name}>{section.campus.code}</p>

    <div style={{'gridArea': 'schedule'}} className='ml-3'>
      {section.meeting_times.map((meeting_time: MeetingTime, index: number) => {
        return(<div key={index} className='grid grid-cols-[minmax(auto,20%)_minmax(auto,35%)_1fr]'>
          {buildingRender(meeting_time.building, meeting_time.room)}
          <p className='ml-3 mt-2 text-sm'>{formatTime(meeting_time.start_time)} - {formatTime(meeting_time.end_time)}</p>
          <div className='ml-3 grid grid-cols-[26px_26px_26px_26px_26px_26px_26px]'>{all_days.map((day) => {
            return circle(meeting_time.days.includes(day), day)
          })}</div>
        </div>)
      })}
    </div>

    <div style={{'gridArea': 'list'}} className='text-sm'>
      <p className='font-bold'>Enrolled: {section.enrollment}/{section.enrollment_max} (Waitlist: {section.waitlist}/{section.waitlist_max})</p>
      <p>{section.part_of_term.name} - {section.delivery_type.name}</p>
      <p>{section.instructional_method ? section.instructional_method.name : '-'}</p>
    </div>

    <div style={{'gridArea': 'btn'}} className='relative'>
      <button onClick={toggleDescription} className='absolute bottom-0 right-0 w-28 border-2'>
        {open ? "Hide Details" : "Show Details"}
      </button>
    </div>

    {open && <div style={{'gridArea': 'details'}} className='mt-4'>
      <div style={{'gridTemplateAreas': '\
        "desc desc desc" \
        "instr . crosslists" \
      '}} className='grid grid-rows-[auto_auto] grid-col-3'>
        <div style={{'gridArea': 'desc'}}>{section.course.catalog_description}</div>
        <div style={{'gridArea': 'instr'}}>{section.instructors.map((instructor: Instructor) => {
          return(<div key={instructor.email} className='ml-1'>{instructorString(instructor)}</div>)
        })}</div>
        <div style={{'gridArea': 'crosslists'}}>{crosslists(section.crosslists)}</div>
      </div>
    </div>}
  </div>)
}

export default ResultRow