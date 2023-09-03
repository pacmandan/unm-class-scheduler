import { useSelector } from 'react-redux';
import { AppDispatch, RootState } from '@/store';
import { Section } from '@/catalog';
import { addSection, removeSection } from '@/features/schedule';
import { useDispatch } from 'react-redux';
import ResultRow from './ResultRow'

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

  return (<div className='absolute top-0 bottom-0 overflow-y-auto w-full'>
    <table className="w-full">
      <tbody>
        {searchState.results.map((section) => (<tr key={section.crn} className='table-row'><ResultRowContainer section={section} /></tr>))}
      </tbody>
    </table>
  </div>)
}

const ResultRowContainer = ({section}: {section: Section}) => {
  const selected = useSelector((state: RootState) => state.schedule.selected[section.crn])
  const dispatch = useDispatch<AppDispatch>()

  const toggleResult = () => {
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

  return (<>
    <td><ResultRow section={section}/></td>
    <td className='w-24'><button onClick={toggleResult} className='border-2 w-20 bg-slate-100'>{selected === undefined ? "ADD" : "REMOVE"}</button></td>
  </>)
}

export default SearchResults;