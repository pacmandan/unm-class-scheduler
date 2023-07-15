import axios from 'axios';

const search = (_params : any) => {
  return axios.get("/api/search", {
    params: {
      semester: "202310",
      campus: "ABQ",
      subject: "MATH",
    }
  })
}

const get_semesters = () => {
  return axios.get("/api/reference/semseters")
}

const get_campuses = () => {
  return axios.get("/api/reference/campuses")
}

const get_subjects = () => {
  return axios.get("/api/reference/subjects")
}

const get_courses = (_params: any) => {
  return axios.get("/api/reference/courses", {
    params: {
      subject: "MATH"
    }
  })
}

export default {
  search,
  get_semesters,
  get_campuses,
  get_subjects,
  get_courses,
}