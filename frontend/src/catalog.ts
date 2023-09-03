interface Coded {
    code: string;
    name: string;
}

export interface Semester extends Coded {}
export interface Subject extends Coded {}
export interface Campus extends Coded {}
export interface Building extends Coded {}
export interface PartOfTerm extends Coded {}
export interface Status extends Coded {}
export interface DeliveryType extends Coded {}
export interface InstructionalMethod extends Coded {}

export interface Course {
    number: string;
    title: string;
    catalog_description: string;
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

export type Crosslist = {
    crn: Crn;
    subject: string;
    course: string;
}

// TODO: Alphabetize (or in some way sort) these later
export interface Section {
    course: Course;
    subject: Subject;
    campus: Campus;
    semester: Semester;
    meeting_times: Array<MeetingTime>;
    instructors: Array<Instructor>;
    number: string;
    crn: Crn;
    crosslists: Array<Crosslist>;
    part_of_term: PartOfTerm;
    instructional_method: InstructionalMethod;
    delivery_type: DeliveryType;
    credits: number;
    enrollment: number;
    enrollment_max: number;
    waitlist: number;
    waitlist_max: number;
    status: Status;
    fees?: number;
}

export interface SelectedSection {
    //index: number,
    color: string,
    section: Section
  }