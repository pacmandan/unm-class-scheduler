interface Coded {
    code: string;
    name: string;
}

interface Semester extends Coded {}
interface Subject extends Coded {}
interface Campus extends Coded {}
interface Building extends Coded {}

interface Course {
    number: string;
    title: string;
    subject: Subject;
}

type Day = 'U' | 'M' | 'T' | 'W' | 'R' | 'F' | 'S'

interface MeetingTime {
    days: Array<Day>;
    start_time: string;
    end_time: string;
    building: Building;
    room: string;
}

interface Instructor {
    primary: boolean;
    first: string;
    last: string;
    middle?: string;
    email: string;
}

type Crn = string;

// TODO: Alphabetize (or in some way sort) these later
interface Section {
    course: Course;
    campus: Campus;
    semester: Semester;
    meeting_times: Array<MeetingTime>;
    instructors: Array<Instructor>;
    number: string;
    crn: Crn;
    crosslists: Array<Crn>;
    part_of_term: string;
    instructional_method: string;
    delivery_type: string;
    credits: number;
    enrollment: number;
    enrollment_max: number;
    waitlist: number;
    waitlist_max: number;
    catalog_description: string;
    status: string;
    fees?: string;
}