import { useSelector } from "react-redux";
import { AppDispatch, RootState } from "./store";
import { useDispatch } from "react-redux";
import { fetchResults } from "./features/search";

interface SearchFormElements extends HTMLFormControlsCollection {
  semester: HTMLSelectElement;
  campus: HTMLSelectElement;
  subject: HTMLSelectElement;
}

interface SearchForm extends HTMLFormElement {
  readonly elements: SearchFormElements;
}

const SearchForm = () => {

  const dispatch = useDispatch<AppDispatch>()

  const references = useSelector((state: RootState) => state.formReference)
  // Make a copy of the references so we can sort them.
  // TODO: Maybe sort them in the state when they are updated?
  const semesters = [...references.semesters]
  const campuses = [...references.campuses]
  const subjects = [...references.subjects]

  const submitForm = (e: React.FormEvent<SearchForm>) => {
    e.preventDefault();

    const data = e.currentTarget.elements;

    const params = {
      semester: data.semester.value,
      campus: data.campus.value,
      subject: data.subject.value,
    }

    console.log(params)
    dispatch(fetchResults(params))
  }

  return (<form onSubmit={submitForm}>
    <label>Semester</label>
    <select id="semester">{semesters.map((semester) => (<option key={semester.code} value={semester.code}>{semester.name}</option>))}</select>
    <label>Campus</label>
    <select id="campus">{campuses.map((campus) => (<option key={campus.code} value={campus.code}>{campus.name}</option>))}</select>
    <label>Subject</label>
    <select id="subject">{
      subjects.sort((a, b) => (a.code > b.code) ? 1 : -1)
      .map((subject) => (<option key={subject.code} value={subject.code}>{subject.code} - {subject.name}</option>))
    }</select>
    <button type="submit">Search!</button>
  </form>)
}

export default SearchForm;