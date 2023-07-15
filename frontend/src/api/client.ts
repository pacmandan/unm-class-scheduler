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

export default {
  search
}