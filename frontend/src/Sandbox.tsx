import React from 'react';
import CourseTag from './CourseTag';

const sections: Section[] = [{
    course: {
        number: "105L",
        title: "Intro to Computer Programming",
        subject: {
            code: "CS",
            name: "Computer Science",
        },
    },
    campus: {
        code: "ABQ",
        name: "Albuquerque/Main",
    },
    semester: {
        code: '202310',
        name: 'Spring 2023',
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
    fees: "45",
},{
    course: {
        number: "1512",
        title: "Calculus I",
        subject: {
            code: "MATH",
            name: "Mathmatics",
        },
    },
    campus: {
        code: "ABQ",
        name: "Albuquerque/Main",
    },
    semester: {
        code: '202310',
        name: 'Spring 2023',
    },
    meeting_times: [{
        days: ["M","W","F"],
        start_time: "0900",
        end_time: "0950",
        building: {
            code: "DSH",
            name: "Dane Smith Hall"
        },
        room: "329",
    },{
        days: ["T"],
        start_time: "0930",
        end_time: "1045",
        building: {
            code: "DSH",
            name: "Dane Smith Hall"
        },
        room: "329"
    }],
    instructors: [{
        primary: true,
        first: "Kevin",
        last: "Burns",
        middle: "",
        email: "kburns@unm.edu",
    }],
    crosslists: ["51530", "51660"],
    number: "001",
    crn: "51529",
    part_of_term: "1",
    instructional_method: "ENH",
    delivery_type: "LC",
    credits: 4,
    enrollment: 13,
    enrollment_max: 16,
    waitlist: 0,
    waitlist_max: 0,
    catalog_description: `Limits. Continuity. Derivative: definition, rules, geometric interpretation and as rate-of-change, applications to graphing, linearization and optimization. Integral: definition, fundamental theorem of calculus, substitution, applications such as areas, volumes, work, averages.

    Credit for both this course and MATH 1430 may not be applied toward a degree program.
    
    Meets New Mexico General Education Curriculum Area 2: Mathematics and Statistics.
    
    Prerequisite: (1230 and 1240) or 1250 or ACT Math =&gt;28 or SAT Math Section =&gt;640 or ACCUPLACER Next-Generation Advanced Algebra and Functions =&gt;284 or Lobo Course Placement Math =&gt;70.`,
    status: "A",
    fees: "0",
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