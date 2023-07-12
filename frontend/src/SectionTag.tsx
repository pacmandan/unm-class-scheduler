import { useState } from 'react'
import { Section, Day, MeetingTime, Instructor } from './catalog'
// import SectionDetails from './SectionDetails'
import { formatTime } from './utils'

function circle(filled:boolean, letter:string) {
    let colors = filled ? 'bg-red-400 text-black' : 'bg-white text-black'
    return (<div className={`m-1 w-6 h-6 leading-6 rounded-[50%] text-center ${colors}`}>
        {letter}
    </div>)
}

const all_days: Day[] = ['U', 'M', 'T', 'W', 'R', 'F', 'S']

// type ModalProps = {
//     handleClose: () => void
// }
// TODO: Move this to its own generic component
// Should provide consistent header/close buttons, as well as children components
// const Modal = ({children, ...props}: PropsWithChildren<ModalProps>) => {
//     return (<div onClick={props.handleClose} className={`fixed top-0 left-0 w-full h-full bg-[#000000AA] block`}>
//         <div onClick={e => e.stopPropagation()} className='fixed bg-white w-[50%] h-auto top-[50%] left-[50%] -translate-x-1/2 -translate-y-1/2'>
//             {children}
//             <button onClick={props.handleClose}>Close</button>
//         </div>
//     </div>)
// }

const SectionTag = ({section}: {section: Section}) => {
    const [open, setOpen] = useState(false)

    const toggleDescription = () => {
        setOpen(!open)
    }

    const displayCrosslists = (crosslists: Array<string>) => {
        if (crosslists.length === 0) {
            return null;
        }
        return (<>
            <br/>
            <div>Crosslist CRNS:</div>
            {crosslists.map((crn: string) => {
                return (<div>- {crn}</div>)
            })}
        </>)
    }

    const instructorString = (instructor: Instructor) => {
        let mi = instructor.middle ? ` ${instructor.middle} ` : ' '
        let primary = instructor.primary ? '* ' : '- ';
        return `${primary}${instructor.first}${mi}${instructor.last} (${instructor.email})`
    }

    return (<div className='w-96 mt-[-2px] pl-3 pr-3 pb-1 pt-1 border-solid border-2 border-black bg-white'>
        <div className='flex'>
            <p className='text-left w-[33%]' title={`${section.status.name}`}>{section.status.code}</p>
            <p className='text-center w-[33%]'>{section.campus.name}</p>
            <p className='text-right w-[33%] font-bold'>{section.crn}</p>
        </div>
        <div className='text-xl font-bold'>{section.course.subject.code} {section.course.number}.{section.number} - {section.course.title}</div>
        <div className='flex'>
            <div className='text-left w-[50%]'>{section.part_of_term.name}</div>
            <div className='text-right w-[50%]' title={`Enrolled: ${section.enrollment}/${section.enrollment_max} (Waitlist: ${section.waitlist}/${section.waitlist_max})`}>E: {section.enrollment}/{section.enrollment_max} (W: {section.waitlist}/{section.waitlist_max})</div>
        </div>
        <div className='flex'>
            <div className='text-left w-[50%]'>{section.delivery_type.name}</div>
            <div className='text-right w-[50%]'>{section.instructional_method ? section.instructional_method.name : '-'}</div>
        </div>
        <div>Instructors:</div>
        {section.instructors.map((instructor: Instructor) => {
            return(<div className='text-sm ml-1'>{instructorString(instructor)}</div>)
        })}
        {section.meeting_times.map((meeting_time: MeetingTime) => {
            return(<>
                <div className='ml-1 mt-3 leading-4'>
                    {formatTime(meeting_time.start_time)} - {formatTime(meeting_time.end_time)}
                </div>
                <div className='flex'>
                    <div className='ml-2 mt-1 leading-6 w-[100px]' title={`${meeting_time.building.name} ${meeting_time.room}`}>
                        {meeting_time.building.code} {meeting_time.room}
                    </div>
                    <div className='mt-1 mr-3'>|</div>
                    <div className='flex'>
                        {all_days.map((day) => {
                            return circle(meeting_time.days.includes(day), day)
                        })}
                    </div>
                </div>
            </>)
        })}
        <button className='font-bold' onClick={toggleDescription}>{open ? "V Hide Description" : "> Show Description"}</button>
        {open && <>
            <div className='whitespace-pre-wrap'>{section.catalog_description}</div>
            {displayCrosslists(section.crosslists)}
        </>}

    </div>)
}

/*

                    <div className='ml-1 leading-4 w-[80px] text-sm'>
                        {formatTime(meeting_time.start_time)} -<br/>{formatTime(meeting_time.end_time)}
                    </div>

        <div>{section.part_of_term.name}, Section {section.number} - {section.enrollment}/{section.enrollment_max} (W:{section.waitlist}/{section.waitlist_max})</div>

        <button onClick={toggleDescription}>(i)</button>
        {open && <Modal handleClose={toggleDescription}>
            <SectionDetails section={section} />
        </Modal>}
*/

export default SectionTag