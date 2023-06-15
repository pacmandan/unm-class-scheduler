function circle(filled:boolean, letter:string) {
    let colors = filled ? 'bg-green-700 text-black' : 'bg-slate-500 text-black'
    return (<div className={`m-1 w-4 h-4 leading-4 rounded-[50%] text-center text-sm ${colors}`}>
        {letter}
    </div>)
}

const all_days: Day[] = ['U', 'M', 'T', 'W', 'R', 'F', 'S']

const CourseTag = ({section}: {section: Section}) => {
    return (<div className='w-96 mt-[-2px] pl-3 pr-3 pb-1 pt-1 border-solid border-2 border-black'>
    <div className='flex'>
        <p className='text-left w-[33%]'>{section.status}</p>
        <p className='text-center w-[33%]'>{section.campus.name}</p>
        <p className='text-right w-[33%]'>{section.crn}</p>
    </div>
    <h1 className='text-xl'>{section.course.subject.code} {section.course.number} - {section.course.title}</h1>
    <p>Section {section.number}</p>
    {section.meeting_times.map((meeting_time: MeetingTime) => {
        return(<>
            <div className='flex'>
                <div className='ml-2 mt-1 leading-4'>
                    {meeting_time.start_time} - {meeting_time.end_time}
                </div>
                <div className='flex ml-2'>
                    {all_days.map((day) => {
                        return circle(meeting_time.days.includes(day), day)
                    })}
                </div>
                <div className='ml-2 mt-1 leading-4'>
                    {meeting_time.building.code} {meeting_time.room}
                </div>
            </div>
        </>)
    })}
</div>)
}

export default CourseTag