import { useSelector } from 'react-redux';
import SectionTag from './SectionTag';
import { AppDispatch, RootState } from './store';
import { Section } from './catalog';
import { addSection, removeSection } from './features/schedule';
import { useDispatch } from 'react-redux';

const SearchResults = () => {
  const searchState = useSelector((store: RootState) => store.search)
  // const dispatch = useDispatch<AppDispatch>()

  // const nextPage = () => {
  //   let opts = {
  //     page: searchState.page + 1,
  //     perPage: searchState.perPage,
  //   }
  //   let params = {
  //     ...searchState.lastSearchParams,
  //     ...opts,
  //   }
  //   console.log(params)
  //   dispatch(fetchResults(params))
  // }

  // const prevPage = () => {
  //   let opts = {
  //     page: searchState.page - 1,
  //     perPage: searchState.perPage,
  //   }
  //   if(searchState.page < 2) {
  //     opts.page = 1
  //   }
  //   let params = {
  //     ...searchState.lastSearchParams,
  //     ...opts,
  //   }
  //   console.log(params)
  //   dispatch(fetchResults(params))
  // }

  return (<div className="w-[25rem]">
    <table>
      <tbody>
        {searchState.results.map((section) => (<tr key={section.crn} className='table-row'><SearchResult section={section} /></tr>))}
      </tbody>
    </table>
  </div>)
}

const SearchResult = ({section}: {section: Section}) => {
  const selected = useSelector((state: RootState) => state.schedule.selected[section.crn])
  const dispatch = useDispatch<AppDispatch>()

  const handleChange = () => {
    console.log(section)
    console.log(selected)
    if (selected == undefined) {
      console.log("ADD SECTION!")
      dispatch(addSection(section))
    } else {
      console.log("DELETE SECTION")
      dispatch(removeSection(section))
    }
  }

  return (
    <>
      <td className='bg-white border-black border-solid border-2'>
        <input type='checkbox' checked={selected != undefined} onChange={handleChange}/>
      </td>
      <td>
        <SectionTag section={section}/>
      </td>
    </>
  )
}

export default SearchResults;