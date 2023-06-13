import React from 'react';
import CourseTag from './CourseTag';

const sections = [{
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
},{
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
    crn: "37993",
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
}]

export default class Sandbox extends React.Component {
    render() {
        return (<div>
            <h1>Sandbox!</h1><br/>
            <div className="flex-auto bg-slate-600 h-auto w-auto">
                {sections.map(function(section) {
                    return <CourseTag section={section} />
                })}
            </div>
        </div>)
    }
}