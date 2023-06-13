import React from 'react';

const section = {
    course: {
        number: "105L",
        title: "Intro to Computer Programming",
    },
    subject: {
        code: "CS",
        name: "Computer Science",
    },
    campus: {
        code: "ABQ",
        name: "Albuquerque/Main",
    },
    meeting_times: [{
        days: ["W"],
        start_time: "1200",
        end_time: "1345",
        building: {
            code: "SMLC",
            name: "Science Math Learning Center"
        },
        room: "B81",
    },{
        days: ["T","R"],
        start_time: "0930",
        end_time: "1045",
        building: {
            code: "CENT",
            name: "Centennial Engineering Center"
        },
        room: "1041"
    }],
    instructors: [{
        primary: true,
        first: "Joseph",
        last: "Haugh",
        middle: "",
        email: "glue500@unm.edu",
    }],
    crosslists: ["37993", "37994"],
    number: "001",
    crn: "37992",
    part_of_term: "1",
    instructional_method: "ENH",
    delivery_type: "LL",
    credits: 3,
    enrollment: 23,
    enrollment_max: 18,
    waitlist: 0,
    waitlist_max: 0,
    catalog_description: "Introduction to Computer Programming is a gentle and fun introduction. Students will use a modern Integrated Development Environment to author small programs in a high level language that do interesting things.",
    status: "A",
    fees: 45,
}

function circle(filled:boolean, letter:string) {
    let colors = filled ? "bg-green-700 text-black" : "text-black"
    return (<div className={`m-1 w-6 h-6 leading-6 rounded-[50%] text-center ${colors}`}>
        {letter}
    </div>)
}

export default class CourseTag extends React.Component {
    // TODO: Define a "section" type to pass here.
    // I'm using Typescript, and yet I'm not actually USING Typescript...
    constructor(props) {
        super(props)
        this.state = props
    }

    render() {
        const { section } = this.state
        return (<div className='w-96 ml-3 mr-3'>
            <div className="flex">
                <p className="text-left w-[33%]">{section.status}</p>
                <p className='text-center w-[33%]'>{section.campus.name}</p>
                <p className='text-right w-[33%]'>{section.crn}</p>
            </div>
            <h1 className='text-2xl'>{section.subject.code} {section.course.number} - {section.course.title}</h1>
            <div className="flex ml-[-0.5rem]">
                {circle(false, "U")}
                {circle(false, "M")}
                {circle(true, "T")}
                {circle(false, "W")}
                {circle(true, "R")}
                {circle(false, "F")}
                {circle(false, "S")}
            </div>
        </div>)
    }
}