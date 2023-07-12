interface Coded {
    code: string;
    name: string;
}

export interface Semester extends Coded {}
export interface Subject extends Coded {}
export interface Campus extends Coded {}
export interface Building extends Coded {}

export interface Course {
    number: string;
    title: string;
    subject: Subject;
}

export type Day = 'U' | 'M' | 'T' | 'W' | 'R' | 'F' | 'S'

export interface MeetingTime {
    days: Array<Day>;
    start_time: string;
    end_time: string;
    building: Building;
    room: string;
}

export interface Instructor {
    primary: boolean;
    first: string;
    last: string;
    middle?: string;
    email: string;
}

export type Crn = string;

// TODO: Alphabetize (or in some way sort) these later
export interface Section {
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