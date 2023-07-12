import { PropsWithChildren, useState } from 'react'
import {Section, Day, MeetingTime} from './catalog'

function circle(filled:boolean, letter:string) {
    let colors = filled ? 'bg-green-700 text-black' : 'bg-slate-500 text-black'
    return (<div className={`m-1 w-4 h-4 leading-4 rounded-[50%] text-center text-sm ${colors}`}>
        {letter}
    </div>)
}

const all_days: Day[] = ['U', 'M', 'T', 'W', 'R', 'F', 'S']

type ModalProps = {
    handleClose: () => void
}
// TODO: Move this to its own generic component
// Should provide consistent header/close buttons, as well as children components
const Modal = ({handleClose, children}: PropsWithChildren<ModalProps>) => {
    return (<div className={`fixed top-0 left-0 w-full h-full bg-[#000000AA] block`}>
        <div className='fixed bg-white w-[50%] h-auto top-[50%] left-[50%] -translate-x-1/2 -translate-y-1/2'>
            <div>Modal!</div>
            {children}
            <button onClick={handleClose}>Close</button>
        </div>
    </div>)
}

const CourseTag = ({section}: {section: Section}) => {
    const [open, setOpen] = useState(false)

    const toggleDescription = () => {
        setOpen(!open)
    }

    /*
    const displayCrosslists = (crosslists: Array<string>) => {
        if (crosslists.length === 0) {
            return null;
        }
        return (<>
            <div>Crosslists</div>
            {crosslists.map((crn: string) => {
                return (<div>{crn}</div>)
            })}
        </>)
    }
    */

    return (<div className='w-96 mt-[-2px] pl-3 pr-3 pb-1 pt-1 border-solid border-2 border-black'>
        <div className='flex'>
            <p className='text-left w-[33%]'>{section.status}</p>
            <p className='text-center w-[33%]'>{section.campus.name}</p>
            <p className='text-right w-[33%]'>{section.crn}</p>
        </div>
        <h1 className='text-xl'>{section.course.subject.code} {section.course.number} - {section.course.title}</h1>
        <p>Section {section.number}  -  E:{section.enrollment}/{section.enrollment_max} (W:{section.waitlist}/{section.waitlist_max})</p>
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
                    <div className='ml-2 mt-1 leading-4' title={`${meeting_time.building.name} ${meeting_time.room}`}>
                        {meeting_time.building.code} {meeting_time.room}
                    </div>
                </div>
            </>)
        })}
        <button onClick={toggleDescription}>(i)</button>
        {open && <Modal handleClose={toggleDescription}>
            <div className='whitespace-pre-wrap'>{section.catalog_description}</div>
        </Modal>}
    </div>)
}

/*

        <button onClick={toggleDescription}>{open ? "V Hide Description" : "> Show Description"}</button>
        {open && <>
            {displayCrosslists(section.crosslists)}
            <div className='whitespace-pre-wrap'>{section.catalog_description}</div>
        </>}
*/

export default CourseTag